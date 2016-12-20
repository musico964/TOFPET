exec ncvhdl -NOCOPYRIGHT -UPDATE -STATUS -CDSLIB cds.lib -V93 -WORK tdc_lib -LOGFILE hdl.log -APPEND_LOG -ERRORMAX 15 -LINEDEBUG \
        ../rtl_tdc/asyn_hitvalidation.vhd \
        ../rtl_tdc/sync_hitvalidation.vhd \
        ../rtl_tdc/clk_divider.vhd \
        ../rtl_tdc/coarsereg.vhd \
        ../rtl_tdc/CONV_CTRL.vhd \
        ../rtl_tdc/counter4bit.vhd \
        ../rtl_tdc/enc4x2.vhd \
        ../rtl_tdc/fifo4.vhd \
        ../rtl_tdc/fifo_ctrl.vhd \
        ../rtl_tdc/FIFO_reg4.vhd \
        ../rtl_tdc/in_enc4x2.vhd \
        ../rtl_tdc/net_latch_asyn_neg_reset.vhd \
        ../rtl_tdc/pet_latch_asyn_neg_reset.vhd \
        ../rtl_tdc/READ_CTRL.vhd \
        ../rtl_tdc/reg10bit.vhd \
        ../rtl_tdc/reg1bit.vhd \
        ../rtl_tdc/reg2bit.vhd \
        ../rtl_tdc/TDC_CTRL_top.vhd \
        ../rtl_tdc/wrdecoder4.vhd \
        ../rtl_tdc/WRITE_CTRL.vhd \
        ../rtl_tdc/wtacgenerator.vhd \
        ../rtl_tdc/TDC_CTRL_top.vhd
