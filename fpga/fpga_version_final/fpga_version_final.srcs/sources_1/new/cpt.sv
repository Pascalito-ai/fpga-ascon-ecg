`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.02.2026 13:57:35
// Design Name: 
// Module Name: cpt
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


module cpt
(
	input logic resetb_i,
	input logic en_cpt_i,
	input logic clock_i,
	input logic init_cpt_i,
	output logic[4:0] cpt_o
);
	logic[4:0] count_s;
	always_ff @(posedge clock_i, negedge resetb_i) begin :
		counter_seq
			if (resetb_i == 1'b0) begin
				count_s <= 0;
			end
			else begin
				if (en_cpt_i == 1'b1) begin
				    count_s <= count_s + 1;
				end else if(init_cpt_i == 1'b1) begin
					count_s <= 0;
			    end
			end
	end : counter_seq // always_ff @ (posedge clock_i, negedge resetb_i)
	assign cpt_o = count_s;

endmodule:cpt
