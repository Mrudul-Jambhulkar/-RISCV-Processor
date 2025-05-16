`timescale 1ns / 1ps

`include "def.v"

module riscv_csr (
    input  wire         clk_i,
    input  wire         rst_i,
    input  wire         intr_i, 
    input  wire         opcode_valid_i,
    input  wire [57:0]  opcode_instr_i,
    input  wire [31:0]  opcode_opcode_i,
    input  wire [31:0]  opcode_pc_i,
    input  wire [4:0]   opcode_rd_idx_i,
    input  wire [4:0]   opcode_ra_idx_i,
    input  wire [4:0]   opcode_rb_idx_i,
    input  wire [31:0]  opcode_ra_operand_i,
    input  wire [31:0]  opcode_rb_operand_i,
    input  wire         branch_exec_request_i,
    input  wire [31:0]  branch_exec_pc_i,
    input  wire [31:0]  cpu_id_i,
    input  wire [31:0]  reset_vector_i,
    input  wire         fault_store_i,
    input  wire         fault_load_i,
    input  wire         fault_misaligned_store_i,
    input  wire         fault_misaligned_load_i,
    input  wire         fault_page_store_i,
    input  wire         fault_page_load_i,
    input  wire [31:0]  fault_addr_i,
    
    output reg  [4:0]   writeback_idx_o,
    output reg          writeback_squash_o,
    output reg  [31:0]  writeback_value_o,
    output reg          stall_o,
    output reg          branch_csr_request_o,
    output reg  [31:0]  branch_csr_pc_o
);

    // Internal registers for CSRs and machine privilege
    reg [1:0]   mpriv;
    reg [31:0]  csr_regs [0:4095];
    `define mstatus      csr_regs[`CSR_MSTATUS]
    `define mtvec        csr_regs[`CSR_MTVEC]
    `define mepc         csr_regs[`CSR_MEPC]
    `define mcause       csr_regs[`CSR_MCAUSE]
    `define mip          csr_regs[`CSR_MIP]
    `define mie          csr_regs[`CSR_MIE]
    `define mscratch     csr_regs[`CSR_MSCRATCH]
    `define mcycle       csr_regs[`CSR_MCYCLE]


    // Instruction decode signals (based on opcode masks/fields from def.v)
    wire ecall_w   = opcode_valid_i && ( ((opcode_opcode_i & `INST_ECALL_MASK)  == `INST_ECALL)  ||
                                         (opcode_instr_i[`ENUM_INST_ECALL]  == 1'b1) );
    wire ebreak_w  = opcode_valid_i && ( ((opcode_opcode_i & `INST_EBREAK_MASK) == `INST_EBREAK) ||
                                         (opcode_instr_i[`ENUM_INST_EBREAK] == 1'b1) );
    wire eret_w    = opcode_valid_i && ( ((opcode_opcode_i & `INST_MRET_MASK)   == `INST_MRET)   ||
                                         (opcode_instr_i[`ENUM_INST_ERET]   == 1'b1) );
    wire csrrw_w   = opcode_valid_i && ( ((opcode_opcode_i & `INST_CSRRW_MASK)  == `INST_CSRRW)  ||
                                         (opcode_instr_i[`ENUM_INST_CSRRW]  == 1'b1) );
    wire csrrs_w   = opcode_valid_i && ( ((opcode_opcode_i & `INST_CSRRS_MASK)  == `INST_CSRRS)  ||
                                         (opcode_instr_i[`ENUM_INST_CSRRS]  == 1'b1) );
    wire csrrc_w   = opcode_valid_i && ( ((opcode_opcode_i & `INST_CSRRC_MASK)  == `INST_CSRRC)  ||
                                         (opcode_instr_i[`ENUM_INST_CSRRC]  == 1'b1) );
    wire csrrwi_w  = opcode_valid_i && ( ((opcode_opcode_i & `INST_CSRRWI_MASK) == `INST_CSRRWI) ||
                                         (opcode_instr_i[`ENUM_INST_CSRRWI] == 1'b1) );
    wire csrrsi_w  = opcode_valid_i && ( ((opcode_opcode_i & `INST_CSRRSI_MASK) == `INST_CSRRSI) ||
                                         (opcode_instr_i[`ENUM_INST_CSRRSI] == 1'b1) );
    wire csrrci_w  = opcode_valid_i && ( ((opcode_opcode_i & `INST_CSRRCI_MASK) == `INST_CSRRCI) ||
                                         (opcode_instr_i[`ENUM_INST_CSRRCI] == 1'b1) );
                                         
    wire fault_w        = opcode_valid_i && ( ((opcode_opcode_i & `INST_FAULT_MASK)  == `INST_FAULT)  ||
                                         (opcode_instr_i[`ENUM_INST_FAULT]  == 1'b1) );
    wire page_fault_w   = opcode_valid_i && ( ((opcode_opcode_i & `INST_FAULT_MASK)  == `INST_FAULT)  ||
                                         (opcode_instr_i[`ENUM_INST_FAULT]  == 1'b1) );

    // Combinational block: determine the CSR mask (which bits are writable)
    reg [31:0] csr_mask;
    always @(*) begin
        case (opcode_opcode_i[31:20])
            12'h300: csr_mask = `CSR_MSTATUS_MASK;
            12'h305: csr_mask = `CSR_MTVEC_MASK;
            12'h341: csr_mask = `CSR_MEPC_MASK;
            12'h342: csr_mask = `CSR_MCAUSE_MASK;
            12'h344: csr_mask = `CSR_MIP_MASK;
            12'h304: csr_mask = `CSR_MIE_MASK;
            12'hC00: csr_mask = `CSR_MCYCLE_MASK;
            12'h340: csr_mask = `CSR_MSCRATCH_MASK;
            default: csr_mask = 32'h0;
        endcase
    end

    // Sequential block: update registers on clock edge or reset using nonblocking assignments.
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            mpriv               <= `PRIV_MACHINE;
            `mstatus            <= 32'h00000000;
            `mtvec              <= reset_vector_i;
            `mepc               <= 32'b0;
            `mcause             <= 32'b0;
            `mip                <= 32'b0;
            `mie                <= 32'b0;
            `mscratch           <= 32'b0;
            `mcycle             <= 32'b0;
            branch_csr_request_o<= 1'b0;
            branch_csr_pc_o     <= 32'b0;
            stall_o             <= 1'b0;
            writeback_idx_o     <= 5'b0;
            writeback_value_o   <= 32'b0;
            writeback_squash_o  <= 1'b0;
        end else begin
            // Increment cycle counter
            `mcycle <= `mcycle + 1;
            // Update interrupt pending bit (assume bit 11 is used)
            `mip[11] <= intr_i;

//            // Default output assignments
//            branch_csr_request_o <= 1'b0;
//            branch_csr_pc_o      <= 32'b0;
//            stall_o              <= 1'b0;
//            writeback_idx_o      <= 5'b0;
//            writeback_value_o    <= 32'b0;
//            writeback_squash_o   <= 1'b0;

            // Exception and Trap Handling
            if (ebreak_w || ecall_w || eret_w || fault_w || page_fault_w ||
                fault_store_i || fault_load_i || fault_misaligned_store_i || (opcode_pc_i[1:0] != 2'b00) ||
                fault_misaligned_load_i || fault_page_store_i || fault_page_load_i || intr_i) begin

                stall_o             <= 1'b0;
                writeback_idx_o     <= 5'b0;
                writeback_value_o   <= 32'b0;
                writeback_squash_o  <= 1'b0;
                
                if (intr_i || ((`mie & `mip) != 32'b0)) begin
                    `mcause <= `MCAUSE_INTERRUPT;
                    `mstatus[12:11] <= mpriv; // Save current privilege in MPP
                    `mstatus[7]     <= `mstatus[3];
                    `mstatus[5]     <= `mstatus[1];
                    `mstatus[4]     <= `mstatus[0];
                    `mstatus[3]     <= 1'b0;
                    `mstatus[1]     <= 1'b0;
                    `mstatus[0]     <= 1'b0;
                    mpriv           <= `PRIV_MACHINE;
                    `mepc          <= opcode_pc_i;
                    branch_csr_pc_o <= `mtvec + (`MCAUSE_INTERRUPT << 2);
                    branch_csr_request_o <= 1'b1;
                end else if (ebreak_w) begin
                    `mcause <= `MCAUSE_BREAKPOINT;
                    `mstatus[12:11] <= mpriv;
                    `mstatus[7]     <= `mstatus[3];
                    `mstatus[5]     <= `mstatus[1];
                    `mstatus[4]     <= `mstatus[0];
                    `mstatus[3]     <= 1'b0;
                    `mstatus[1]     <= 1'b0;
                    `mstatus[0]     <= 1'b0;
                    mpriv           <= `PRIV_MACHINE;
                    `mepc          <= opcode_pc_i;
                    branch_csr_pc_o <= `mtvec + (`MCAUSE_BREAKPOINT << 2);
                    branch_csr_request_o <= 1'b1;
                end else if (ecall_w) begin
                    case (mpriv)
                        `PRIV_USER:   begin  
                                          `mcause <= `MCAUSE_ECALL_U;
                                          branch_csr_pc_o <= `mtvec + (`MCAUSE_ECALL_U << 2);
                                       end
                        `PRIV_SUPER:  begin  
                                          `mcause <= `MCAUSE_ECALL_S;
                                          branch_csr_pc_o <= `mtvec + (`MCAUSE_ECALL_S << 2);
                                       end
                        `PRIV_MACHINE:begin 
                                          `mcause <= `MCAUSE_ECALL_M;
                                          branch_csr_pc_o <= `mtvec + (`MCAUSE_ECALL_M << 2);
                                       end
                        default:      begin 
                                          `mcause <= `MCAUSE_ECALL_M;
                                          branch_csr_pc_o <= `mtvec + (`MCAUSE_ECALL_M << 2);
                                       end
                    endcase
                    `mstatus[12:11] <= mpriv;
                    `mstatus[7]     <= `mstatus[3];
                    `mstatus[5]     <= `mstatus[1];
                    `mstatus[4]     <= `mstatus[0];
                    `mstatus[3]     <= 1'b0;
                    `mstatus[1]     <= 1'b0;
                    `mstatus[0]     <= 1'b0;
                    mpriv           <= `PRIV_MACHINE;
                    `mepc          <= opcode_pc_i;
                    branch_csr_request_o <= 1'b1;
                end else if (eret_w) begin
                    if (mpriv != `PRIV_MACHINE) begin
                        `mcause <= `MCAUSE_ILLEGAL_INSTRUCTION;
                        `mstatus[12:11] <= mpriv;
                        `mstatus[7]     <= `mstatus[3];
                        `mstatus[5]     <= `mstatus[1];
                        `mstatus[4]     <= `mstatus[0];
                        `mstatus[3]     <= 1'b0;
                        `mstatus[1]     <= 1'b0;
                        `mstatus[0]     <= 1'b0;
                        mpriv           <= `PRIV_MACHINE;
                        `mepc          <= opcode_pc_i;
                        branch_csr_pc_o <= `mtvec + (`MCAUSE_ILLEGAL_INSTRUCTION << 2);
                        branch_csr_request_o <= 1'b1;
                    end else begin
                        mpriv           <= `mstatus[12:11];
                        `mstatus[3]     <= `mstatus[7];
                        `mstatus[1]     <= `mstatus[5];
                        `mstatus[0]     <= `mstatus[4];
                        branch_csr_pc_o <= `mepc;
                        branch_csr_request_o <= 1'b1;
                    end
                end else if (opcode_pc_i[1:0] != 2'b00) begin
                    // Misaligned fetch
                    `mcause <= `MCAUSE_MISALIGNED_FETCH;
                    `mstatus[12:11] <= mpriv;
                    `mstatus[7]     <= `mstatus[3];
                    `mstatus[5]     <= `mstatus[1];
                    `mstatus[4]     <= `mstatus[0];
                    `mstatus[3]     <= 1'b0;
                    `mstatus[1]     <= 1'b0;
                    `mstatus[0]     <= 1'b0;
                    mpriv           <= `PRIV_MACHINE;
                    `mepc          <= opcode_pc_i;
                    branch_csr_pc_o <= `mtvec + (`MCAUSE_MISALIGNED_FETCH << 2);
                    branch_csr_request_o <= 1'b1;
                end else if (fault_store_i || fault_load_i || fault_w || page_fault_w ||
                             fault_misaligned_store_i || fault_misaligned_load_i ||
                             fault_page_store_i || fault_page_load_i) begin
                    if (fault_misaligned_load_i) begin
                        `mcause <= `MCAUSE_MISALIGNED_LOAD;
                        branch_csr_pc_o <= `mtvec + (`MCAUSE_MISALIGNED_LOAD << 2);
                    end else if (fault_load_i) begin
                        `mcause <= `MCAUSE_FAULT_LOAD;
                        branch_csr_pc_o <= `mtvec + (`MCAUSE_FAULT_LOAD << 2);
                    end else if (fault_misaligned_store_i) begin
                        `mcause <= `MCAUSE_MISALIGNED_STORE;
                        branch_csr_pc_o <= `mtvec + (`MCAUSE_MISALIGNED_STORE << 2);
                    end else if (fault_store_i) begin
                        `mcause <= `MCAUSE_FAULT_STORE;
                        branch_csr_pc_o <= `mtvec + (`MCAUSE_FAULT_STORE << 2);
                    end else if (fault_page_load_i) begin
                        `mcause <= `MCAUSE_PAGE_FAULT_LOAD;
                        branch_csr_pc_o <= `mtvec + (`MCAUSE_PAGE_FAULT_LOAD << 2);
                    end else if (fault_page_store_i) begin
                        `mcause <= `MCAUSE_PAGE_FAULT_STORE;
                        branch_csr_pc_o <= `mtvec + (`MCAUSE_PAGE_FAULT_STORE << 2);
                    end else if (fault_w) begin
                        `mcause <= `MCAUSE_FAULT_FETCH;
                        branch_csr_pc_o <= `mtvec + (`MCAUSE_FAULT_FETCH << 2);
                    end else if (page_fault_w) begin
                        `mcause <= `MCAUSE_PAGE_FAULT_INST;
                        branch_csr_pc_o <= `mtvec + (`MCAUSE_PAGE_FAULT_INST << 2);
                    end
                        
                    `mstatus[12:11] <= mpriv;
                    `mstatus[7]     <= `mstatus[3];
                    `mstatus[5]     <= `mstatus[1];
                    `mstatus[4]     <= `mstatus[0];
                    `mstatus[3]     <= 1'b0;
                    `mstatus[1]     <= 1'b0;
                    `mstatus[0]     <= 1'b0;
                    mpriv           <= `PRIV_MACHINE;
                    `mepc          <= opcode_pc_i;
                    branch_csr_request_o <= 1'b1;
                end

            // CSR Access Instructions (reads/writes)
            end else if (csrrw_w || csrrs_w || csrrc_w ||
                         csrrwi_w || csrrsi_w || csrrci_w) begin

                if ((((opcode_opcode_i & `INST_CSRRW_MASK)  != `INST_CSRRW) &&
                     ((opcode_opcode_i & `INST_CSRRS_MASK)  != `INST_CSRRS) &&
                     ((opcode_opcode_i & `INST_CSRRC_MASK)  != `INST_CSRRC) &&
                     ((opcode_opcode_i & `INST_CSRRWI_MASK) != `INST_CSRRWI) &&
                     ((opcode_opcode_i & `INST_CSRRSI_MASK) != `INST_CSRRSI) &&
                     ((opcode_opcode_i & `INST_CSRRCI_MASK) != `INST_CSRRCI)) ||
                    (mpriv != `PRIV_MACHINE)) begin

                    stall_o <= 1'b0;
                    `mcause <= `MCAUSE_ILLEGAL_INSTRUCTION;
                    `mstatus[12:11] <= mpriv;
                    `mstatus[7]     <= `mstatus[3];
                    `mstatus[5]     <= `mstatus[1];
                    `mstatus[4]     <= `mstatus[0];
                    `mstatus[3]     <= 1'b0;
                    `mstatus[1]     <= 1'b0;
                    `mstatus[0]     <= 1'b0;
                    mpriv           <= `PRIV_MACHINE;
                    `mepc          <= opcode_pc_i;
                    branch_csr_pc_o <= `mtvec + (`MCAUSE_ILLEGAL_INSTRUCTION << 2);
                    branch_csr_request_o <= 1'b1;
                    writeback_value_o <= 32'b0;
                    writeback_idx_o   <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                    writeback_squash_o<= 1'b0;
                end else begin
                    stall_o             <= 1'b1;
                    branch_csr_request_o<= 1'b0;
                    branch_csr_pc_o     <= 32'b0;
                    writeback_squash_o  <= ((opcode_opcode_i[11:7] | opcode_rd_idx_i) == 5'b0);
                
                    case (opcode_opcode_i[31:20])
                        12'h300: begin // mstatus
                            if (csrrw_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mstatus;
                                `mstatus = opcode_ra_operand_i;
                            end else if (csrrs_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mstatus;
                                `mstatus = `mstatus | (opcode_ra_operand_i & csr_mask);
                            end else if (csrrc_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mstatus;
                                `mstatus = `mstatus & (~opcode_ra_operand_i | ~csr_mask);
                            end else if (csrrwi_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mstatus;
                                `mstatus = {27'b0, opcode_opcode_i[19:15] | opcode_ra_idx_i};
                            end else if (csrrsi_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mstatus;
                                `mstatus = `mstatus | ({27'b0, opcode_opcode_i[19:15] | opcode_ra_idx_i} & csr_mask);
                            end else if (csrrci_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mstatus;
                                `mstatus = `mstatus & ((~{27'b0, opcode_opcode_i[19:15] | opcode_ra_idx_i}) | ~csr_mask);
                            end
                        end
                        12'h305: begin // mtvec
                            if (csrrw_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mtvec;
                                `mtvec = opcode_ra_operand_i;
                            end else if (csrrs_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mtvec;
                                `mtvec = `mtvec | (opcode_ra_operand_i & csr_mask);
                            end else if (csrrc_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mtvec;
                                `mtvec = `mtvec & (~opcode_ra_operand_i | ~csr_mask);
                            end else if (csrrwi_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mtvec;
                                `mtvec = {27'b0, opcode_opcode_i[19:15] | opcode_ra_idx_i};
                            end else if (csrrsi_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mtvec;
                                `mtvec = `mtvec | ({27'b0, opcode_opcode_i[19:15] | opcode_ra_idx_i} & csr_mask);
                            end else if (csrrci_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mtvec;
                                `mtvec = `mtvec & ((~{27'b0, opcode_opcode_i[19:15] | opcode_ra_idx_i}) | ~csr_mask);
                            end
                        end
                        12'h341: begin // mepc
                            if (csrrw_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mepc;
                                `mepc = opcode_ra_operand_i;
                            end else if (csrrs_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mepc;
                                `mepc = `mepc | (opcode_ra_operand_i & csr_mask);
                            end else if (csrrc_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mepc;
                                `mepc = `mepc & (~opcode_ra_operand_i | ~csr_mask);
                            end else if (csrrwi_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mepc;
                                `mepc = {27'b0, opcode_opcode_i[19:15] | opcode_ra_idx_i};
                            end else if (csrrsi_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mepc;
                                `mepc = `mepc | ({27'b0, opcode_opcode_i[19:15] | opcode_ra_idx_i} & csr_mask);
                            end else if (csrrci_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mepc;
                                `mepc = `mepc & ((~{27'b0, opcode_opcode_i[19:15] | opcode_ra_idx_i}) | ~csr_mask);
                            end
                        end
                        12'h342: begin // mcause
                            if (csrrw_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mcause;
                                `mcause = opcode_ra_operand_i;
                            end else if (csrrs_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mcause;
                                `mcause = `mcause | (opcode_ra_operand_i & csr_mask);
                            end else if (csrrc_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mcause;
                                `mcause = `mcause & (~opcode_ra_operand_i | ~csr_mask);
                            end else if (csrrwi_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mcause;
                                `mcause = {27'b0, opcode_opcode_i[19:15] | opcode_ra_idx_i};
                            end else if (csrrsi_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mcause;
                                `mcause = `mcause | ({27'b0, opcode_opcode_i[19:15] | opcode_ra_idx_i} & csr_mask);
                            end else if (csrrci_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mcause;
                                `mcause = `mcause & ((~{27'b0, opcode_opcode_i[19:15] | opcode_ra_idx_i}) | ~csr_mask);
                            end
                        end
                        12'h344: begin // mip
                            if (csrrw_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mip;
                                `mip <= opcode_ra_operand_i;
                            end else if (csrrs_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mip;
                                `mip <= `mip | (opcode_ra_operand_i & csr_mask);
                            end else if (csrrc_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mip;
                                `mip <= `mip & (~opcode_ra_operand_i | ~csr_mask);
                            end else if (csrrwi_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mip;
                                `mip <= {27'b0, opcode_opcode_i[19:15] | opcode_ra_idx_i};
                            end else if (csrrsi_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mip;
                                `mip <= `mip | ({27'b0, opcode_opcode_i[19:15] | opcode_ra_idx_i} & csr_mask);
                            end else if (csrrci_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mip;
                                `mip <= `mip & ((~{27'b0, opcode_opcode_i[19:15] | opcode_ra_idx_i}) | ~csr_mask);
                            end
                        end
                        12'h304: begin // mie
                            if (csrrw_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mie;
                                `mie <= opcode_ra_operand_i;
                            end else if (csrrs_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mie;
                                `mie <= `mie | (opcode_ra_operand_i & csr_mask);
                            end else if (csrrc_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mie;
                                `mie <= `mie & (~opcode_ra_operand_i | ~csr_mask);
                            end else if (csrrwi_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mie;
                                `mie <= {27'b0, opcode_opcode_i[19:15] | opcode_ra_idx_i};
                            end else if (csrrsi_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mie;
                                `mie <= `mie | ({27'b0, opcode_opcode_i[19:15] | opcode_ra_idx_i} & csr_mask);
                            end else if (csrrci_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mie;
                                `mie <= `mie & ((~{27'b0, opcode_opcode_i[19:15] | opcode_ra_idx_i}) | ~csr_mask);
                            end
                        end
                        12'h340: begin // mscratch
                            if (csrrw_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mscratch;
                                `mscratch <= opcode_ra_operand_i;
                            end else if (csrrs_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mscratch;
                                `mscratch <= `mscratch | (opcode_ra_operand_i & csr_mask);
                            end else if (csrrc_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mscratch;
                                `mscratch <= `mscratch & (~opcode_ra_operand_i | ~csr_mask);
                            end else if (csrrwi_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mscratch;
                                `mscratch <= {27'b0, opcode_opcode_i[19:15] | opcode_ra_idx_i};
                            end else if (csrrsi_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mscratch;
                                `mscratch <= `mscratch | ({27'b0, opcode_opcode_i[19:15] | opcode_ra_idx_i} & csr_mask);
                            end else if (csrrci_w) begin
                                writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                                writeback_value_o  <= `mscratch;
                                `mscratch <= `mscratch & ((~{27'b0, opcode_opcode_i[19:15] | opcode_ra_idx_i}) | ~csr_mask);
                            end
                        end
                        default: begin
                            writeback_idx_o <= opcode_opcode_i[11:7] | opcode_rd_idx_i;
                            writeback_value_o  <= 32'b0;
                        end
                    endcase
                end
            end else if (branch_exec_request_i) begin
                // Branch execution request handling
                writeback_squash_o   <= 1'b0;
                stall_o              <= 1'b0;
                branch_csr_request_o <= 1'b1;
                branch_csr_pc_o      <= branch_exec_pc_i;
                writeback_value_o    <= 32'b0;
                writeback_idx_o      <= 5'b0;
            end else begin
                branch_csr_request_o <= 1'b0;
                stall_o              <= 1'b0;
                writeback_idx_o      <= 5'b0;
                writeback_value_o    <= 32'b0;
                branch_csr_pc_o      <= 32'b0;
                writeback_squash_o   <= 1'b0;
            end
        end
    end

endmodule