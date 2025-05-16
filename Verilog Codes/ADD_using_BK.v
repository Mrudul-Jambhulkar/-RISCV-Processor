`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 12.02.2025 11:29:58
//// Design Name: 
//// Module Name: ADD_using_BK
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

module ADD_SUB_using_BK (
    input [31:0] A,               
    input [31:0] B,               
    input op_code,                
    output [31:0] Y               
);
    wire cin;                     
    wire cout;                    
    wire [31:0] NegB;
    wire [31:0] B_or_NegB;
    
    assign NegB = ~B;       
    assign B_or_NegB = (op_code) ? NegB : B;
    assign cin = op_code;          

    // instantiating the Brent-Kung adder
    BK_Adder_32 brent_kung (
        .a(A),                     
        .b(B_or_NegB),             
        .cin(cin),                 
        .sum(Y),                   
        .cout(cout)                
    );
endmodule