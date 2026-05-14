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

# Create util_vector_logic
cell xilinx.com:ip:util_vector_logic not_0 {
  C_SIZE 1
  C_OPERATION not
} {
  Op1 phy_0/user_tx_reset_0
}

# BSCAN

# Create axis_bscan
cell axis_bscan bscan_0 {} {
  aclk phy_0/tx_mii_clk_0
  aresetn not_0/Res
}

# HUB

# Create axis_hub_32
cell axis_hub_32 hub_0 {
  CFG_DATA_WIDTH 32
  STS_DATA_WIDTH 32
} {
  S_AXIS bscan_0/M_AXIS
  M_AXIS bscan_0/S_AXIS
  aclk phy_0/tx_mii_clk_0
  aresetn not_0/Res
}

# LED

# Create port_slicer
cell port_slicer slice_0 {
  DIN_WIDTH 32 DIN_FROM 2 DIN_TO 0
} {
  din hub_0/cfg_data
}

# Create c_counter_binary
cell xilinx.com:ip:c_counter_binary cntr_0 {
  OUTPUT_WIDTH 32
} {
  CLK phy_0/tx_mii_clk_0
}

# Create port_slicer
cell port_slicer slice_1 {
  DIN_WIDTH 32 DIN_FROM 25 DIN_TO 25
} {
  din cntr_0/Q
}

# Create xlconcat
cell xilinx.com:ip:xlconcat concat_0 {
  NUM_PORTS 2
  IN0_WIDTH 3
  IN1_WIDTH 1
} {
  In0 slice_0/dout
  In1 slice_1/dout
  dout led_o
}

# COUNTER

# Create axis_counter
cell axis_counter cntr_1 {
  AXIS_TDATA_WIDTH 32
} {
  M_AXIS hub_0/S00_AXIS
  aclk phy_0/tx_mii_clk_0
  aresetn not_0/Res
}

# FIFO

# Create axis_fifo
cell axis_fifo fifo_1 {
  S_AXIS_TDATA_WIDTH 32
  M_AXIS_TDATA_WIDTH 32
  WRITE_DEPTH 4096
} {
  S_AXIS hub_0/M01_AXIS
  M_AXIS hub_0/S01_AXIS
  aclk phy_0/tx_mii_clk_0
  aresetn not_0/Res
}

# BRAM

# Create blk_mem_gen
cell xilinx.com:ip:blk_mem_gen bram_0 {
  MEMORY_TYPE True_Dual_Port_RAM
  USE_BRAM_BLOCK Stand_Alone
  USE_BYTE_WRITE_ENABLE true
  BYTE_SIZE 8
  WRITE_WIDTH_A 32
  WRITE_DEPTH_A 131072
  REGISTER_PORTA_OUTPUT_OF_MEMORY_PRIMITIVES false
  REGISTER_PORTB_OUTPUT_OF_MEMORY_PRIMITIVES false
} {
  BRAM_PORTA hub_0/B02_BRAM
  BRAM_PORTB hub_0/B03_BRAM
}
