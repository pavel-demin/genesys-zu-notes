
`timescale 1 ns / 1 ps

module axis_udp
(
  input  wire        aclk,
  input  wire        aresetn,

  input  wire        xgmii_clk,
  input  wire        xgmii_rst,

  input  wire [7:0]  xgmii_rxc,
  input  wire [63:0] xgmii_rxd,

  output wire [7:0]  xgmii_txc,
  output wire [63:0] xgmii_txd,

  input  wire [63:0] s_axis_tdata,
  input  wire [7:0]  s_axis_tkeep,
  input  wire        s_axis_tuser,
  input  wire        s_axis_tlast,
  input  wire        s_axis_tvalid,
  output wire        s_axis_tready,

  output wire [63:0] m_axis_tdata,
  output wire [7:0]  m_axis_tkeep,
  output wire        m_axis_tuser,
  output wire        m_axis_tlast,
  output wire        m_axis_tvalid,
  input  wire        m_axis_tready
);
  // Configuration
  wire [47:0] local_mac = 48'h52_54_0A_01_01_70;
  wire [31:0] local_ip = {8'd10, 8'd1, 8'd1, 8'd112};
  wire [15:0] local_port = 16'd1234;
  wire [31:0] gateway_ip = {8'd10, 8'd1, 8'd1, 8'd1};
  wire [31:0] subnet_mask = {8'd255, 8'd255, 8'd255, 8'd0};

  wire [63:0] tx_fifo_tdata [1:0];
  wire [7:0] tx_fifo_tkeep [1:0];
  wire [1:0] tx_fifo_tuser;
  wire [1:0] tx_fifo_tlast;
  wire tx_fifo_tvalid, tx_fifo_tready;

  wire [63:0] rx_fifo_tdata [1:0];
  wire [7:0] rx_fifo_tkeep [1:0];
  wire [1:0] rx_fifo_tuser;
  wire [1:0] rx_fifo_tlast;
  wire rx_fifo_tvalid, rx_fifo_tready;

  wire [12:0] tx_fifo_count;
  wire [1:0] tx_fifo_empty, tx_fifo_full;
  wire [1:0] rx_fifo_empty, rx_fifo_full;

  // Ethernet frame between Ethernet modules and UDP stack
  wire rx_eth_hdr_ready;
  wire rx_eth_hdr_valid;
  wire [47:0] rx_eth_dest_mac;
  wire [47:0] rx_eth_src_mac;
  wire [15:0] rx_eth_type;
  wire [63:0] rx_eth_payload_axis_tdata;
  wire [7:0] rx_eth_payload_axis_tkeep;
  wire rx_eth_payload_axis_tvalid;
  wire rx_eth_payload_axis_tready;
  wire rx_eth_payload_axis_tlast;
  wire rx_eth_payload_axis_tuser;

  wire tx_eth_hdr_ready;
  wire tx_eth_hdr_valid;
  wire [47:0] tx_eth_dest_mac;
  wire [47:0] tx_eth_src_mac;
  wire [15:0] tx_eth_type;
  wire [63:0] tx_eth_payload_axis_tdata;
  wire [7:0] tx_eth_payload_axis_tkeep;
  wire tx_eth_payload_axis_tvalid;
  wire tx_eth_payload_axis_tready;
  wire tx_eth_payload_axis_tlast;
  wire tx_eth_payload_axis_tuser;

  // UDP frame connections
  wire rx_udp_hdr_valid;
  wire rx_udp_hdr_ready;
  wire [31:0] rx_udp_ip_source_ip;
  wire [15:0] rx_udp_dest_port;

  wire [63:0] rx_udp_payload_axis_tdata;
  wire rx_udp_payload_axis_tlast;
  wire rx_udp_payload_axis_tvalid;
  wire rx_udp_payload_axis_tready;

  wire tx_udp_hdr_valid;
  wire tx_udp_hdr_ready;

  wire [63:0] tx_udp_payload_axis_tdata;
  wire tx_udp_payload_axis_tlast;
  wire tx_udp_payload_axis_tvalid;
  wire tx_udp_payload_axis_tready;

  wire match = rx_udp_dest_port == local_port;

  wire rx_fifo_wren;

  wire tx_fifo_valid, tx_fifo_rden;

  reg match_reg = 1'b0;
  reg no_match_reg = 1'b1;

  reg [31:0] tx_udp_dest_ip_reg = 32'd0;
  reg [9:0] tx_fifo_cntr_reg = 10'd0;
  reg tx_udp_hdr_valid_reg = 1'b0;
  reg tx_udp_payload_valid_reg = 1'b0;

  always @(posedge xgmii_clk)
  begin
    if(xgmii_rst)
    begin
      tx_udp_dest_ip_reg <= 32'd0;
      match_reg <= 1'b0;
      no_match_reg <= 1'b1;
    end
    else if(rx_udp_hdr_valid)
    begin
      tx_udp_dest_ip_reg <= rx_udp_ip_source_ip;
      match_reg <= match;
      no_match_reg <= ~match;
    end
  end

  always @(posedge xgmii_clk)
  begin
    if(xgmii_rst)
    begin
      tx_udp_hdr_valid_reg <= 1'b0;
      tx_udp_payload_valid_reg <= 1'b0;
      tx_fifo_cntr_reg <= 10'd0;
    end
    else
    begin
      if(tx_fifo_valid)
      begin
        tx_udp_hdr_valid_reg <= 1'b1;
        tx_udp_payload_valid_reg <= 1'b1;
      end

      if(tx_udp_hdr_valid & tx_udp_hdr_ready)
      begin
        tx_udp_hdr_valid_reg <= 1'b0;
      end

      if(tx_fifo_rden)
      begin
        tx_fifo_cntr_reg <= tx_fifo_cntr_reg + 1'b1;
      end

      if(tx_udp_payload_axis_tready & tx_udp_payload_axis_tlast)
      begin
        tx_udp_payload_valid_reg <= 1'b0;
      end
    end
  end

  assign tx_fifo_valid = (tx_fifo_count > 1023) & ~tx_udp_payload_valid_reg;
  assign tx_udp_hdr_valid = tx_fifo_valid | tx_udp_hdr_valid_reg;
  assign tx_udp_payload_axis_tvalid = tx_fifo_valid | tx_udp_payload_valid_reg;

  assign tx_fifo_rden = tx_udp_payload_axis_tvalid & tx_udp_payload_axis_tready;
  assign tx_udp_payload_axis_tlast = &tx_fifo_cntr_reg;

  assign rx_udp_hdr_ready = 1'b1;

  assign rx_fifo_wren = rx_udp_payload_axis_tvalid & match_reg;
  assign rx_udp_payload_axis_tready = (~rx_fifo_full[1] & match_reg) | no_match_reg;

  axis_xgmii_rx_64 axis_xgmii_rx (
    .clk(xgmii_clk),
    .rst(xgmii_rst),
    .xgmii_rxd(xgmii_rxd),
    .xgmii_rxc(xgmii_rxc),
    .m_axis_tdata(rx_fifo_tdata[0]),
    .m_axis_tkeep(rx_fifo_tkeep[0]),
    .m_axis_tuser(rx_fifo_tuser[0]),
    .m_axis_tlast(rx_fifo_tlast[0]),
    .m_axis_tvalid(rx_fifo_tvalid),
    .ptp_ts(96'd0),
    .cfg_rx_enable(1'b1),
    .start_packet(),
    .error_bad_frame(),
    .error_bad_fcs()
  );

  xpm_fifo_sync #(
    .WRITE_DATA_WIDTH(74),
    .FIFO_WRITE_DEPTH(4096),
    .READ_DATA_WIDTH(74),
    .READ_MODE("fwft"),
    .FIFO_READ_LATENCY(0),
    .FIFO_MEMORY_TYPE("block"),
    .USE_ADV_FEATURES("0000")
  ) fifo_sync_rx (
    .rst(xgmii_rst),

    .full(rx_fifo_full[0]),
    .empty(rx_fifo_empty[0]),

    .wr_clk(xgmii_clk),
    .wr_en(rx_fifo_tvalid),
    .din({rx_fifo_tlast[0], rx_fifo_tuser[0], rx_fifo_tkeep[0], rx_fifo_tdata[0]}),

    .rd_en(rx_fifo_tready),
    .dout({rx_fifo_tlast[1], rx_fifo_tuser[1], rx_fifo_tkeep[1], rx_fifo_tdata[1]})
  );

  eth_axis_rx #(
    .DATA_WIDTH(64)
  ) eth_axis_rx_inst (
    .clk(xgmii_clk),
    .rst(xgmii_rst),
    // AXI input
    .s_axis_tdata(rx_fifo_tdata[1]),
    .s_axis_tkeep(rx_fifo_tkeep[1]),
    .s_axis_tuser(rx_fifo_tuser[1]),
    .s_axis_tlast(rx_fifo_tlast[1]),
    .s_axis_tvalid(~rx_fifo_empty[0]),
    .s_axis_tready(rx_fifo_tready),
    // Ethernet frame output
    .m_eth_hdr_valid(rx_eth_hdr_valid),
    .m_eth_hdr_ready(rx_eth_hdr_ready),
    .m_eth_dest_mac(rx_eth_dest_mac),
    .m_eth_src_mac(rx_eth_src_mac),
    .m_eth_type(rx_eth_type),
    .m_eth_payload_axis_tdata(rx_eth_payload_axis_tdata),
    .m_eth_payload_axis_tkeep(rx_eth_payload_axis_tkeep),
    .m_eth_payload_axis_tuser(rx_eth_payload_axis_tuser),
    .m_eth_payload_axis_tlast(rx_eth_payload_axis_tlast),
    .m_eth_payload_axis_tvalid(rx_eth_payload_axis_tvalid),
    .m_eth_payload_axis_tready(rx_eth_payload_axis_tready),
    // Status signals
    .busy(),
    .error_header_early_termination()
  );

  eth_axis_tx #(
    .DATA_WIDTH(64)
  ) eth_axis_tx_inst (
    .clk(xgmii_clk),
    .rst(xgmii_rst),
    // Ethernet frame input
    .s_eth_hdr_valid(tx_eth_hdr_valid),
    .s_eth_hdr_ready(tx_eth_hdr_ready),
    .s_eth_dest_mac(tx_eth_dest_mac),
    .s_eth_src_mac(tx_eth_src_mac),
    .s_eth_type(tx_eth_type),
    .s_eth_payload_axis_tdata(tx_eth_payload_axis_tdata),
    .s_eth_payload_axis_tkeep(tx_eth_payload_axis_tkeep),
    .s_eth_payload_axis_tuser(tx_eth_payload_axis_tuser),
    .s_eth_payload_axis_tlast(tx_eth_payload_axis_tlast),
    .s_eth_payload_axis_tvalid(tx_eth_payload_axis_tvalid),
    .s_eth_payload_axis_tready(tx_eth_payload_axis_tready),
    // AXI output
    .m_axis_tdata(tx_fifo_tdata[0]),
    .m_axis_tkeep(tx_fifo_tkeep[0]),
    .m_axis_tuser(tx_fifo_tuser[0]),
    .m_axis_tlast(tx_fifo_tlast[0]),
    .m_axis_tvalid(tx_fifo_tvalid),
    .m_axis_tready(~tx_fifo_full[0]),
    // Status signals
    .busy()
  );

  xpm_fifo_sync #(
    .WRITE_DATA_WIDTH(74),
    .FIFO_WRITE_DEPTH(4096),
    .READ_DATA_WIDTH(74),
    .READ_MODE("fwft"),
    .FIFO_READ_LATENCY(0),
    .FIFO_MEMORY_TYPE("block"),
    .USE_ADV_FEATURES("0000")
  ) fifo_sync_tx (
    .rst(xgmii_rst),

    .full(tx_fifo_full[0]),
    .empty(tx_fifo_empty[0]),

    .wr_clk(xgmii_clk),
    .wr_en(tx_fifo_tvalid),
    .din({tx_fifo_tlast[0], tx_fifo_tuser[0], tx_fifo_tkeep[0], tx_fifo_tdata[0]}),

    .rd_en(tx_fifo_tready),
    .dout({tx_fifo_tlast[1], tx_fifo_tuser[1], tx_fifo_tkeep[1], tx_fifo_tdata[1]})
  );

  axis_xgmii_tx_64 axis_xgmii_tx (
    .clk(xgmii_clk),
    .rst(xgmii_rst),
    .s_axis_tdata(tx_fifo_tdata[1]),
    .s_axis_tkeep(tx_fifo_tkeep[1]),
    .s_axis_tuser(tx_fifo_tuser[1]),
    .s_axis_tlast(tx_fifo_tlast[1]),
    .s_axis_tvalid(~tx_fifo_empty[0]),
    .s_axis_tready(tx_fifo_tready),
    .xgmii_txd(xgmii_txd),
    .xgmii_txc(xgmii_txc),
    .cfg_ifg(8'd12),
    .cfg_tx_enable(1'b1),
    .start_packet(),
    .error_underflow()
  );

  udp_complete_64 udp_complete_inst (
    .clk(xgmii_clk),
    .rst(xgmii_rst),
    // Ethernet frame input
    .s_eth_hdr_valid(rx_eth_hdr_valid),
    .s_eth_hdr_ready(rx_eth_hdr_ready),
    .s_eth_dest_mac(rx_eth_dest_mac),
    .s_eth_src_mac(rx_eth_src_mac),
    .s_eth_type(rx_eth_type),
    .s_eth_payload_axis_tdata(rx_eth_payload_axis_tdata),
    .s_eth_payload_axis_tkeep(rx_eth_payload_axis_tkeep),
    .s_eth_payload_axis_tuser(rx_eth_payload_axis_tuser),
    .s_eth_payload_axis_tlast(rx_eth_payload_axis_tlast),
    .s_eth_payload_axis_tvalid(rx_eth_payload_axis_tvalid),
    .s_eth_payload_axis_tready(rx_eth_payload_axis_tready),
    // Ethernet frame output
    .m_eth_hdr_valid(tx_eth_hdr_valid),
    .m_eth_hdr_ready(tx_eth_hdr_ready),
    .m_eth_dest_mac(tx_eth_dest_mac),
    .m_eth_src_mac(tx_eth_src_mac),
    .m_eth_type(tx_eth_type),
    .m_eth_payload_axis_tdata(tx_eth_payload_axis_tdata),
    .m_eth_payload_axis_tkeep(tx_eth_payload_axis_tkeep),
    .m_eth_payload_axis_tuser(tx_eth_payload_axis_tuser),
    .m_eth_payload_axis_tlast(tx_eth_payload_axis_tlast),
    .m_eth_payload_axis_tvalid(tx_eth_payload_axis_tvalid),
    .m_eth_payload_axis_tready(tx_eth_payload_axis_tready),
    // IP frame output
    .m_ip_hdr_ready(1'b1),
    .m_ip_payload_axis_tready(1'b1),
    // UDP frame input
    .s_udp_hdr_valid(tx_udp_hdr_valid),
    .s_udp_hdr_ready(tx_udp_hdr_ready),
    .s_udp_ip_dscp(6'd0),
    .s_udp_ip_ecn(2'd0),
    .s_udp_ip_ttl(8'd64),
    .s_udp_ip_source_ip(local_ip),
    .s_udp_ip_dest_ip(tx_udp_dest_ip_reg),
    .s_udp_source_port(local_port),
    .s_udp_dest_port(local_port),
    .s_udp_length(16'd8192),
    .s_udp_checksum(16'd0),
    .s_udp_payload_axis_tdata(tx_udp_payload_axis_tdata),
    .s_udp_payload_axis_tkeep(8'd255),
    .s_udp_payload_axis_tuser(1'b0),
    .s_udp_payload_axis_tlast(tx_udp_payload_axis_tlast),
    .s_udp_payload_axis_tvalid(tx_udp_payload_axis_tvalid),
    .s_udp_payload_axis_tready(tx_udp_payload_axis_tready),
    // UDP frame output
    .m_udp_hdr_valid(rx_udp_hdr_valid),
    .m_udp_hdr_ready(rx_udp_hdr_ready),
    .m_udp_eth_dest_mac(),
    .m_udp_eth_src_mac(),
    .m_udp_eth_type(),
    .m_udp_ip_version(),
    .m_udp_ip_ihl(),
    .m_udp_ip_dscp(),
    .m_udp_ip_ecn(),
    .m_udp_ip_length(),
    .m_udp_ip_identification(),
    .m_udp_ip_flags(),
    .m_udp_ip_fragment_offset(),
    .m_udp_ip_ttl(),
    .m_udp_ip_protocol(),
    .m_udp_ip_header_checksum(),
    .m_udp_ip_source_ip(rx_udp_ip_source_ip),
    .m_udp_ip_dest_ip(),
    .m_udp_source_port(),
    .m_udp_dest_port(rx_udp_dest_port),
    .m_udp_length(),
    .m_udp_checksum(),
    .m_udp_payload_axis_tdata(rx_udp_payload_axis_tdata),
    .m_udp_payload_axis_tkeep(),
    .m_udp_payload_axis_tuser(),
    .m_udp_payload_axis_tlast(rx_udp_payload_axis_tlast),
    .m_udp_payload_axis_tvalid(rx_udp_payload_axis_tvalid),
    .m_udp_payload_axis_tready(rx_udp_payload_axis_tready),
    // Configuration
    .local_mac(local_mac),
    .local_ip(local_ip),
    .gateway_ip(gateway_ip),
    .subnet_mask(subnet_mask),
    .clear_arp_cache(1'b0)
  );

  xpm_fifo_async #(
    .WRITE_DATA_WIDTH(64),
    .FIFO_WRITE_DEPTH(4096),
    .READ_DATA_WIDTH(64),
    .READ_MODE("fwft"),
    .FIFO_READ_LATENCY(0),
    .FIFO_MEMORY_TYPE("block"),
    .USE_ADV_FEATURES("0000"),
    .CDC_SYNC_STAGES(4)
  ) fifo_async_rx (
    .rst(xgmii_rst),

    .full(rx_fifo_full[1]),
    .empty(rx_fifo_empty[1]),

    .wr_clk(xgmii_clk),
    .wr_en(rx_fifo_wren),
    .din(rx_udp_payload_axis_tdata),

    .rd_clk(aclk),
    .rd_en(m_axis_tready),
    .dout(m_axis_tdata)
  );

  xpm_fifo_async #(
    .WRITE_DATA_WIDTH(64),
    .FIFO_WRITE_DEPTH(4096),
    .READ_DATA_WIDTH(64),
    .READ_MODE("fwft"),
    .FIFO_READ_LATENCY(0),
    .FIFO_MEMORY_TYPE("block"),
    .USE_ADV_FEATURES("0400"),
    .RD_DATA_COUNT_WIDTH(13),
    .CDC_SYNC_STAGES(4)
  ) fifo_async_tx (
    .rst(~aresetn),

    .full(tx_fifo_full[1]),
    .empty(tx_fifo_empty[1]),
    .rd_data_count(tx_fifo_count),

    .wr_clk(aclk),
    .wr_en(s_axis_tvalid),
    .din(s_axis_tdata),

    .rd_clk(xgmii_clk),
    .rd_en(tx_fifo_rden),
    .dout(tx_udp_payload_axis_tdata)
  );

  assign m_axis_tvalid = ~rx_fifo_empty[1];
  assign s_axis_tready = ~tx_fifo_full[1];

endmodule
