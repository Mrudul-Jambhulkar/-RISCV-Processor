`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.02.2025 16:42:13
// Design Name: 
// Module Name: Arith_shift_right
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
///////////////////////////////////////////////////////////////////////////////
module Arith_shift_right(
    input  signed [31:0] A, 
    input         [4:0]  n, 
    output signed [31:0] Y  
);
    reg signed [31:0] temp;
    integer i;

    always @(*) begin
        temp = A; 
        for (i = 0; i < n; i = i + 1) begin
            
            temp = {temp[31], temp[31:1]};
        end
    end

    assign Y = temp;
endmodule
