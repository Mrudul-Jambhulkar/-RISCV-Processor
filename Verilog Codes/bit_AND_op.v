`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.02.2025 22:20:27
// Design Name: 
// Module Name: bit_AND_op
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


module bit_AND_op(
    input [31:0] A,B,  
    output [31:0] Y
 );
 
 genvar i;
 generate
    for (i=0; i<32; i=i+1)begin
        assign Y[i] = A[i] & B[i];
    end 
 endgenerate
endmodule
