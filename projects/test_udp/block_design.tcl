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

# UDP

# Create util_vector_logic
cell xilinx.com:ip:util_vector_logic not_0 {
  C_SIZE 1
  C_OPERATION not
} {
  Op1 phy_0/user_tx_reset_0
}

# Create axis_udp
cell pavel-demin:user:axis_udp udp_0 {} {
  xgmii_rxc phy_0/rx_mii_c_0
  xgmii_rxd phy_0/rx_mii_d_0
  xgmii_txc phy_0/tx_mii_c_0
  xgmii_txd phy_0/tx_mii_d_0
  xgmii_clk phy_0/tx_mii_clk_0
  xgmii_rst phy_0/user_tx_reset_0
  aclk phy_0/tx_mii_clk_0
  aresetn not_0/Res
}

# HUB

# Create axis_hub
cell pavel-demin:user:axis_hub hub_0 {
  CFG_DATA_WIDTH 64
  STS_DATA_WIDTH 64
} {
  S_AXIS udp_0/M_AXIS
  aclk phy_0/tx_mii_clk_0
  aresetn not_0/Res
}

# LED

# Create port_slicer
cell pavel-demin:user:port_slicer slice_0 {
  DIN_WIDTH 64 DIN_FROM 3 DIN_TO 0
} {
  din hub_0/cfg_data
  dout led_o
}

# COUNTER

# Create port_slicer
cell pavel-demin:user:port_slicer slice_1 {
  DIN_WIDTH 64 DIN_FROM 0 DIN_TO 0
} {
  din hub_0/cfg_data
}

# Create axis_counter
cell pavel-demin:user:axis_counter cntr_0 {
  AXIS_TDATA_WIDTH 64
} {
  M_AXIS udp_0/S_AXIS
  aclk phy_0/tx_mii_clk_0
  aresetn slice_1/dout
}
