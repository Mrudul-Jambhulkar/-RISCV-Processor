`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.02.2025 13:30:37
// Design Name: 
// Module Name: Left_Right_shifter
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


module Left_Right_shifter(
    input [31:0] A,       
    input [4:0] n,  
    input shift_direction,     
    output [31:0] Left_Right_shifter_out      
);

    reg [31:0] reversed_input;   
    reg [31:0] ls_out=0; 
    wire [31:0] shift_1, shift_2, shift_4, shift_8, shift_16; 
    wire [31:0] rs_out; 
    integer i;                  

    //left shifting 
    always @(*) begin
        if (shift_direction) begin
            for (i = 0; i < 32; i = i + 1) begin
                reversed_input[i] = A[31 - i];
            end
        end else begin
            reversed_input = A;
        end
    end

    // Perform shifting by 1 bit if n[0] is set
    mux2to1 shift_by_1 (
        .mux_in_A({1'b0, reversed_input[31:1]}),  
        .mux_in_B(reversed_input),               
        .sel(n[0]),           
        .mux_out(shift_1)                        
    );

    // Perform shifting by 2 bits if n[1] is set
    mux2to1 shift_by_2 (
        .mux_in_A({2'b00, shift_1[31:2]}),        
        .mux_in_B(shift_1),                      
        .sel(n[1]),           
        .mux_out(shift_2)                        
    );

    // Perform shifting by 4 bits if n[2] is set
    mux2to1 shift_by_4 (
        .mux_in_A({4'b0000, shift_2[31:4]}),
        .mux_in_B(shift_2),                
        .sel(n[2]),                       
        .mux_out(shift_4)                  
    );
    
    //perform shifting by 8 bits if n[3]
    mux2to1 shift_by_8(
        .mux_in_A({8'b00000000, shift_4[31:8]}),
        .mux_in_B(shift_4),
        .sel(n[3]),
        .mux_out(shift_8)
    );
    
    mux2to1 shift_by_16(
        .mux_in_A({16'b0000000000000000, shift_8[31:16]}),
        .mux_in_B(shift_8),
        .sel(n[4]),
        .mux_out(shift_16)
    );
    
    
    // right shift output
    assign rs_out = shift_16; 

    // Reverse the right shift output for left shift
    always @(*) begin
        if (shift_direction) begin
            for (i = 0; i < 32; i = i + 1) begin
                ls_out[i] = shift_16[31 - i];
            end
        end else begin
            ls_out = 32'b0;
           end
    end

    // Final selection between left shifte and right shifte results
    mux2to1 final_output_mux (
        .mux_in_A(ls_out),           
        .mux_in_B(rs_out),           
        .sel(shift_direction),       
        .mux_out(Left_Right_shifter_out)
    );
endmodule

// implemented  Multiplexer
module mux2to1 (
    input wire [31:0] mux_in_A,          
    input wire [31:0] mux_in_B,          
    input wire sel,              
    output wire [31:0] mux_out          
    );
    wire not_sel;                
    wire [31:0] and_out_A, and_out_B;   

    // Generate the complement of the selection signal
    not (not_sel, sel);

    // Generate AND gates for each input
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : and_logic
            and (and_out_A[i], mux_in_A[i], sel);         
            and (and_out_B[i], mux_in_B[i], not_sel);     
        end
    endgenerate

    // Generateing the OR gates to combine results from AND gates
    generate
        for (i = 0; i < 32; i = i + 1) begin : or_logic
            or (mux_out[i], and_out_A[i], and_out_B[i]);   
        end
    endgenerate

endmodule