set_time_format -unit ns -decimal_places 3

set TofPet_ck_period 6.25
set Slow_ck_period 100.0
set tSU_TofPet 10.0
set tH_TofPet 1.5
set tCO_TofPet 1.5
set tCOslow_TofPet 20.0

create_clock -name {TofPet_clk_virt} -period $TofPet_ck_period
create_clock -name {Slow_clk_virt} -period $Slow_ck_period
create_clock -name {clkin_bot_p_virt} -period 10.0
create_clock -name {enet_gtx_clk_virt} -period 40.0

create_clock -name CLKIN_PARALLEL -period 10.0 [get_ports {clkin_bot_p}]
create_clock -name ENET_RX_CK -period 40.0 [get_ports {enet_rx_clk}]
create_clock -name CLKO_0 -period $TofPet_ck_period [get_ports {hsma_clk_in_p2}]
create_clock -name CLKO_1 -period $TofPet_ck_period [get_ports {hsma_rx_d_p[14]}]
create_clock -name CLKO_2 -period $TofPet_ck_period [get_ports {hsma_rx_d_p[11]}]
create_clock -name CLKO_3 -period $TofPet_ck_period [get_ports {hsma_clk_in_p1}]
create_clock -name CLKO_4 -period $TofPet_ck_period [get_ports {hsma_rx_d_p[6]}]
create_clock -name CLKO_5 -period $TofPet_ck_period [get_ports {hsma_rx_d_p[3]}]

derive_pll_clocks -create_base_clocks
# derive_pll_clocks -use_tan_name
derive_clock_uncertainty

#**************************************************************
# Set Input Delay
#**************************************************************
# ENET_RX
set_input_delay -clock ENET_RX_CK -max 3 [get_ports {enet_rx_d[*]}]
set_input_delay -clock ENET_RX_CK -min 0 [get_ports {enet_rx_d[*]}]
# ENET_RX_DV
set_input_delay -clock ENET_RX_CK -max 3 [get_ports {enet_rx_dv}]
set_input_delay -clock ENET_RX_CK -min 0 [get_ports {enet_rx_dv}]
# SDO
set_input_delay -clock Slow_clk_virt -max $tCOslow_TofPet [get_ports {hsma_rx_d_p[0]}]
set_input_delay -clock Slow_clk_virt -min 0 [get_ports {hsma_rx_d_p[0]}]
# TX0 on Test_Hybrid, TX0_5 on EndoProbe
set_input_delay -clock TofPet_clk_virt -max $tCO_TofPet [get_ports {hsma_rx_d_p[1]}]
set_input_delay -clock TofPet_clk_virt -min 0 [get_ports {hsma_rx_d_p[1]}]
# TX1 on Test_Hybrid, TX1_5 on EndoProbe
set_input_delay -clock TofPet_clk_virt -max $tCO_TofPet [get_ports {hsma_rx_d_p[2]}]
set_input_delay -clock TofPet_clk_virt -min 0 [get_ports {hsma_rx_d_p[2]}]
# TX0_4 on EndoProbe
set_input_delay -clock TofPet_clk_virt -max $tCO_TofPet [get_ports {hsma_rx_d_p[5]}]
set_input_delay -clock TofPet_clk_virt -min 0 [get_ports {hsma_rx_d_p[5]}]
# TX1_4 on EndoProbe
set_input_delay -clock TofPet_clk_virt -max $tCO_TofPet [get_ports {hsma_rx_d_p[4]}]
set_input_delay -clock TofPet_clk_virt -min 0 [get_ports {hsma_rx_d_p[4]}]
# TX0_3 on EndoProbe
set_input_delay -clock TofPet_clk_virt -max $tCO_TofPet [get_ports {hsma_rx_d_p[8]}]
set_input_delay -clock TofPet_clk_virt -min 0 [get_ports {hsma_rx_d_p[8]}]
# TX1_3 on EndoProbe
set_input_delay -clock TofPet_clk_virt -max $tCO_TofPet [get_ports {hsma_rx_d_p[10]}]
set_input_delay -clock TofPet_clk_virt -min 0 [get_ports {hsma_rx_d_p[10]}]
# TX0_2 on EndoProbe
set_input_delay -clock TofPet_clk_virt -max $tCO_TofPet [get_ports {hsma_rx_d_p[7]}]
set_input_delay -clock TofPet_clk_virt -min 0 [get_ports {hsma_rx_d_p[7]}]
# TX1_2 on EndoProbe
set_input_delay -clock TofPet_clk_virt -max $tCO_TofPet [get_ports {hsma_rx_d_p[9]}]
set_input_delay -clock TofPet_clk_virt -min 0 [get_ports {hsma_rx_d_p[9]}]
# TX0_1 on EndoProbe
set_input_delay -clock TofPet_clk_virt -max $tCO_TofPet [get_ports {hsma_rx_d_p[13]}]
set_input_delay -clock TofPet_clk_virt -min 0 [get_ports {hsma_rx_d_p[13]}]
# TX1_1 on EndoProbe
set_input_delay -clock TofPet_clk_virt -max $tCO_TofPet [get_ports {hsma_rx_d_p[12]}]
set_input_delay -clock TofPet_clk_virt -min 0 [get_ports {hsma_rx_d_p[12]}]
# TX0_0 on EndoProbe
set_input_delay -clock TofPet_clk_virt -max $tCO_TofPet [get_ports {hsma_rx_d_p[16]}]
set_input_delay -clock TofPet_clk_virt -min 0 [get_ports {hsma_rx_d_p[16]}]
# TX1_0 on EndoProbe
set_input_delay -clock TofPet_clk_virt -max $tCO_TofPet [get_ports {hsma_rx_d_p[15]}]
set_input_delay -clock TofPet_clk_virt -min 0 [get_ports {hsma_rx_d_p[15]}]


