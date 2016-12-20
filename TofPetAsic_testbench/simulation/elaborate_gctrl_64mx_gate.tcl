file delete hdl.log

exec ncvhdl -NOCOPYRIGHT -UPDATE -STATUS -CDSLIB cds.lib -V93 -WORK gctrl_lib -LOGFILE hdl.log -APPEND_LOG -ERRORMAX 15 \
	../rtl/asic_k.vhd

exec ncvlog -NOCOPYRIGHT -UPDATE -STATUS -CDSLIB cds.lib -WORK gctrl_lib -LOGFILE hdl.log -APPEND_LOG -ERRORMAX 15 -LINEDEBUG \
    ../simulation_fixes/FGTIE_G_A.v \
	gate_models/gctrl/current/gctrl.v
	
exec ncsdfc gate_models/gctrl/current/gctrl.sdf
	
exec ncvhdl -NOCOPYRIGHT -UPDATE -STATUS -CDSLIB cds.lib -V93 -WORK worklib -LOGFILE hdl.log -APPEND_LOG -ERRORMAX 15 \
	../testbench/asic_i2c.vhd \
	../testbench/8b10_dec.vhd \
	../testbench/gctrl_64mx_tb_data.vhd \
	../testbench/gctrl_64mx_tb_cfg.vhd
	
exec ncelab -cdslib cds.lib -logfile ncelab.log -errormax 15 -access +wc -status \
	-TIMESCALE 1ns/10ps \
	-SDF_CMD_FILE sdf.cmd -MAXDELAYS \
	worklib.gctrl_64mx_tb_data:behavioral
	
exec ncelab -cdslib cds.lib -logfile ncelab.log -errormax 15 -access +wc -status \
	-TIMESCALE 1ns/10ps \
	-SDF_CMD_FILE sdf.cmd -MAXDELAYS \
	worklib.gctrl_64mx_tb_cfg:behavioral	