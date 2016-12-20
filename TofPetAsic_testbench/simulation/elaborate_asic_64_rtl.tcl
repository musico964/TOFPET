file delete hdl.log
source load_gctrl_rtl.tcl
source load_tdc_rtl.tcl

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

exec ncelab -cdslib cds.lib -logfile ncelab.log -errormax 15 -access +wc -status worklib.asic_64_tb:behavioral
exec ncelab -cdslib cds.lib -logfile ncelab.log -errormax 15 -access +wc -status worklib.asic_64_tb2:behavioral
exec ncelab -cdslib cds.lib -logfile ncelab.log -errormax 15 -access +wc -status worklib.asic_64_tb3:behavioral
exec ncelab -cdslib cds.lib -logfile ncelab.log -errormax 15 -access +wc -status worklib.tdc_tb3:behavioral
