`timescale 1ns / 1ps



`define SPI_DGIER    8'h1c

    `define SPI_DGIER_GIE      31
    `define SPI_DGIER_GIE_DEFAULT    0
    `define SPI_DGIER_GIE_B          31
    `define SPI_DGIER_GIE_T          31
    `define SPI_DGIER_GIE_W          1
    `define SPI_DGIER_GIE_R          31:31

`define SPI_IPISR    8'h20

    `define SPI_IPISR_TX_EMPTY      2
    `define SPI_IPISR_TX_EMPTY_DEFAULT    0
    `define SPI_IPISR_TX_EMPTY_B          2
    `define SPI_IPISR_TX_EMPTY_T          2
    `define SPI_IPISR_TX_EMPTY_W          1
    `define SPI_IPISR_TX_EMPTY_R          2:2

`define SPI_IPIER    8'h28

    `define SPI_IPIER_TX_EMPTY      2
    `define SPI_IPIER_TX_EMPTY_DEFAULT    0
    `define SPI_IPIER_TX_EMPTY_B          2
    `define SPI_IPIER_TX_EMPTY_T          2
    `define SPI_IPIER_TX_EMPTY_W          1
    `define SPI_IPIER_TX_EMPTY_R          2:2

`define SPI_SRR    8'h40

    `define SPI_SRR_RESET_DEFAULT    0
    `define SPI_SRR_RESET_B          0
    `define SPI_SRR_RESET_T          31
    `define SPI_SRR_RESET_W          32
    `define SPI_SRR_RESET_R          31:0

`define SPI_CR    8'h60

    `define SPI_CR_LOOP      0
    `define SPI_CR_LOOP_DEFAULT    0
    `define SPI_CR_LOOP_B          0
    `define SPI_CR_LOOP_T          0
    `define SPI_CR_LOOP_W          1
    `define SPI_CR_LOOP_R          0:0

    `define SPI_CR_SPE      1
    `define SPI_CR_SPE_DEFAULT    0
    `define SPI_CR_SPE_B          1
    `define SPI_CR_SPE_T          1
    `define SPI_CR_SPE_W          1
    `define SPI_CR_SPE_R          1:1

    `define SPI_CR_MASTER      2
    `define SPI_CR_MASTER_DEFAULT    0
    `define SPI_CR_MASTER_B          2
    `define SPI_CR_MASTER_T          2
    `define SPI_CR_MASTER_W          1
    `define SPI_CR_MASTER_R          2:2

    `define SPI_CR_CPOL      3
    `define SPI_CR_CPOL_DEFAULT    0
    `define SPI_CR_CPOL_B          3
    `define SPI_CR_CPOL_T          3
    `define SPI_CR_CPOL_W          1
    `define SPI_CR_CPOL_R          3:3

    `define SPI_CR_CPHA      4
    `define SPI_CR_CPHA_DEFAULT    0
    `define SPI_CR_CPHA_B          4
    `define SPI_CR_CPHA_T          4
    `define SPI_CR_CPHA_W          1
    `define SPI_CR_CPHA_R          4:4

    `define SPI_CR_TXFIFO_RST      5
    `define SPI_CR_TXFIFO_RST_DEFAULT    0
    `define SPI_CR_TXFIFO_RST_B          5
    `define SPI_CR_TXFIFO_RST_T          5
    `define SPI_CR_TXFIFO_RST_W          1
    `define SPI_CR_TXFIFO_RST_R          5:5

    `define SPI_CR_RXFIFO_RST      6
    `define SPI_CR_RXFIFO_RST_DEFAULT    0
    `define SPI_CR_RXFIFO_RST_B          6
    `define SPI_CR_RXFIFO_RST_T          6
    `define SPI_CR_RXFIFO_RST_W          1
    `define SPI_CR_RXFIFO_RST_R          6:6

    `define SPI_CR_MANUAL_SS      7
    `define SPI_CR_MANUAL_SS_DEFAULT    0
    `define SPI_CR_MANUAL_SS_B          7
    `define SPI_CR_MANUAL_SS_T          7
    `define SPI_CR_MANUAL_SS_W          1
    `define SPI_CR_MANUAL_SS_R          7:7

    `define SPI_CR_TRANS_INHIBIT      8
    `define SPI_CR_TRANS_INHIBIT_DEFAULT    0
    `define SPI_CR_TRANS_INHIBIT_B          8
    `define SPI_CR_TRANS_INHIBIT_T          8
    `define SPI_CR_TRANS_INHIBIT_W          1
    `define SPI_CR_TRANS_INHIBIT_R          8:8

    `define SPI_CR_LSB_FIRST      9
    `define SPI_CR_LSB_FIRST_DEFAULT    0
    `define SPI_CR_LSB_FIRST_B          9
    `define SPI_CR_LSB_FIRST_T          9
    `define SPI_CR_LSB_FIRST_W          1
    `define SPI_CR_LSB_FIRST_R          9:9

`define SPI_SR    8'h64

    `define SPI_SR_RX_EMPTY      0
    `define SPI_SR_RX_EMPTY_DEFAULT    0
    `define SPI_SR_RX_EMPTY_B          0
    `define SPI_SR_RX_EMPTY_T          0
    `define SPI_SR_RX_EMPTY_W          1
    `define SPI_SR_RX_EMPTY_R          0:0

    `define SPI_SR_RX_FULL      1
    `define SPI_SR_RX_FULL_DEFAULT    0
    `define SPI_SR_RX_FULL_B          1
    `define SPI_SR_RX_FULL_T          1
    `define SPI_SR_RX_FULL_W          1
    `define SPI_SR_RX_FULL_R          1:1

    `define SPI_SR_TX_EMPTY      2
    `define SPI_SR_TX_EMPTY_DEFAULT    0
    `define SPI_SR_TX_EMPTY_B          2
    `define SPI_SR_TX_EMPTY_T          2
    `define SPI_SR_TX_EMPTY_W          1
    `define SPI_SR_TX_EMPTY_R          2:2

    `define SPI_SR_TX_FULL      3
    `define SPI_SR_TX_FULL_DEFAULT    0
    `define SPI_SR_TX_FULL_B          3
    `define SPI_SR_TX_FULL_T          3
    `define SPI_SR_TX_FULL_W          1
    `define SPI_SR_TX_FULL_R          3:3

