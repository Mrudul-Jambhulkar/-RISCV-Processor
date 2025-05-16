`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.02.2025 11:55:14
// Design Name: 
// Module Name: MUL_using_Dadda
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


module MUL_using_Dadda(
    input [15:0] A,
    input [15:0] B, 
    output [31:0] Y
    );
    
    Dadda multiply(
        .A(A),
        .B(B),
        .Dadda_out(Y)
    );
endmodule
