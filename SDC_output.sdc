## Generated SDC file "SDC_output.sdc"

## Copyright (C) 1991-2013 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Full Version"

## DATE    "Thu Jun 19 15:08:23 2014"

##
## DEVICE  "EP2AGX125EF35C4"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {altera_reserved_tck} -period 100.000 -waveform { 0.000 50.000 } [get_ports {altera_reserved_tck}]
create_clock -name {TofPet_clk_virt} -period 6.250 -waveform { 0.000 3.125 } 
create_clock -name {clkin_bot_p_virt} -period 10.000 -waveform { 0.000 5.000 } 
create_clock -name {ck2_virt} -period 20.000 -waveform { 0.000 10.000 } 
create_clock -name {clkin_bot_p} -period 10.000 -waveform { 0.000 5.000 } [get_ports {clkin_bot_p}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {tx_clk_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 5 -divide_by 4 -master_clock {clkin_bot_p} [get_pins {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]} -source [get_pins {tx_clk_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -divide_by 4 -master_clock {clkin_bot_p} [get_pins {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]} -source [get_pins {tx_clk_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -divide_by 40 -master_clock {clkin_bot_p} [get_pins {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]}] 
create_generated_clock -name {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {TofPetPll_Instance|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 8 -divide_by 5 -master_clock {clkin_bot_p} [get_pins {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[1]} -source [get_pins {TofPetPll_Instance|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -divide_by 10 -master_clock {clkin_bot_p} [get_pins {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[1]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {altera_reserved_tck}] -rise_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altera_reserved_tck}] -fall_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altera_reserved_tck}] -rise_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altera_reserved_tck}] -fall_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {clkin_bot_p}]  0.060  
set_clock_uncertainty -rise_from [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {clkin_bot_p}]  0.060  
set_clock_uncertainty -rise_from [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {TofPet_clk_virt}]  0.050  
set_clock_uncertainty -rise_from [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {TofPet_clk_virt}]  0.050  
set_clock_uncertainty -fall_from [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {clkin_bot_p}]  0.060  
set_clock_uncertainty -fall_from [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {clkin_bot_p}]  0.060  
set_clock_uncertainty -fall_from [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {TofPet_clk_virt}]  0.050  
set_clock_uncertainty -fall_from [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {TofPet_clk_virt}]  0.050  
set_clock_uncertainty -rise_from [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {TofPet_clk_virt}]  0.050  
set_clock_uncertainty -rise_from [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {TofPet_clk_virt}]  0.050  
set_clock_uncertainty -fall_from [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {TofPet_clk_virt}]  0.050  
set_clock_uncertainty -fall_from [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {TofPet_clk_virt}]  0.050  
set_clock_uncertainty -rise_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]}] -rise_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]}] -fall_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]}] -rise_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]}] -fall_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]}] -rise_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]}] -fall_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]}] -rise_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]}] -fall_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]}] -rise_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]}] -fall_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]}] -rise_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]}] -fall_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clkin_bot_p}] -rise_to [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[1]}]  0.060  
set_clock_uncertainty -rise_from [get_clocks {clkin_bot_p}] -fall_to [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[1]}]  0.060  
set_clock_uncertainty -rise_from [get_clocks {clkin_bot_p}] -rise_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]}]  0.060  
set_clock_uncertainty -rise_from [get_clocks {clkin_bot_p}] -fall_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]}]  0.060  
set_clock_uncertainty -rise_from [get_clocks {clkin_bot_p}] -rise_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.060  
set_clock_uncertainty -rise_from [get_clocks {clkin_bot_p}] -fall_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.060  
set_clock_uncertainty -rise_from [get_clocks {clkin_bot_p}] -rise_to [get_clocks {clkin_bot_p}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clkin_bot_p}] -fall_to [get_clocks {clkin_bot_p}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clkin_bot_p}] -rise_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.060  
set_clock_uncertainty -rise_from [get_clocks {clkin_bot_p}] -fall_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.060  
set_clock_uncertainty -fall_from [get_clocks {clkin_bot_p}] -rise_to [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[1]}]  0.060  
set_clock_uncertainty -fall_from [get_clocks {clkin_bot_p}] -fall_to [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[1]}]  0.060  
set_clock_uncertainty -fall_from [get_clocks {clkin_bot_p}] -rise_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]}]  0.060  
set_clock_uncertainty -fall_from [get_clocks {clkin_bot_p}] -fall_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]}]  0.060  
set_clock_uncertainty -fall_from [get_clocks {clkin_bot_p}] -rise_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.060  
set_clock_uncertainty -fall_from [get_clocks {clkin_bot_p}] -fall_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.060  
set_clock_uncertainty -fall_from [get_clocks {clkin_bot_p}] -rise_to [get_clocks {clkin_bot_p}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clkin_bot_p}] -fall_to [get_clocks {clkin_bot_p}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clkin_bot_p}] -rise_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.060  
set_clock_uncertainty -fall_from [get_clocks {clkin_bot_p}] -fall_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.060  
set_clock_uncertainty -rise_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[2]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {tx_clk_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {TofPet_clk_virt}] -rise_to [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[1]}]  0.050  
set_clock_uncertainty -rise_from [get_clocks {TofPet_clk_virt}] -fall_to [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[1]}]  0.050  
set_clock_uncertainty -fall_from [get_clocks {TofPet_clk_virt}] -rise_to [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[1]}]  0.050  
set_clock_uncertainty -fall_from [get_clocks {TofPet_clk_virt}] -fall_to [get_clocks {TofPetPll_Instance|altpll_component|auto_generated|pll1|clk[1]}]  0.050  


