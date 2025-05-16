`timescale 1ns / 1ps

module tb_soc;
    parameter GPIO_BASE  = 32'h94000000;
    parameter IRQ_BASE   = 32'h90000000;
    parameter UART_BASE  = 32'h92000000;
    parameter TIMER_BASE = 32'h91000000;
    parameter SPI_BASE   = 32'h93000000;
    parameter MEM_BASE   = 32'h00000000;
    
    // UART Parameters
    localparam CLK_FREQ = 100_000_000; // 100 MHz
    localparam BAUD_RATE = 921_600;    // Bit rate
    localparam BIT_PERIOD = (CLK_FREQ / BAUD_RATE) * 10; // Bit period in ns
    localparam NUM_BITS = 10;          // Start bit + 8 data bits + stop bit

    // UART Register Offsets
    parameter ULITE_RX      = UART_BASE + 32'h0;
    parameter ULITE_TX      = UART_BASE + 32'h4;
    parameter ULITE_STATUS  = UART_BASE + 32'h8;
    parameter ULITE_CONTROL = UART_BASE + 32'hc;

    reg           clk_i;
    reg           rst_i;

    reg           inport_awvalid_i;
    reg  [31:0]   inport_awaddr_i;
    reg  [3:0]    inport_awid_i;
    reg  [7:0]    inport_awlen_i;
    reg  [1:0]    inport_awburst_i;
    reg           inport_wvalid_i;
    reg  [31:0]   inport_wdata_i;
    reg  [3:0]    inport_wstrb_i;
    reg           inport_wlast_i;
    reg           inport_bready_i;
    reg           inport_arvalid_i;
    reg  [31:0]   inport_araddr_i;
    reg  [3:0]    inport_arid_i;
    reg  [7:0]    inport_arlen_i;
    reg  [1:0]    inport_arburst_i;
    reg           inport_rready_i;

    // AXI4 Memory Signals
    reg           mem_awready_i;
    reg           mem_wready_i;
    reg           mem_bvalid_i;
    reg  [1:0]    mem_bresp_i;
    reg  [3:0]    mem_bid_i;
    reg           mem_arready_i;
    reg           mem_rvalid_i;
    reg  [31:0]   mem_rdata_i;
    reg  [1:0]    mem_rresp_i;
    reg  [3:0]    mem_rid_i;
    reg           mem_rlast_i;

    // AXI4 CPU Instruction Signals
    reg           cpu_i_awvalid_i;
    reg  [31:0]   cpu_i_awaddr_i;
    reg  [3:0]    cpu_i_awid_i;
    reg  [7:0]    cpu_i_awlen_i;
    reg  [1:0]    cpu_i_awburst_i;
    reg           cpu_i_wvalid_i;
    reg  [31:0]   cpu_i_wdata_i;
    reg  [3:0]    cpu_i_wstrb_i;
    reg           cpu_i_wlast_i;
    reg           cpu_i_bready_i;
    reg           cpu_i_arvalid_i;
    reg  [31:0]   cpu_i_araddr_i;
    reg  [3:0]    cpu_i_arid_i;
    reg  [7:0]    cpu_i_arlen_i;
    reg  [1:0]    cpu_i_arburst_i;
    reg           cpu_i_rready_i;

    // AXI4 CPU Data Signals
    reg           cpu_d_awvalid_i;
    reg  [31:0]   cpu_d_awaddr_i;
    reg  [3:0]    cpu_d_awid_i;
    reg  [7:0]    cpu_d_awlen_i;
    reg  [1:0]    cpu_d_awburst_i;
    reg           cpu_d_wvalid_i;
    reg  [31:0]   cpu_d_wdata_i;
    reg  [3:0]    cpu_d_wstrb_i;
    reg           cpu_d_wlast_i;
    reg           cpu_d_bready_i;
    reg           cpu_d_arvalid_i;
    reg  [31:0]   cpu_d_araddr_i;
    reg  [3:0]    cpu_d_arid_i;
    reg  [7:0]    cpu_d_arlen_i;
    reg  [1:0]    cpu_d_arburst_i;
    reg           cpu_d_rready_i;

    // Peripheral Inputs
    reg           spi_miso_i;
    reg           uart_txd_i;
    reg  [31:0]   gpio_input_i;

    // Outputs
    wire          intr_o;
    wire          inport_awready_o;
    wire          inport_wready_o;
    wire          inport_bvalid_o;
    wire [1:0]    inport_bresp_o;
    wire [3:0]    inport_bid_o;
    wire          inport_arready_o;
    wire          inport_rvalid_o;
    wire [31:0]   inport_rdata_o;
    wire [1:0]    inport_rresp_o;
    wire [3:0]    inport_rid_o;
    wire          inport_rlast_o;
    wire          mem_awvalid_o;
    wire [31:0]   mem_awaddr_o;
    wire [3:0]    mem_awid_o;
    wire [7:0]    mem_awlen_o;
    wire [1:0]    mem_awburst_o;
    wire          mem_wvalid_o;
    wire [31:0]   mem_wdata_o;
    wire [3:0]    mem_wstrb_o;
    wire          mem_wlast_o;
    wire          mem_bready_o;
    wire          mem_arvalid_o;
    wire [31:0]   mem_araddr_o;
    wire [3:0]    mem_arid_o;
    wire [7:0]    mem_arlen_o;
    wire [1:0]    mem_arburst_o;
    wire          mem_rready_o;
    wire          cpu_i_awready_o;
    wire          cpu_i_wready_o;
    wire          cpu_i_bvalid_o;
    wire [1:0]    cpu_i_bresp_o;
    wire [3:0]    cpu_i_bid_o;
    wire          cpu_i_arready_o;
    wire          cpu_i_rvalid_o;
    wire [31:0]   cpu_i_rdata_o;
    wire [1:0]    cpu_i_rresp_o;
    wire [3:0]    cpu_i_rid_o;
    wire          cpu_i_rlast_o;
    wire          cpu_d_awready_o;
    wire          cpu_d_wready_o;
    wire          cpu_d_bvalid_o;
    wire [1:0]    cpu_d_bresp_o;
    wire [3:0]    cpu_d_bid_o;
    wire          cpu_d_arready_o;
    wire          cpu_d_rvalid_o;
    wire [31:0]   cpu_d_rdata_o;
    wire [1:0]    cpu_d_rresp_o;
    wire [3:0]    cpu_d_rid_o;
    wire          cpu_d_rlast_o;
    wire          spi_clk_o;
    wire          spi_mosi_o;
    wire          spi_cs_o;
    wire          uart_rxd_o;
    wire [31:0]   gpio_output_o;
    wire [31:0]   gpio_output_enable_o;

  
    soc uut (
     
        .clk_i(clk_i), .rst_i(rst_i),
        .inport_awvalid_i(inport_awvalid_i), .inport_awaddr_i(inport_awaddr_i),
        .inport_awid_i(inport_awid_i), .inport_awlen_i(inport_awlen_i),
        .inport_awburst_i(inport_awburst_i), .inport_wvalid_i(inport_wvalid_i),
        .inport_wdata_i(inport_wdata_i), .inport_wstrb_i(inport_wstrb_i),
        .inport_wlast_i(inport_wlast_i), .inport_bready_i(inport_bready_i),
        .inport_arvalid_i(inport_arvalid_i), .inport_araddr_i(inport_araddr_i),
        .inport_arid_i(inport_arid_i), .inport_arlen_i(inport_arlen_i),
        .inport_arburst_i(inport_arburst_i), .inport_rready_i(inport_rready_i),
        .mem_awready_i(mem_awready_i), .mem_wready_i(mem_wready_i),
        .mem_bvalid_i(mem_bvalid_i), .mem_bresp_i(mem_bresp_i), .mem_bid_i(mem_bid_i),
        .mem_arready_i(mem_arready_i), .mem_rvalid_i(mem_rvalid_i),
        .mem_rdata_i(mem_rdata_i), .mem_rresp_i(mem_rresp_i), .mem_rid_i(mem_rid_i),
        .mem_rlast_i(mem_rlast_i), .cpu_i_awvalid_i(cpu_i_awvalid_i),
        .cpu_i_awaddr_i(cpu_i_awaddr_i), .cpu_i_awid_i(cpu_i_awid_i),
        .cpu_i_awlen_i(cpu_i_awlen_i), .cpu_i_awburst_i(cpu_i_awburst_i),
        .cpu_i_wvalid_i(cpu_i_wvalid_i), .cpu_i_wdata_i(cpu_i_wdata_i),
        .cpu_i_wstrb_i(cpu_i_wstrb_i), .cpu_i_wlast_i(cpu_i_wlast_i),
        .cpu_i_bready_i(cpu_i_bready_i), .cpu_i_arvalid_i(cpu_i_arvalid_i),
        .cpu_i_araddr_i(cpu_i_araddr_i), .cpu_i_arid_i(cpu_i_arid_i),
        .cpu_i_arlen_i(cpu_i_arlen_i), .cpu_i_arburst_i(cpu_i_arburst_i),
        .cpu_i_rready_i(cpu_i_rready_i), .cpu_d_awvalid_i(cpu_d_awvalid_i),
        .cpu_d_awaddr_i(cpu_d_awaddr_i), .cpu_d_awid_i(cpu_d_awid_i),
        .cpu_d_awlen_i(cpu_d_awlen_i), .cpu_d_awburst_i(cpu_d_awburst_i),
        .cpu_d_wvalid_i(cpu_d_wvalid_i), .cpu_d_wdata_i(cpu_d_wdata_i),
        .cpu_d_wstrb_i(cpu_d_wstrb_i), .cpu_d_wlast_i(cpu_d_wlast_i),
        .cpu_d_bready_i(cpu_d_bready_i), .cpu_d_arvalid_i(cpu_d_arvalid_i),
        .cpu_d_araddr_i(cpu_d_araddr_i), .cpu_d_arid_i(cpu_d_arid_i),
        .cpu_d_arlen_i(cpu_d_arlen_i), .cpu_d_arburst_i(cpu_d_arburst_i),
        .cpu_d_rready_i(cpu_d_rready_i), .spi_miso_i(spi_miso_i),
        .uart_txd_i(uart_txd_i), .gpio_input_i(gpio_input_i),
        .intr_o(intr_o), .inport_awready_o(inport_awready_o),
        .inport_wready_o(inport_wready_o), .inport_bvalid_o(inport_bvalid_o),
        .inport_bresp_o(inport_bresp_o), .inport_bid_o(inport_bid_o),
        .inport_arready_o(inport_arready_o), .inport_rvalid_o(inport_rvalid_o),
        .inport_rdata_o(inport_rdata_o), .inport_rresp_o(inport_rresp_o),
        .inport_rid_o(inport_rid_o), .inport_rlast_o(inport_rlast_o),
        .mem_awvalid_o(mem_awvalid_o), .mem_awaddr_o(mem_awaddr_o),
        .mem_awid_o(mem_awid_o), .mem_awlen_o(mem_awlen_o),
        .mem_awburst_o(mem_awburst_o), .mem_wvalid_o(mem_wvalid_o),
        .mem_wdata_o(mem_wdata_o), .mem_wstrb_o(mem_wstrb_o),
        .mem_wlast_o(mem_wlast_o), .mem_bready_o(mem_bready_o),
        .mem_arvalid_o(mem_arvalid_o), .mem_araddr_o(mem_araddr_o),
        .mem_arid_o(mem_arid_o), .mem_arlen_o(mem_arlen_o),
        .mem_arburst_o(mem_arburst_o), .mem_rready_o(mem_rready_o),
        .cpu_i_awready_o(cpu_i_awready_o), .cpu_i_wready_o(cpu_i_wready_o),
        .cpu_i_bvalid_o(cpu_i_bvalid_o), .cpu_i_bresp_o(cpu_i_bresp_o),
        .cpu_i_bid_o(cpu_i_bid_o), .cpu_i_arready_o(cpu_i_arready_o),
        .cpu_i_rvalid_o(cpu_i_rvalid_o), .cpu_i_rdata_o(cpu_i_rdata_o),
        .cpu_i_rresp_o(cpu_i_rresp_o), .cpu_i_rid_o(cpu_i_rid_o),
        .cpu_i_rlast_o(cpu_i_rlast_o), .cpu_d_awready_o(cpu_d_awready_o),
        .cpu_d_wready_o(cpu_d_wready_o), .cpu_d_bvalid_o(cpu_d_bvalid_o),
        .cpu_d_bresp_o(cpu_d_bresp_o), .cpu_d_bid_o(cpu_d_bid_o),
        .cpu_d_arready_o(cpu_d_arready_o), .cpu_d_rvalid_o(cpu_d_rvalid_o),
        .cpu_d_rdata_o(cpu_d_rdata_o), .cpu_d_rresp_o(cpu_d_rresp_o),
        .cpu_d_rid_o(cpu_d_rid_o), .cpu_d_rlast_o(cpu_d_rlast_o),
        .spi_clk_o(spi_clk_o), .spi_mosi_o(spi_mosi_o), .spi_cs_o(spi_cs_o),
        .uart_rxd_o(uart_rxd_o), .gpio_output_o(gpio_output_o),
        .gpio_output_enable_o(gpio_output_enable_o)
    );

    // Clock Generation
    initial begin
        clk_i = 0;
        forever #10 clk_i = ~clk_i; 
    end

    // Initialization
    initial begin
        rst_i = 1;
        inport_awvalid_i = 0; inport_awaddr_i = 0; inport_awid_i = 0; inport_awlen_i = 0; inport_awburst_i = 0;
        inport_wvalid_i = 0; inport_wdata_i = 0; inport_wstrb_i = 0; inport_wlast_i = 0; inport_bready_i = 0;
        inport_arvalid_i = 0; inport_araddr_i = 0; inport_arid_i = 0; inport_arlen_i = 0; inport_arburst_i = 0;
        inport_rready_i = 0;
        mem_awready_i = 0; mem_wready_i = 0; mem_bvalid_i = 0; mem_bresp_i = 0; mem_bid_i = 0;
        mem_arready_i = 0; mem_rvalid_i = 0; mem_rdata_i = 0; mem_rresp_i = 0; mem_rid_i = 0; mem_rlast_i = 0;
        cpu_i_awvalid_i = 0; cpu_i_awaddr_i = 0; cpu_i_awid_i = 0; cpu_i_awlen_i = 0; cpu_i_awburst_i = 0;
        cpu_i_wvalid_i = 0; cpu_i_wdata_i = 0; cpu_i_wstrb_i = 0; cpu_i_wlast_i = 0; cpu_i_bready_i = 0;
        cpu_i_arvalid_i = 0; cpu_i_araddr_i = 0; cpu_i_arid_i = 0; cpu_i_arlen_i = 0; cpu_i_arburst_i = 0;
        cpu_i_rready_i = 0;
        cpu_d_awvalid_i = 0; cpu_d_awaddr_i = 0; cpu_d_awid_i = 0; cpu_d_awlen_i = 0; cpu_d_awburst_i = 0;
        cpu_d_wvalid_i = 0; cpu_d_wdata_i = 0; cpu_d_wstrb_i = 0; cpu_d_wlast_i = 0; cpu_d_bready_i = 0;
        cpu_d_arvalid_i = 0; cpu_d_araddr_i = 0; cpu_d_arid_i = 0; cpu_d_arlen_i = 0; cpu_d_arburst_i = 0;
        cpu_d_rready_i = 0;
        spi_miso_i = 1; uart_txd_i = 1; gpio_input_i = 32'h00000000;

        #40 rst_i = 0;
    end

    // AXI Write Task
    task axi_write;
        input [31:0] addr;
        input [31:0] data;
        input [1:0]  master_sel; // 0: inport, 1: cpu_i, 2: cpu_d
        begin
            case (master_sel)
                0: begin // inport
                    @(posedge clk_i);
                    inport_awvalid_i = 1;
                    inport_awaddr_i = addr;
                    inport_awid_i = 4'b0000;
                    inport_awlen_i = 8'h00;
                    inport_awburst_i = 2'b01;
                    inport_wvalid_i = 1;
                    inport_wdata_i = data;
                    inport_wstrb_i = 4'b1111;
                    inport_wlast_i = 1;
                    @(posedge clk_i);
                    wait(inport_awready_o && inport_wready_o);
                    @(posedge clk_i);
                    inport_awvalid_i = 0;
                    inport_wvalid_i = 0;
                    inport_wlast_i = 0;
                    inport_bready_i = 1;
                    wait(inport_bvalid_o);
                    @(posedge clk_i);
                    inport_bready_i = 0;
                end
                1: begin // cpu_i
                    @(posedge clk_i);
                    cpu_i_awvalid_i = 1;
                    cpu_i_awaddr_i = addr;
                    cpu_i_awid_i = 4'b1000;
                    cpu_i_awlen_i = 8'h00;
                    cpu_i_awburst_i = 2'b01;
                    cpu_i_wvalid_i = 1;
                    cpu_i_wdata_i = data;
                    cpu_i_wstrb_i = 4'b1111;
                    cpu_i_wlast_i = 1;
                    @(posedge clk_i);
                    wait(cpu_i_awready_o && cpu_i_wready_o);
                    @(posedge clk_i);
                    cpu_i_awvalid_i = 0;
                    cpu_i_wvalid_i = 0;
                    cpu_i_wlast_i = 0;
                    cpu_i_bready_i = 1;
                    wait(cpu_i_bvalid_o);
                    @(posedge clk_i);
                    cpu_i_bready_i = 0;
                end
                2: begin // cpu_d
                    @(posedge clk_i);
                    cpu_d_awvalid_i = 1;
                    cpu_d_awaddr_i = addr;
                    cpu_d_awid_i = 4'b0100;
                    cpu_d_awlen_i = 8'h00;
                    cpu_d_awburst_i = 2'b01;
                    cpu_d_wvalid_i = 1;
                    cpu_d_wdata_i = data;
                    cpu_d_wstrb_i = 4'b1111;
                    cpu_d_wlast_i = 1;
                    @(posedge clk_i);
                    wait(cpu_d_awready_o && cpu_d_wready_o);
                    @(posedge clk_i);
                    cpu_d_awvalid_i = 0;
                    cpu_d_wvalid_i = 0;
                    cpu_d_wlast_i = 0;
                    cpu_d_bready_i = 1;
                    wait(cpu_d_bvalid_o);
                    @(posedge clk_i);
                    cpu_d_bready_i = 0;
                end
            endcase
        end
    endtask
    
    task send_uart_byte(input [7:0] data);
        integer i;
        begin
            #8000 uart_txd_i = 0; // Start bit
            for (i = 0; i < 8; i = i + 1) begin
                #8000 uart_txd_i = data[i];
            end
            #8000 uart_txd_i = 1; // Stop bit
        end
    endtask

    // AXI Read Task
    task axi_read;
        input [31:0] addr;
        input [1:0]  master_sel; // 0: inport, 1: cpu_i, 2: cpu_d
        begin
            case (master_sel)
                0: begin // inport
                    @(posedge clk_i);
                    inport_arvalid_i = 1;
                    inport_araddr_i = addr;
                    inport_arid_i = 4'b0000;
                    inport_arlen_i = 8'h00;
                    inport_arburst_i = 2'b01;
                    @(posedge clk_i);
                    wait(inport_arready_o);
                    @(posedge clk_i);
                    inport_arvalid_i = 0;
                    inport_rready_i = 1;
                    wait(inport_rvalid_o);
                    @(posedge clk_i);
                    inport_rready_i = 0;
                end
                1: begin // cpu_i
                    @(posedge clk_i);
                    cpu_i_arvalid_i = 1;
                    cpu_i_araddr_i = addr;
                    cpu_i_arid_i = 4'b1010;
                    cpu_i_arlen_i = 8'h00;
                    cpu_i_arburst_i = 2'b01;
                    @(posedge clk_i);
                    wait(cpu_i_arready_o);
                    @(posedge clk_i);
                    cpu_i_arvalid_i = 0;
                    cpu_i_rready_i = 1;
                    wait(cpu_i_rvalid_o);
                    @(posedge clk_i);
                    cpu_i_rready_i = 0;
                end
                2: begin // cpu_d
                    @(posedge clk_i);
                    cpu_d_arvalid_i = 1;
                    cpu_d_araddr_i = addr;
                    cpu_d_arid_i = 4'b0110;
                    cpu_d_arlen_i = 8'h00;
                    cpu_d_arburst_i = 2'b01;
                    @(posedge clk_i);
                    wait(cpu_d_arready_o);
                    @(posedge clk_i);
                    cpu_d_arvalid_i = 0;
                    cpu_d_rready_i = 1;
                    wait(cpu_d_rvalid_o);
                    @(posedge clk_i);
                    cpu_d_rready_i = 0;
                end
            endcase
        end
    endtask
 
    initial begin
        #20; 

        //----------GPIO Testcases------------------------
        gpio_input_i = 32'h900000FF;

        // Read from GPIO
        #20;
        $display("reached 1");
        axi_read(32'h94000004, 1);
        #20;
        // Write to GPIO
        $display("reached 2");
        axi_write(32'h94000008, 32'h0000AAAA, 1);
        #20;
        // Read back from GPIO
        $display("reached 3");
        axi_read(32'h94000008, 1);
        #20;
        // Write to GPIO
        $display("reached 4");
        axi_write(32'h94000018, 32'h000A0A0A, 2);
        #20;
        // Read back from GPIO
        $display("reached 5");
        axi_read(32'h94000018, 2);
        #20;
        // Write to GPIO
        $display("reached 6");
        axi_write(32'h94000000, 32'h0000AAAA, 1);
        #20;
        // Write to GPIO
        $display("reached 7");
        axi_write(32'h94000008, 32'h0000AAAA, 0);
        $display("reached 8");
        $display("Finished the GPIO Testcases");
        #20;     
        
        //--------------SPI Test Cases----------------------------
        #20;
        $display("reached 9");
        axi_write(32'h93000060, 32'h000000C6, 1);  
        #20;
        $display("reached 10");
        axi_write(32'h93000068, 32'h000000AA, 0);
        #1800;
        $display("reached 11");
        axi_read(32'h9300006C, 1);
        $display("reached 12");
        $display("SPI TestCases Completed");
        #100;
        
        //-----------------Timer Test Cases-------------------------
        $display("reached 13");
        axi_write(32'h9100000C, 32'hFFFFFFF0, 0); // Timer0 Count
        #20;

        $display("reached 14");
        axi_write(32'h91000008, 32'h00000004, 2); // Timer0 Enable
        #20;

        $display("reached 15");
        axi_read(32'h91000008, 1); // Timer1 Count
        #20;

        $display("reached 16");
        axi_write(32'h91000014, 32'h00000004, 0); // Timer1 Enable
        #100; // Wait for timers to run

        $display("reached 17");
        axi_read(32'h9100000C, 0);
        #20;

        $display("reached 18");
        axi_read(32'h91000008, 0);
        #20;

        $display("reached 19");
        axi_read(32'h91000010, 0);
        #20;

        $display("reached 20");
        axi_read(32'h91000014, 0);
        #20;

        $display("reached 21");
        axi_read(32'h91000018, 1);
        #20;

        $display("reached 22");
        axi_read(32'h9100001C, 2);
        $display("Finished the Timer Testcases");
        
        //-----UART Testcases-------------------------------------------
        // 1. Enable UART Interrupt
        $display("UART: Enabling Interrupt");
        // Send UART byte (0xB5)
        send_uart_byte(8'hB5); // inport
        #40;

        // 2. Write Data to TX Register
        $display("UART: Writing 0xA5 to TX");
        axi_write(32'h92000004, 32'h00000055, 1); // Transmit 'A' via inport
        #40;

        // 3. Read Status Register (Check TXEMPTY)
        $display("UART: Reading Status (TXEMPTY)");
        axi_write(32'h9200000C, 32'h00000016, 0); // inport
        #40;
        
        axi_read(32'h92000008, 0);
        #40 axi_read(32'h92000000, 0);

       // 4. Simulate UART Data Reception
        $display("UART: Simulating RX Data (0x58)");
        uart_rx_transmit(8'h58); // Transmit 'X' to uart_txd_i
        #100;

        // 5. Read RX Register
        $display("UART: Reading RX Data");
        axi_read(ULITE_RX, 0); // inport
        #14000;
        
        $display("Testbench completed");
        $finish;
    end

endmodule
