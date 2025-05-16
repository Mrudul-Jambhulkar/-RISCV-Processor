`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.02.2025 09:29:55
// Design Name: 
// Module Name: slave_controller
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




module timer(clk_i, rst_i, 
                        cfg_awvalid_i, cfg_awaddr_i, cfg_wvalid_i, cfg_wdata_i, cfg_wstrb_i, cfg_bready_i, 
                        cfg_arvalid_i, cfg_araddr_i, cfg_rready_i,
                        cfg_awready_o, cfg_wready_o, cfg_bvalid_o, cfg_bresp_o, 
                        cfg_arready_o, cfg_rvalid_o, cfg_rdata_o, cfg_rresp_o, 
                        intr_o);
  input clk_i, rst_i;
  input [31:0]cfg_awaddr_i, cfg_wdata_i, cfg_araddr_i;
  input [3:0]cfg_wstrb_i;
  input cfg_awvalid_i, cfg_wvalid_i, cfg_bready_i, cfg_arvalid_i, cfg_rready_i;
  
  output reg[31:0]cfg_rdata_o;
  output reg[1:0]cfg_bresp_o, cfg_rresp_o;
  output reg cfg_awready_o, cfg_wready_o, cfg_bvalid_o, cfg_arready_o, cfg_rvalid_o;
  output reg intr_o;
  
  reg [31:0]cmp1, cmp0;
  wire [31:0]val1, val0;
  reg [1:0]cnt;
  reg en1, en0;
  
  reg [2:0] state;
  
  wire [1:0]I;
  timer32 T0 (.clk(clk_i), .enable(en0), .cmp(cmp0), .val(val0), .I(I[0]));
  timer32 T1 (.clk(clk_i), .enable(en1), .cmp(cmp1), .val(val1), .I(I[1]));
  
  always @(posedge clk_i) begin// or negedge rst_i) begin
    if (rst_i) begin
      intr_o <= 1'b0;
      cfg_awready_o <= 1'b0;
      cfg_wready_o <= 1'b0;
      cfg_bvalid_o <= 1'b0;
      cfg_arready_o <= 1'b0;
      cfg_rvalid_o <= 1'b0;
      cfg_rdata_o <= 32'b0;
      cnt <= 2'b00;
      state <= 3'h0;
      cmp0 <= 32'h00000000;
      cmp1 <= 32'h00000000;
      en0 <= 1'b0;
      en1 <= 1'b0;
    end else begin
      intr_o <= (I[0] && en0) || (I[1] && en1);
      case (state)
        3'h0: begin
          cfg_wready_o <= 1'b1;
          cfg_awready_o <= 1'b1;
          cfg_arready_o <= 1'b1;
          if (cfg_awvalid_i && cfg_wvalid_i) begin
            //cfg_awready_o <= 1'b1;
            case (cfg_awaddr_i[7:0])
              8'h08: begin
                en0 <= cfg_wdata_i[2];
              end
              8'h0C: begin
                if (cfg_wstrb_i[0]) begin
                  cmp0[7:0] <= cfg_wdata_i[7:0];
                end
                if (cfg_wstrb_i[1]) begin
                  cmp0[15:8] <= cfg_wdata_i[15:8];
                end
                if (cfg_wstrb_i[2]) begin
                  cmp0[23:16] <= cfg_wdata_i[23:16];
                end
                if (cfg_wstrb_i[3]) begin
                  cmp0[31:24] <= cfg_wdata_i[31:24];
                end
              end
              8'h14: begin
                en1 <= cfg_wdata_i[2];
              end
              8'h18: begin
                if (cfg_wstrb_i[0]) begin
                  cmp1[7:0] <= cfg_wdata_i[7:0];
                end
                if (cfg_wstrb_i[1]) begin
                  cmp1[15:8] <= cfg_wdata_i[15:8];
                end
                if (cfg_wstrb_i[2]) begin
                  cmp1[23:16] <= cfg_wdata_i[23:16];
                end
                if (cfg_wstrb_i[3]) begin
                  cmp1[31:24] <= cfg_wdata_i[31:24];
                end
              end
            endcase
            state <= 3'h1;
          end else begin
            if (cfg_arvalid_i) begin
              case (cfg_araddr_i[7:0])
                8'h08: begin
                  cfg_rdata_o[2:1] <= {en0, I[0]};
                end
                8'h0C: begin
                  cfg_rdata_o <= cmp0;
                end
                8'h10: begin
                  cfg_rdata_o <= val0;
                end
                8'h14: begin
                  cfg_rdata_o[2:1] <= {en1, I[1]};
                end
                8'h18: begin
                  cfg_rdata_o <= cmp1;
                end
                8'h1C: begin
                  cfg_rdata_o <= val1;
                end
              endcase
              state <= 3'h4;
            end
          end
        end
        3'h1: begin
          if (cfg_awready_o && cfg_wready_o && cfg_bready_i) begin
            cfg_awready_o <= 1'b0;
            cfg_wready_o <= 1'b0;
            cfg_bvalid_o <= 1'b1;
            cfg_bresp_o <= 2'b00;
            state <= 3'h2;
          end
        end
        3'h2: begin
          cnt <= cnt + 1'b1;
          if (cnt == 2'b11) begin
            cnt <= 2'b00;
            state <= 3'h0;
          end else begin
            if (cfg_awvalid_i && cfg_wvalid_i) begin
              cfg_awready_o <= 1'b1;
              cnt <= 2'b00;
              state <= 3'h1;
            end else begin
              if (cfg_bready_i) begin
                cfg_bvalid_o <= 1'b0;
                state <= 3'h0;
                cnt <= 2'b00;
              end
            end
          end
        end
        
        
        3'h4: begin
          if (cfg_arready_o) begin
            //
            cfg_arready_o <= 1'b0;
            cfg_rvalid_o <= 1'b1;
            cfg_rresp_o <= 2'b00;
            cnt <= 2'b00;
            state <= 3'h5;
          end
        end
        3'h5: begin
          cnt <= cnt + 1'b1;
          if (cnt == 2'b11) begin
            cnt <= 2'b00;
            state <= 3'h0;
          end else begin
            if (cfg_rready_i) begin
              cfg_rvalid_o <= 1'b0;
              state <= 3'h0;
              cnt <= 2'b00;
            end
          end
        end
        
        default: begin
          state <= 3'h0;
        end
      endcase
    end
  end
endmodule