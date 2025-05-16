`timescale 1ns / 1ps

module riscv_regfile
(
// Inputs
input clk_i
,input rst_i
,input [4:0] rd0_i
,input [4:0] rd1_i
,input [4:0] rd2_i
,input [4:0] rd3_i
,input [31:0] rd0_value_i
,input [31:0] rd1_value_i
,input [31:0] rd2_value_i
,input [31:0] rd3_value_i
,input [4:0] ra_i
,input [4:0] rb_i
// Outputs
,output [31:0] ra_value_o
,output [31:0] rb_value_o
);

reg [31:0] registers [31:0];
integer i;

always @(posedge clk_i or posedge rst_i)
begin
    if(rst_i == 1)
        begin
        for (i = 0; i < 32; i = i + 1) begin
           registers[i] = 32'b0;
        end
    end
    else 
    begin
        if (rd0_i == rd1_i == rd2_i == rd3_i)
            registers[rd0_i] <= rd0_value_i;
        else
        begin
        registers[rd0_i] <= rd0_value_i;
        registers[rd1_i] <= rd1_value_i;
        registers[rd2_i] <= rd2_value_i;
        registers[rd3_i] <= rd3_value_i;
        end
    end
end

assign ra_value_o = registers[ra_i];
assign rb_value_o = registers[rb_i];

endmodule
