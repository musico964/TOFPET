exec ncvhdl -NOCOPYRIGHT -UPDATE -STATUS -CDSLIB cds.lib -V93 -WORK gctrl_lib -LOGFILE hdl.log -APPEND_LOG -ERRORMAX 15 -LINEDEBUG \
	../rtl/asic_k.vhd \
	../rtl/arithm.vhd \
	../rtl/full_data.vhd \
	../rtl/test_frame_generator.vhd \
	../rtl/encoder_8b10b.vhd \
	../rtl/channel.vhd \
	../rtl/config_controller.vhd \
	../rtl/word_fifo.vhd \
	../rtl/frame_buffer.vhd \
	../rtl/frame_formater.vhd \
	../rtl/frame_block.vhd \
	../rtl/pulse_generator.vhd \
	../rtl/sdr_output.vhd \
	../rtl/ddr_output.vhd \
	../rtl/encoder_8b10b.vhd \
	../rtl/tx_lane.vhd \
	../rtl/tx_block.vhd \
	../rtl/tdc_reset_generator.vhd \
	../rtl/tac_refresh_generator.vhd \
	../rtl/channel_count_generator.vhd \
	../rtl/mux64_decoder.vhd \
	../rtl/mux4.vhd \
	../rtl/mux64.vhd \
	../rtl/gctrl_64mx.vhd 
