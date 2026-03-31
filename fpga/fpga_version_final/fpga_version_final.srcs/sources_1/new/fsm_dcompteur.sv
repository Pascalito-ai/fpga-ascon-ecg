`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.03.2026 12:39:55
// Design Name: 
// Module Name: fsm_dcompteur
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
module fsm_dcompteur 
#(
    parameter WIDTH = 9
)
(
    input  logic clock_i,     //main clock
    input  logic resetb_i,    //asynchronous reset active low
    input  logic en_i,
    input  logic init_i,  //storing AD
    input  [WIDTH-1:0] load_i,
    output logic [WIDTH-1:0] cpt_o
);

  logic [WIDTH-1:0] cpt_s;

  always_ff @(posedge clock_i or negedge resetb_i) begin : seq_0
    if (resetb_i == 1'b0) cpt_s <= '1;
    else begin
      if (en_i == 1'b1) begin
        if (init_i == 1'b1) begin
          cpt_s <= load_i;
        end else if( cpt_s !=0 ) begin
          cpt_s <= cpt_s - 1;
        end
      end
    end
  end : seq_0
  assign cpt_o = cpt_s;

endmodule : fsm_dcompteur
