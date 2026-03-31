`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2026 15:41:56
// Design Name: 
// Module Name: Ascon_top
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


module Ascon_top(
    input  logic clock_i,       // Horloge de la carte
    input  logic rest_btn_i,    // Bouton de reset matériel
    
    // UART
    input  logic Rx_i,          // Réception (PC --> FPGA)
    output logic Tx_o,          // Transmission (FPGA --> PC)
    output logic RTS_o          // Request to send
    );
    
    //  1 - Gestion de l'horloge et du reset
    logic clock_50MHz_s;        // Horloge interne générée par le clocking wizard
    logic clock_locked_s;
    
    logic resetb_s;             // Reset actif à l'état BAS
    assign resetb_s = ~rest_btn_i;
    assign RTS_o    = 1'b0;       // RTS Actif à l'état bas pour autoriser la réception
    
    //  2 - Déclaration des signaux déclaration
    // Signaux de controle ASCON et fsm_uart
    logic         init_s;
    logic         associate_data_s;
    logic         finalisation_s;
    logic [ 63:0] data_s;
    logic         data_valid_s;
    logic [127:0] key_s, nonce_s;
    logic [ 63:0] ad_s; 
    logic         start_s, end_s, ad_phase; 
    
    // Le signal de debug s'activera à la fin du chiffrement
    assign en_led_s = end_s; 
    
    // Signaux des compteurs de blocs ASCON
    logic         en_cpt_s, init_cpt_s;
    logic [4:0]   cpt_s;
    
    // Signaux interface UART
    logic       rx_ready_s, tx_busy_s, tx_load_s, rx_error_s;
    logic [7:0] rx_data_s, tx_byte_s, byte_from_mem_s;
    logic [7:0] addr_mem_s;      
    logic       en_mem_s, we_mem_s;
    logic [63:0] mem_data_fsm_s;
    
    // Signaux registre Trame de donnees
    logic [63:0] douta_s, dina_s, doutb_s;   
    logic [4:0]  addra_s, addrb_s;
    logic        wea_s, ena_s;
    
    // Signaux Registre Cipher Tag
    logic [63:0] douta_ct_s, dina_ct_s, doutb_ct_s, dinb_ct_s;   
    logic [4:0]  addra_ct_s, addrb_ct_s;
    logic        wea_ct_s, ena_ct_s, web_ct_s, enb_ct_s;
    logic [ 63:0] cipher_s;
    logic [127:0] tag_s;
    
    // Signaux de controle
    logic end_associate_s, cipher_valid_s, end_tag_s, end_initialisation_s, end_cipher_s;
    
    //  3 - Multiplexage et aiguillage des données
    // Bloc sequentiel pour savoir si on est dans la phase Associated Data
    always_ff @(posedge clock_50MHz_s, negedge resetb_s) begin
        if (resetb_s == 1'b0) 
            ad_phase <= 0;
        else if (associate_data_s) 
            ad_phase <= 1;
        else if (end_associate_s)  
            ad_phase <= 0;
    end
    
    // MUX D'ADRESSE : La RAM ne gère plus que la trame (0-21) et la finalisation (22)
    always_comb begin
        if(finalisation_s) 
            addrb_s = 5'd22; 
        else               
            addrb_s = cpt_s;   
    end

    // MUX DE DONNÉES : Aiguillage entre le registre AD et la RAM
    always_comb begin
        if (associate_data_s || ad_phase) 
            data_s = ad_s;     // Source = Registre 64 bits de la FSM
        else                              
            data_s = doutb_s;  // Source = BRAM
    end

    // MUX DE LECTURE UART (trame cipher et tag --> UART)
    // Extraction d'un octet (8 bits) à partir du mot de 64 bits de la BRAM
    always_comb begin
        case (addr_mem_s[2:0])
            3'd0: byte_from_mem_s = doutb_ct_s[63:56]; 
            3'd1: byte_from_mem_s = doutb_ct_s[55:48];
            3'd2: byte_from_mem_s = doutb_ct_s[47:40]; 
            3'd3: byte_from_mem_s = doutb_ct_s[39:32];
            3'd4: byte_from_mem_s = doutb_ct_s[31:24]; 
            3'd5: byte_from_mem_s = doutb_ct_s[23:16];
            3'd6: byte_from_mem_s = doutb_ct_s[15:8];  
            3'd7: byte_from_mem_s = doutb_ct_s[7:0];
            default: byte_from_mem_s = 8'h00;
        endcase
    end   
    
    // Conversion des adresses octets (UART) en adresses mots de 64 bits (RAM)
    assign addrb_ct_s = addr_mem_s[7:3];// On divise par 8 pour tansformeer l'addr (pour cipher tag)
    assign addra_s = addr_mem_s[4:0];  //  (pour la trame registre)
    
    // Affectation des signaux de contrôle des mémoires
    assign ena_ct_s  = 1'b1;
    assign enb_ct_s  = 1'b1;
    assign web_ct_s  = 1'b0;
    
    assign dina_s  = mem_data_fsm_s;
    assign wea_s   = we_mem_s;
    assign ena_s   = en_mem_s;
    
    assign dinb_ct_s = 64'h0; // Le port B du registre cipher_tag est utilisé en lecture seule par l'UART
    // Mux pour chosir la donnée à écrire dans la RAM Cipher/Tag
    assign dina_ct_s = (addra_ct_s == 5'd24) ? tag_s[63:0] : (addra_ct_s == 5'd23) ? tag_s[127:64] : cipher_s;
   
   
   // 4 - Instanciation des IP et modules
   
    clk_wiz clock_50mhz(
        // Clock out ports
        .clk_out1(clock_50MHz_s),     // output clk_out1
        // Status and control signals
        .reset(rest_btn_i), // input reset
        .locked(clock_locked_s),       // output locked
       // Clock in ports
        .clk_in1(clock_i)      // input clk_in1
    );
        
    uart_core UART_Core(
       .clock_i(clock_50MHz_s), 
       .resetb_i(resetb_s),
       .Din_i(tx_byte_s),   
       .LD_i(tx_load_s),    
       .Rx_i(Rx_i),    
       .Baud_i(3'b000),  
       .RXRdy_o(rx_ready_s), 
       .RXErr_o(rx_error_s), 
       .Dout_o(rx_data_s),  
       .Tx_o(Tx_o),    
       .TxBusy_o(tx_busy_s)    
    );        

    fsm_uart drive_uart(
        .clock_i(clock_50MHz_s), 
        .resetb_i(resetb_s), 
        .rx_ready_i(rx_ready_s), 
        .rx_data_i(rx_data_s),     
        .tx_busy_i(tx_busy_s), 
        .tx_byte_o(tx_byte_s), 
        .tx_load_o(tx_load_s),     
        .mem_data_i(byte_from_mem_s), 
        .addr_o(addr_mem_s), 
        .en_addr_o(en_mem_s), 
        .init_addr_o(), 
        .mem_we_o(we_mem_s), 
        .mem_data_o(mem_data_fsm_s),
        .cipher_ready_i(end_s), 
        .go_o(start_s), 
        .key_o(key_s), 
        .nonce_o(nonce_s), 
        .ad_o(ad_s)  
    );
    
    // RAM contenant le plain text
    blk_mem_gen_0 data_mem ( 
        .clka(clock_50MHz_s), 
        .ena(ena_s), 
        .wea(wea_s), 
        .addra(addra_s), 
        .dina(dina_s), 
        .douta(douta_s), 
        .clkb(clock_50MHz_s), 
        .enb(1'b1),  
        .web(1'b0),  
        .addrb(addrb_s), 
        .dinb(64'h0), 
        .doutb(doutb_s) 
    );
    // RAM contenant le cipher et le tag générés par ASCON
    blk_mem_gen_0 cipher_tag_mem ( 
        .clka(clock_50MHz_s), 
        .ena(ena_ct_s), 
        .wea(wea_ct_s), 
        .addra(addra_ct_s), 
        .dina(dina_ct_s), 
        .douta(douta_ct_s), 
        .clkb(clock_50MHz_s), 
        .enb(enb_ct_s), 
        .web(web_ct_s), 
        .addrb(addrb_ct_s), 
        .dinb(dinb_ct_s), 
        .doutb(doutb_ct_s) 
    );

    ascon DUT (
        .clock_i(clock_50MHz_s), 
        .reset_i(~resetb_s), 
        .init_i(init_s), 
        .associate_data_i(associate_data_s),
        .finalisation_i(finalisation_s), 
        .data_i(data_s), 
        .data_valid_i(data_valid_s),
        .key_i(key_s), 
        .nonce_i(nonce_s),
        .end_associate_o(end_associate_s), 
        .cipher_o(cipher_s), 
        .cipher_valid_o(cipher_valid_s),
        .tag_o(tag_s), 
        .end_tag_o(end_tag_s), 
        .end_initialisation_o(end_initialisation_s),
        .end_cipher_o(end_cipher_s)
    );

    cpt cpt_bloc(
        .clock_i(clock_50MHz_s), 
        .resetb_i(resetb_s), 
        .en_cpt_i(en_cpt_s), 
        .init_cpt_i(init_cpt_s), 
        .cpt_o(cpt_s)
    );
  
    drive_ascon ason_cmd(
        .clock_i(clock_50MHz_s), 
        .resetb_i(resetb_s), 
        .start_i(start_s),             
        .end_initialisation_i(end_initialisation_s), 
        .end_associate_i(end_associate_s),     
        .end_cipher_i(end_cipher_s), 
        .cipher_valid_i(cipher_valid_s),
        .end_tag_i(end_tag_s), 
        .cpt_i(cpt_s),  
        .init_o(init_s), 
        .data_valid_o(data_valid_s),       
        .associate_o(associate_data_s), 
        .finalisation_o(finalisation_s),     
        .en_cpt_o(en_cpt_s), 
        .init_cpt_o(init_cpt_s), 
        .end_o(end_s), 
        .w_en_ct_reg_o(wea_ct_s), 
        .addr_ct_reg_o(addra_ct_s)        
    );
    // Module de debug
    ila_0 ila_test (
        .clk(clock_50MHz_s), // input wire clk
        .probe0(Rx_i), // input wire [0:0]  probe0  
        .probe1(Tx_o) // input wire [0:0]  probe1
    );   
    
endmodule
