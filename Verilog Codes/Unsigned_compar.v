`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 14.02.2025 11:21:18
//// Design Name: 
//// Module Name: Unsigned_compar
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////

module Unsigned_compar (
    input [31:0] A,  
    input [31:0] B,  
    output [31:0] Y  
);
    reg [31:0] result;

    always @(*) begin
        if (A < B) begin
            result = 32'd1; 
        end else begin
            result = 32'd0; 
        end
    end

    assign Y = result;  
endmodule
