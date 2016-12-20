file delete hdl.log
exec rm -rf INCA_libs/*lib/*

exec ncvhdl -NOCOPYRIGHT -UPDATE -STATUS -CDSLIB cds.lib -V93 -WORK gctrl_lib -LOGFILE hdl.log -APPEND_LOG -ERRORMAX 15 \
	../rtl/asic_k.vhd

exec ncvlog -NOCOPYRIGHT -UPDATE -STATUS -CDSLIB cds.lib -WORK gctrl_lib -LOGFILE hdl.log -APPEND_LOG -ERRORMAX 15 -LINEDEBUG \
    ../simulation_fixes/FGTIE_G_A.v \
	gate_models/gctrl/current/gctrl.v
exec ncsdfc gate_models/gctrl/current/gctrl.sdf
	

exec ncvlog -NOCOPYRIGHT -UPDATE -STATUS -CDSLIB cds.lib -WORK tdc_lib -LOGFILE hdl.log -APPEND_LOG -ERRORMAX 15 -LINEDEBUG \
    ../gate_tdc/dfm.v
exec ncsdfc ../gate_tdc/dfm.sdf

# Load Testbenches 
exec ncvhdl -NOCOPYRIGHT -UPDATE -STATUS -CDSLIB cds.lib -V93 -WORK worklib -LOGFILE hdl.log -APPEND_LOG -ERRORMAX 15 -LINEDEBUG \
	../testbench/txt_util.vhd \
	../testbench/asic_i2c.vhd \
	../testbench/8b10_dec.vhd \
	../testbench/asic_rx.vhd \
	../testbench/asic_math.vhd \
	../testbench/latched_comparator.vhd \
	../testbench/tdc_emulator.vhd \
	../testbench/channel_emulator.vhd \
	../testbench/asic_64_tb.vhd \
	../testbench/asic_64_tb2.vhd \
	../testbench/asic_64_tb3.vhd \
	../testbench/tdc_tb3.vhd



set delayOption MAXDELAYS 

exec ncelab -cdslib cds.lib -logfile ncelab.log -errormax 15 -access +wc -status \
	-TIMESCALE 1ns/10ps \
	-SDF_CMD_FILE sdf.cmd -${delayOption} \
	worklib.asic_64_tb:behavioral

exec ncelab -cdslib cds.lib -logfile ncelab.log -errormax 15 -access +wc -status \
	-TIMESCALE 1ns/10ps \
	-SDF_CMD_FILE sdf.cmd -${delayOption} \
	worklib.asic_64_tb3:behavioral	

exec ncelab -cdslib cds.lib -logfile ncelab.log -errormax 15 -access +wc -status \
	-TIMESCALE 1ns/10ps \
	-SDF_CMD_FILE sdf.cmd -${delayOption} \
	worklib.tdc_tb3:behavioral	
