`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.03.2026 21:28:51
// Design Name: 
// Module Name: reg_shift_sv
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


module reg_shift_sv#(
    parameter WIDTH = 128
)(
    input  logic         CLK,
    input  logic         RSTB,
    input  logic         EN,
    input  logic [7:0]   D,   
    output logic [WIDTH-1:0] Q
);

always_ff @(posedge CLK) begin
    if (RSTB == 1'b0) Q <= '0;
    else begin
        if(EN == 1'b1)begin
            Q <= {Q[WIDTH-9:0], D};
        end
    end
end

endmodule
