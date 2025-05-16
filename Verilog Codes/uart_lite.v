module uart_lite (
    input           clk_i,
    input           rst_i,
    // AXI-Lite Configuration Inputs
    input           cfg_awvalid_i,
    input  [31:0]   cfg_awaddr_i,
    input           cfg_wvalid_i,
    input  [31:0]   cfg_wdata_i,
    input  [3:0]    cfg_wstrb_i,
    input           cfg_bready_i,
    input           cfg_arvalid_i,
    input  [31:0]   cfg_araddr_i,
    input           cfg_rready_i,
    // UART Serial Input
    input           rx_i,
    // AXI-Lite Configuration Outputs
    output reg      cfg_awready_o,
    output reg      cfg_wready_o,
    output reg      cfg_bvalid_o,
    output reg [1:0] cfg_bresp_o,
    output reg      cfg_arready_o,
    output reg      cfg_rvalid_o,
    output reg [31:0] cfg_rdata_o,
    output reg [1:0] cfg_rresp_o,
    // UART Serial Output
    output reg      tx_o,
    output reg      intr_o
);

    // Internal Registers and Wires
    reg [7:0]  ulite_rx_reg;        // Holds received data
    reg [7:0]  ulite_tx_reg;        // Holds data to be transmitted
    reg [4:0]  ulite_status_reg;    // Holds status bits
    reg [4:0]  ulite_control_reg;   // Holds control bits
    
    // Define Control and Status Bit Fields
    `define ULITE_CONTROL_IE       4
    `define ULITE_CONTROL_RST_RX   1
    `define ULITE_CONTROL_RST_TX   0
    `define ULITE_STATUS_IE        4
    `define ULITE_STATUS_TXFULL    3
    `define ULITE_STATUS_TXEMPTY   2
    `define ULITE_STATUS_RXFULL    1
    `define ULITE_STATUS_RXVALID   0
    `define ULITE_RX       8'h00
    `define ULITE_TX       8'h04
    `define ULITE_STATUS   8'h08
    `define ULITE_CONTROL  8'h0C

    reg [2:0] tindex;
    reg       tcount;  
    reg [2:0] rindex;
    reg       rcount;
    reg txdone;
    reg rxdone;
    wire baud_clk;

    // AXI-Lite Write FSM States
    parameter [1:0] WRITE_IDLE = 2'b00;
    parameter [1:0] WRITE_DATA = 2'b01;
    parameter [1:0] WRITE_RESP = 2'b10;
    reg [1:0] write_state;

    // AXI-Lite Read FSM States
    parameter [1:0] READ_IDLE = 2'b00;
    parameter [1:0] READ_DATA = 2'b01;
    reg [1:0] read_state;

    // Input Synchronization
    reg rx_q;
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            rx_q <= 1'b1;
        end else begin
            rx_q <= rx_i;
        end
    end

    // AXI-Lite Write FSM (unchanged)
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            write_state <= WRITE_IDLE;
            cfg_awready_o <= 1'b0;
            cfg_wready_o <= 1'b0;
            cfg_bvalid_o <= 1'b0;
            cfg_bresp_o <= 2'b00;
            ulite_tx_reg <= 8'b0;
            ulite_status_reg <= 5'b00100;
            ulite_control_reg <= 5'b00000;
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
                    case (cfg_awaddr_i[7:0])
                        `ULITE_TX: begin
                            if (ulite_status_reg[`ULITE_STATUS_TXEMPTY]) begin
                                ulite_tx_reg <= cfg_wdata_i[7:0];
                                ulite_status_reg[`ULITE_STATUS_TXEMPTY] <= 1'b0;
                                ulite_status_reg[`ULITE_STATUS_TXFULL] <= 1'b1;
                                cfg_bresp_o <= 2'b00; // OKAY
                            end else begin
                                cfg_bresp_o <= 2'b10; // SLVERR
                            end
                        end
                        `ULITE_CONTROL: begin
                            ulite_control_reg <= cfg_wdata_i[4:0];
                            if (cfg_wdata_i[0]) begin // Reset TX
                                ulite_tx_reg <= 8'b0;
                                ulite_status_reg[`ULITE_STATUS_TXEMPTY] <= 1'b1;
                                ulite_status_reg[`ULITE_STATUS_TXFULL] <= 1'b0;
                            end
                            if (cfg_wdata_i[1]) // Reset RX
                                ulite_rx_reg <= 8'b0;
                            cfg_bresp_o <= 2'b00; // OKAY
                        end
                        default: cfg_bresp_o <= 2'b10; // SLVERR
                    endcase
                    cfg_bvalid_o <= 1'b1;
                    write_state <= WRITE_RESP;
                end
                WRITE_RESP: begin
                    if (cfg_bready_i) begin
                        cfg_bvalid_o <= 1'b0;
                        write_state <= WRITE_IDLE;
                    end
                end
            endcase
        end
    end

    // Corrected AXI-Lite Read FSM
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            read_state <= READ_IDLE;
            cfg_arready_o <= 1'b0;
            cfg_rvalid_o <= 1'b0;
            cfg_rdata_o <= 32'b0;
            cfg_rresp_o <= 2'b00;
            intr_o <= 1'b0;
        end else begin
            case (read_state)
                READ_IDLE: begin
                    if (cfg_arvalid_i) begin
                        cfg_arready_o <= 1'b1;
                        cfg_rvalid_o <= 1'b1;
                        read_state <= READ_DATA;
                        // Set data immediately based on address
                        case (cfg_araddr_i[7:0])
                            `ULITE_RX: cfg_rdata_o <= {24'b0, ulite_rx_reg};
                            `ULITE_STATUS: cfg_rdata_o <= {27'b0, ulite_status_reg};
                            `ULITE_CONTROL: cfg_rdata_o <= {27'b0, ulite_control_reg};
                            default: begin
                                cfg_rdata_o <= 32'b0;
                                cfg_rresp_o <= 2'b10; // SLVERR
                            end
                        endcase
                    end else begin
                        cfg_arready_o <= 1'b0;
                        cfg_rvalid_o <= 1'b0;
                        cfg_rdata_o <= 32'b0;
                        cfg_rresp_o <= 2'b00;
                    end
                end
                READ_DATA: begin
                    cfg_arready_o <= 1'b0;
                    if (cfg_rready_i) begin
                        // Update status only after successful read
                        if (cfg_araddr_i[7:0] == `ULITE_RX && ulite_status_reg[`ULITE_STATUS_RXFULL]) begin
                            ulite_status_reg[`ULITE_STATUS_RXFULL] <= 1'b0;
                            ulite_status_reg[`ULITE_STATUS_RXVALID] <= 1'b0;
                            intr_o <= 1'b0;
                        end
                        cfg_rvalid_o <= 1'b0;
                        cfg_rresp_o <= 2'b00; // OKAY
                        read_state <= READ_IDLE;
                    end
                end
            endcase
        end
    end

    // UART TX Shifting Process
    always @(posedge baud_clk or posedge rst_i) begin
        if (rst_i) begin
            tx_o <= 1'b1;
            tindex <= 3'd7;
            tcount <= 1'b0;
            txdone <= 1'b0;
        end else if (!ulite_status_reg[`ULITE_STATUS_TXEMPTY]) begin
            if (!tcount) begin
                tx_o <= 1'b0;    // Start bit
                tcount <= 1'b1;
            end else begin
                tx_o <= ulite_tx_reg[tindex];
                if (tindex == 3'd0) begin
                    txdone <= 1'b1;
                    tindex <= 3'd7;
                    tcount <= 1'b0;
                end else begin
                    tindex <= tindex - 1;
                end
            end
        end else if (txdone) begin
            tx_o <= 1'b1; // Stop bit
            txdone <= 1'b0;
            ulite_status_reg[`ULITE_STATUS_TXEMPTY] <= 1'b1;
            ulite_status_reg[`ULITE_STATUS_TXFULL] <= 1'b0;
        end
    end

    // UART RX Sampling Process
    always @(posedge baud_clk or posedge rst_i) begin
        if (rst_i) begin
            rcount <= 1'b0;
            rindex <= 3'd7;
            rxdone <= 1'b0;
            ulite_rx_reg <= 8'b0; // Ensure defined state on reset
        end else begin
            if (!rx_q && !rcount) begin
                rcount <= 1'b1;
            end else if (rcount && rindex > 0) begin
                ulite_rx_reg[rindex] <= rx_q;
                rindex <= rindex - 1;
            end else if (rcount && rindex == 0) begin
                ulite_rx_reg[0] <= rx_q;
                rcount <= 1'b0;
                rindex <= 3'd7;
                rxdone <= 1'b1;
                ulite_status_reg[`ULITE_STATUS_RXFULL] <= 1'b1;
                ulite_status_reg[`ULITE_STATUS_RXVALID] <= 1'b1;
                if (ulite_status_reg[`ULITE_STATUS_IE])
                    intr_o <= 1'b1;
            end else if (rxdone) begin
                rxdone <= 1'b0;
            end
        end
    end

    // Baud Rate Generator Instantiation
    baud_rate_gen #(
        .SYSTEM_CLK_FREQ(125_000_000),
        .OUT_CLK_FREQ(115200)
    ) u_baud (
        .clk(clk_i),
        .out_clk(baud_clk)
    );
endmodule