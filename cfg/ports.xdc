### clock input

set_property IOSTANDARD LVCMOS18 [get_ports clk_i]

set_property PACKAGE_PIN E12 [get_ports clk_i]

### buttons

set_property IOSTANDARD LVCMOS18 [get_ports {btn_i[*]}]

set_property PACKAGE_PIN A12 [get_ports {btn_i[0]}]
set_property PACKAGE_PIN F12 [get_ports {btn_i[1]}]
set_property PACKAGE_PIN J12 [get_ports {btn_i[2]}]
set_property PACKAGE_PIN H12 [get_ports {btn_i[3]}]
set_property PACKAGE_PIN B10 [get_ports {btn_i[4]}]

### LED

set_property IOSTANDARD LVCMOS33 [get_ports {led_o[*]}]
set_property SLEW SLOW [get_ports {led_o[*]}]
set_property DRIVE 4 [get_ports {led_o[*]}]

set_property PACKAGE_PIN L14 [get_ports {led_o[0]}]
set_property PACKAGE_PIN L13 [get_ports {led_o[1]}]
set_property PACKAGE_PIN K14 [get_ports {led_o[2]}]
set_property PACKAGE_PIN J14 [get_ports {led_o[3]}]

### PMOD

set_property IOSTANDARD LVCMOS33 [get_ports {pmod_b_tri_io[*]}]

