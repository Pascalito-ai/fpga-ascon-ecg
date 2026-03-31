`timescale 1ns / 1ps

module Ascon_tb import ascon_pack::*; ();

    logic clock_s, reset_s, resetb_s;
    assign resetb_s = ~reset_s;

    logic         init_s;
    logic         associate_data_s;
    logic         finalisation_s;
    logic [ 63:0] data_s;
    logic         data_valid_s;
    
    // Signaux de registres
    logic [127:0] key_s, nonce_s;
    logic [ 63:0] ad_s; 
    
    logic         en_cpt_s, init_cpt_s;
    logic [4:0]   cpt_s;
    logic         start_s, end_s, ad_phase; 

    // Signaux UART & BRAM
    logic       rx_ready_s, tx_busy_s, tx_load_s;
    logic [7:0] rx_data_s, tx_byte_s, byte_from_mem_s;
    logic [7:0] addr_mem_s;      
    logic       en_mem_s, we_mem_s;
    logic [63:0] mem_data_fsm_s;
    
    // registre Trame de donnees
    logic [63:0] douta_s, dina_s, doutb_s;   
    logic [4:0]  addra_s, addrb_s;
    logic        wea_s, ena_s;
    
    // Registre Cipher Tag
    logic [63:0] douta_ct_s, dina_ct_s, doutb_ct_s, dinb_ct_s;   
    logic [4:0]  addra_ct_s, addrb_ct_s;
    logic        wea_ct_s, ena_ct_s, web_ct_s, enb_ct_s;
    
    logic end_associate_s, cipher_valid_s, end_tag_s, end_initialisation_s, end_cipher_s;
    logic [ 63:0] cipher_s;
    logic [127:0] tag_s;
    logic [  4:0] cpt_ct_s;
    
    logic [0:21][63:0] trame_s ={
      64'h5A5B5B5A5A5A5A5A, 64'h59554E4A4C4F5455, 64'h5351535456575857, 
      64'h5A5A595756595B5A, 64'h5554545252504F4F, 64'h4C4C4D4D4A494444, 
      64'h4747464442434140, 64'h3B36383E44494947, 64'h4746464443424345, 
      64'h4745444546474A49, 64'h4745484F58697C92, 64'hAECEEDFFFFE3B47C, 
      64'h471600041729363C, 64'h3F3E40414141403F, 64'h3F403F3E3B3A3B3E, 
      64'h3D3E3C393C414646, 64'h46454447464A4C4F, 64'h4C505555524F5155, 
      64'h595C5A595A5C5C5B, 64'h5959575351504F4F, 64'h53575A5C5A5B5D5E, 
      64'h6060615F605F5E5A  
    };
    
    logic [63:0] iv_block = 64'h4120746F20428000;
    logic [63:0] last_block = 64'h5857545252800000;
    
    //  3 - Multiplexage et aiguillage des données
    // Bloc sequentiel pour savoir si on est dans la phase Associated Data
    always_ff @(posedge clock_s, negedge resetb_s) begin
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
    uart_core UART_Core(
       .clock_i(clock_i), 
       .resetb_i(resetb_i),
       .Din_i(),   
       .LD_i(),    
       .Rx_i(),    
       .Baud_i(),  
       .RXRdy_o(), 
       .RXErr_o(), 
       .Dout_o(),  
       .Tx_o(),    
       .TxBusy_o(tx_busy_i)    
    );        

    fsm_uart drive_uart(
        .clock_i(clock_s), 
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
        .clka(clock_s), 
        .ena(ena_s), 
        .wea(wea_s), 
        .addra(addra_s), 
        .dina(dina_s), 
        .douta(douta_s), 
        .clkb(clock_s), 
        .enb(1'b1),  
        .web(1'b0),  
        .addrb(addrb_s), 
        .dinb(64'h0), 
        .doutb(doutb_s) 
    );
    // RAM contenant le cipher et le tag générés par ASCON
    blk_mem_gen_0 cipher_tag_mem ( 
        .clka(clock_s), 
        .ena(ena_ct_s), 
        .wea(wea_ct_s), 
        .addra(addra_ct_s), 
        .dina(dina_ct_s), 
        .douta(douta_ct_s), 
        .clkb(clock_s), 
        .enb(enb_ct_s), 
        .web(web_ct_s), 
        .addrb(addrb_ct_s), 
        .dinb(dinb_ct_s), 
        .doutb(doutb_ct_s) 
    );

    ascon DUT (
        .clock_i(clock_s), 
        .reset_i(reset_s), 
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
        .clock_i(clock_s), 
        .resetb_i(resetb_s), 
        .en_cpt_i(en_cpt_s), 
        .init_cpt_i(init_cpt_s), 
        .cpt_o(cpt_s)
    );
  
    drive_ascon ason_cmd(
        .clock_i(clock_s), 
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
    
    initial begin 
        clock_s = 0; 
        forever #10 clock_s = ~clock_s; 
    end

    task send_byte(input logic [7:0] data);
        @(negedge clock_s); 
        rx_data_s = data; 
        rx_ready_s = 1'b1;
        
        @(negedge clock_s);
        rx_ready_s = 1'b0;
        repeat(20) @(posedge clock_s); 
    endtask

    initial begin    
        reset_s = 1'b0; 
        rx_ready_s = 1'b0; 
        rx_data_s = 8'h00; 
        tx_busy_s = 1'b0;
        
        #40; 
        reset_s = 1'b1; 
        #40; 
        reset_s = 1'b0; 
        #40;

        $display("--- 1. Envoi CLE (K) ---");
        send_byte(8'h4B);
        send_byte(8'h8A); send_byte(8'h55); send_byte(8'h11); send_byte(8'h4D);
        send_byte(8'h1C); send_byte(8'hB6); send_byte(8'hA9); send_byte(8'hA2);
        send_byte(8'hBE); send_byte(8'h26); send_byte(8'h3D); send_byte(8'h4D);
        send_byte(8'h7A); send_byte(8'hEC); send_byte(8'hAA); send_byte(8'hFF);
        
        $display("--- 2. Envoi NONCE (N) ---");
        send_byte(8'h4E);
        send_byte(8'h4E); send_byte(8'hD0); send_byte(8'hEC); send_byte(8'h0B);
        send_byte(8'h98); send_byte(8'hC5); send_byte(8'h29); send_byte(8'hB7);
        send_byte(8'hC8); send_byte(8'hCD); send_byte(8'hDF); send_byte(8'h37);
        send_byte(8'hBC); send_byte(8'hD0); send_byte(8'h28); send_byte(8'h4A);

        $display("--- 3. Envoi AD (A) ---");
        send_byte(8'h41); // {48'h4120746F2042, 16'h8000}
        for(int j=7; j>=0; j--) begin
            send_byte(iv_block[j*8 +: 8]); 
        end
        
        $display("--- 4. Envoi Trame RAM (W) ---");
        send_byte(8'h57);
        for(int i=0; i<=21; i++) begin
            for(int j=7; j>=0; j--) 
                send_byte(trame_s[i][j*8 +: 8]); 
        end
        for(int j=7; j>=0; j--) 
            send_byte(last_block[j*8 +: 8]);
        
        #500;
        $display("--- 5. START (G) ---");
        send_byte(8'h47); 
        
        wait(end_s == 1'b1);
        $display("--- FIN DU CHIFFREMENT ASCON ---");
        #1000;

        /*$display("--- 5. Recetion Cipher (C) ---");
        send_byte(8'h43); 
        
        #1000;*/
        
        $display("--- 5. Reception Tag (T) ---");
        send_byte(8'h54);
        
        #1000;
         
        $stop();
    end
endmodule