`define SPI_DTR    8'h68

    `define SPI_DTR_DATA_DEFAULT    0
    `define SPI_DTR_DATA_B          0
    `define SPI_DTR_DATA_T          7
    `define SPI_DTR_DATA_W          8
    `define SPI_DTR_DATA_R          7:0

`define SPI_DRR    8'h6c

    `define SPI_DRR_DATA_DEFAULT    0
    `define SPI_DRR_DATA_B          0
    `define SPI_DRR_DATA_T          7
    `define SPI_DRR_DATA_W          8
    `define SPI_DRR_DATA_R          7:0

`define SPI_SSR    8'h70

    `define SPI_SSR_VALUE      0
    `define SPI_SSR_VALUE_DEFAULT    1
    `define SPI_SSR_VALUE_B          0
    `define SPI_SSR_VALUE_T          0
    `define SPI_SSR_VALUE_W          1
    `define SPI_SSR_VALUE_R          0:0

//-----------------------------------------------------------------
// Module:  SPI-Lite Peripheral (Xilinx IP emulation)
//-----------------------------------------------------------------
module spi_lite
(
    // Inputs
     input          clk_i
    ,input          rst_i
    ,input          cfg_awvalid_i
    ,input  [31:0]  cfg_awaddr_i
    ,input          cfg_wvalid_i
    ,input  [31:0]  cfg_wdata_i
    ,input  [3:0]   cfg_wstrb_i
    ,input          cfg_bready_i
    ,input          cfg_arvalid_i
    ,input  [31:0]  cfg_araddr_i
    ,input          cfg_rready_i
    ,input          spi_miso_i

    // Outputs
    ,output      reg   cfg_awready_o
    ,output      reg    cfg_wready_o
    ,output       reg  cfg_bvalid_o
    ,output [1:0]   cfg_bresp_o
    ,output      reg   cfg_arready_o
    ,output      reg   cfg_rvalid_o
    ,output  [31:0]  cfg_rdata_o
    ,output [1:0]   cfg_rresp_o
    ,output         spi_clk_o
    ,output         spi_mosi_o
    ,output        spi_cs_o
    ,output         intr_o
);

//-----------------------------------------------------------------
// Retime write data
//-----------------------------------------------------------------
reg [31:0] wr_data_q;

always @ (posedge clk_i)
if (rst_i)
    wr_data_q <= 32'b0;
else
    wr_data_q <= cfg_wdata_i;

//-----------------------------------------------------------------
// Request Logic
//-----------------------------------------------------------------
wire read_en_w,write_en_w;
assign read_en_w = cfg_arvalid_i & cfg_arready_o;
assign write_en_w = cfg_awvalid_i & cfg_awready_o;
// Default assignments
assign cfg_bresp_o   = 2'b00; // OKAY response
assign cfg_rresp_o   = 2'b00; // OKAY response

always @(*) begin
    if(rst_i)begin
        cfg_bvalid_o = 1'b0;
        cfg_rvalid_o = 1'b0;
        cfg_awready_o = 1'b0;
        cfg_wready_o  = 1'b0;
        cfg_arready_o = 1'b0;
    end 
    else begin
    cfg_awready_o = (cfg_awvalid_i & ~cfg_arvalid_i);
    cfg_wready_o  = cfg_wvalid_i;
    cfg_arready_o = cfg_arvalid_i;
    if (write_en_w) 
        cfg_bvalid_o = 1'b1;
    else 
        cfg_bvalid_o = 1'b0;
    if (read_en_w) 
        cfg_rvalid_o = 1'b1;
    else 
        cfg_rvalid_o = 1'b0;

    end
end


//-----------------------------------------------------------------
// Register spi_dgier
//-----------------------------------------------------------------
reg spi_dgier_wr_q;

always @ (posedge clk_i)
if (rst_i)
    spi_dgier_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_DGIER))
    spi_dgier_wr_q <= 1'b1;
else
    spi_dgier_wr_q <= 1'b0;

// spi_dgier_gie [internal]
reg        spi_dgier_gie_q;

always @ (posedge clk_i)
if (rst_i)
    spi_dgier_gie_q <= 1'd`SPI_DGIER_GIE_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_DGIER))
    spi_dgier_gie_q <= cfg_wdata_i[`SPI_DGIER_GIE_R];

wire        spi_dgier_gie_out_w = spi_dgier_gie_q;


//-----------------------------------------------------------------
// Register spi_ipisr
//-----------------------------------------------------------------
reg spi_ipisr_wr_q;

always @ (posedge clk_i)
if (rst_i)
    spi_ipisr_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_IPISR))
    spi_ipisr_wr_q <= 1'b1;
else
    spi_ipisr_wr_q <= 1'b0;

// spi_ipisr_tx_empty [external]
wire        spi_ipisr_tx_empty_out_w = wr_data_q[`SPI_IPISR_TX_EMPTY_R];