set_property PACKAGE_PIN AE13 [get_ports {pmod_b_tri_io[0]}]
set_property PACKAGE_PIN AG14 [get_ports {pmod_b_tri_io[1]}]
set_property PACKAGE_PIN AH14 [get_ports {pmod_b_tri_io[2]}]
set_property PACKAGE_PIN AG13 [get_ports {pmod_b_tri_io[3]}]
set_property PACKAGE_PIN AE14 [get_ports {pmod_b_tri_io[4]}]
set_property PACKAGE_PIN AF13 [get_ports {pmod_b_tri_io[5]}]
set_property PACKAGE_PIN AE15 [get_ports {pmod_b_tri_io[6]}]
set_property PACKAGE_PIN AH13 [get_ports {pmod_b_tri_io[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {pmod_c_tri_io[*]}]

set_property PACKAGE_PIN E13 [get_ports {pmod_c_tri_io[0]}]
set_property PACKAGE_PIN G13 [get_ports {pmod_c_tri_io[1]}]
set_property PACKAGE_PIN B13 [get_ports {pmod_c_tri_io[2]}]
set_property PACKAGE_PIN D14 [get_ports {pmod_c_tri_io[3]}]
set_property PACKAGE_PIN F13 [get_ports {pmod_c_tri_io[4]}]
set_property PACKAGE_PIN C13 [get_ports {pmod_c_tri_io[5]}]
set_property PACKAGE_PIN C14 [get_ports {pmod_c_tri_io[6]}]
set_property PACKAGE_PIN A13 [get_ports {pmod_c_tri_io[7]}]

### I2S

set_property IOSTANDARD LVCMOS18 [get_ports i2s_*]

set_property PACKAGE_PIN B11 [get_ports i2s_adc_data_i]
set_property PACKAGE_PIN C12 [get_ports i2s_bclk_o]
set_property PACKAGE_PIN D11 [get_ports i2s_dac_data_o]
set_property PACKAGE_PIN A10 [get_ports i2s_lrclk_o]
set_property PACKAGE_PIN C11 [get_ports i2s_mclk_o]

### SFP

set_property IOSTANDARD LVCMOS33 [get_ports sfp_*]

set_property PACKAGE_PIN AD14 [get_ports sfp_mod_abs_i]
set_property PACKAGE_PIN W14 [get_ports sfp_rx_los_i]
set_property PACKAGE_PIN AA13 [get_ports sfp_tx_fault_i]
set_property PACKAGE_PIN AB13 [get_ports sfp_tx_disable_o]
set_property PACKAGE_PIN W13 [get_ports {sfp_rs_o[0]}]
set_property PACKAGE_PIN Y14 [get_ports {sfp_rs_o[1]}]

### multiplexer

set_property IOSTANDARD LVCMOS18 [get_ports sel_sfp_o]

set_property PACKAGE_PIN D10 [get_ports sel_sfp_o]

### GTX

set_property PACKAGE_PIN Y6 [get_ports gtx_clk_p_i]
set_property PACKAGE_PIN Y5 [get_ports gtx_clk_n_i]
set_property PACKAGE_PIN P2 [get_ports gtx_rx_p_i]
set_property PACKAGE_PIN P1 [get_ports gtx_rx_n_i]
set_property PACKAGE_PIN N4 [get_ports gtx_tx_p_o]
set_property PACKAGE_PIN N3 [get_ports gtx_tx_n_o]

### ADC

set_property IOSTANDARD LVCMOS18 [get_ports {adc_data_i[*]}]

set_property PACKAGE_PIN AG11 [get_ports {adc_data_i[0]}] ;# S24
set_property PACKAGE_PIN AF12 [get_ports {adc_data_i[1]}] ;# S22
set_property PACKAGE_PIN AE7 [get_ports {adc_data_i[2]}] ;# D4N
set_property PACKAGE_PIN U8 [get_ports {adc_data_i[3]}] ;# D6P
set_property PACKAGE_PIN V8 [get_ports {adc_data_i[4]}] ;# D6N
set_property PACKAGE_PIN AE10 [get_ports {adc_data_i[5]}] ;# S16
set_property PACKAGE_PIN AF10 [get_ports {adc_data_i[6]}] ;# S18
set_property PACKAGE_PIN AF11 [get_ports {adc_data_i[7]}] ;# S20
set_property PACKAGE_PIN AC12 [get_ports {adc_data_i[8]}] ;# S17
set_property PACKAGE_PIN AD7 [get_ports {adc_data_i[9]}] ;# D4P
set_property PACKAGE_PIN AD12 [get_ports {adc_data_i[10]}] ;# S19
set_property PACKAGE_PIN AE12 [get_ports {adc_data_i[11]}] ;# S21
set_property PACKAGE_PIN AH12 [get_ports {adc_data_i[12]}] ;# S23
set_property PACKAGE_PIN AG10 [get_ports {adc_data_i[13]}] ;# S25

set_property IOSTANDARD LVCMOS18 [get_ports adc_dco_i]

set_property PACKAGE_PIN AD5 [get_ports adc_dco_i] ;# P2C_CLKP

set_property IOSTANDARD LVCMOS18 [get_ports {adc_spi_o[*]}]

set_property PACKAGE_PIN AE3 [get_ports {adc_spi_o[0]}] ;# D2P
set_property PACKAGE_PIN AF3 [get_ports {adc_spi_o[1]}] ;# D2N
set_property PACKAGE_PIN AH11 [get_ports {adc_spi_o[2]}] ;# S26

### CDCE GPIO

set_property IOSTANDARD LVCMOS18 [get_ports {cdce_gpio_tri_io[*]}]

set_property PACKAGE_PIN AE5 [get_ports {cdce_gpio_tri_io[0]}] ;# D3P
set_property PACKAGE_PIN AB1 [get_ports {cdce_gpio_tri_io[1]}] ;# D0P
set_property PACKAGE_PIN AF2 [get_ports {cdce_gpio_tri_io[2]}] ;# D1N
set_property PACKAGE_PIN AF5 [get_ports {cdce_gpio_tri_io[3]}] ;# D3N
set_property PACKAGE_PIN AG6 [get_ports {cdce_gpio_tri_io[4]}] ;# D5P

### CDCE IIC

set_property IOSTANDARD LVCMOS18 [get_ports {cdce_iic_tri_io[*]}]

set_property PACKAGE_PIN AC1 [get_ports {cdce_iic_tri_io[0]}] ;# D0N
set_property PACKAGE_PIN AE2 [get_ports {cdce_iic_tri_io[1]}] ;# D1P

### VADJ GPIO

set_property IOSTANDARD LVCMOS18 [get_ports {vadj_gpio_o[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vadj_gpio_o[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vadj_gpio_o[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vadj_pg_i}]

set_property PACKAGE_PIN G10 [get_ports {vadj_gpio_o[0]}] ;# VADJ_AUTON
set_property PACKAGE_PIN AC14 [get_ports {vadj_gpio_o[1]}] ;# VADJ_LEVEL0
set_property PACKAGE_PIN AC13 [get_ports {vadj_gpio_o[2]}] ;# VADJ_LEVEL1
set_property PACKAGE_PIN AA12 [get_ports {vadj_pg_i}]
