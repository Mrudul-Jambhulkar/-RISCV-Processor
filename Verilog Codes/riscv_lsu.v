
// Includes
`include "riscv_defs.v"

module riscv_lsu
(
    // Inputs
    input clk_i,
    input rst_i, //active high
    input opcode_valid_i, //Indicates whether the incoming opcode is valid
    input [ 57:0] opcode_instr_i, //--new input-- Instruction from the instruction decoder
    input [ 31:0] opcode_opcode_i, //Immediate and opcode bits extracted from instruction
    input [ 31:0] opcode_pc_i, //[unused] Program counter value for the instruction
    input [ 4:0] opcode_rd_idx_i, //Index of the destination register (for loads)
    input [ 4:0] opcode_ra_idx_i, //[unused] Index of the first source register
    input [ 4:0] opcode_rb_idx_i, //[unused] Index of the second source register
    input [ 31:0] opcode_ra_operand_i, //Data from source register A (for loads, or for stores??)
    input [ 31:0] opcode_rb_operand_i, //Data from source register B (for stores)
    input [ 31:0] mem_data_rd_i, //Data read from memory in response to a load
    input mem_accept_i, //Memory system indicates readiness to accept requests
    input mem_ack_i, //Acknowledgment from memory for a completed transaction
    input mem_error_i, //Indicates an error in memory transaction - useful for fault detection
    input [ 10:0] mem_resp_tag_i, //Tag to track responses for load operations

    // Outputs
    output reg [31:0] mem_addr_o,         // Address for memory read/write operations
    output reg [31:0] mem_data_wr_o,      // Data to be written to memory
    output reg        mem_rd_o,           // Indicates a memory read request
    output reg [3:0]  mem_wr_o,           // Indicates a memory write request (byte enable signals)
    output reg        mem_cacheable_o,    // Specifies if the memory access is cacheable
    output reg [10:0] mem_req_tag_o,      // Tag for tracking memory requests
    output reg        mem_invalidate_o,   // Signals a cache invalidation request - if opcode is CSR_DINVALIDATE
    output reg        mem_flush_o,        // Signals a cache flush request - if opcode is CSR_DFLUSH
    output reg [4:0]  writeback_idx_o,    // Register index for writing back the loaded data
    output            writeback_squash_o, // Indicates if writeback should be ignored (default = 0)
    output reg [31:0] writeback_value_o,  // Data to be written back to the register file
    output reg        fault_store_o,      // Indicates a store fault - depends on mem_resp_tag_i and mem_error_i
    output reg        fault_load_o,       // Indicates a load fault - depends on mem_resp_tag_i and mem_error_i
    output reg        fault_misaligned_store_o, // Indicates a misaligned store fault (when address is unaligned)
    output reg        fault_misaligned_load_o,  // Indicates a misaligned load fault
    output            fault_page_store_o,       // Indicates a page fault on store (default = 0)
    output            fault_page_load_o,        // Indicates a page fault on load (default = 0)
    output     [31:0] fault_addr_o,       // Address that caused a fault (default = 0)
    output            stall_o             // Indicates that the LSU is stalling the pipeline (if cache is busy)

);

// Parameters
parameter MEM_CACHE_ADDR_MIN = 32'h00000000;
parameter MEM_CACHE_ADDR_MAX = 32'h7fffffff;

// Intermediate registers & wires 
wire load_byte_req, load_half_word_req, load_word_req, store_byte_req, store_half_word_req, store_word_req, load_instr, store_instr, load_signed_instr;
                                                    
reg [31:0]  mem_addr_temp;
reg         mem_unaligned_temp;
reg [31:0]  mem_data_temp;
wire         mem_rd_temp;
reg [3:0]   mem_wr_temp;
wire mem_flush_temp;
wire mem_invalidate_temp;

wire         mem_unaligned;

wire cache_flush, cache_writeback, cache_invalidate;

reg lsu_op_pending;
wire complete_ok, complete_err;

wire delay_lsu_next_instr;

// Internal signals for load operation
wire [1:0]  addr_lsb_tag;
wire        load_word_tag;
wire        load_byte_tag;
wire        load_half_tag;
wire        load_signed_tag;
reg [31:0]  wb_result_reg;

// Decoding the opcode
assign load_byte_req = ((opcode_opcode_i & `INST_LB_MASK) == `INST_LB) || ((opcode_opcode_i & `INST_LBU_MASK) == `INST_LBU);
assign load_half_word_req = ((opcode_opcode_i & `INST_LH_MASK) == `INST_LH) || ((opcode_opcode_i & `INST_LHU_MASK) == `INST_LHU);
assign load_word_req = ((opcode_opcode_i & `INST_LW_MASK) == `INST_LW) || ((opcode_opcode_i & `INST_LWU_MASK) == `INST_LWU);
assign store_byte_req = ((opcode_opcode_i & `INST_SB_MASK) == `INST_SB);
assign store_half_word_req = ((opcode_opcode_i & `INST_SH_MASK) == `INST_SH);
assign store_word_req = ((opcode_opcode_i & `INST_SW_MASK) == `INST_SW);

assign load_instr = load_byte_req || load_half_word_req || load_word_req;
assign store_instr =  store_byte_req || store_half_word_req || store_word_req;
assign load_signed_instr = (((opcode_opcode_i & `INST_LB_MASK) == `INST_LB)  || 
                           ((opcode_opcode_i & `INST_LH_MASK) == `INST_LH)  || 
                           ((opcode_opcode_i & `INST_LW_MASK) == `INST_LW));
                           
assign cache_flush      = ((opcode_opcode_i & `INST_CSRRW_MASK) == `INST_CSRRW) && (opcode_opcode_i[31:20] == `CSR_DFLUSH);
assign cache_writeback  = ((opcode_opcode_i & `INST_CSRRW_MASK) == `INST_CSRRW) && (opcode_opcode_i[31:20] == `CSR_DWRITEBACK);
assign cache_invalidate = ((opcode_opcode_i & `INST_CSRRW_MASK) == `INST_CSRRW) && (opcode_opcode_i[31:20] == `CSR_DINVALIDATE);   

