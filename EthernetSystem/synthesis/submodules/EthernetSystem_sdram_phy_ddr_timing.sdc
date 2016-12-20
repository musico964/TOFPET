# 
# Legal Notice: (C)2007 Altera Corporation. All rights reserved. Your
# use of Altera Corporation's design tools, logic functions and other
# software and tools, and its AMPP partner logic functions, and any
# output files any of the foregoing (including device programming or
# simulation files), and any associated documentation or information are
# expressly subject to the terms and conditions of the Altera Program
# License Subscription Agreement or other applicable license agreement,
# including, without limitation, that your use is for the sole purpose
# of programming logic devices manufactured by Altera and sold by Altera
# or its authorized distributors. Please refer to the applicable
# agreement for further details.

################################################################################
# This file constrains the ALTMEMPHY memory interface PHY. The parameters at
# the top of thie file may be edited, but be warned that it it overwritten when
# regenerating the ALTMEMPHY Megacore Function.
################################################################################
# Generated by:13.0
# variation name : EthernetSystem_sdram_phy
# family : Arria II GX
# speed_grade : 4
# local_if_drate : Half
# pll_ref_clk_mhz : 100.0
# mem_if_clk_mhz : 300.0
# mem_if_preset : Micron ArriaIIGX_DDR3_Kit(MT41J64M16LA-15E)
# chip_or_dimm : Discrete Device
# mem_if_dq_per_dqs : 8
# ac_phase : 90
# ac_clk_select : 90

set corename "EthernetSystem_sdram_phy"
source "[list [file join [file dirname [info script]] EthernetSystem_sdram_phy_ddr_timing.tcl]]"

################################################################################
# A callback to collect the results of the top level pin detection
################################################################################
proc ddr_pin {n pin pins_array_name} {
	upvar 1 $pins_array_name pins
	global pins
	if {![info exists pins($n)] } {
		post_message -type critical_warning "ddr_pin $n $pin $pins_array_name didn't recognise '$n' as a pin type"
	} else {
		lappend pins($n) $pin
	}
}

################################################################################
# Locate the top level pins that are connected to this ALTMEMPHY instance
################################################################################
set pin_file_name "EthernetSystem_sdram_phy_ddr_pins.tcl"
set dirname [file dirname [info script]] 
set fn [file join $dirname $pin_file_name]
source $fn

