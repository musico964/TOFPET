for {set n 0} {$n < 64} {incr n} {
	## Supress _gen, because DOx pulses may violate clock minimum pulse width
	## Supress 1st _buf, because _gen output is asynchronous with clock

	## Basic
	tcheck ":CHANNEL_GENERATOR($n):CHANNEL:TDC:TDC.dut_wtacgenerator_T.DOxL_buf.Q_reg" -off
	tcheck ":CHANNEL_GENERATOR($n):CHANNEL:TDC:TDC.dut_wtacgenerator_E.DOxL_buf.Q_reg" -off
	tcheck ":CHANNEL_GENERATOR($n):CHANNEL:TDC:TDC.DOEL_buf.Q_reg" -off
	tcheck ":CHANNEL_GENERATOR($n):CHANNEL:TDC:TDC.dut_wtacgenerator_T.DOxL_gen.Q_reg" -off
	tcheck ":CHANNEL_GENERATOR($n):CHANNEL:TDC:TDC.dut_wtacgenerator_E.DOxL_gen.Q_reg" -off
	tcheck ":CHANNEL_GENERATOR($n):CHANNEL:TDC:TDC.DOEL_gen.Q_reg" -off
	

	## Used by async mode
	tcheck ":CHANNEL_GENERATOR($n):CHANNEL:TDC:TDC.dut_asyn_hitvalidation.validhit_buf.Q_reg" -off
	tcheck ":CHANNEL_GENERATOR($n):CHANNEL:TDC:TDC.dut_asyn_hitvalidation.falsehit_buf.Q_reg" -off
	tcheck ":CHANNEL_GENERATOR($n):CHANNEL:TDC:TDC.dut_asyn_hitvalidation.validhit_gen.Q_reg" -off
	tcheck ":CHANNEL_GENERATOR($n):CHANNEL:TDC:TDC.dut_asyn_hitvalidation.falsehit_gen.Q_reg" -off
}
