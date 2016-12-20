# Legal Notice: (C)2014 Altera Corporation. All rights reserved.  Your
# use of Altera Corporation's design tools, logic functions and other
# software and tools, and its AMPP partner logic functions, and any
# output files any of the foregoing (including device programming or
# simulation files), and any associated documentation or information are
# expressly subject to the terms and conditions of the Altera Program
# License Subscription Agreement or other applicable license agreement,
# including, without limitation, that your use is for the sole purpose
# of programming logic devices manufactured by Altera and sold by Altera
# or its authorized distributors.  Please refer to the applicable
# agreement for further details.

#**************************************************************
# Timequest JTAG clock definition
#   Uncommenting the following lines will define the JTAG
#   clock in TimeQuest Timing Analyzer
#**************************************************************

#create_clock -period 10MHz {altera_reserved_tck}
#set_clock_groups -asynchronous -group {altera_reserved_tck}

#**************************************************************
# Set TCL Path Variables 
#**************************************************************

set 	EthernetSystem_nios2_Processor 	EthernetSystem_nios2_Processor:*
set 	EthernetSystem_nios2_Processor_oci 	EthernetSystem_nios2_Processor_nios2_oci:the_EthernetSystem_nios2_Processor_nios2_oci
set 	EthernetSystem_nios2_Processor_oci_break 	EthernetSystem_nios2_Processor_nios2_oci_break:the_EthernetSystem_nios2_Processor_nios2_oci_break
set 	EthernetSystem_nios2_Processor_ocimem 	EthernetSystem_nios2_Processor_nios2_ocimem:the_EthernetSystem_nios2_Processor_nios2_ocimem
set 	EthernetSystem_nios2_Processor_oci_debug 	EthernetSystem_nios2_Processor_nios2_oci_debug:the_EthernetSystem_nios2_Processor_nios2_oci_debug
set 	EthernetSystem_nios2_Processor_wrapper 	EthernetSystem_nios2_Processor_jtag_debug_module_wrapper:the_EthernetSystem_nios2_Processor_jtag_debug_module_wrapper
set 	EthernetSystem_nios2_Processor_jtag_tck 	EthernetSystem_nios2_Processor_jtag_debug_module_tck:the_EthernetSystem_nios2_Processor_jtag_debug_module_tck
set 	EthernetSystem_nios2_Processor_jtag_sysclk 	EthernetSystem_nios2_Processor_jtag_debug_module_sysclk:the_EthernetSystem_nios2_Processor_jtag_debug_module_sysclk
set 	EthernetSystem_nios2_Processor_oci_path 	 [format "%s|%s" $EthernetSystem_nios2_Processor $EthernetSystem_nios2_Processor_oci]
set 	EthernetSystem_nios2_Processor_oci_break_path 	 [format "%s|%s" $EthernetSystem_nios2_Processor_oci_path $EthernetSystem_nios2_Processor_oci_break]
set 	EthernetSystem_nios2_Processor_ocimem_path 	 [format "%s|%s" $EthernetSystem_nios2_Processor_oci_path $EthernetSystem_nios2_Processor_ocimem]
set 	EthernetSystem_nios2_Processor_oci_debug_path 	 [format "%s|%s" $EthernetSystem_nios2_Processor_oci_path $EthernetSystem_nios2_Processor_oci_debug]
set 	EthernetSystem_nios2_Processor_jtag_tck_path 	 [format "%s|%s|%s" $EthernetSystem_nios2_Processor_oci_path $EthernetSystem_nios2_Processor_wrapper $EthernetSystem_nios2_Processor_jtag_tck]
set 	EthernetSystem_nios2_Processor_jtag_sysclk_path 	 [format "%s|%s|%s" $EthernetSystem_nios2_Processor_oci_path $EthernetSystem_nios2_Processor_wrapper $EthernetSystem_nios2_Processor_jtag_sysclk]
set 	EthernetSystem_nios2_Processor_jtag_sr 	 [format "%s|*sr" $EthernetSystem_nios2_Processor_jtag_tck_path]

#**************************************************************
# Set False Paths
#**************************************************************

set_false_path -from [get_keepers *$EthernetSystem_nios2_Processor_oci_break_path|break_readreg*] -to [get_keepers *$EthernetSystem_nios2_Processor_jtag_sr*]
set_false_path -from [get_keepers *$EthernetSystem_nios2_Processor_oci_debug_path|*resetlatch]     -to [get_keepers *$EthernetSystem_nios2_Processor_jtag_sr[33]]
set_false_path -from [get_keepers *$EthernetSystem_nios2_Processor_oci_debug_path|monitor_ready]  -to [get_keepers *$EthernetSystem_nios2_Processor_jtag_sr[0]]
set_false_path -from [get_keepers *$EthernetSystem_nios2_Processor_oci_debug_path|monitor_error]  -to [get_keepers *$EthernetSystem_nios2_Processor_jtag_sr[34]]
set_false_path -from [get_keepers *$EthernetSystem_nios2_Processor_ocimem_path|*MonDReg*] -to [get_keepers *$EthernetSystem_nios2_Processor_jtag_sr*]
set_false_path -from *$EthernetSystem_nios2_Processor_jtag_sr*    -to *$EthernetSystem_nios2_Processor_jtag_sysclk_path|*jdo*
set_false_path -from sld_hub:*|irf_reg* -to *$EthernetSystem_nios2_Processor_jtag_sysclk_path|ir*
set_false_path -from sld_hub:*|sld_shadow_jsm:shadow_jsm|state[1] -to *$EthernetSystem_nios2_Processor_oci_debug_path|monitor_go
