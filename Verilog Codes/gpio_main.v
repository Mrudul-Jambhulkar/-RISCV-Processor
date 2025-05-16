//`timescale 1ns / 1ps
module gpio (
    input wire clk_i,                // System clock
    input wire rst_i,                // Active-high reset
    input wire cfg_awvalid_i,        // AXI-Lite Write Address Valid
    (* KEEP = "TRUE" *) input wire [31:0] cfg_awaddr_i,  // AXI-Lite Write Address
    input wire cfg_wvalid_i,         // AXI-Lite Write Data Valid
    (* KEEP = "TRUE" *) input wire [31:0] cfg_wdata_i,   // AXI-Lite Write Data
    input wire cfg_bready_i,         // AXI-Lite Write Response Ready
    input wire cfg_arvalid_i,        // AXI-Lite Read Address Valid
    input wire [31:0] cfg_araddr_i,  // AXI-Lite Read Address
    input wire cfg_rready_i,         // AXI-Lite Read Data Ready
    input wire [31:0] gpio_input_i,  // External GPIO input signals
     input wire [3:0] cfg_wstrb_i,

    output reg cfg_awready_o,        // AXI-Lite Write Address Ready
    output reg cfg_wready_o,         // AXI-Lite Write Data Ready
    output reg cfg_bvalid_o,         // AXI-Lite Write Response Valid
    output reg [1:0] cfg_bresp_o,    // AXI-Lite Write Response
    output reg cfg_arready_o,        // AXI-Lite Read Address Ready
    output reg cfg_rvalid_o,         // AXI-Lite Read Data Valid
    output reg [31:0] cfg_rdata_o,   // AXI-Lite Read Data
    output reg [1:0] cfg_rresp_o,    // AXI-Lite Read Response
    output reg [31:0] gpio_output_o, // GPIO output data
    (* KEEP = "TRUE", DONT_TOUCH = "TRUE" *) output reg [31:0] gpio_output_enable_o, // GPIO output enable
    output reg intr_o                );
    // Internal Registers
    (* KEEP = "TRUE", DONT_TOUCH = "TRUE" *) reg [31:0] gpio_direction_q;
    (* KEEP = "TRUE", DONT_TOUCH = "TRUE" *) reg [31:0] gpio_output_q;
    (* KEEP = "TRUE", DONT_TOUCH = "TRUE" *) reg [31:0] gpio_int_mask_q;
    (* KEEP = "TRUE", DONT_TOUCH = "TRUE" *) reg [31:0] gpio_int_set_q;
    (* KEEP = "TRUE", DONT_TOUCH = "TRUE" *) reg [31:0] gpio_int_clr_q;
    (* KEEP = "TRUE", DONT_TOUCH = "TRUE" *) reg [31:0] gpio_int_level_q;
    (* KEEP = "TRUE", DONT_TOUCH = "TRUE" *) reg [31:0] gpio_output_set_q;
    (* KEEP = "TRUE", DONT_TOUCH = "TRUE" *) reg [31:0] gpio_output_clr_q;
    (* KEEP = "TRUE", DONT_TOUCH = "TRUE" *) reg [31:0] gpio_int_mode_q;  // New Register for Interrupt Mode
    (* KEEP = "TRUE", DONT_TOUCH = "TRUE" *) reg [31:0] gpio_int_status_q;    
    
    // Internal Signals for Submodules
    wire [31:0] gpio_int_status_w;
    wire intr_w;
    wire [31:0] gpio_output_w;
    wire [31:0] gpio_output_enable_w = gpio_direction_q;
    (* KEEP = "TRUE", DONT_TOUCH = "TRUE" *)wire unused_signal;
    (* KEEP = "TRUE", DONT_TOUCH = "TRUE" *)assign unused_signal = |gpio_output_enable_o;
      // AXI-Lite Write FSM States
    parameter [1:0] WRITE_IDLE = 2'b00;
    parameter [1:0] WRITE_DATA = 2'b01;
    parameter [1:0] WRITE_RESP = 2'b10;
    reg [1:0] write_state;

    // AXI-Lite Read FSM States
    parameter [1:0] READ_IDLE = 2'b00;
    parameter [1:0] READ_DATA = 2'b01;
    reg [1:0] read_state;

    // Input Synchronization for metastability protection
    reg [31:0] gpio_input_q;
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            gpio_input_q <= 32'b0;
        end else begin
            gpio_input_q <= gpio_input_i;
        end
    end
 // AXI-Lite Write FSM
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            write_state <= WRITE_IDLE;
            cfg_awready_o <= 1'b0;
            cfg_wready_o <= 1'b0;
            cfg_bvalid_o <= 1'b0;
            cfg_bresp_o <= 2'b00;
            gpio_direction_q <= 32'b0;
            gpio_output_q <= 32'b0;
            gpio_int_mask_q <= 32'b0;
            gpio_int_set_q <= 32'b0;
            gpio_int_clr_q <= 32'b0;
            gpio_int_level_q <= 32'b0;
            gpio_output_set_q <= 32'b0;
            gpio_output_clr_q <= 32'b0;
            gpio_int_mode_q <= 32'b0;
        end else begin
            case (write_state)
                WRITE_IDLE: begin
                    if (cfg_awvalid_i && cfg_wvalid_i) begin
                        cfg_awready_o <= 1'b1;
                        cfg_wready_o <= 1'b1;
                        write_state <= WRITE_DATA;
                    end
                end
                WRITE_DATA: begin
                    cfg_awready_o <= 1'b0;
                    cfg_wready_o <= 1'b0;
                    //if (cfg_awvalid_i && cfg_wvalid_i) begin
                        //cfg_wready_o <= 1'b0;
                        case (cfg_awaddr_i[7:0])
                            8'h00: gpio_direction_q <= cfg_wdata_i;
                            8'h08: gpio_output_q <= cfg_wdata_i;
                            8'h0C: gpio_output_set_q <= cfg_wdata_i;
                            8'h10: gpio_output_clr_q <= cfg_wdata_i;
                            8'h14: gpio_int_mask_q <= cfg_wdata_i;
                            8'h18: gpio_int_set_q <= cfg_wdata_i;
                            8'h1C: gpio_int_clr_q <= cfg_wdata_i;
                            8'h24: gpio_int_level_q <= cfg_wdata_i;
                            8'h28: gpio_int_mode_q <= cfg_wdata_i;
                            default: cfg_bresp_o <= 2'b10; // SLVERR
                        endcase
                        cfg_bvalid_o <= 1'b1;
                        write_state <= WRITE_RESP;
                    //end
                end
                WRITE_RESP: begin
                    //cfg_bvalid_o <= 1'b1;
                    if (cfg_bready_i) begin
                        cfg_bvalid_o <= 1'b0;
                        write_state <= WRITE_IDLE;
                    end
                    //write_state <= WRITE_IDLE;
                end
            endcase
        end
    end


  // AXI-Lite Read FSM
