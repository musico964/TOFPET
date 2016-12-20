file delete hdl.log
source load_gctrl_rtl.tcl

# Load Testbenches 
exec ncvhdl -NOCOPYRIGHT -UPDATE -STATUS -CDSLIB cds.lib -V93 -WORK worklib -LOGFILE hdl.log -APPEND_LOG -ERRORMAX 15 \
	../testbench/8b10_dec.vhd \
	../testbench/asic_i2c.vhd \
	../testbench/gctrl_64mx_tb_data.vhd \
	../testbench/mux64_tb.vhd \
	../testbench/gctrl_64mx_tb_cfg.vhd
	
#exec ncelab -cdslib cds.lib -logfile ncelab.log -errormax 15 -access +wc -status worklib.mux64_tb:behavioral
exec ncelab -cdslib cds.lib -logfile ncelab.log -errormax 15 -access +wc -status worklib.gctrl_64mx_tb_data:behavioral
exec ncelab -cdslib cds.lib -logfile ncelab.log -errormax 15 -access +wc -status worklib.gctrl_64mx_tb_cfg:behavioral
