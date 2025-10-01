# PHY

# Create xlconstant
cell xilinx.com:ip:xlconstant const_0

# Create xlconstant
cell xilinx.com:ip:xlconstant const_1 {
  CONST_WIDTH 1
  CONST_VAL 0
}

# Create xlconstant
cell xilinx.com:ip:xlconstant const_2 {
  CONST_WIDTH 3
  CONST_VAL 5
}

wire sel_sfp_o const_0/dout
wire sfp_tx_disable_o const_1/dout

# Create xxv_ethernet
cell xilinx.com:ip:xxv_ethernet phy_0 {
  BASE_R_KR BASE-R
  CORE {Ethernet PCS/PMA 64-bit}
  GT_DRP_CLK.VALUE_SRC USER
  GT_DRP_CLK 156.25
} {
  gt_rxp_in_0 gtx_rx_p_i
  gt_rxn_in_0 gtx_rx_n_i
  gt_txp_out_0 gtx_tx_p_o
  gt_txn_out_0 gtx_tx_n_o
  gt_refclk_p gtx_clk_p_i
  gt_refclk_n gtx_clk_n_i
  rxoutclksel_in_0 const_2/dout
  txoutclksel_in_0 const_2/dout
  rx_core_clk_0 phy_0/tx_mii_clk_0
  dclk phy_0/gt_refclk_out
}

# LED

# Create c_counter_binary
cell xilinx.com:ip:c_counter_binary cntr_0 {
  OUTPUT_WIDTH 32
} {
  CLK phy_0/tx_mii_clk_0
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_0 {
  DIN_WIDTH 32 DIN_FROM 26 DIN_TO 26
} {
  din cntr_0/Q
  dout led_o
}
