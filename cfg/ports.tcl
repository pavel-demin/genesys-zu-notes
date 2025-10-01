### clock input
create_bd_port -dir I clk_i
set_property CONFIG.FREQ_HZ 25000000 [get_bd_ports clk_i]

### buttons
create_bd_port -dir I -from 4 -to 0 btn_i

### LED
create_bd_port -dir O -from 3 -to 0 led_o

### PMOD

create_bd_port -dir IO -from 7 -to 0 pmod_b_tri_io
create_bd_port -dir IO -from 7 -to 0 pmod_c_tri_io

### I2S

create_bd_port -dir I i2s_adc_data_i
create_bd_port -dir O i2s_bclk_o
create_bd_port -dir O i2s_dac_data_o
create_bd_port -dir O i2s_lrclk_o
create_bd_port -dir O i2s_mclk_o

### SFP

create_bd_port -dir I sfp_mod_abs_i
create_bd_port -dir I sfp_rx_los_i
create_bd_port -dir I sfp_tx_fault_i

create_bd_port -dir O sfp_tx_disable_o
create_bd_port -dir O -from 1 -to 0 sfp_rs_o

### multiplexer

create_bd_port -dir O sel_sfp_o

### GTX

create_bd_port -dir I gtx_clk_p_i
create_bd_port -dir I gtx_clk_n_i

create_bd_port -dir I gtx_rx_p_i
create_bd_port -dir I gtx_rx_n_i

create_bd_port -dir O gtx_tx_p_o
create_bd_port -dir O gtx_tx_n_o

### ADC

create_bd_port -dir I -from 13 -to 0 adc_data_i

create_bd_port -dir I adc_dco_i

create_bd_port -dir O -from 2 -to 0 adc_spi_o

create_bd_port -dir IO -from 4 -to 0 cdce_gpio_tri_io

create_bd_port -dir IO -from 1 -to 0 cdce_iic_tri_io

### VADJ GPIO

create_bd_port -dir O -from 2 -to 0 vadj_gpio_o
create_bd_port -dir I vadj_pg_i
