`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.02.2025 16:57:13
// Design Name: 
// Module Name: timer32
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


module timer32(clk, enable, cmp, val, I);
  input [31:0] cmp;
  input clk, enable;
  
  output [31:0] val;
  output I;
  
  wire res;
  wire [31:0]temp;
  assign val = ~temp;
  compare32 cmp32 (.A(cmp), .B(val), .S(I));
  
  assign res = I || (~enable);
  
  counter32 cnt32 (.clk(clk), .reset(res), .Q(temp));
endmodule
