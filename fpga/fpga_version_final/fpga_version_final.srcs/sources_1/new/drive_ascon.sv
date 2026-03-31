`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.02.2026 14:08:37
// Design Name: 
// Module Name: drive_ascon
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


module drive_ascon(
    //horloge et reset
    input logic clock_i,
    input logic resetb_i,
    
    //Inputs
    input logic start_i,
    input logic end_initialisation_i,
    input logic end_associate_i,
    input logic end_cipher_i,
    input logic cipher_valid_i,
    input logic end_tag_i,
    input logic[4:0] cpt_i,

    //Outputs 
    output logic init_o,
    output logic data_valid_o,
    output logic associate_o,
    output logic finalisation_o,
    output logic en_cpt_o,
    output logic init_cpt_o,
    output logic end_o,
    //Signaux d'activation du registre cipher tag
    output logic w_en_ct_reg_o,
    output logic[4:0] addr_ct_reg_o
);

typedef enum {
    idle,           // Attente de la commande GO
    conf_cpt,       // RAZ du Cpt
    init_start,     // Lancement de l'intialisation d'ASCON 
    init_idle,      // Attente de la fin d'intialisation
    init_end,       // Transition d'état
    ad_start,       // Injection d'associated data (AD)
    ad_idle,        // Attente fin AD
    ad_end,         // Transition d'état
    pt_start,       // Début chiffrement du plaintext
    pt_idle,        // Traitement du plaintext et attente de validité
    pt_end,         // Transition vers le dernier bloc
    tag_start,      // Début géneration du Tag
    tag_idle,       // Traitement du Tag
    tag_wait_mem,   // Attente de l'écriture en mémoire du Tag
    tag_end         // Fin total du processus de calcul    
} state_t;

state_t current_state, next_state;

// 1 - Affectation des transitions
always_ff @(posedge clock_i or negedge resetb_i) begin : sequentiel 
    if (resetb_i == 1'b0)
        current_state <= idle;
    else 
        current_state <= next_state;
end : sequentiel

always_comb begin : tansition
    case (current_state)
        idle:
            if(start_i == 1'b1)
                next_state = conf_cpt;
            else
                next_state = idle;
        conf_cpt:
            next_state = init_start;
        init_start:
            next_state = init_idle;
        init_idle:
            if(end_initialisation_i == 1'b1)
                next_state = init_end;
            else
                next_state = init_idle;    
        init_end:
            next_state = ad_start;            
        ad_start:
            next_state = ad_idle; 
        ad_idle:
            if(end_associate_i == 1'b1)
                next_state = ad_end;
            else
                next_state = ad_idle;
        ad_end:
            next_state = pt_start;
        pt_start:
            next_state = pt_idle;
        pt_idle:
            if(end_cipher_i == 1'b1 && cpt_i == 'd21)
                next_state = pt_end;
            else if(end_cipher_i == 1'b1)
                next_state = pt_start;
            else
                next_state = pt_idle;
        pt_end:
            next_state = tag_start;
        tag_start:
            next_state = tag_idle;
        tag_idle:
            if(end_tag_i == 1'b1)
                next_state = tag_wait_mem;
            else
                next_state = tag_idle;    
        tag_wait_mem:
            next_state = tag_end;
        tag_end:
            next_state = idle;
        default: 
            next_state = idle;
    endcase 
end : tansition
	
// 2 - Affectation des sorties

always_comb begin : sortie
    // Initialisation des valeurs par défaut 	
   init_o = 1'b0;
   data_valid_o = 1'b0;
   associate_o = 1'b0;
   finalisation_o = 1'b0;
   en_cpt_o = 1'b0;
   init_cpt_o = 1'b0;
   end_o = 1'b0;
   w_en_ct_reg_o = 1'b0;
   addr_ct_reg_o = 5'b0;
    case (current_state)
        idle:
            begin
            end
        conf_cpt:
            begin
                init_cpt_o = 1'b1;
            end
        init_start:
            begin
                init_o = 1'b1;
            end
        init_idle:
            begin
            end  
        init_end:
            begin
            end           
        ad_start:
            begin
                associate_o  = 1'b1;
                data_valid_o = 1'b1;
            end 
        ad_idle:
            begin
                associate_o  = 1'b1;
            end
        ad_end:
            begin
            end
        pt_start:
            begin
                data_valid_o = 1'b1;
            end
        pt_idle:
            begin
                // Fin de calcul d'un bloc --> incrementation du compteur
                if (end_cipher_i == 1'b1) begin
                    en_cpt_o = 1'b1;
                end
                
                // Un bloc cipher est ready --> Autorisation de l'écriture en RAM
                if (cipher_valid_i == 1'b1) begin
                    w_en_ct_reg_o = 1'b1;
                    addr_ct_reg_o = cpt_i;
                end
            end
        pt_end:
            begin
            end
        tag_start:
            begin
                finalisation_o = 1'b1;
                data_valid_o   = 1'b1;
                // Ecriture du dernier bloc du Cipher
                if (cipher_valid_i == 1'b1) begin
                    w_en_ct_reg_o = 1'b1;
                    addr_ct_reg_o = cpt_i;
                end
                // Ecriture de la premiere partie du Tag ( [127 : 64] )
                if (end_tag_i == 1'b1) begin
                    w_en_ct_reg_o = 1'b1;
                    addr_ct_reg_o = 5'd23;
                end
                
            end
        tag_idle:
            begin
                finalisation_o = 1'b1;
                
                if (cipher_valid_i == 1'b1) begin
                    w_en_ct_reg_o = 1'b1;
                    addr_ct_reg_o = cpt_i;
                end
                if (end_tag_i == 1'b1) begin
                    w_en_ct_reg_o = 1'b1;
                    addr_ct_reg_o = 5'd23;
                end
            end
        tag_wait_mem:
            begin
                // Ecriture de la derniere partie du Tag ( [63 : 0] )
                w_en_ct_reg_o = 1'b1;
                addr_ct_reg_o = 5'd24;
            end
        tag_end:
            begin
                end_o = 1'b1;
            end
        default: 
            begin
            end
    endcase 
end : sortie



endmodule
