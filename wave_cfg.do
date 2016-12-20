onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label Cs -radix hexadecimal /_a_TofPetInterface_tb/Dut/CS
add wave -noupdate -label Sclk /_a_TofPetInterface_tb/Dut/SCLK
add wave -noupdate -label Sdi /_a_TofPetInterface_tb/Dut/SDI
add wave -noupdate -label Sdo /_a_TofPetInterface_tb/Dut/SDO
add wave -noupdate -label GotAck /_a_TofPetInterface_tb/Dut/GotAck
add wave -noupdate -label fsm_status -radix unsigned /_a_TofPetInterface_tb/Dut/ReadWriteSequencer/fsm_status
add wave -noupdate -label FifoDataIn -radix hexadecimal /_a_TofPetInterface_tb/Dut/ReadWriteSequencer/FIFO_DATA_IN
add wave -noupdate -label FifoRead /_a_TofPetInterface_tb/Dut/ReadWriteSequencer/fifo_read
add wave -noupdate -label FifoDataOut -radix hexadecimal /_a_TofPetInterface_tb/Dut/ReadWriteSequencer/FIFO_DATA_OUT
add wave -noupdate -label FifoWrite /_a_TofPetInterface_tb/Dut/ReadWriteSequencer/fifo_write
add wave -noupdate -label shreg -radix hexadecimal /_a_TofPetInterface_tb/Dut/ReadWriteSequencer/shreg
add wave -noupdate -label bit_counter -radix unsigned /_a_TofPetInterface_tb/Dut/ReadWriteSequencer/bit_counter
add wave -noupdate -label n2_counter -radix unsigned /_a_TofPetInterface_tb/Dut/ReadWriteSequencer/n2_counter
add wave -noupdate -divider {CONFIG CONTROLLER}
add wave -noupdate -label cmd_r /_a_TofPetInterface_tb/TofPetAsic_Controller/cfg_ctrl/cmd_r
add wave -noupdate -label cmd_c /_a_TofPetInterface_tb/TofPetAsic_Controller/cfg_ctrl/cmd_c
add wave -noupdate -label addr_r -radix unsigned /_a_TofPetInterface_tb/TofPetAsic_Controller/cfg_ctrl/addr_r
add wave -noupdate -label payload_r -radix unsigned /_a_TofPetInterface_tb/TofPetAsic_Controller/cfg_ctrl/payload_r
add wave -noupdate -label state /_a_TofPetInterface_tb/TofPetAsic_Controller/cfg_ctrl/state
add wave -noupdate -label bit_counter -radix decimal /_a_TofPetInterface_tb/TofPetAsic_Controller/cfg_ctrl/bit_counter
add wave -noupdate -label crc_read_r -radix hexadecimal /_a_TofPetInterface_tb/TofPetAsic_Controller/cfg_ctrl/crc_read_r
add wave -noupdate -label crc_calc -radix hexadecimal /_a_TofPetInterface_tb/TofPetAsic_Controller/cfg_ctrl/crc_calc
add wave -noupdate -divider TEST_PULSE
add wave -noupdate -label TEST_CMD /_a_TofPetInterface_tb/Dut/TestGenerator/TEST_CMD
add wave -noupdate -label sync_test_cmd /_a_TofPetInterface_tb/Dut/TestGenerator/sync_test_cmd
add wave -noupdate -label SYNC_TIMEBASE /_a_TofPetInterface_tb/Dut/TestGenerator/SYNC_TIMEBASE
add wave -noupdate -label sync_time0 /_a_TofPetInterface_tb/Dut/TestGenerator/sync_time0
add wave -noupdate -label TEST_OUT /_a_TofPetInterface_tb/Dut/TestGenerator/TEST_OUT
add wave -noupdate -label DELAY -radix hexadecimal /_a_TofPetInterface_tb/Dut/TestGenerator/DELAY
add wave -noupdate -label POLARITY /_a_TofPetInterface_tb/Dut/TestGenerator/POLARITY
add wave -noupdate -label WIDTH_HI -radix hexadecimal /_a_TofPetInterface_tb/Dut/TestGenerator/WIDTH_HI
add wave -noupdate -label WIDTH_LO -radix hexadecimal /_a_TofPetInterface_tb/Dut/TestGenerator/WIDTH_LO
add wave -noupdate -label delay_counter -radix hexadecimal /_a_TofPetInterface_tb/Dut/TestGenerator/delay_counter
add wave -noupdate -label width0_counter -radix hexadecimal /_a_TofPetInterface_tb/Dut/TestGenerator/width0_counter
add wave -noupdate -label width1_counter -radix hexadecimal /_a_TofPetInterface_tb/Dut/TestGenerator/width1_counter
add wave -noupdate -color Magenta -label fsm_status -radix unsigned /_a_TofPetInterface_tb/Dut/TestGenerator/fsm_status
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {56406700 ps} 0} {{Cursor 2} {56400500 ps} 0}
configure wave -namecolwidth 157
configure wave -valuecolwidth 66
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {57336398 ps} {60010436 ps}