always @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        read_state <= READ_IDLE;
        cfg_arready_o <= 1'b0;
        cfg_rvalid_o <= 1'b0;
        cfg_rdata_o <= 32'b0;
        cfg_rresp_o <= 2'b00;
        //gpio_direction_q <= 32'b0;
        
    end else begin
        case (read_state)
            READ_IDLE: begin
                if (cfg_arvalid_i ) begin
                    cfg_arready_o <= 1'b1;
                    cfg_rvalid_o <= 1'b1;
                    read_state <= READ_DATA;
                end
            end
            READ_DATA: begin
                //cfg_arready_o <= 1'b0;
                //cfg_rvalid_o <= 1'b1;
                case (cfg_araddr_i[7:0])
                    8'h00: cfg_rdata_o <= gpio_direction_q;
                    8'h04: cfg_rdata_o <= gpio_input_q;
                    8'h08: cfg_rdata_o <= gpio_output_q;
                    8'h0C: cfg_rdata_o <= gpio_output_set_q ;
                    8'h10: cfg_rdata_o <= gpio_output_clr_q ;
                    8'h14: cfg_rdata_o <= gpio_int_mask_q;
                    8'h18: cfg_rdata_o <= gpio_int_set_q ;
                    8'h1C: cfg_rdata_o <= gpio_int_clr_q ;
                    8'h20: cfg_rdata_o <= gpio_int_status_q;   // Added Interrupt Status Register
                    8'h24: cfg_rdata_o <= gpio_int_level_q;
                    8'h28: cfg_rdata_o <= gpio_int_mode_q;
                    default: begin
                        cfg_rresp_o <= 2'b10; // SLVERR
                        cfg_rdata_o <= 32'b0;
                    end
                 
                endcase
                cfg_arready_o <= 1'b0;
                //cfg_rvalid_o <= 1'b1;
                if (cfg_rready_i) begin
                    cfg_rvalid_o <= 1'b0;
                    read_state <= READ_IDLE;
                end
                //read_state <= READ_IDLE;
            end
        endcase
    end
end
    
     gpio_output_logic u_gpio_output_logic (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .gpio_direction_i(gpio_direction_q),
        .gpio_output_i(gpio_output_q),
        .gpio_output_set_i(gpio_output_set_q),
        .gpio_output_clr_i(gpio_output_clr_q),
        .gpio_output_o(gpio_output_w)
        //.gpio_output_enable_o(gpio_output_enable_w)
    );
    // Instantiate gpio_interrupt Module
    gpio_interrupt u_gpio_interrupt (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .gpio_input_i(gpio_input_q),
        .gpio_int_mask_i(gpio_int_mask_q),
        .gpio_int_level_i(gpio_int_level_q),
        .gpio_int_set_i(gpio_int_set_q),
        .gpio_int_clr_i(gpio_int_clr_q),
        .gpio_int_mode_i(gpio_int_mode_q),  // Connect GPIO_INT_MODE
        .gpio_int_status_o(gpio_int_status_w),
        .intr_o(intr_w)
    );
    // Connecting Submodule Outputs to Main Outputs
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            gpio_output_o <= 32'b0;
            gpio_output_enable_o <= 32'b0;
            intr_o <= 1'b0;
            gpio_int_status_q  <= 1'b0;
        end else begin
            gpio_output_o <= gpio_output_w;
            gpio_output_enable_o <= gpio_output_enable_w;
            intr_o <= intr_w;
            gpio_int_status_q <= gpio_int_status_w;
        end
    end

endmodule