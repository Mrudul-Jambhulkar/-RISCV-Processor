`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.02.2025 17:27:25
// Design Name: 
// Module Name: compare32
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


module compare32(A, B, S);
  input [31:0] A, B;
  output S;
  
  wire [31:0]Y;
  wire [15:0]M1;
  wire [7:0]M2;
  wire [3:0]M3;
  wire [1:0]M4;
  
  genvar i;
  
  generate
    for (i = 0; i < 32; i=i+1) begin
      assign Y[i] = ~(A[i] ^ B[i]);
    end
    for (i = 0; i < 16; i = i+1) begin
      assign M1[i] = Y[2*i] && Y[2*i+1];
    end
    for (i = 0; i < 8; i = i+1) begin
      assign M2[i] = M1[2*i] && M1[2*i+1];
    end
    for (i = 0; i < 4; i = i+1) begin
      assign M3[i] = M2[2*i] && M2[2*i+1];
    end
    for (i = 0; i < 2; i = i+1) begin
      assign M4[i] = M3[2*i] && M3[2*i+1];
    end
    assign S = M4[0] && M4[1];
  endgenerate
endmodule