#**************************************************************
# Set Output Delay
#**************************************************************
# ENET_TX
set_output_delay -clock enet_gtx_clk_virt -max $tSU_TofPet [get_ports {enet_tx_d[*]}]
set_output_delay -clock enet_gtx_clk_virt -min $tH_TofPet [get_ports {enet_tx_d[*]}]
# ENET_TX_EN
set_output_delay -clock enet_gtx_clk_virt -max $tSU_TofPet [get_ports {enet_tx_en}]
set_output_delay -clock enet_gtx_clk_virt -min $tH_TofPet [get_ports {enet_tx_en}]
# SDI on Test_Hybrid, SCLK on EndoProbe
set_output_delay -clock Slow_clk_virt -max $tSU_TofPet [get_ports {hsma_tx_d_p[16]}]
set_output_delay -clock Slow_clk_virt -min $tH_TofPet [get_ports {hsma_tx_d_p[16]}]
# CS[5] on Test_Hybrid and EndoProbe
set_output_delay -clock Slow_clk_virt -max $tSU_TofPet [get_ports {hsma_tx_d_p[7]}]
set_output_delay -clock Slow_clk_virt -min $tH_TofPet [get_ports {hsma_tx_d_p[7]}]
# CS[4] on Test_Hybrid and EndoProbe
set_output_delay -clock Slow_clk_virt -max $tSU_TofPet [get_ports {hsma_tx_d_p[8]}]
set_output_delay -clock Slow_clk_virt -min $tH_TofPet [get_ports {hsma_tx_d_p[8]}]
# CS[3] on Test_Hybrid and EndoProbe
set_output_delay -clock Slow_clk_virt -max $tSU_TofPet [get_ports {hsma_tx_d_p[9]}]
set_output_delay -clock Slow_clk_virt -min $tH_TofPet [get_ports {hsma_tx_d_p[9]}]
# CS[2] on Test_Hybrid and EndoProbe
set_output_delay -clock Slow_clk_virt -max $tSU_TofPet [get_ports {hsma_tx_d_p[10]}]
set_output_delay -clock Slow_clk_virt -min $tH_TofPet [get_ports {hsma_tx_d_p[10]}]
# CS[1] on Test_Hybrid and EndoProbe
set_output_delay -clock Slow_clk_virt -max $tSU_TofPet [get_ports {hsma_tx_d_p[11]}]
set_output_delay -clock Slow_clk_virt -min $tH_TofPet [get_ports {hsma_tx_d_p[11]}]
# CS[0] on Test_Hybrid, SYBC_RST EndoProbe
set_output_delay -clock Slow_clk_virt -max $tSU_TofPet [get_ports {hsma_tx_d_p[14]}]
set_output_delay -clock Slow_clk_virt -min $tH_TofPet [get_ports {hsma_tx_d_p[14]}]
# TEST on Test_Hybrid, CS[0] on EndoProbe
set_output_delay -clock TofPet_clk_virt -max $tCO_TofPet [get_ports {hsma_tx_d_p[12]}]
set_output_delay -clock TofPet_clk_virt -min 0 [get_ports {hsma_tx_d_p[12]}]
# SYNC_RST on Test_Hybrid, TEST_PULSE on EndoProbe
set_output_delay -clock TofPet_clk_virt -max $tCO_TofPet [get_ports {hsma_tx_d_p[13]}]
set_output_delay -clock TofPet_clk_virt -min 0 [get_ports {hsma_tx_d_p[13]}]
# SCLK on Test_Hybrid, SDI on EndoProbe
set_output_delay -clock TofPet_clk_virt -max $tCO_TofPet [get_ports {hsma_tx_d_p[15]}]
set_output_delay -clock TofPet_clk_virt -min 0 [get_ports {hsma_tx_d_p[15]}]

set_max_delay -from * -to [get_ports {hsma_tx_d_p[16]}] 5.0
set_min_delay -from * -to [get_ports {hsma_tx_d_p[16]}] 0.0
