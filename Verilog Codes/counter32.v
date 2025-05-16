`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.02.2025 16:47:47
// Design Name: 
// Module Name: counter32
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

module TFF (T, Q, clk, reset);
  input T, clk, reset;
  output reg Q;
  
  always @(posedge clk) begin
    if (reset) begin
      Q <= 1'b0;
    end else begin
      if (T)
        Q <= ~Q;
    end
  end
  
endmodule

module counter32(clk, reset, Q);
  input clk, reset;
  output [31:0]Q;
  
  wire [30:1]Y;
  
  genvar i;
  
  TFF T0 (.T(1), .Q(Q[0]), .clk(clk), .reset(reset));
  
  TFF T1 (.T(Q[0]), .Q(Q[1]), .clk(clk), .reset(reset));
  assign Y[1] = Q[0] && Q[1];
  
  generate
    for (i = 2; i < 31; i=i+1) begin
      TFF Ti (.T(Y[i-1]), .Q(Q[i]), .clk(clk), .reset(reset));
      assign Y[i] = Y[i-1] && Q[i];
    end
  endgenerate
  
  TFF T31 (.T(Y[30]), .Q(Q[31]), .clk(clk), .reset(reset));
  
endmodule