//-----------------------------------------------------------------
// Register spi_ipier
//-----------------------------------------------------------------
reg spi_ipier_wr_q;

always @ (posedge clk_i)
if (rst_i)
    spi_ipier_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_IPIER))
    spi_ipier_wr_q <= 1'b1;
else
    spi_ipier_wr_q <= 1'b0;

// spi_ipier_tx_empty [internal]
reg        spi_ipier_tx_empty_q;

always @ (posedge clk_i)
if (rst_i)
    spi_ipier_tx_empty_q <= 1'd`SPI_IPIER_TX_EMPTY_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_IPIER))
    spi_ipier_tx_empty_q <= cfg_wdata_i[`SPI_IPIER_TX_EMPTY_R];

wire        spi_ipier_tx_empty_out_w = spi_ipier_tx_empty_q;


//-----------------------------------------------------------------
// Register spi_srr
//-----------------------------------------------------------------
reg spi_srr_wr_q;

always @ (posedge clk_i)
if (rst_i)
    spi_srr_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_SRR))
    spi_srr_wr_q <= 1'b1;
else
    spi_srr_wr_q <= 1'b0;

// spi_srr_reset [auto_clr]
reg [31:0]  spi_srr_reset_q;

always @ (posedge clk_i)
if (rst_i)
    spi_srr_reset_q <= 32'd`SPI_SRR_RESET_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_SRR))
    spi_srr_reset_q <= cfg_wdata_i[`SPI_SRR_RESET_R];
else
    spi_srr_reset_q <= 32'd`SPI_SRR_RESET_DEFAULT;

wire [31:0]  spi_srr_reset_out_w = spi_srr_reset_q;


//-----------------------------------------------------------------
// Register spi_cr
//-----------------------------------------------------------------
reg spi_cr_wr_q;

always @ (posedge clk_i)
if (rst_i)
    spi_cr_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_CR))
    spi_cr_wr_q <= 1'b1;
else
    spi_cr_wr_q <= 1'b0;

// spi_cr_loop [internal]
reg        spi_cr_loop_q;

