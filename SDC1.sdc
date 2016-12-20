set_time_format -unit ns -decimal_places 3

set TofPet_ck_period 6.25
set tSU_TofPet 2.5
set tH_TofPet 0.5
set tCO_TofPet 4.5

create_clock -name {TofPet_clk_virt} -period $TofPet_ck_period
create_clock -name {clkin_bot_p_virt} -period 10.0
create_clock -name {ck2_virt} -period 20.0

derive_pll_clocks -create_base_clocks
# derive_pll_clocks -use_tan_name

#**************************************************************
# Set Input Delay
#**************************************************************
set_input_delay -clock TofPet_clk_virt -max [expr $TofPet_ck_period - $tSU_TofPet] [get_ports {hsma_rx_d_p[*]}]
set_input_delay -clock TofPet_clk_virt -min $tH_TofPet [get_ports {hsma_rx_d_p[*]}]

#**************************************************************
# Set Output Delay
#**************************************************************
set_output_delay -clock TofPet_clk_virt -max [expr $TofPet_ck_period - $tCO_TofPet] [get_ports {hsma_tx_d_p[*]}]
set_output_delay -clock TofPet_clk_virt -min [expr -1 * $tCO_TofPet] [get_ports {hsma_tx_d_p[*]}]