#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  3.750 [get_ports {hsma_rx_d_p[0]}]
set_input_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  0.500 [get_ports {hsma_rx_d_p[0]}]
set_input_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  3.750 [get_ports {hsma_rx_d_p[1]}]
set_input_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  0.500 [get_ports {hsma_rx_d_p[1]}]
set_input_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  3.750 [get_ports {hsma_rx_d_p[2]}]
set_input_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  0.500 [get_ports {hsma_rx_d_p[2]}]
set_input_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  3.750 [get_ports {hsma_rx_d_p[3]}]
set_input_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  0.500 [get_ports {hsma_rx_d_p[3]}]
set_input_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  3.750 [get_ports {hsma_rx_d_p[4]}]
set_input_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  0.500 [get_ports {hsma_rx_d_p[4]}]
set_input_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  3.750 [get_ports {hsma_rx_d_p[5]}]
set_input_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  0.500 [get_ports {hsma_rx_d_p[5]}]
set_input_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  3.750 [get_ports {hsma_rx_d_p[6]}]
set_input_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  0.500 [get_ports {hsma_rx_d_p[6]}]
set_input_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  3.750 [get_ports {hsma_rx_d_p[7]}]
set_input_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  0.500 [get_ports {hsma_rx_d_p[7]}]
set_input_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  3.750 [get_ports {hsma_rx_d_p[8]}]
set_input_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  0.500 [get_ports {hsma_rx_d_p[8]}]
set_input_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  3.750 [get_ports {hsma_rx_d_p[9]}]
set_input_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  0.500 [get_ports {hsma_rx_d_p[9]}]
set_input_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  3.750 [get_ports {hsma_rx_d_p[10]}]
set_input_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  0.500 [get_ports {hsma_rx_d_p[10]}]
set_input_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  3.750 [get_ports {hsma_rx_d_p[11]}]
set_input_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  0.500 [get_ports {hsma_rx_d_p[11]}]
set_input_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  3.750 [get_ports {hsma_rx_d_p[12]}]
set_input_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  0.500 [get_ports {hsma_rx_d_p[12]}]
set_input_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  3.750 [get_ports {hsma_rx_d_p[13]}]
set_input_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  0.500 [get_ports {hsma_rx_d_p[13]}]
set_input_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  3.750 [get_ports {hsma_rx_d_p[14]}]
set_input_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  0.500 [get_ports {hsma_rx_d_p[14]}]
set_input_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  3.750 [get_ports {hsma_rx_d_p[15]}]
set_input_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  0.500 [get_ports {hsma_rx_d_p[15]}]
set_input_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  3.750 [get_ports {hsma_rx_d_p[16]}]
set_input_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  0.500 [get_ports {hsma_rx_d_p[16]}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  1.750 [get_ports {hsma_tx_d_p[0]}]
set_output_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  -4.500 [get_ports {hsma_tx_d_p[0]}]
set_output_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  1.750 [get_ports {hsma_tx_d_p[1]}]
set_output_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  -4.500 [get_ports {hsma_tx_d_p[1]}]
set_output_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  1.750 [get_ports {hsma_tx_d_p[2]}]
set_output_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  -4.500 [get_ports {hsma_tx_d_p[2]}]
set_output_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  1.750 [get_ports {hsma_tx_d_p[3]}]
set_output_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  -4.500 [get_ports {hsma_tx_d_p[3]}]
set_output_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  1.750 [get_ports {hsma_tx_d_p[4]}]
set_output_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  -4.500 [get_ports {hsma_tx_d_p[4]}]
set_output_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  1.750 [get_ports {hsma_tx_d_p[5]}]
set_output_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  -4.500 [get_ports {hsma_tx_d_p[5]}]
set_output_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  1.750 [get_ports {hsma_tx_d_p[6]}]
set_output_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  -4.500 [get_ports {hsma_tx_d_p[6]}]
set_output_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  1.750 [get_ports {hsma_tx_d_p[7]}]
set_output_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  -4.500 [get_ports {hsma_tx_d_p[7]}]
set_output_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  1.750 [get_ports {hsma_tx_d_p[8]}]
set_output_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  -4.500 [get_ports {hsma_tx_d_p[8]}]
set_output_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  1.750 [get_ports {hsma_tx_d_p[9]}]
set_output_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  -4.500 [get_ports {hsma_tx_d_p[9]}]
set_output_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  1.750 [get_ports {hsma_tx_d_p[10]}]
set_output_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  -4.500 [get_ports {hsma_tx_d_p[10]}]
set_output_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  1.750 [get_ports {hsma_tx_d_p[11]}]
set_output_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  -4.500 [get_ports {hsma_tx_d_p[11]}]
set_output_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  1.750 [get_ports {hsma_tx_d_p[12]}]
set_output_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  -4.500 [get_ports {hsma_tx_d_p[12]}]
set_output_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  1.750 [get_ports {hsma_tx_d_p[13]}]
set_output_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  -4.500 [get_ports {hsma_tx_d_p[13]}]
set_output_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  1.750 [get_ports {hsma_tx_d_p[14]}]
set_output_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  -4.500 [get_ports {hsma_tx_d_p[14]}]
set_output_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  1.750 [get_ports {hsma_tx_d_p[15]}]
set_output_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  -4.500 [get_ports {hsma_tx_d_p[15]}]
set_output_delay -add_delay -max -clock [get_clocks {TofPet_clk_virt}]  1.750 [get_ports {hsma_tx_d_p[16]}]
set_output_delay -add_delay -min -clock [get_clocks {TofPet_clk_virt}]  -4.500 [get_ports {hsma_tx_d_p[16]}]


#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 


#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_registers {*|alt_jtag_atlantic:*|jupdate}] -to [get_registers {*|alt_jtag_atlantic:*|jupdate1*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|rdata[*]}] -to [get_registers {*|alt_jtag_atlantic*|td_shift[*]}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|read}] -to [get_registers {*|alt_jtag_atlantic:*|read1*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|read_req}] 
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|rvalid}] -to [get_registers {*|alt_jtag_atlantic*|td_shift[*]}]
set_false_path -from [get_registers {*|t_dav}] -to [get_registers {*|alt_jtag_atlantic:*|tck_t_dav}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|user_saw_rvalid}] -to [get_registers {*|alt_jtag_atlantic:*|rvalid0*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|wdata[*]}] -to [get_registers *]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|write}] -to [get_registers {*|alt_jtag_atlantic:*|write1*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|write_stalled}] -to [get_registers {*|alt_jtag_atlantic:*|t_ena*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|write_stalled}] -to [get_registers {*|alt_jtag_atlantic:*|t_pause*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|write_valid}] 
set_false_path -to [get_keepers {*altera_std_synchronizer:*|din_s1}]
set_false_path -to [get_registers {*altera_tse_a_fifo_24:*|wr_g_rptr*}]
set_false_path -to [get_registers {*altera_tse_a_fifo_24:*|rd_g_wptr*}]
set_false_path -to [get_registers {*altera_tse_a_fifo_34:*|wr_g_rptr*}]
set_false_path -from [get_registers {*altera_tse_clock_crosser:*|in_data_buffer*}] -to [get_registers {*altera_tse_clock_crosser:*|out_data_buffer*}]
set_false_path -to [get_pins -nocase -compatibility_mode {*|alt_rst_sync_uq1|altera_reset_synchronizer_int_chain*|clrn}]
set_false_path -from [get_registers {*|altera_tse_register_map:U_REG|command_config[9]}] -to [get_registers {*|altera_tse_mac_tx:U_TX|*}]
set_false_path -from [get_registers {*|altera_tse_register_map:U_REG|mac_0[*]}] -to [get_registers {*|altera_tse_mac_tx:U_TX|*}]
set_false_path -from [get_registers {*|altera_tse_register_map:U_REG|mac_1[*]}] -to [get_registers {*|altera_tse_mac_tx:U_TX|*}]
set_false_path -from [get_registers {*|altera_tse_register_map:U_REG|mac_0[*]}] -to [get_registers {*|altera_tse_mac_rx:U_RX|*}]
set_false_path -from [get_registers {*|altera_tse_register_map:U_REG|mac_1[*]}] -to [get_registers {*|altera_tse_mac_rx:U_RX|*}]
set_false_path -from [get_registers {*|altera_tse_register_map:U_REG|frm_length[*]}] -to [get_registers {*|altera_tse_mac_rx:U_RX|*}]
set_false_path -from [get_registers {*|altera_tse_register_map:U_REG|command_config[16]}] -to [get_registers {*|altera_tse_mac_tx:U_TX|*}]
set_false_path -from [get_registers {*|altera_tse_register_map:U_REG|command_config[17]}] -to [get_registers {*|altera_tse_mac_tx:U_TX|*}]
set_false_path -from [get_registers {*|altera_tse_register_map:U_REG|command_config[18]}] -to [get_registers {*|altera_tse_mac_tx:U_TX|*}]
set_false_path -from [get_registers {*|altera_tse_register_map:U_REG|smac_0*}] -to [get_registers {*|altera_tse_mac_tx:U_TX|*}]
set_false_path -from [get_registers {*|altera_tse_register_map:U_REG|smac_1*}] -to [get_registers {*|altera_tse_mac_tx:U_TX|*}]
set_false_path -from [get_registers {*|altera_tse_register_map:U_REG|smac_2*}] -to [get_registers {*|altera_tse_mac_tx:U_TX|*}]
set_false_path -from [get_registers {*|altera_tse_register_map:U_REG|smac_3*}] -to [get_registers {*|altera_tse_mac_tx:U_TX|*}]
set_false_path -from [get_registers {*|altera_tse_register_map:U_REG|smac_0*}] -to [get_registers {*|altera_tse_mac_rx:U_RX|*}]
set_false_path -from [get_registers {*|altera_tse_register_map:U_REG|smac_1*}] -to [get_registers {*|altera_tse_mac_rx:U_RX|*}]
set_false_path -from [get_registers {*|altera_tse_register_map:U_REG|smac_2*}] -to [get_registers {*|altera_tse_mac_rx:U_RX|*}]
set_false_path -from [get_registers {*|altera_tse_register_map:U_REG|smac_3*}] -to [get_registers {*|altera_tse_mac_rx:U_RX|*}]
set_false_path -from [get_registers {*|altera_tse_mac_rx:*|pause_quant_val*}] -to [get_registers {*|altera_tse_mac_tx:*|pause_latch*}]
set_false_path -from [get_registers {*|altera_tse_register_map:U_REG|pause_quant_reg*}] -to [get_registers {*|altera_tse_mac_tx:U_TX|*}]
set_false_path -from [get_registers {*|altera_tse_register_map:U_REG|holdoff_quant*}] -to [get_registers {*|altera_tse_mac_tx:U_TX|*}]
set_false_path -from [get_registers {*|altera_tse_register_map:U_REG|mac_0[*]}] -to [get_registers {*|altera_tse_magic_detection:U_MAGIC|*}]
set_false_path -from [get_registers {*|altera_tse_register_map:U_REG|mac_1[*]}] -to [get_registers {*|altera_tse_magic_detection:U_MAGIC|*}]
set_false_path -from [get_registers {*|altera_tse_register_map:U_REG|smac_0*}] -to [get_registers {*|altera_tse_magic_detection:U_MAGIC|*}]
set_false_path -from [get_registers {*|altera_tse_register_map:U_REG|smac_1*}] -to [get_registers {*|altera_tse_magic_detection:U_MAGIC|*}]
set_false_path -from [get_registers {*|altera_tse_register_map:U_REG|smac_2*}] -to [get_registers {*|altera_tse_magic_detection:U_MAGIC|*}]
set_false_path -from [get_registers {*|altera_tse_register_map:U_REG|smac_3*}] -to [get_registers {*|altera_tse_magic_detection:U_MAGIC|*}]
set_false_path -to [get_pins -nocase -compatibility_mode {*|altera_tse_reset_synchronizer:*|altera_tse_reset_synchronizer_chain*|clrn}]
set_false_path -from [get_keepers {*EthernetSystem_cpu:*|EthernetSystem_cpu_nios2_oci:the_EthernetSystem_cpu_nios2_oci|EthernetSystem_cpu_nios2_oci_break:the_EthernetSystem_cpu_nios2_oci_break|break_readreg*}] -to [get_keepers {*EthernetSystem_cpu:*|EthernetSystem_cpu_nios2_oci:the_EthernetSystem_cpu_nios2_oci|EthernetSystem_cpu_jtag_debug_module_wrapper:the_EthernetSystem_cpu_jtag_debug_module_wrapper|EthernetSystem_cpu_jtag_debug_module_tck:the_EthernetSystem_cpu_jtag_debug_module_tck|*sr*}]
set_false_path -from [get_keepers {*EthernetSystem_cpu:*|EthernetSystem_cpu_nios2_oci:the_EthernetSystem_cpu_nios2_oci|EthernetSystem_cpu_nios2_oci_debug:the_EthernetSystem_cpu_nios2_oci_debug|*resetlatch}] -to [get_keepers {*EthernetSystem_cpu:*|EthernetSystem_cpu_nios2_oci:the_EthernetSystem_cpu_nios2_oci|EthernetSystem_cpu_jtag_debug_module_wrapper:the_EthernetSystem_cpu_jtag_debug_module_wrapper|EthernetSystem_cpu_jtag_debug_module_tck:the_EthernetSystem_cpu_jtag_debug_module_tck|*sr[33]}]
set_false_path -from [get_keepers {*EthernetSystem_cpu:*|EthernetSystem_cpu_nios2_oci:the_EthernetSystem_cpu_nios2_oci|EthernetSystem_cpu_nios2_oci_debug:the_EthernetSystem_cpu_nios2_oci_debug|monitor_ready}] -to [get_keepers {*EthernetSystem_cpu:*|EthernetSystem_cpu_nios2_oci:the_EthernetSystem_cpu_nios2_oci|EthernetSystem_cpu_jtag_debug_module_wrapper:the_EthernetSystem_cpu_jtag_debug_module_wrapper|EthernetSystem_cpu_jtag_debug_module_tck:the_EthernetSystem_cpu_jtag_debug_module_tck|*sr[0]}]
set_false_path -from [get_keepers {*EthernetSystem_cpu:*|EthernetSystem_cpu_nios2_oci:the_EthernetSystem_cpu_nios2_oci|EthernetSystem_cpu_nios2_oci_debug:the_EthernetSystem_cpu_nios2_oci_debug|monitor_error}] -to [get_keepers {*EthernetSystem_cpu:*|EthernetSystem_cpu_nios2_oci:the_EthernetSystem_cpu_nios2_oci|EthernetSystem_cpu_jtag_debug_module_wrapper:the_EthernetSystem_cpu_jtag_debug_module_wrapper|EthernetSystem_cpu_jtag_debug_module_tck:the_EthernetSystem_cpu_jtag_debug_module_tck|*sr[34]}]
set_false_path -from [get_keepers {*EthernetSystem_cpu:*|EthernetSystem_cpu_nios2_oci:the_EthernetSystem_cpu_nios2_oci|EthernetSystem_cpu_nios2_ocimem:the_EthernetSystem_cpu_nios2_ocimem|*MonDReg*}] -to [get_keepers {*EthernetSystem_cpu:*|EthernetSystem_cpu_nios2_oci:the_EthernetSystem_cpu_nios2_oci|EthernetSystem_cpu_jtag_debug_module_wrapper:the_EthernetSystem_cpu_jtag_debug_module_wrapper|EthernetSystem_cpu_jtag_debug_module_tck:the_EthernetSystem_cpu_jtag_debug_module_tck|*sr*}]
set_false_path -from [get_keepers {*EthernetSystem_cpu:*|EthernetSystem_cpu_nios2_oci:the_EthernetSystem_cpu_nios2_oci|EthernetSystem_cpu_jtag_debug_module_wrapper:the_EthernetSystem_cpu_jtag_debug_module_wrapper|EthernetSystem_cpu_jtag_debug_module_tck:the_EthernetSystem_cpu_jtag_debug_module_tck|*sr*}] -to [get_keepers {*EthernetSystem_cpu:*|EthernetSystem_cpu_nios2_oci:the_EthernetSystem_cpu_nios2_oci|EthernetSystem_cpu_jtag_debug_module_wrapper:the_EthernetSystem_cpu_jtag_debug_module_wrapper|EthernetSystem_cpu_jtag_debug_module_sysclk:the_EthernetSystem_cpu_jtag_debug_module_sysclk|*jdo*}]
set_false_path -from [get_keepers {sld_hub:*|irf_reg*}] -to [get_keepers {*EthernetSystem_cpu:*|EthernetSystem_cpu_nios2_oci:the_EthernetSystem_cpu_nios2_oci|EthernetSystem_cpu_jtag_debug_module_wrapper:the_EthernetSystem_cpu_jtag_debug_module_wrapper|EthernetSystem_cpu_jtag_debug_module_sysclk:the_EthernetSystem_cpu_jtag_debug_module_sysclk|ir*}]
set_false_path -from [get_keepers {sld_hub:*|sld_shadow_jsm:shadow_jsm|state[1]}] -to [get_keepers {*EthernetSystem_cpu:*|EthernetSystem_cpu_nios2_oci:the_EthernetSystem_cpu_nios2_oci|EthernetSystem_cpu_nios2_oci_debug:the_EthernetSystem_cpu_nios2_oci_debug|monitor_go}]


