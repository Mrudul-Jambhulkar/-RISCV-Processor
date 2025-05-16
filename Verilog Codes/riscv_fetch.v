module riscv_fetch(
    // Input Signals
    input clk_i,
    input rst_i,
    input fetch_branch_i,
    input [31:0] fetch_branch_pc_i,
    input fetch_accept_i,
    input icache_accept_i,
    input icache_valid_i,
    input icache_error_i,
    input [31:0] icache_inst_i,
    input fetch_invalidate_i,
    
    // Output Signals
    output reg fetch_valid_o,
    output reg [31:0] fetch_instr_o,
    output reg [31:0] fetch_pc_o,
    output reg icache_rd_o,
    output reg icache_flush_o,
    output wire icache_invalidate_o, 
    output reg [31:0] icache_pc_o
);

parameter INST_FAULT = 32'h53;
assign icache_invalidate_o = 1'b0;

// Internal signals
reg [31:0] next_pc;
reg waiting_for_cache;

//stalls
wire stalls = (icache_rd_o && !icache_valid_i);

// Next PC calculation
always @(*) begin
    if (fetch_branch_i) begin
        next_pc = fetch_branch_pc_i;
    end
    else if (stalls) begin
        next_pc = icache_pc_o;
    end
    else begin
        next_pc = icache_pc_o + 4;
    end
end

// ICache request logic
always @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        icache_rd_o <= 0;
        icache_pc_o <= 0;
        waiting_for_cache <= 0;
    end
    else begin   
        if (fetch_branch_i) begin
            icache_rd_o <= 1'b1;
            icache_pc_o <= fetch_branch_pc_i;
            waiting_for_cache <= 1'b1;
        end
             else if (waiting_for_cache) begin
            if (icache_valid_i) begin
                icache_rd_o <= 1'b0;
                waiting_for_cache <= 1'b0;
            end
            else begin
                icache_rd_o <= 1'b1;
            end
        end
        else if (fetch_accept_i && !stalls) begin
            icache_rd_o <= 1'b1;
            icache_pc_o <= next_pc;
            waiting_for_cache <= 1'b1;
        end
    end
end

always @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        fetch_valid_o <= 0;
    end
    else if (fetch_accept_i || !fetch_valid_o) begin
        fetch_valid_o <= icache_valid_i;
    end
end

always @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        fetch_instr_o <= 32'b0;
    end
    else if (icache_error_i) begin
        fetch_instr_o <= INST_FAULT;
    end
    else if (icache_valid_i) begin
        fetch_instr_o <= icache_inst_i;
    end
end

// PC output
always @(posedge clk_i or posedge rst_i) begin
  if (rst_i) begin
     fetch_pc_o <= 0;
    end
    else if (icache_valid_i) begin
        fetch_pc_o <= icache_pc_o;
    end
end

// Flush logic
always @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        icache_flush_o <= 0;
    end
    else begin
        icache_flush_o <= fetch_invalidate_i;
    end
end

endmodule