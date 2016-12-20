#!/usr/bin/python

nChannels = 64;

for c in range(nChannels):
	print """  -- Channel %(c)d
  ch%(c)d_clk => cir(%(c)d).clk,
  ch%(c)d_reset_bar => cir(%(c)d).reset_bar,
  ch%(c)d_frame_id => cir(%(c)d).frame_id,
  ch%(c)d_ctime => cir(%(c)d).ctime,
  ch%(c)d_tac_refresh_pulse => cir(%(c)d).tac_refresh_pulse,
  ch%(c)d_test_pulse => cir(%(c)d).test_pulse,
  ch%(c)d_ev_data_valid => cir(%(c)d).ev_data_valid,
  ch%(c)d_ev_data => cir(%(c)d).ev_data,
  ch%(c)d_dark_strobe => cir(%(c)d).dark_strobe,
  ch%(c)d_trig_err_strobe => cir(%(c)d).trig_err_strobe,
  ch%(c)d_config => cir(%(c)d).config,
  ch%(c)d_tconfig => cir(%(c)d).tconfig,
""" % locals()