assign complete_ok  = mem_ack_i & ~mem_error_i;
assign complete_err = mem_ack_i & mem_error_i; 

// Outstanding response late - delay next instruction
assign delay_lsu_next_instr = lsu_op_pending && !complete_ok;    

assign mem_rd_temp = (opcode_valid_i && load_instr && !mem_unaligned_temp);  

// Computing output memory address
always @ (*)
begin
        if (opcode_valid_i && ((opcode_opcode_i & `INST_CSRRW_MASK) == `INST_CSRRW))
        mem_addr_temp = opcode_ra_operand_i;
    else if (opcode_valid_i && load_instr)
        mem_addr_temp = opcode_ra_operand_i + {{20{opcode_opcode_i[31]}}, opcode_opcode_i[31:20]};
    else if (opcode_valid_i && store_instr)
        mem_addr_temp = opcode_ra_operand_i + {{20{opcode_opcode_i[31]}}, opcode_opcode_i[31:25], opcode_opcode_i[11:7]};
    else
        mem_addr_temp = 0; //added
end

// Computing memory unaligned signal
always @(*) begin
    if (opcode_valid_i && (load_word_req || store_word_req))
        mem_unaligned_temp = (mem_addr_temp[1:0] != 2'b0);
    else if (opcode_valid_i && (load_half_word_req || store_half_word_req))
        mem_unaligned_temp = mem_addr_temp[0];
    else 
        mem_unaligned_temp = 0; //added
end

// Computing mem_data_temp and mem_wr_temp
always @(*) begin
    if (opcode_valid_i && store_word_req && !mem_unaligned_temp)
    begin
        mem_data_temp  = opcode_rb_operand_i;
        mem_wr_temp    = 4'hF;
    end
    else if (opcode_valid_i && store_half_word_req && !mem_unaligned_temp)
    begin
        case (mem_addr_temp[1:0])
        2'h2 :
        begin
            mem_data_temp  = {opcode_rb_operand_i[15:0],16'h0000};
            mem_wr_temp    = 4'b1100;
        end
        2'h0 :
        begin
            mem_data_temp  = {16'h0000,opcode_rb_operand_i[15:0]};
            mem_wr_temp    = 4'b0011;
        end
        default :
        begin
            mem_data_temp  = {16'h0000,opcode_rb_operand_i[15:0]};
            mem_wr_temp    = 4'b0011;
        end
        endcase
    end
    else if (opcode_valid_i && store_byte_req && !mem_unaligned_temp)
    begin
        case (mem_addr_temp[1:0])
        2'h3 :
        begin
            mem_data_temp  = {opcode_rb_operand_i[7:0],24'h000000};
            mem_wr_temp    = 4'b1000;
        end
        2'h2 :
        begin
            mem_data_temp  = {{8'h00,opcode_rb_operand_i[7:0]},16'h0000};
            mem_wr_temp    = 4'b0100;
        end
        2'h1 :
        begin
            mem_data_temp  = {{16'h0000,opcode_rb_operand_i[7:0]},8'h00};
            mem_wr_temp    = 4'b0010;
        end
        2'h0 :
        begin
            mem_data_temp  = {24'h000000,opcode_rb_operand_i[7:0]};
            mem_wr_temp    = 4'b0001;
        end
        endcase
    end
    else
    begin
        mem_data_temp  = 32'b0;
        mem_wr_temp    = 4'b0;
    end
end                          
                         
// Pending operations tracking                          
always @ (*) begin
    if ((mem_rd_temp || (|mem_wr_temp) || mem_invalidate_temp || mem_flush_temp) && mem_accept_i)
        lsu_op_pending = 1'b1;
    else if (complete_ok || complete_err)
        lsu_op_pending = 1'b0;
    else
        lsu_op_pending = 1'b0;
end

assign mem_unaligned = mem_unaligned_temp & ~delay_lsu_next_instr;

assign mem_flush_temp = opcode_valid_i & cache_flush;
assign mem_invalidate_temp = opcode_valid_i & cache_invalidate;

// Computing outputs
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
begin
    mem_addr_o       <= 32'b0;
    mem_data_wr_o    <= 32'b0;
    mem_rd_o         <= 1'b0;
    mem_wr_o         <= 4'b0;
    mem_cacheable_o  <= 1'b0;
    mem_invalidate_o <= 1'b0;
    mem_flush_o      <= 1'b0;
    mem_req_tag_o    <= 11'b0;
end
else begin
    if (complete_err || mem_unaligned)
    begin
        mem_addr_o       <= 32'b0;
        mem_data_wr_o    <= 32'b0;
        mem_rd_o         <= 1'b0;
        mem_wr_o         <= 4'b0;
        mem_cacheable_o  <= 1'b0;
        mem_invalidate_o <= 1'b0;
        mem_flush_o      <= 1'b0;
        mem_req_tag_o    <= 11'b0;
    end
    else if (!((mem_invalidate_o || mem_flush_o || mem_rd_o || mem_wr_o != 4'b0) && !mem_accept_i))
    begin
        mem_addr_o         <= mem_addr_temp;
        mem_data_wr_o      <= mem_data_temp;
        mem_rd_o           <= mem_rd_temp;
        mem_wr_o           <= mem_wr_temp;
        mem_cacheable_o  <= (mem_addr_temp >= MEM_CACHE_ADDR_MIN && mem_addr_temp <= MEM_CACHE_ADDR_MAX) ||
                            (opcode_valid_i && (cache_invalidate || cache_writeback || cache_flush));
    
        mem_invalidate_o <= mem_invalidate_temp;
        mem_flush_o      <= mem_flush_temp;
        mem_req_tag_o       <= {load_signed_instr, load_word_req, load_half_word_req, load_byte_req, mem_addr_temp[1:0], opcode_rd_idx_i};    
    end
      else begin
        mem_addr_o         <= mem_addr_temp;
        mem_data_wr_o      <= mem_data_temp;
        mem_rd_o           <= mem_rd_temp;
        mem_wr_o           <= mem_wr_temp;
        mem_cacheable_o  <= (mem_addr_temp >= MEM_CACHE_ADDR_MIN && mem_addr_temp <= MEM_CACHE_ADDR_MAX) ||
                            (opcode_valid_i && (cache_invalidate || cache_writeback || cache_flush));
    
        mem_invalidate_o <= mem_invalidate_temp;
        mem_flush_o      <= mem_flush_temp;
        mem_req_tag_o       <= {load_signed_instr, load_word_req, load_half_word_req, load_byte_req, mem_addr_temp[1:0], opcode_rd_idx_i};
      end

end

assign writeback_squash_o  = 1'b0;
assign fault_page_store_o = 1'b0;
assign fault_page_load_o  = 1'b0;
assign fault_addr_o       = 32'b0;

//Computing fault outputs
always @ (posedge clk_i or posedge rst_i) begin
    if (rst_i) 
    begin
        fault_store_o               <= 0;
        fault_load_o                <= 0;
        fault_misaligned_store_o    <= 0;
        fault_misaligned_load_o     <= 0;
    end
    else begin
        fault_store_o               <= mem_ack_i & store_instr & mem_error_i;
        fault_load_o                <= mem_ack_i & load_instr & mem_error_i; 
        fault_misaligned_store_o    <= mem_unaligned & store_instr;
        fault_misaligned_load_o     <= mem_unaligned & load_instr;    
    end
end
    


// Stall output
assign stall_o          = ((mem_invalidate_o || mem_flush_o || mem_rd_o || mem_wr_o != 4'b0) && !mem_accept_i) || delay_lsu_next_instr || mem_unaligned_temp;

// Load operation
// Tag associated with load
assign addr_lsb_tag    = mem_resp_tag_i[6:5];
assign load_byte_tag   = mem_resp_tag_i[7];
assign load_half_tag   = mem_resp_tag_i[8];
assign load_word_tag   = mem_resp_tag_i[9];
assign load_signed_tag = mem_resp_tag_i[10];

always @ (*)
begin
    // Access fault - pass corresponding address on writeback result bus
    if ((mem_ack_i && mem_error_i) || mem_unaligned)
        wb_result_reg = mem_addr_temp;
    // Handle responses
    else if (|(mem_resp_tag_i[4:0]) && load_instr)
    begin
        if (load_byte_tag)
        begin
            case (addr_lsb_tag[1:0])
            2'h3: wb_result_reg = {24'b0, mem_data_rd_i[31:24]};
            2'h2: wb_result_reg = {24'b0, mem_data_rd_i[23:16]};
            2'h1: wb_result_reg = {24'b0, mem_data_rd_i[15:8]};
            2'h0: wb_result_reg = {24'b0, mem_data_rd_i[7:0]};
            endcase

            if (load_signed_tag && wb_result_reg[7])
                wb_result_reg = {24'hFFFFFF, wb_result_reg[7:0]};
        end
        else if (load_half_tag)
        begin
            if (addr_lsb_tag[1])
                wb_result_reg = {16'b0, mem_data_rd_i[31:16]};
            else
                wb_result_reg = {16'b0, mem_data_rd_i[15:0]};

            if (load_signed_tag && wb_result_reg[15])
                wb_result_reg = {16'hFFFF, wb_result_reg[15:0]};
        end
        else if (load_word_tag)
            wb_result_reg = mem_data_rd_i;
        else
            wb_result_reg = 32'b0; 
    end
    else 
        wb_result_reg = 32'b0; 
end

// Computing writeback_idx_o and writeback_value_o
always @ (posedge clk_i or posedge rst_i) begin
    if(rst_i) begin
        writeback_idx_o     <= 0;
        writeback_value_o   <= 0;
    end
    else begin
        writeback_idx_o     <=  mem_resp_tag_i[4:0] & {5{load_instr}}; 
        writeback_value_o   <= wb_result_reg;
    end
end

endmodule