always @ (posedge clk_i)
if (rst_i)
    spi_cr_loop_q <= 1'd`SPI_CR_LOOP_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_CR))
    spi_cr_loop_q <= cfg_wdata_i[`SPI_CR_LOOP_R];

wire        spi_cr_loop_out_w = spi_cr_loop_q;


// spi_cr_spe [internal]
reg        spi_cr_spe_q;

always @ (posedge clk_i)
if (rst_i)
    spi_cr_spe_q <= 1'd`SPI_CR_SPE_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_CR))
    spi_cr_spe_q <= cfg_wdata_i[`SPI_CR_SPE_R];

wire        spi_cr_spe_out_w = spi_cr_spe_q;


// spi_cr_master [internal]
reg        spi_cr_master_q;

always @ (posedge clk_i)
if (rst_i)
    spi_cr_master_q <= 1'd`SPI_CR_MASTER_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_CR))
    spi_cr_master_q <= cfg_wdata_i[`SPI_CR_MASTER_R];

wire        spi_cr_master_out_w = spi_cr_master_q;


// spi_cr_cpol [internal]
reg        spi_cr_cpol_q;

always @ (posedge clk_i)
if (rst_i)
    spi_cr_cpol_q <= 1'd`SPI_CR_CPOL_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_CR))
    spi_cr_cpol_q <= cfg_wdata_i[`SPI_CR_CPOL_R];

wire        spi_cr_cpol_out_w = spi_cr_cpol_q;


// spi_cr_cpha [internal]
reg        spi_cr_cpha_q;

always @ (posedge clk_i)
if (rst_i)
    spi_cr_cpha_q <= 1'd`SPI_CR_CPHA_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_CR))
    spi_cr_cpha_q <= cfg_wdata_i[`SPI_CR_CPHA_R];

wire        spi_cr_cpha_out_w = spi_cr_cpha_q;


// spi_cr_txfifo_rst [auto_clr]
reg        spi_cr_txfifo_rst_q;

always @ (posedge clk_i)
if (rst_i)
    spi_cr_txfifo_rst_q <= 1'd`SPI_CR_TXFIFO_RST_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_CR))
    spi_cr_txfifo_rst_q <= cfg_wdata_i[`SPI_CR_TXFIFO_RST_R];
else
    spi_cr_txfifo_rst_q <= 1'd`SPI_CR_TXFIFO_RST_DEFAULT;

wire        spi_cr_txfifo_rst_out_w = spi_cr_txfifo_rst_q;


// spi_cr_rxfifo_rst [auto_clr]
reg        spi_cr_rxfifo_rst_q;

always @ (posedge clk_i)
if (rst_i)
    spi_cr_rxfifo_rst_q <= 1'd`SPI_CR_RXFIFO_RST_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_CR))
    spi_cr_rxfifo_rst_q <= cfg_wdata_i[`SPI_CR_RXFIFO_RST_R];
else
    spi_cr_rxfifo_rst_q <= 1'd`SPI_CR_RXFIFO_RST_DEFAULT;

wire        spi_cr_rxfifo_rst_out_w = spi_cr_rxfifo_rst_q;


// spi_cr_manual_ss [internal]
reg        spi_cr_manual_ss_q;

always @ (posedge clk_i)
if (rst_i)
    spi_cr_manual_ss_q <= 1'd`SPI_CR_MANUAL_SS_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_CR))
    spi_cr_manual_ss_q <= cfg_wdata_i[`SPI_CR_MANUAL_SS_R];

wire        spi_cr_manual_ss_out_w = spi_cr_manual_ss_q;


// spi_cr_trans_inhibit [internal]
reg        spi_cr_trans_inhibit_q;

always @ (posedge clk_i)
if (rst_i)
    spi_cr_trans_inhibit_q <= 1'd`SPI_CR_TRANS_INHIBIT_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_CR))
    spi_cr_trans_inhibit_q <= cfg_wdata_i[`SPI_CR_TRANS_INHIBIT_R];

wire        spi_cr_trans_inhibit_out_w = spi_cr_trans_inhibit_q;


// spi_cr_lsb_first [internal]
reg        spi_cr_lsb_first_q;

always @ (posedge clk_i)
if (rst_i)
    spi_cr_lsb_first_q <= 1'd`SPI_CR_LSB_FIRST_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_CR))
    spi_cr_lsb_first_q <= cfg_wdata_i[`SPI_CR_LSB_FIRST_R];

wire        spi_cr_lsb_first_out_w = spi_cr_lsb_first_q;


//-----------------------------------------------------------------
// Register spi_sr
//-----------------------------------------------------------------
reg spi_sr_wr_q;

always @ (posedge clk_i)
if (rst_i)
    spi_sr_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_SR))
    spi_sr_wr_q <= 1'b1;
else
    spi_sr_wr_q <= 1'b0;





//-----------------------------------------------------------------
// Register spi_dtr
//-----------------------------------------------------------------
reg spi_dtr_wr_q;

always @ (posedge clk_i)
if (rst_i)
    spi_dtr_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_DTR))
    spi_dtr_wr_q <= 1'b1;
else
    spi_dtr_wr_q <= 1'b0;

// spi_dtr_data [external]
wire [7:0]  spi_dtr_data_out_w = wr_data_q[`SPI_DTR_DATA_R];


