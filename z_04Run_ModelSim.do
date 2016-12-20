
vsim -t 1ps -L altera_lib -L rtl_work -L work -L gctrl_lib -novopt _a_TofPetInterface_tb

do wave.do

view structure
view signals
run -all
