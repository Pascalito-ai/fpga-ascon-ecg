`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.03.2026 14:27:17
// Design Name: 
// Module Name: trans_receive
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


module trans_receive
  import uart_pkg::*;
(
    input  logic       clock_i,          
    input  logic       resetb_i,        
    input  logic [7:0] RxData_i,
    input  logic       en_i,
    output logic [7:0] data_converted_o
);
  logic [7:0] data_converted_s;

  always_ff @(posedge clock_i or negedge resetb_i) begin : seq_0
    if (resetb_i == 1'b0) data_converted_s <= '0;
    else begin
      if (en_i == 1'b1) begin
         data_converted_s <= RxData_i;
      end else begin
        data_converted_s <= data_converted_s;
      end
    end
  end : seq_0
  assign data_converted_o = data_converted_s;

endmodule : trans_receive