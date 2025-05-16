`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.02.2025 22:16:31
// Design Name: 
// Module Name: riscv_alu
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
////////////////////////////////////////////////////////

module riscv_alu(
    input [3:0] alu_op_i,
    input [31:0] alu_a_i,
    input [31:0] alu_b_i,
    output reg [31:0] alu_p_o
    );
    localparam [3:0] 
        ALU_NONE            = 4'b0000,
        ALU_SHIFTL          = 4'b0001,
        ALU_SHIFTR          = 4'b0010,
        ALU_SHIFTR_ARITH    = 4'b0011,
        ALU_ADD             = 4'b0100,
        ALU_SUB             = 4'b0110,
        ALU_AND             = 4'b0111,
        ALU_OR              = 4'b1000,
        ALU_XOR             = 4'b1001,
        ALU_LESS_THAN       = 4'b1010,
        ALU_LESS_THAN_SIGNED = 4'b1011,
        ALU_MUL             = 4'b1100;

    wire [31:0] SHIFTL_result; 
    wire [31:0] SHIFTR_result; 
    wire [31:0] SHIFTR_ARITH_result; 
    wire [31:0] ADD_result; 
    wire [31:0] SUB_result; 
    wire [31:0] AND_result; 
    wire [31:0] OR_result;  
    wire [31:0] MUL_result; 
    wire [31:0] LESS_THAN_result; 
    wire [31:0] LESS_THAN_SIGNED_result; 

    Left_Right_shifter leftshifter(
        .A(alu_a_i),
        .n(alu_b_i[4:0]),
        .shift_direction(1'b1),
        .Left_Right_shifter_out(SHIFTL_result)
    );
    
    Left_Right_shifter rightshifter(
        .A(alu_a_i),
        .n(alu_b_i[4:0]),
        .shift_direction(1'b0),
        .Left_Right_shifter_out(SHIFTR_result)
    );

    Arith_shift_right arith_shifter (
        .A(alu_a_i),
        .n(alu_b_i[4:0]),
        .Y(SHIFTR_ARITH_result)
    );
    
   ADD_SUB_using_BK add (
        .A(alu_a_i[31:0]),    
        .B(alu_b_i[31:0]),
        .op_code(1'b0),   
        .Y(ADD_result)
    );

    ADD_SUB_using_BK sub (
        .A(alu_a_i[31:0]),     
        .B(alu_b_i[31:0]),
        .op_code(1'b1),   
        .Y(SUB_result)
    );
    
    bit_AND_op bitand(
        .A(alu_a_i[31:0]),
        .B(alu_b_i[31:0]),
        .Y(AND_result)
    );

    bit_OR_op bitor(
        .A(alu_a_i[31:0]),
        .B(alu_b_i[31:0]),
        .Y(OR_result)
    );
    
    MUL_using_Dadda mulop(
        .A(alu_a_i[31:0]),
        .B(alu_b_i[31:0]),
        .Y(MUL_result)
    );

    Unsigned_compar compareunsigned (
        .A(alu_a_i ),
        .B(alu_b_i[31:0]),
        .Y(LESS_THAN_result)
    );

    Signed_compar comparesigned (
        .A(alu_a_i[31:0]),
        .B(alu_b_i[31:0]),
        .Y(LESS_THAN_SIGNED_result)
    );
    

    // ALU output selection using continuous assignments
    always @(*) begin
        case(alu_op_i)
            ALU_NONE: alu_p_o = 32'b0;
            ALU_SHIFTL: alu_p_o = SHIFTL_result;
            ALU_SHIFTR: alu_p_o = SHIFTR_result;
            ALU_SHIFTR_ARITH: alu_p_o = SHIFTR_ARITH_result;
            ALU_ADD: alu_p_o = ADD_result;
            ALU_SUB: alu_p_o = SUB_result;
            ALU_AND: alu_p_o = AND_result;
            ALU_OR: alu_p_o = OR_result;
            ALU_XOR: alu_p_o = alu_a_i ^ alu_b_i;
            ALU_LESS_THAN: alu_p_o = LESS_THAN_result;
            ALU_LESS_THAN_SIGNED: alu_p_o = LESS_THAN_SIGNED_result;
            ALU_MUL: alu_p_o = MUL_result;
            default: alu_p_o = 32'b0;
         endcase
    end
endmodule