//-----------------------------------------------------------------
// Register spi_drr
//-----------------------------------------------------------------
reg spi_drr_wr_q;

always @ (posedge clk_i)
if (rst_i)
    spi_drr_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_DRR))
    spi_drr_wr_q <= 1'b1;
else
    spi_drr_wr_q <= 1'b0;


//-----------------------------------------------------------------
// Register spi_ssr
//-----------------------------------------------------------------
reg spi_ssr_wr_q;

always @ (posedge clk_i)
if (rst_i)
    spi_ssr_wr_q <= 1'b0;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_SSR))
    spi_ssr_wr_q <= 1'b1;
else
    spi_ssr_wr_q <= 1'b0;

// spi_ssr_value [internal]
reg        spi_ssr_value_q;

always @ (posedge clk_i)
if (rst_i)
    spi_ssr_value_q <= 1'd`SPI_SSR_VALUE_DEFAULT;
else if (write_en_w && (cfg_awaddr_i[7:0] == `SPI_SSR))
    spi_ssr_value_q <= cfg_wdata_i[`SPI_SSR_VALUE_R];

wire        spi_ssr_value_out_w = spi_ssr_value_q;


wire        spi_ipisr_tx_empty_in_w;
wire        spi_sr_rx_empty_in_w;
wire        spi_sr_rx_full_in_w;
wire        spi_sr_tx_empty_in_w;
wire        spi_sr_tx_full_in_w;
wire [7:0]  spi_drr_data_in_w;


//-----------------------------------------------------------------
// Read mux
//-----------------------------------------------------------------
reg [31:0] data_r;

always @ *
begin
    data_r = 32'b0;

    case (cfg_araddr_i[7:0])

    `SPI_DGIER:
    begin
        data_r[`SPI_DGIER_GIE_R] = spi_dgier_gie_q;
    end
    `SPI_IPISR:
    begin
        data_r[`SPI_IPISR_TX_EMPTY_R] = spi_ipisr_tx_empty_in_w;
    end
    `SPI_IPIER:
    begin
        data_r[`SPI_IPIER_TX_EMPTY_R] = spi_ipier_tx_empty_q;
    end
    `SPI_SRR:
    begin
    end
    `SPI_CR:
    begin
        data_r[`SPI_CR_LOOP_R] = spi_cr_loop_q;
        data_r[`SPI_CR_SPE_R] = spi_cr_spe_q;
        data_r[`SPI_CR_MASTER_R] = spi_cr_master_q;
        data_r[`SPI_CR_CPOL_R] = spi_cr_cpol_q;
        data_r[`SPI_CR_CPHA_R] = spi_cr_cpha_q;
        data_r[`SPI_CR_MANUAL_SS_R] = spi_cr_manual_ss_q;
        data_r[`SPI_CR_TRANS_INHIBIT_R] = spi_cr_trans_inhibit_q;
        data_r[`SPI_CR_LSB_FIRST_R] = spi_cr_lsb_first_q;
    end
    `SPI_SR:
    begin
        data_r[`SPI_SR_RX_EMPTY_R] = spi_sr_rx_empty_in_w;
        data_r[`SPI_SR_RX_FULL_R] = spi_sr_rx_full_in_w;
        data_r[`SPI_SR_TX_EMPTY_R] = spi_sr_tx_empty_in_w;
        data_r[`SPI_SR_TX_FULL_R] = spi_sr_tx_full_in_w;
    end
    `SPI_DRR:
    begin
        data_r[`SPI_DRR_DATA_R] = spi_drr_data_in_w;
    end
    `SPI_SSR:
    begin
        data_r[`SPI_SSR_VALUE_R] = spi_ssr_value_q;
    end
    default :
        data_r = 32'b0;
    endcase
end

//-----------------------------------------------------------------
// RVALID
//-----------------------------------------------------------------


//-----------------------------------------------------------------
// Retime read response
//-----------------------------------------------------------------
reg [31:0] rd_data_q;

always @ (posedge clk_i)
if (rst_i)
    rd_data_q <= 32'b0;
else if (!cfg_rvalid_o || cfg_rready_i)
    rd_data_q <= data_r;

assign cfg_rdata_o = rd_data_q;
assign cfg_rresp_o = 2'b0;

//-----------------------------------------------------------------
// BVALID
//-----------------------------------------------------------------



wire spi_cr_rd_req_w = read_en_w & (cfg_araddr_i[7:0] == `SPI_CR);
wire spi_drr_rd_req_w = read_en_w & (cfg_araddr_i[7:0] == `SPI_DRR);

wire spi_ipisr_wr_req_w = spi_ipisr_wr_q;
wire spi_cr_wr_req_w = spi_cr_wr_q;
wire spi_dtr_wr_req_w = spi_dtr_wr_q;
wire spi_drr_wr_req_w = spi_drr_wr_q;

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
parameter [31:0] C_SCK_RATIO = 32'd2;

//-----------------------------------------------------------------
// TX FIFO
//-----------------------------------------------------------------
wire       sw_reset_w      = spi_srr_reset_out_w == 32'h0000000A;
wire       tx_fifo_flush_w = sw_reset_w | spi_cr_txfifo_rst_out_w;
wire       rx_fifo_flush_w = sw_reset_w | spi_cr_rxfifo_rst_out_w;

wire       tx_accept_w;
wire       tx_ready_w;
wire [7:0] tx_data_raw_w;
wire       tx_pop_w;

spi_lite_fifo
#(
    .WIDTH(8),
    .DEPTH(4),
    .ADDR_W(2)
)
u_tx_fifo
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .flush_i(tx_fifo_flush_w),

    .data_in_i(spi_dtr_data_out_w),
    .push_i(spi_dtr_wr_req_w),
    .accept_o(tx_accept_w),

    .pop_i(tx_pop_w),
    .data_out_o(tx_data_raw_w),
    .valid_o(tx_ready_w)
);

assign spi_sr_tx_empty_in_w = ~tx_ready_w;
assign spi_sr_tx_full_in_w  = ~tx_accept_w;

// Reverse order if LSB first
wire [7:0] tx_data_w = spi_cr_lsb_first_out_w ? 
    {
      tx_data_raw_w[0]
    , tx_data_raw_w[1]
    , tx_data_raw_w[2]
    , tx_data_raw_w[3]
    , tx_data_raw_w[4]
    , tx_data_raw_w[5]
    , tx_data_raw_w[6]
    , tx_data_raw_w[7]
    } : tx_data_raw_w;

//-----------------------------------------------------------------
// RX FIFO
//-----------------------------------------------------------------
wire       rx_accept_w;
wire       rx_ready_w;
wire [7:0] rx_data_w;
wire       rx_push_w;

spi_lite_fifo
#(
    .WIDTH(8),
    .DEPTH(4),
    .ADDR_W(2)
)
u_rx_fifo
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .flush_i(rx_fifo_flush_w),

    .data_in_i(rx_data_w),
    .push_i(rx_push_w),
    .accept_o(rx_accept_w),

    .pop_i(spi_drr_rd_req_w),
    .data_out_o(spi_drr_data_in_w),
    .valid_o(rx_ready_w)
);

assign spi_sr_rx_empty_in_w = ~rx_ready_w;
assign spi_sr_rx_full_in_w  = ~rx_accept_w;

//-----------------------------------------------------------------
// Configuration
//-----------------------------------------------------------------
wire [31:0]     clk_div_w = C_SCK_RATIO;

//-----------------------------------------------------------------
// Registers
//-----------------------------------------------------------------
reg   active_q;
reg [5:0] bit_count_q;
reg [7:0]   shift_reg_q;
reg [31:0]    clk_div_q;
reg   done_q;

// Xilinx placement pragmas:
//synthesis attribute IOB of spi_clk_q is "TRUE"
//synthesis attribute IOB of spi_mosi_q is "TRUE"
//synthesis attribute IOB of spi_cs_o is "TRUE"
reg   spi_clk_q;
reg   spi_mosi_q;

//-----------------------------------------------------------------
// Implementation
//-----------------------------------------------------------------
wire enable_w = spi_cr_spe_out_w & spi_cr_master_out_w & ~spi_cr_trans_inhibit_out_w;

// Something to do, SPI enabled...
wire start_w = enable_w & ~active_q & ~done_q & tx_ready_w;

// Loopback more or normal
wire miso_w = spi_cr_loop_out_w ? spi_mosi_o : spi_miso_i;

//-----------------------------------------------------------------
// SPI Clock Generator
//-----------------------------------------------------------------

wire clk_en_w;

spi_clock_gen spi_clk_en
(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .spi_start_i(start_w),
    .sw_reset_i(sw_reset_w),
    .clk_per_sclk_i(clk_div_w),
    .sclk_en_o(clk_en_w)
);

//-----------------------------------------------------------------
// Sample, Drive pulse generation
//-----------------------------------------------------------------
wire drive_r;
wire sample_r;

drvsamp_pulse_gen drv_samp
(
    .spi_start_i(start_w),
    .spi_cpha_i(spi_cr_cpha_out_w),
    .spi_active_i(active_q),
    .spi_bitcount(bit_count_q),
    .clk_en_i(clk_en_w),
    
    .drive_o(drive_r),
    .sample_o(sample_r)
);

//-----------------------------------------------------------------
// Shift register
//-----------------------------------------------------------------
always @ (posedge clk_i)
if (rst_i)
begin
    shift_reg_q    <= 8'b0;
    spi_clk_q      <= 1'b0;
    spi_mosi_q     <= 1'b0;
end
else
begin
    // SPI = RESET (or potentially update CPOL)
    if (sw_reset_w || (spi_cr_wr_req_w & !start_w))
    begin
        shift_reg_q    <= 8'b0;
        spi_clk_q      <= spi_cr_cpol_out_w;
    end
    // SPI = IDLE
    else if (start_w)
    begin
        spi_clk_q      <= spi_cr_cpol_out_w;

        // CPHA = 0
        if (drive_r)
        begin
            spi_mosi_q    <= tx_data_w[7];
            shift_reg_q   <= {tx_data_w[6:0], 1'b0};
        end
        // CPHA = 1
        else
            shift_reg_q   <= tx_data_w;
    end
    // SPI = ACTIVE
    else if (active_q && clk_en_w)
    begin
        // Toggle SPI clock output
        if (!spi_cr_loop_out_w)
            spi_clk_q <= ~spi_clk_q;

        // Drive MOSI
        if (drive_r)
        begin
            spi_mosi_q  <= shift_reg_q[7];
            shift_reg_q <= {shift_reg_q[6:0],1'b0};
        end
        // Sample MISO
        else if (sample_r)
            shift_reg_q[0] <= miso_w;
    end
end

//-----------------------------------------------------------------
// Bit counter
//-----------------------------------------------------------------
always @ (posedge clk_i)
if (rst_i)
begin
    bit_count_q    <= 6'b0;
    active_q       <= 1'b0;
    done_q         <= 1'b0;
end
else if (sw_reset_w)
begin
    bit_count_q    <= 6'b0;
    active_q       <= 1'b0;
    done_q         <= 1'b0;
end
else if (start_w)
begin
    bit_count_q    <= 6'b0;
    active_q       <= 1'b1;
    done_q         <= 1'b0;
end
else if (active_q && clk_en_w)
begin
    // End of SPI transfer reached
    if (bit_count_q == 6'd15)
    begin
        // Go back to IDLE active_q
        active_q  <= 1'b0;

        // Set transfer complete flags
        done_q   <= 1'b1;
    end
    // Increment cycle counter
    else 
        bit_count_q <= bit_count_q + 6'd1;
end
else
    done_q         <= 1'b0;

// Delayed done_q for FIFO level check
reg check_tx_level_q;
always @ (posedge clk_i)
if (rst_i)
    check_tx_level_q <= 1'b0;
else
    check_tx_level_q <= done_q;

// Interrupt
reg intr_q;

always @ (posedge clk_i)
if (rst_i)
    intr_q <= 1'b0;
else if (check_tx_level_q && spi_ipier_tx_empty_out_w && spi_ipisr_tx_empty_in_w)
    intr_q <= 1'b1;
else if (spi_ipisr_wr_req_w && spi_ipisr_tx_empty_out_w)
    intr_q <= 1'b0;

assign spi_ipisr_tx_empty_in_w = spi_sr_tx_empty_in_w;

//-----------------------------------------------------------------
// Assignments
//-----------------------------------------------------------------
assign spi_clk_o            = spi_clk_q;
assign spi_mosi_o           = spi_mosi_q;

// Reverse order if LSB first
assign rx_data_w = spi_cr_lsb_first_out_w ? 
    {
      shift_reg_q[0]
    , shift_reg_q[1]
    , shift_reg_q[2]
    , shift_reg_q[3]
    , shift_reg_q[4]
    , shift_reg_q[5]
    , shift_reg_q[6]
    , shift_reg_q[7]
    } : shift_reg_q;


assign rx_push_w            = done_q;
assign tx_pop_w             = done_q;

assign spi_cs_o             = spi_ssr_value_out_w;
assign intr_o               = spi_dgier_gie_out_w & intr_q;

endmodule

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------

module spi_lite_fifo
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
    parameter WIDTH   = 8,
    parameter DEPTH   = 4,
    parameter ADDR_W  = 2
)
//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    // Inputs
     input               clk_i
    ,input               rst_i
    ,input  [WIDTH-1:0]  data_in_i
    ,input               push_i
    ,input               pop_i
    ,input               flush_i

    // Outputs
    ,output [WIDTH-1:0]  data_out_o
    ,output              accept_o
    ,output              valid_o
);

//-----------------------------------------------------------------
// Local Params
//-----------------------------------------------------------------
localparam COUNT_W = ADDR_W + 1;

//-----------------------------------------------------------------
// Registers
//-----------------------------------------------------------------
reg [WIDTH-1:0]   ram_q[DEPTH-1:0];
reg [ADDR_W-1:0]  rd_ptr_q;
reg [ADDR_W-1:0]  wr_ptr_q;
reg [COUNT_W-1:0] count_q;

//-----------------------------------------------------------------
// Sequential
//-----------------------------------------------------------------
always @ (posedge clk_i)
if (rst_i)
begin
    count_q   <= {(COUNT_W) {1'b0}};
    rd_ptr_q  <= {(ADDR_W) {1'b0}};
    wr_ptr_q  <= {(ADDR_W) {1'b0}};
end
else if (flush_i)
begin
    count_q   <= {(COUNT_W) {1'b0}};
    rd_ptr_q  <= {(ADDR_W) {1'b0}};
    wr_ptr_q  <= {(ADDR_W) {1'b0}};
end
else
begin
    // Push
    if (push_i & accept_o)
    begin
        ram_q[wr_ptr_q] <= data_in_i;
        wr_ptr_q        <= wr_ptr_q + 1;
    end

    // Pop
    if (pop_i & valid_o)
        rd_ptr_q      <= rd_ptr_q + 1;

    // Count up
    if ((push_i & accept_o) & ~(pop_i & valid_o))
        count_q <= count_q + 1;
    // Count down
    else if (~(push_i & accept_o) & (pop_i & valid_o))
        count_q <= count_q - 1;
end

//-------------------------------------------------------------------
// Combinatorial
//-------------------------------------------------------------------
/* verilator lint_off WIDTH */
assign valid_o       = (count_q != 0);
assign accept_o      = (count_q != DEPTH);
/* verilator lint_on WIDTH */

assign data_out_o    = ram_q[rd_ptr_q];



endmodule

/*
SPI clock generator to derive the spi_clk_o from clk_i. The job of this is to set an enable each time the spi_clk_o
must be toggled.
*/
module spi_clock_gen 
// Ports
(
    // Inputs
     input wire clk_i
    ,input wire rst_i
    ,input wire spi_start_i
    ,input wire sw_reset_i
    ,input wire [31:0] clk_per_sclk_i
    // Outputs
    ,output wire sclk_en_o
);
    // when counter reaches 0, spi_clk must be toggled, so this sets an enable bit to enact this task in the shift register module
    reg [31:0] down_counter;
    
    always @ (posedge clk_i)
        // Reset the counter to 0 if a reset input is given --
        if (rst_i)
            down_counter <= 32'd0;
        // In the case of a software reset, a pending SPI start, or during an active spi, if the counter comes down to 0, set the downcounter to its initial value.
        else if (spi_start_i || sw_reset_i || down_counter == 32'd0)
            down_counter <= clk_per_sclk_i;
        else
            down_counter <= down_counter - 32'd1;
     
    
    assign sclk_en_o = (down_counter == 32'd0);
 
endmodule    

/*
We utilize a single shift register. This register must know when to sample the MISO line, and when to load its value
on to the MOSI line. This is controlled by DRIVE and SAMPLE pulses generated by the block below.
*/
module drvsamp_pulse_gen
(
    //Inputs
     input wire        spi_start_i // When SPI is idle, spi_start determines initialization of drive and sample bits. 
    ,input wire        spi_cpha_i // CPHA determines whether we sample on the first clock edge (CPHA = 0) or the second edge (CPHA = 1)
    ,input wire        spi_active_i // When SPI is active, we deal with it differently.
    ,input wire [5:0]  spi_bitcount
    ,input wire        clk_en_i
    //Outputs
    ,output wire       drive_o
    ,output wire       sample_o
); 
    reg sample;
    reg drive;  
    
    always @ *
    begin
        sample = 1'b0;
        drive = 1'b0;
        
        // SPI IDLE
        if (spi_start_i)
            drive = ~spi_cpha_i; // Initial Data to drive
        // SPI ACTIVE
        else if (spi_active_i && clk_en_i)
        begin
            // First check if we have to sample
            // CPHA = 0 --> sampling on first edge, driving on second
            // CPHA = 1 --> sampling on second edge, driving on third
            if (spi_bitcount[0] == spi_cpha_i)
                sample = 1'b1;
            // Drive (CPHA = 1)
            else if (spi_cpha_i)
                drive = 1'b1;
            // Drive (CPHA = 0). Don't drive at the start and end of transmission
            else
                drive = (spi_bitcount != 6'd0) && (spi_bitcount != 6'd15);
         end
    end
    
    assign drive_o = drive;
    assign sample_o = sample;
         
endmodule       
     
        
    