#**************************************************************
# Set Multicycle Path
#**************************************************************

set_multicycle_path -setup -end -from [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_altsyncram_dpm_fifo:U_RTSM|altsyncram*}] -to [get_registers *] 5
set_multicycle_path -setup -end -from [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_retransmit_cntl:U_RETR|*}] -to [get_registers *] 5
set_multicycle_path -setup -end -from [get_registers *] -to [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_retransmit_cntl:U_RETR|*}] 5
set_multicycle_path -hold -end -from [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_altsyncram_dpm_fifo:U_RTSM|altsyncram*}] -to [get_registers *] 5
set_multicycle_path -hold -end -from [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_retransmit_cntl:U_RETR|*}] -to [get_registers *] 5
set_multicycle_path -hold -end -from [get_registers *] -to [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_retransmit_cntl:U_RETR|*}] 5


#**************************************************************
# Set Maximum Delay
#**************************************************************

set_max_delay -from [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|dout_reg_sft*}] -to [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_top_1geth:U_GETH|altera_tse_mac_tx:U_TX|*}] 7.000
set_max_delay -from [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|eop_sft*}] -to [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_top_1geth:U_GETH|altera_tse_mac_tx:U_TX|*}] 7.000
set_max_delay -from [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|sop_reg*}] -to [get_registers {*|altera_tse_top_w_fifo:U_MAC|altera_tse_top_1geth:U_GETH|altera_tse_mac_tx:U_TX|*}] 7.000


#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