################################################################################
# Add the SDC constraints for a single instantiation of this ALTMEMPHY
# variation. This is called multiple times if the variation has multiple
# instantiations.
################################################################################
proc add_requirements_for_instance {corename instance_name t_name board_name ISI_name EthernetSystem_sdram_phy_use_flexible_timing} {
	upvar 1 $t_name t
	upvar 1 $board_name board
	upvar 1 $ISI_name ISI
	set instname "${instance_name}|${corename}"

	global ck_output_clocks
	array unset ck_output_clocks

	global pins
	array unset pins

	set pins(ck_p) [list]
	set pins(ck_n) [list]
	set pins(addrcmd) [list]
	set pins(addrcmd_2t) [list]
	set pins(dqsgroup) [list]
	set pins(dgroup) [list]
	set pins(resetn) [list]

################################################################################
# Cache the result of the automatic top level pin detection to reduce fit times
	global pins_cache
	if { [array exists pins_cache] &&  [info exists pins_cache($corename-$instance_name)] } {
		# post_message -type critical_warning "cache hit"
		array set pins $pins_cache($corename-$instance_name)
	} else {
		# post_message -type critical_warning "cache miss"
		get_ddr_pins $instname pins $corename
		set pins_cache($corename-$instance_name) [array get pins]
	}

################################################################################
# Create the PLL input clock and derive clocks on the PLL outputs
	set msg_list [list]

	set ck_pll_clock_id [get_output_clock_id $pins(ck_p) "CK output" msg_list]
	if {$ck_pll_clock_id == -1} {
		foreach {msg_type msg} $msg_list {
			post_message -type $msg_type "EthernetSystem_sdram_phy_ddr_timing.sdc: $msg"
		}
		post_message -type warning "EthernetSystem_sdram_phy_ddr_timing.sdc: Failed to find PLL clock for pins [join $pins(ck_p)]"
	} else {
		set ck_pll_clock [get_node_info -name $ck_pll_clock_id]
		set pll_ref_clk_id [get_input_clk_id $ck_pll_clock_id]
		if {$pll_ref_clk_id != -1} {
			set pll_ref_clk [get_node_info -name $pll_ref_clk_id]
			if {[get_collection_size [get_clocks -nowarn $pll_ref_clk]] == 0} {
				create_clock -period $::t(inclk_period) $pll_ref_clk
			}

			if {[get_collection_size [get_clocks -nowarn $ck_pll_clock]] > 0} {
				# PLL clocks already derived
			} else {
				derive_pll_clocks
			}
		} else {
			post_message -type info "EthernetSystem_sdram_phy_ddr_timing.sdc: Could not find PLL clocks for $ck_pll_clock. Creating PLL base clocks"
			# Attempt to recover
			derive_pll_clocks -create_base_clocks
		}
		derive_clock_uncertainty
	}

################################################################################

# Find the TimeQuest name for the resync clock. If it is not found, create one.
	set resync_clock_pattern ${instname}_alt_mem_phy_*inst|clk|*|altpll_component|auto_generated|pll1|clk\[4\]
	set resync_clock_id ""
	sett_collection resync_clock_id [get_pins -compatibility_mode $resync_clock_pattern]
	set resync_clock [get_node_info -name $resync_clock_id]
	set resync_pll_ref_clk_id [get_input_clk_id $resync_clock_id]

	if {$resync_pll_ref_clk_id != -1} {
		set resync_pll_ref_clk [get_node_info -name $resync_pll_ref_clk_id]
		if {[get_collection_size [get_clocks -nowarn $resync_pll_ref_clk]] == 0} {
			create_clock -period $::t(inclk_period) $resync_pll_ref_clk
		}
	} else {
		post_message -type warning "EthernetSystem_sdram_phy_ddr_timing.sdc: Failed to find PLL input clock pin driving $resync_clock"
	}

################################################################################

# Find the TimeQuest name for the mimic clock. If it is not found, create one.
	set mimic_clock_pattern ${instname}_alt_mem_phy_*inst|clk|*|altpll_component|auto_generated|pll1|clk\[5\]
	set mimic_clock_pins [get_pins -nowarn -compatibility_mode $mimic_clock_pattern]

	if {[get_collection_size $mimic_clock_pins] == 1} {
		set mimic_clock_id ""
		sett_collection mimic_clock_id $mimic_clock_pins
		set mimic_clock [get_node_info -name $mimic_clock_id]
		# Cut the path from the mimic pin to the mimic clock
		set_false_path -from [get_ports $pins(ck_p)] -to [get_clocks $mimic_clock]
	} else {
		post_message -type error "Couldn't find mimic clock from pattern $mimic_clock_pattern"
		set mimic_clock ""
	}

################################################################################

# Find the TimeQuest name for the system clock. If it is not found, create one.
	set system_clock_pattern ${instname}_alt_mem_phy_*inst|clk|*|altpll_component|auto_generated|pll1|clk\[0\]
	set system_clock_pins [get_pins -nowarn -compatibility_mode $system_clock_pattern]

	if {[get_collection_size $system_clock_pins] == 1} {
		set system_clock_id ""
		sett_collection system_clock_id $system_clock_pins
		set system_clock [get_node_info -name $system_clock_id]
		if {[info exists pll_ref_clk]} {
			set_false_path -from $pll_ref_clk -to $system_clock
			set_false_path -to $pll_ref_clk -from $system_clock
			#Cut the path from the system clock to the mimic clock :
			set_false_path -from $system_clock -to [get_clocks $mimic_clock]
		}
	} else {
		set system_clock ""
	}

set fpga_tREAD_CAPTURE_SETUP_ERROR 0
set fpga_tREAD_CAPTURE_HOLD_ERROR 0
set fpga_RESYNC_SETUP_ERROR 0
set fpga_RESYNC_HOLD_ERROR 0
set fpga_PA_DQS_SETUP_ERROR 0
set fpga_PA_DQS_HOLD_ERROR 0
set WR_DQS_DQ_SETUP_ERROR 0
set WR_DQS_DQ_HOLD_ERROR 0
set fpga_tCK_ADDR_CTRL_SETUP_ERROR 0
set fpga_tCK_ADDR_CTRL_HOLD_ERROR 0
set fpga_tDQSS_SETUP_ERROR 0
set fpga_tDQSS_HOLD_ERROR 0
set fpga_tDSSH_SETUP_ERROR 0
set fpga_tDSSH_HOLD_ERROR 0
################################################################################
# post_message -type info "Creating CK output clocks"
	set ck_clock_types_list [list ac_rise ac_fall]
	set source $ck_pll_clock

	foreach ckpin [concat $pins(ck_p) $pins(ck_n)] {
		if { [lsearch -exact $pins(ck_p) $ckpin] != -1 } { 
			set invert 0
			set ckpn p
		} elseif { [lsearch -exact $pins(ck_n) $ckpin] != -1 } {
			set invert 1
			set ckpn n
		} else {
			error "Can't find pin $ckpin in $pins(ck_p) or $pins(ck_n)"
		}

		# We don't care about the tco of the memory clocks
		set_false_path -from * -to [get_ports $ckpin]
		set clocknamestub "${instname}_ck_${ckpn}_${ckpin}"

		foreach ck_clock_type $ck_clock_types_list {
			set clockname "${clocknamestub}_${ck_clock_type}"
			if { $invert } { 
				create_generated_clock -add -multiply_by 1 -source $source -master_clock $source -invert -name $clockname $ckpin
			} else { 
				create_generated_clock -add -multiply_by 1 -source $source -master_clock $source -name $clockname $ckpin
			}
			add_output_clock $ck_clock_type $ckpn $clockname
		}
	}


################################################################################
# The scan clock provides a slow-speed clock domain to drive the PLL phase
# stepping interface. It is created by dividing down a PLL output phase. All
# transfers to and from the scan clock domain have asynchronous clock domain
# crossings, so the only constraint on these paths is that they have a skew
# less than 2 whole cycles of the scan clock. The fastest that the scan clock
# can run is 100MHz, so we set a +/- 9ns skew constraint across the clock
# domain crossing.
################################################################################
	set scan_clock_patterns [list ${instname}_alt_mem_phy_inst|clk|scan_clk|q 2]
	foreach {pattern divide_by} $scan_clock_patterns {
		foreach_in_collection c [get_pins -compatibility_mode $pattern] {
			set source [get_node_info -name $c]
			set sys_pll_clock [get_pll_clock [list $c] "System" "" 16]
			if {$sys_pll_clock != ""} {
				post_sdc_message info "Creating scan clock ${source}_clock driven by $sys_pll_clock divided by $divide_by"
				create_generated_clock -multiply_by 1 -divide_by $divide_by -source $sys_pll_clock -master_clock $sys_pll_clock $source -name ${source}_clock
				set_max_delay -to [get_clocks $sys_pll_clock] -from [get_clocks ${source}_clock] 9.0
				set_max_delay -from [get_clocks $sys_pll_clock] -to [get_clocks ${source}_clock] 9.0
				set_min_delay -to [get_clocks $sys_pll_clock] -from [get_clocks ${source}_clock] -9.0
				set_min_delay -from [get_clocks $sys_pll_clock] -to [get_clocks ${source}_clock] -9.0
			} else {
				post_message -type warning "Cannot find source clock of $source"
			}
		}
	}

####################################################################################
# Get some values that are needed to determine the input and output delay constraints

set io_std "DIFFERENTIAL 1.5-V SSTL CLASS I"
set interface_type "HPAD"
# This is the peak-to-peak jitter, of which half is considered to be tJITper
set tJITper [expr [get_io_standard_node_delay -dst MEM_CK_PERIOD_JITTER -io_standard $io_std -parameters [list IO $interface_type] -in_fitter -period $::t(period)]/2000.0]
# This is the peak-to-peak jitter on the whole DQ-DQS read capture path
set DQSpathjitter [expr [get_io_standard_node_delay -dst DQDQS_JITTER -io_standard $io_std -parameters [list IO $interface_type] -in_fitter]/1000.0]
# This is the proportion of the DQ-DQS read capture path jitter that applies to setup
set DQSpathjitter_setup_prop [expr [get_io_standard_node_delay -dst DQDQS_JITTER_DIVISION -io_standard $io_std -parameters [list IO $interface_type] -in_fitter]/100.0]
# This is the peak-to-peak jitter on the whole DQ-DQS write path
set outputDQSpathjitter [expr [get_io_standard_node_delay -dst OUTPUT_DQDQS_JITTER -io_standard $io_std -parameters [list IO $interface_type] -in_fitter]/1000.0]
# This is the proportion of the DQ-DQS write path jitter that applies to setup
set outputDQSpathjitter_setup_prop [expr [get_io_standard_node_delay -dst OUTPUT_DQDQS_JITTER_DIVISION -io_standard $io_std -parameters [list IO $interface_type] -in_fitter]/100.0]

# Read Capture and Write input and output delay constraints
set input_max_delay   [round_3dp [expr -$::t(DQS_PSERR_min) - $DQSpathjitter*$DQSpathjitter_setup_prop       + $::t(min_additional_dqs_variation) - $fpga_tREAD_CAPTURE_SETUP_ERROR]]
set input_min_delay   [round_3dp [expr  $::t(DQS_PSERR_max) + $DQSpathjitter*(1.0-$DQSpathjitter_setup_prop) + $::t(max_additional_dqs_variation) + $fpga_tREAD_CAPTURE_HOLD_ERROR - $::t(QH) + $tJITper]]
set input_max_delay2  [round_3dp [expr $::t(DQSQ) + $::t(board_skew) + $::SSN(rel_pushout_i)]]
set input_min_delay2  [round_3dp [expr            - $::t(board_skew) - $::SSN(rel_pullin_i)]]

set output_max_delay  [round_3dp [expr   $::t(board_skew) + $::t(DS) + $outputDQSpathjitter*$outputDQSpathjitter_setup_prop + $WR_DQS_DQ_SETUP_ERROR + $::ISI(DQ)/2 + $::ISI(DQS)/2 + $::SSN(rel_pushout_o)]]
set output_min_delay  [round_3dp [expr  -$::t(board_skew) - $::t(DH) - $outputDQSpathjitter*(1.0-$outputDQSpathjitter_setup_prop) - $WR_DQS_DQ_HOLD_ERROR  - $::ISI(DQ)/2 - $::ISI(DQS)/2 - $::SSN(rel_pullin_o)]]

	set msg_list [list]
################################################################################
# Locate the clocks that drive the DQ and DQS pins when writing
################################################################################
	set dqs_pll_clock_id [get_output_clock_id [get_all_dqs_pins $pins(dqsgroup)] "DQS output" msg_list]
	set dq_pll_clock_id [get_output_clock_id [get_all_dq_pins $pins(dqsgroup)] "DQ output" msg_list]

	if {$dqs_pll_clock_id == -1 || $dq_pll_clock_id == -1} {
		foreach {msg_type msg} $msg_list {
			post_message -type $msg_type "EthernetSystem_sdram_phy_ddr_timing.sdc: $msg"
		}
		post_message -type warning "EthernetSystem_sdram_phy_ddr_timing.sdc: Failed to find PLL clock for pins [join [get_all_dqs_pins $pins(dqsgroup)]]"
	} else {
		set dqsclksource [get_node_info -name $dqs_pll_clock_id]
		set dqclksource [get_node_info -name $dq_pll_clock_id]
	}

################################################################################
	foreach dqsgroup $pins(dqsgroup) {
		set dqspin [lindex $dqsgroup 0]

		# If this design uses macro timing parameters, SDC constraints are not needed
		if {$EthernetSystem_sdram_phy_use_flexible_timing} {
			# DQS output clock
			set dqs_out_clockname "${instname}_ddr_dqsout_${dqspin}"
			create_generated_clock -multiply_by 1 -source $dqsclksource -master_clock $dqsclksource $dqspin -name $dqs_out_clockname -add

			# The clock uncertainty is explicitly made 0 since all the clock uncertainty is included in the set_output_delay constraints
			set_clock_uncertainty  -from [get_clocks $dqclksource] -to [get_clocks $dqs_out_clockname] 0
			if {$EthernetSystem_sdram_phy_use_flexible_timing && ($::quartus(nameofexecutable) ne "quartus_fit")} {
				lappend ::dqs_clocks $dqs_out_clockname
			}
		}
		# endif $EthernetSystem_sdram_phy_use_flexible_timing

		# DQS input clock
		set dqs_in_clockname "${instname}_ddr_dqsin_${dqspin}"
		create_clock -period $::t(period) -name $dqs_in_clockname $dqspin -add

		if {$EthernetSystem_sdram_phy_use_flexible_timing && ($::quartus(nameofexecutable) ne "quartus_fit")} {
			lappend ::dqs_clocks $dqs_in_clockname
		}
		if {$EthernetSystem_sdram_phy_use_flexible_timing} {

################################################################################
# The write timing constrains the DQ write data with respect to the DQS strobe.
# An output clock is created on the DQS strobe, and we create a pair of
# set_output_delay assignments: one for the DQ data vs the rising edge of the
# DQS and the other against the falling edge.
# For the two max delay (setup) constraints:
# 
# $t(board_skew)
# The worst case difference in propagation delay between the DQS strobe and any
# DQ pin within the same group.
# 
# $t(DS)
# The setup requirement at the memory
# 
# $WR_DQS_DQ_SETUP_ERROR
# An uncertainty term for HardCopy II designs, contact the HardCopy Design
# Centre for more information.
# 
# For the two min delay (hold) constraints:
# - $t(board_skew)
# The worst case difference in propagation delay between the DQS strobe and any
# DQ pin within the same group.
# 
# -$t(DH)	
# The hold requirement at the memory
# 
# - $t(DCD_total)
# Duty cycle distortion, since the launch and latch edges will be on the
# opposite edges
# 
# - $WR_DQS_DQ_HOLD_ERROR
# An uncertainty term for HardCopy II designs, contact the HardCopy Design
# Centre for more information.
################################################################################
			set_output_delay -add_delay -clock $dqs_out_clockname -max $output_max_delay [concat [lindex $dqsgroup 1] [lindex $dqsgroup 2]]
			set_output_delay -add_delay -clock $dqs_out_clockname -min $output_min_delay [concat [lindex $dqsgroup 1] [lindex $dqsgroup 2]]
			set_output_delay -add_delay -clock_fall -clock $dqs_out_clockname -max $output_max_delay [concat [lindex $dqsgroup 1] [lindex $dqsgroup 2]]
			set_output_delay -add_delay -clock_fall -clock $dqs_out_clockname -min $output_min_delay [concat [lindex $dqsgroup 1] [lindex $dqsgroup 2]]
		}
		# endif $EthernetSystem_sdram_phy_use_flexible_timing

		if {$EthernetSystem_sdram_phy_use_flexible_timing} {
		}
		# endif $EthernetSystem_sdram_phy_use_flexible_timing

				set_max_delay -from [lindex $dqsgroup 2] -to * $input_max_delay
				set_min_delay -from [lindex $dqsgroup 2] -to * $input_min_delay
				set_input_delay -add_delay -clock $dqs_in_clockname -max $input_max_delay2 [lindex $dqsgroup 2]
				set_input_delay -add_delay -clock $dqs_in_clockname -min $input_min_delay2 [lindex $dqsgroup 2]

################################################################################
# There are three potential timing paths through a DDIO to the output pin. Two
# of these are from the output registers, and the third is the combinatorial
# path
# The only timing path through a DDIO that actually affects the output is the
# one that goes through the MUX. The timing delays through the other paths are
# chosen to ensure this.
################################################################################
		set_false_path -from [all_registers] -to [get_ports $dqspin]
		set dqsnpin [lindex $dqsgroup 3]
		set_false_path -from [all_registers] -to [get_ports $dqsnpin]

		set_false_path -to [get_clocks $resync_clock] -from [get_clocks $dqs_in_clockname]
		set_false_path -from [get_clocks $resync_clock] -to [get_clocks $dqs_in_clockname]
		set_false_path -from [get_keepers *bidir_dq_*_oe_ff_inst]
		set write_clock_pattern ${instname}_alt_mem_phy_*inst|clk|*|altpll_component|auto_generated|pll1|clk\[3\]
		if {[get_collection_size [get_pins -nowarn -compatibility_mode $write_clock_pattern]] == 0} {
			# Clocks have been shared need to be found in other instances
			set instance_list [get_core_instance_list $corename]
			foreach inst $instance_list {
				set testinstname "${inst}|${corename}"
				set write_clock_pattern ${testinstname}_alt_mem_phy_*inst|clk|*|altpll_component|auto_generated|pll1|clk\[3\]
				if {[get_collection_size [get_pins -nowarn -compatibility_mode $write_clock_pattern]] > 0} {
					break
				}
			}
		}
		set write_clock_id ""
		sett_collection write_clock_id [get_pins -compatibility_mode $write_clock_pattern]
		set write_clock [get_node_info -name $write_clock_id]
		set_false_path -from [get_clocks $write_clock] -to [get_clocks $dqs_in_clockname]
		if {$EthernetSystem_sdram_phy_use_flexible_timing} {
			set_false_path -to [get_clocks $resync_clock] -from [get_clocks $dqs_out_clockname]
			set_false_path -from [get_clocks $resync_clock] -to [get_clocks $dqs_out_clockname]
			set_false_path -from [get_clocks $dqclksource] -to [get_clocks $dqs_in_clockname]
			set_false_path -from [get_clocks $dqs_out_clockname] -to [get_clocks $dqs_in_clockname]
			set_false_path -from [get_clocks $dqs_in_clockname] -to [get_clocks $dqs_out_clockname]
			set_false_path -setup -rise_from [get_clocks $dqclksource] -fall_to [get_clocks $dqs_out_clockname]
			set_false_path -setup -fall_from [get_clocks $dqclksource] -rise_to [get_clocks $dqs_out_clockname]
			set_false_path -hold -rise_from [get_clocks $dqclksource] -rise_to [get_clocks $dqs_out_clockname]
			set_false_path -hold -fall_from [get_clocks $dqclksource] -fall_to [get_clocks $dqs_out_clockname]	
			set_false_path -from [get_clocks $write_clock] -to [get_clocks $dqs_out_clockname] -through *ams_pipe*
		}
		# endif $EthernetSystem_sdram_phy_use_flexible_timing
	}


	if {!$EthernetSystem_sdram_phy_use_flexible_timing} {
		# Cut paths to read capture registers, since they are subject to macro timing analysis
		set dq_list [get_all_dq_pins $pins(dqsgroup)]
		if {[llength $dq_list] > 0} {
			set_false_path -from [concat $dq_list] -to [all_registers]
		}
		# Cut paths from write registers and PLL clocks-as-data
		set d_dm_list [concat $dq_list [get_all_dm_pins $pins(dqsgroup)]]
		if {[llength $d_dm_list] > 0} {
			set_false_path -from * -to $d_dm_list
		}
	} else {
		# These are paths that are cross clock domains, and are covered in the write-levelling
		# and resynchronization calibrated paths and are analyzed there
		set dq_list [get_all_dq_pins $pins(dqsgroup)]
		if {[llength $dq_list] > 0} {
			set_false_path -from [concat $dq_list] -to [get_keepers *datain_reg*]
		}
	}
	# endif !$EthernetSystem_sdram_phy_use_flexible_timing

#False path the read and write latency values from the sequencer, as these will be static when being used :
set rd_wr_latency_ops [get_pins -compatibility_mode ${instname}_alt_mem_phy_inst|*seq_wrapper|*seq_inst|*dgrb|?d_lat*|clk]
set_false_path -from $rd_wr_latency_ops
#False path the sequencer memory clock disable signal from the sequencer, as this will be static when being used :
set_false_path -from [get_pins -compatibility_mode  ${instname}_alt_mem_phy_inst|*seq_wrapper|*seq_inst|seq_mem_clk_disable*]

# Cut asynchronous reset paths for clock domain crossing in the clocking and
# reset block

#  - clk|global_pre_clear|clrn: The master reset flop, driven by the PLL locked
# output and the soft_reset_n and global_reset_n signals

#  - clk|reset_master_ams|clrn: Synchronises the PLL locked reset to the
# global_pre_clear reset

#  - clk|mem_pipe|ams_pipe\[*\]|clrn: Transfers the master reset to the mem
# clock domain

#  - clk|mem_clk_pipe|ams_pipe\[*\]|clrn: Transfers the master reset to the mem
# clock domain

#  - clk|write_clk_pipe|ams_pipe\[*\]|clrn: Transfers the master reset to the
# write clock domain

#  - clk|measure_clk_pipe|ams_pipe\[*\]|clrn: Transfers the master reset to the
# measure clock domain

#  - clk|resync_clk_pipe|ams_pipe\[*\]|clrn: Transfers the master reset to the
# resync clock domain
#  - clk|clk_div_reset_ams_n_r|clrn: Master reset clock domain crossing
#  - clk|clk_div_reset_ams_n|clrn: Master reset clock domain crossing

#  - clk|pll_reconfig_reset_ams_n_r|clrn: Master reset clock domain crossing to
# the PLL reconfig block

#  - clk|pll_reconfig_reset_ams_n|clrn: Master reset clock domain crossing to
# the PLL reconfig block

#  - clk|phs_shft_busy_siii|d: Cut the phase shift busy signal since it's
# resynchronized in the sequencer

#  - clk|poa_clk_pipe|ams_pipe\[*\]|clrn: Transfers the master reset to the
# postamble clock domain
	set clear_list [list \
		${instname}_alt_mem_phy*_inst|clk|*pll|altpll_component|auto_generated|pll_lock_sync|clrn \
		${instname}_alt_mem_phy*_inst|clk|global_pre_clear|clrn \
		${instname}_alt_mem_phy*_inst|clk|reset_master_ams|clrn \
		${instname}_alt_mem_phy*_inst|clk|mem_pipe|ams_pipe\[*\]|clrn \
		${instname}_alt_mem_phy*_inst|clk|mem_clk_pipe|ams_pipe\[*\]|clrn \
		${instname}_alt_mem_phy*_inst|clk|write_clk_pipe|ams_pipe\[*\]|clrn \
		${instname}_alt_mem_phy*_inst|clk|measure_clk_pipe|ams_pipe\[*\]|clrn \
		${instname}_alt_mem_phy*_inst|clk|resync_clk_pipe|ams_pipe\[*\]|clrn \
		${instname}_alt_mem_phy*_inst|clk|clk_div_reset_ams_n_r|clrn \
		${instname}_alt_mem_phy*_inst|clk|clk_div_reset_ams_n|clrn \
		${instname}_alt_mem_phy*_inst|clk|pll_reconfig_reset_ams_n_r|clrn \
		${instname}_alt_mem_phy*_inst|clk|pll_reconfig_reset_ams_n|clrn \
		${instname}_alt_mem_phy*_inst|clk|phs_shft_busy_siii|d \
		${instname}_alt_mem_phy*_inst|clk|poa_clk_pipe|ams_pipe\[*\]|clrn \
	]

	foreach clear $clear_list {
		set clear_pins [get_pins -nowarn -compatibility_mode $clear]
		if {[get_collection_size $clear_pins] > 0} {
			set_false_path -thru $clear_pins -to *
		}
	}

# Cut the asynchronous memory reset control
	foreach resetn $pins(resetn) {
		set_false_path -to $resetn
	}

# Cut the sequencer's mimic start request and other static outputs :
set_false_path -from [get_pins -compatibility_mode *_alt_mem_phy_inst|*seq_wrapper|*seq_inst|*|seq_mmc_start*|*] -to [get_keepers *alt_mem_phy_mimic:mmc|seq_mmc_start_metastable*]
set_false_path -from [get_keepers *_alt_mem_phy_inst|*seq_wrapper|*seq_inst|seq_ac_add_1t_ac_lat_internal*] 
set_false_path -from [get_pins -compatibility_mode *_alt_mem_phy_inst|*mmc|mimic_done_out*] -to [get_keepers *_alt_mem_phy_inst|*seq_wrapper|*seq_inst|*dgrb|*v_mmc_seq_done_1r*]


################################################################################
# Timing constrain the Address/command outputs. Note that ALTMEMPHY uses a DDIO
# structure to generate the output, even though the output is single data rate
# (or half data rate for the non-chip-select pins, when in half rate mode). It
# does this by controlling the input to the DDIO such that the same data is
# driven out on the rising and falling edges, or on the falling edge and the
# subsequent rising edge. This is used to provide a 180 degree phase shift to
# the output when the address/command phase in the wizard is set to 90 degree
# or 180 degrees, which are inverted versions of the 270 degree write clock or
# 0 degree DQS clock.
# 
# The transitions on the select signal driving the DDIO output MUX control the
# timing, so we have to cut the paths coming from the registers to the IO pin
# with a set_false_path -from [all_registers] assignment.
# 
# We also have to tell TimeQuest that only the rising (or falling) edge of the
# address/command clock generates a transition on the output. This is done with
# a set_false_path -rise_from (or -fall_from) assignment.
# 
# When the core is in half-rate mode, which is the default and needed to
# achieve the maximum possible frequency, all the address/command pins except
# the chip select (cs) pin are driven out a whole cycle early. This improves
# timing when the address bus has a greater load than the Chip Select signal.
# It is simply a set_multicycle_path assignment to all the 2t address/command
# pins.
################################################################################
################################################################################
# Address/Command
################################################################################
	set msg_list [list]
	set ac_pll_clock_id [get_output_clock_id $pins(addrcmd) "Address/Command output" msg_list]
	if {$ac_pll_clock_id == -1} {
		foreach {msg_type msg} $msg_list {
			post_message -type $msg_type "EthernetSystem_sdram_phy_ddr_timing.sdc: $msg"
		}
		post_message -type warning "EthernetSystem_sdram_phy_ddr_timing.sdc: Failed to find PLL clock for pins [join $pins(addrcmd)]"
	} else {
		set ac_pll_clock [get_node_info -name $ac_pll_clock_id]

################################################################################
# These offset parameters are needed for designs that have the 'Use Dedicated
# PLL clock outputs' set. They are not needed in this case, and are set to
# zero.
################################################################################
		set ded_off_rise 0
		set ded_off_fall 0
		set off $ded_off_fall
		# Only analyze the DDIO mux select
		set_false_path -from [all_registers] -to [concat $pins(addrcmd) $pins(addrcmd_2t)]
		foreach ckclock [get_output_clocks ac_fall p] {
			set_output_delay -add_delay -clock $ckclock -max [round_3dp [expr {$off*$::t(period) + $::t(IS) + $::t(board_skew) + $fpga_tCK_ADDR_CTRL_SETUP_ERROR + $::t(additional_addresscmd_tpd)}]] $pins(addrcmd)
			set_output_delay -add_delay -clock $ckclock -min [round_3dp [expr {$off*$::t(period) - $::t(IH) - $::t(board_skew) - $fpga_tCK_ADDR_CTRL_HOLD_ERROR + $::t(additional_addresscmd_tpd)}]] $pins(addrcmd)
			if {[llength $pins(addrcmd_2t)] > 0} {
				set_output_delay -add_delay -clock $ckclock -max [round_3dp [expr {$off*$::t(period) + $::t(IS) + $::t(board_skew) + $fpga_tCK_ADDR_CTRL_SETUP_ERROR + $::ISI(addresscmd_setup) + $::t(additional_addresscmd_tpd)}]] $pins(addrcmd_2t)
				set_output_delay -add_delay -clock $ckclock -min [round_3dp [expr {$off*$::t(period) - $::t(IH) - $::t(board_skew) - $fpga_tCK_ADDR_CTRL_HOLD_ERROR - $::ISI(addresscmd_hold) + $::t(additional_addresscmd_tpd)}]] $pins(addrcmd_2t)
			}
		}
		foreach ckclock [get_output_clocks ac_fall n] {
			set_output_delay -add_delay -clock_fall -clock $ckclock -max [round_3dp [expr {$off*$::t(period) + $::t(IS) + $::t(board_skew) + $fpga_tCK_ADDR_CTRL_SETUP_ERROR + $::t(additional_addresscmd_tpd)}]] $pins(addrcmd)
			set_output_delay -add_delay -clock_fall -clock $ckclock -min [round_3dp [expr {$off*$::t(period) - $::t(IH) - $::t(board_skew) - $fpga_tCK_ADDR_CTRL_HOLD_ERROR + $::t(additional_addresscmd_tpd)}]] $pins(addrcmd)
			if {[llength $pins(addrcmd_2t)] > 0} {
				set_output_delay -add_delay -clock_fall -clock $ckclock -max [round_3dp [expr {$off*$::t(period) + $::t(IS) + $::t(board_skew) + $fpga_tCK_ADDR_CTRL_SETUP_ERROR + $::ISI(addresscmd_setup) + $::t(additional_addresscmd_tpd)}]] $pins(addrcmd_2t)
				set_output_delay -add_delay -clock_fall -clock $ckclock -min [round_3dp [expr {$off*$::t(period) - $::t(IH) - $::t(board_skew) - $fpga_tCK_ADDR_CTRL_HOLD_ERROR - $::ISI(addresscmd_hold) + $::t(additional_addresscmd_tpd)}]] $pins(addrcmd_2t)
			}
		}
		if {$ac_pll_clock_id != -1} {
			foreach ckclock [concat [get_output_clocks ac_fall p] [get_output_clocks ac_fall n]] {
				set_false_path -rise_from [get_clocks $ac_pll_clock] -to $ckclock
			}
		}
	}
	if { [llength $pins(addrcmd_2t)] > 0 } {
		# post_message -type info "Address/Command (half rate)"
		set_multicycle_path -setup -to $pins(addrcmd_2t) 2
		set_multicycle_path -hold -to $pins(addrcmd_2t) 1
	}


################################################################################
# The mimic path uses the calibrated mimic clock to capture the memory clock as
# data in the resync register within the IO Cell. Due to the dynamic phase of
# the mimic clock the path from memory clock to mimic clock is cut.
################################################################################
	set mimic_clock_pattern ${instname}_alt_mem_phy_*inst|clk|*|altpll_component|auto_generated|pll1|clk\[5\]
	set mimic_clock_pins [get_pins -nowarn -compatibility_mode $mimic_clock_pattern]
	if {[get_collection_size $mimic_clock_pins] == 1} {
		set mimic_clock [get_node_info -name $mimic_clock_id]
		foreach ckclock [concat [get_output_clocks ac_fall p] [get_output_clocks ac_rise p]] {
			set_false_path -from [get_clocks $ckclock]  -to [get_clocks $mimic_clock]
		}
		set_max_delay -from [get_clocks $mimic_clock] -to [get_clocks $system_clock] $::t(period)
		set_min_delay -from [get_clocks $mimic_clock] -to [get_clocks $system_clock] -$::t(period)
	}

	if {$EthernetSystem_sdram_phy_use_flexible_timing && (($::quartus(nameofexecutable) ne "quartus_fit") && ($::quartus(nameofexecutable) ne "quartus_map"))} {
		if {[llength $::dqs_clocks] > 0} {
			post_sdc_message info "Setting DQS clocks as inactive; use Report DDR to timing analyze DQS clocks"
			set_active_clocks [remove_from_collection [get_active_clocks] [get_clocks $::dqs_clocks]]
		}
	}

}

################################################################################


# Apply the timing constraints to every instantiation of this ALTMEMPHY
# variation within the design.
set instance_list [get_core_instance_list $corename]
foreach inst $instance_list {
	post_sdc_message info "Adding SDC requirements for $corename instance $inst"
	add_requirements_for_instance $corename $inst t board ISI $EthernetSystem_sdram_phy_use_flexible_timing
	add_ddr_report_command "source [list [file join [file dirname [info script]] ${corename}_report_timing.tcl]]"
}
