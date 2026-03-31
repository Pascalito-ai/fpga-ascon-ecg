`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.03.2026 17:08:37
// Design Name: 
// Module Name: fsm_uart
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fsm_uart 
    import uart_pkg::*;
(   
    input  logic        clock_i,
    input  logic        resetb_i,    
    
    // Interface uart
    input  logic        rx_ready_i,
    input  logic [7:0]  rx_data_i,
    input  logic        tx_busy_i,
    output logic [7:0]  tx_byte_o,
    output logic        tx_load_o,
    
    // Interface double mémoire (trame)
    input  logic [7:0]  mem_data_i,  // Donnée lue en depuis mem trame
    output logic [7:0]  addr_o,      // Adresse mémoire
    output logic        en_addr_o,   
    output logic        init_addr_o, 
    output logic        mem_we_o,
    output logic [63:0] mem_data_o, // Donnée de 64 à ecrire dans la double memoire
    
    
    // Interface Ascon
    input  logic        cipher_ready_i,  // Fin calcul ascon 
    output logic        go_o,            // Signal de start d'Ascon
    
    
    // Sorties des registres
    output logic [127:0] key_o,
    output logic [127:0] nonce_o,
    output logic [63:0]  ad_o
);

    logic [7:0] data_converted_s;
    
    // Signaux d'activation des registres à décalage
    logic       en_trans_s;
    logic       en_key_s;
    logic       en_nonce_s;
    logic       en_ad_s;
    
    // Signaux du décompteurs pour gérer la taille des commandes entrantes
    logic [8:0] cpt_s;
    logic       en_cpt_s;
    logic       init_cpt_s;
    logic [8:0] load_cpt_s; // Valeur de chargement en fct de la cmd
    
    // Registres tampons
    logic [63:0] buffer_reg;
    logic [2 :0] cpt_id_reg; // compte 0 à 7 pour savoir si le tampon est plein
    
    // Affectation de la sortie en prenant en compte le decalage de 8 bits
    assign mem_data_o = {buffer_reg[55:0],data_converted_s};
    
    // Instanciation des modules
    fsm_dcompteur #(.WIDTH(9)) fsm_dcounter_0 (
      .clock_i(clock_i),
      .resetb_i(resetb_i),
      .en_i(en_cpt_s),
      .init_i(init_cpt_s),
      .load_i(load_cpt_s),
      .cpt_o(cpt_s)
    );
    
    trans_receive trans_receive_0 (
        .clock_i(clock_i),
        .resetb_i(resetb_i),
        .RxData_i(rx_data_i),
        .en_i(en_trans_s),
        .data_converted_o(data_converted_s)
    );
    
    // Régistres à décalage (key,nonce,AD)
    reg_shift_sv #(.WIDTH(128)) key_reg_shift (
        .D(data_converted_s), 
        .EN(en_key_s),
        .RSTB(resetb_i),
        .CLK(clock_i), 
        .Q(key_o) 
    );

    reg_shift_sv #(.WIDTH(128)) nonce_reg_shift (
        .D(data_converted_s), 
        .EN(en_nonce_s),
        .CLK(clock_i),
        .RSTB(resetb_i),
        .Q(nonce_o) 
    );
    
    reg_shift_sv #(.WIDTH(64)) ad_reg_shift (
        .D(data_converted_s), 
        .EN(en_ad_s),    
        .RSTB(resetb_i), 
        .CLK(clock_i), 
        .Q(ad_o)
    );
   

    typedef enum {
        idle,
        init_cmd,
        
        // Pour la commande K ou k
        wait_rx_key,
        stock_key,
        // Pour la commande N ou n 
        wait_rx_nonce,
        stock_nonce,
        // Pour la commande A ou a
        wait_rx_ad,
        stock_ad,
        // Pour la commande W ou w
        wait_rx_mem,
        stock_mem,
        // Pour la commande G ou g
        execute_cipher,
        wait_cipher,
        // Pour la lecture (T/t ou C/c)
        init_read, 
        wait_ram_1, // Etat d'attente pour respecter les cycles de latence 
        wait_ram_2, // Etat d'attente pour respecter les cycles de latence 
        send_data_mem,
        wait_tx_ready,
        wait_ram,
        // Pour l'envoi de la réponse OK\n
        send_o,
        send_k,
        send_lf
    } Etats;

    Etats Ep, Ef;
    
    logic [7:0]  cmd_reg;   // Cmd reçue
    logic [7:0]  addr_reg; // Adresse ram courante

    assign addr_o = addr_reg;
    
    // Détermination de la longueur de la boucle suivant la commande décodée
    always_comb begin
        case (cmd_reg)
            8'h4B, 8'h6b, 8'h4E, 8'h6e  :load_cpt_s = 9'd16;  // K / k, N / n 
            8'h41, 8'h61                :load_cpt_s = 9'd8;  // A / a 
            8'h57, 8'h77                :load_cpt_s = 9'd184; // W / w 
            
            8'h43, 8'h63                :load_cpt_s = 9'd184+'d1; // C / c
            8'h54, 8'h74                :load_cpt_s = 9'd16+'d1;  // T / t
            default                     :load_cpt_s = 9'd0;
        endcase
    end
    
    // Gestion de l'état, du tampon et de l'adresse
    always_ff @(posedge clock_i, negedge resetb_i) begin 
        if(resetb_i == 1'b0) begin 
            Ep       <= idle;
            addr_reg <= 8'h0;
            cmd_reg  <= 8'h0;
            buffer_reg <= 64'h0;
            cpt_id_reg <= 3'h0;
        end else begin 
            Ep <= Ef;
            // Detection de la commande entrante
            if (Ep == idle && rx_ready_i) 
                cmd_reg <= rx_data_i;
            // Decalage des octets reçus dans le buffer de 64 bits
            if (Ep == stock_mem ) begin 
                buffer_reg <= {buffer_reg[55:0],data_converted_s};
                cpt_id_reg <= cpt_id_reg + 1;
            end
            
            // Écriture : On incrémente l'adresse globale quand un mot(8 octes) est plein
            if (( Ep == stock_mem && cpt_id_reg == 3'd7)) begin 
                addr_reg <= addr_reg + 1;
            end else if (Ep == wait_tx_ready && tx_busy_i == 1'b0 && cpt_s > 9'd1) begin
                addr_reg <= addr_reg + 1; // Lecture : On incrémente après chaque envoi UART
            end else if (Ep == idle ) begin
                addr_reg <= 8'h0;
                cpt_id_reg <= 3'h0;
            end else if ( Ep == init_read) begin
                if( cmd_reg == 8'h54 || cmd_reg == 8'h74 )
                    addr_reg <= 8'd184; // Commande Tag : début lecture au bloc 23
                else
                    addr_reg <= 8'd0; //Commande Cipher : debut au bloc 0
                cpt_id_reg <= 3'h0;
            end
        end
    end
    
    // Gestion des transitions
    always_comb begin 
        case(Ep)
            idle:           
                if(rx_ready_i) 
                    Ef = init_cmd; 
                else 
                    Ef = idle;
            init_cmd: // Decodage de la commande entrante       
                case(cmd_reg)
                    8'h4B, 8'h6b :                     
                        Ef = wait_rx_key;
                    8'h4E, 8'h6e :                     
                        Ef = wait_rx_nonce;
                    8'h41, 8'h61:
                        Ef = wait_rx_ad; 
                    8'h57, 8'h77:               
                        Ef = wait_rx_mem;
                    8'h47, 8'h67:                      
                        Ef = execute_cipher;
                    8'h43,8'h63, 8'h54, 8'h74:
                        Ef = init_read;
                    default:                    
                        Ef = idle;
                endcase
            wait_rx_key:  
                if(rx_ready_i) 
                    Ef = stock_key; 
                else 
                    Ef = wait_rx_key;
            stock_key:      
                if(cpt_s <= 9'd1) 
                    Ef = send_o; 
                else   
                    Ef = wait_rx_key;
            wait_rx_nonce:  
                if(rx_ready_i) 
                    Ef = stock_nonce; 
                else 
                    Ef = wait_rx_nonce;
            stock_nonce:      
                if(cpt_s <= 9'd1) 
                    Ef = send_o; 
                else   
                    Ef = wait_rx_nonce;
            wait_rx_ad:  
                if(rx_ready_i) 
                    Ef = stock_ad; 
                else 
                    Ef = wait_rx_ad;
            stock_ad:      
                if(cpt_s <= 9'd1) 
                    Ef = send_o; 
                else   
                    Ef = wait_rx_ad;
            wait_rx_mem:  
                if(rx_ready_i) 
                    Ef = stock_mem; 
                else 
                    Ef = wait_rx_mem;
            stock_mem:      
                if(cpt_s == 9'd1) 
                    Ef = send_o; 
                else   
                    Ef = wait_rx_mem;        
            execute_cipher: 
                Ef = wait_cipher;
            wait_cipher:    
                if(cipher_ready_i == 1'b1) 
                    Ef = send_o; 
                else 
                    Ef = wait_cipher;
            init_read:      
                Ef = wait_ram_1;
            wait_ram_1:
                Ef = wait_ram_2;
            wait_ram_2:
                Ef = send_data_mem;
            send_data_mem:  
                Ef = wait_tx_ready;
            wait_tx_ready:  
                if (tx_busy_i) 
                    Ef = wait_tx_ready;
                else if (cpt_s <= 9'd1) 
                    Ef = send_o;
                else 
                    Ef = wait_ram_1; // On repart en attente 2 cycles avec le next octet
            
            // Envoi du OK\n au pc
            send_o:         
                if(!tx_busy_i) 
                    Ef = send_k;  
                else 
                    Ef = send_o;
            send_k:         
                if(!tx_busy_i) 
                    Ef = send_lf; 
                else 
                    Ef = send_k;
            send_lf:        
                if(!tx_busy_i) 
                    Ef = idle;    
                else 
                    Ef = send_lf;
            default:        
                Ef = idle;
        endcase
    end

    always_comb begin 
        tx_byte_o   = 8'h00; 
        tx_load_o   = 1'b0;
        en_addr_o   = 1'b0;  
        init_addr_o = 1'b0;
        mem_we_o    = 1'b0;  
        go_o        = 1'b0;
        en_trans_s  = 1'b0;
        en_key_s    = 1'b0;
        en_nonce_s  = 1'b0;
        en_ad_s     = 1'b0;
        en_cpt_s    = 1'b0;
        init_cpt_s  = 1'b0;
        
        case(Ep)
            idle: begin
                init_addr_o = 1'b1;
            end
            init_cmd: begin    
                en_cpt_s    = 1'b1;
                init_cpt_s  = 1'b1;
            end
            wait_rx_key: begin
                en_trans_s  = rx_ready_i;
            end
            stock_key: begin
                en_key_s    = 1'b1;
                en_cpt_s    = 1'b1;
            end
            wait_rx_nonce: begin
                en_trans_s  = rx_ready_i;
            end
            stock_nonce: begin
                en_nonce_s  = 1'b1;
                en_cpt_s    = 1'b1;
            end
            wait_rx_ad: begin
                en_trans_s  = rx_ready_i;
            end
            stock_ad: begin
                en_ad_s  = 1'b1;
                en_cpt_s    = 1'b1;
            end
            wait_rx_mem: begin
                en_trans_s  = rx_ready_i;
            end
            stock_mem: begin
                if(cpt_id_reg == 3'd7) begin // Activation de l'ecriture quand l'ocet 7 arrive
                    en_addr_o   = 1'b1;
                    mem_we_o    = 1'b1;
                end
                en_cpt_s    = 1'b1;
            end
            execute_cipher: begin 
                go_o        = 1'b1;
            end
            wait_cipher: begin
            end
            init_read: begin  
                init_addr_o = 1'b1;
            end
            send_data_mem: begin
                tx_byte_o   = mem_data_i; 
                tx_load_o   = 1'b1;
                en_cpt_s    = 1'b1;
            end
            wait_tx_ready: begin
                en_addr_o   = (tx_busy_i == 1'b0);
            end
            send_o: begin
                tx_byte_o   = 8'h4F; 
                tx_load_o   = 1'b1;
            end
            send_k: begin
                tx_byte_o   = 8'h4B; 
                tx_load_o   = 1'b1;
            end
            send_lf: begin
                tx_byte_o   = 8'h0A; 
                tx_load_o   = 1'b1;
            end
            default: begin
            end
        endcase
    end
endmodule