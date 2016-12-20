if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work
vlog -vlog01compat -work rtl_work {C:/Users/musico/Documents/INFN/TOPEM/EndoProbe/AlteraDevelBoards/DK-DEV-A2GX125N_Eth/CtrlFifo_32x32.v}
vlog -vlog01compat -work rtl_work {C:/Users/musico/Documents/INFN/TOPEM/EndoProbe/AlteraDevelBoards/DK-DEV-A2GX125N_Eth/DataFifo_2048x32.v}
vlog -vlog01compat -work rtl_work {C:/Users/musico/Documents/INFN/TOPEM/EndoProbe/AlteraDevelBoards/DK-DEV-A2GX125N_Eth/TofPetInterface.v}
vlog -vlog01compat -work rtl_work {C:/Users/musico/Documents/INFN/TOPEM/EndoProbe/AlteraDevelBoards/DK-DEV-A2GX125N_Eth/TofPet_Avalon_MM_IF.v}
vlog -vlog01compat -work rtl_work {C:/Users/musico/Documents/INFN/TOPEM/EndoProbe/AlteraDevelBoards/DK-DEV-A2GX125N_Eth/Ddr_In.v}
vlog -vlog01compat -work rtl_work {C:/Users/musico/Documents/INFN/TOPEM/EndoProbe/AlteraDevelBoards/DK-DEV-A2GX125N_Eth/dec_8b_10b.vo}
#vlog -vlog01compat -work rtl_work {C:/Users/musico/Documents/INFN/TOPEM/EndoProbe/AlteraDevelBoards/DK-DEV-A2GX125N_Eth/dec_8b_10b_dec8b10b.v}
#vcom -work rtl_work {C:/Users/musico/Documents/INFN/TOPEM/EndoProbe/AlteraDevelBoards/DK-DEV-A2GX125N_Eth/dec_8b10b.vhd}
vlog -vlog01compat -work rtl_work {C:/Users/musico/Documents/INFN/TOPEM/EndoProbe/AlteraDevelBoards/DK-DEV-A2GX125N_Eth/TofPetInterface_tb.v}
