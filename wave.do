onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label CK /_a_TofPetInterface_tb/Dut/CK
add wave -noupdate -label LFCK /_a_TofPetInterface_tb/Dut/LFCK
add wave -noupdate -label RESETb /_a_TofPetInterface_tb/Dut/RESETb
add wave -noupdate -label SyncRst /_a_TofPetInterface_tb/Dut/SYNC_RST
add wave -noupdate -label TestPulse /_a_TofPetInterface_tb/Dut/TEST_PULSE
add wave -noupdate -label Cs -radix hexadecimal /_a_TofPetInterface_tb/Dut/CS
add wave -noupdate -label Sclk /_a_TofPetInterface_tb/Dut/SCLK
add wave -noupdate -label Sdi /_a_TofPetInterface_tb/Dut/SDI
add wave -noupdate -label Sdo /_a_TofPetInterface_tb/Dut/SDO
add wave -noupdate -divider {Avalon BUS}
add wave -noupdate -label avalon_addr -radix hexadecimal /_a_TofPetInterface_tb/avalon_addr
add wave -noupdate -label avalon_din -radix hexadecimal /_a_TofPetInterface_tb/avalon_din
add wave -noupdate -label avalon_dout -radix hexadecimal /_a_TofPetInterface_tb/avalon_dout
add wave -noupdate -label avalon_cs /_a_TofPetInterface_tb/avalon_cs
add wave -noupdate -label avalon_rdB /_a_TofPetInterface_tb/avalon_readB
add wave -noupdate -label avalon_wrB /_a_TofPetInterface_tb/avalon_writeB
add wave -noupdate -divider GCTL
add wave -noupdate -label tx_mode /_a_TofPetInterface_tb/TofPetAsic_Controller/tx/tx_mode
add wave -noupdate -label di -radix hexadecimal /_a_TofPetInterface_tb/TofPetAsic_Controller/tx/tx_lane0/di
add wave -noupdate -label ki /_a_TofPetInterface_tb/TofPetAsic_Controller/tx/tx_lane0/ki
add wave -noupdate -label enc_do -radix hexadecimal /_a_TofPetInterface_tb/TofPetAsic_Controller/tx/tx_lane0/enc_do
add wave -noupdate -label state_x2 /_a_TofPetInterface_tb/TofPetAsic_Controller/tx/state_x2
add wave -noupdate -divider {CH 0}
add wave -noupdate -label TX0 /_a_TofPetInterface_tb/Dut/Ch0/TX0
add wave -noupdate -label TX1 /_a_TofPetInterface_tb/Dut/Ch0/TX1
add wave -noupdate -label DDRMODE /_a_TofPetInterface_tb/Dut/Ch0/DDRMODE
add wave -noupdate -label TXMODE /_a_TofPetInterface_tb/Dut/Ch0/TXMODE
add wave -noupdate -label k_0 /_a_TofPetInterface_tb/Dut/Ch0/k_0
add wave -noupdate -label data_valid0 /_a_TofPetInterface_tb/Dut/Ch0/data_valid0
add wave -noupdate -label sdr0_shreg -radix hexadecimal /_a_TofPetInterface_tb/Dut/Ch0/sdr0_shreg
add wave -noupdate -label reg8_0 -radix hexadecimal /_a_TofPetInterface_tb/Dut/Ch0/reg8_0
add wave -noupdate -divider {CH0 Sync0 Machine}
add wave -noupdate -label DATA -radix hexadecimal /_a_TofPetInterface_tb/Dut/Ch0/reg0
add wave -noupdate -label bit_value -radix unsigned /_a_TofPetInterface_tb/Dut/Ch0/SyncGenerator0/bit_value
add wave -noupdate -label fsm_status -radix unsigned /_a_TofPetInterface_tb/Dut/Ch0/SyncGenerator0/fsm_status
add wave -noupdate -label K28_5 /_a_TofPetInterface_tb/Dut/Ch0/SyncGenerator0/K28_5
add wave -noupdate -label K28_1 /_a_TofPetInterface_tb/Dut/Ch0/SyncGenerator0/K28_1
add wave -noupdate -label SYNCED /_a_TofPetInterface_tb/Dut/Ch0/SyncGenerator0/SYNCED
add wave -noupdate -label RUNNING /_a_TofPetInterface_tb/Dut/Ch0/SyncGenerator0/RUNNING
add wave -noupdate -label LOAD_REG /_a_TofPetInterface_tb/Dut/Ch0/SyncGenerator0/LOAD_REG
add wave -noupdate -label valid_count -radix unsigned /_a_TofPetInterface_tb/Dut/Ch0/SyncGenerator0/valid_count
add wave -noupdate -label sync_count -radix unsigned /_a_TofPetInterface_tb/Dut/Ch0/SyncGenerator0/sync_count
add wave -noupdate -divider {CH0 Pack Machine}
add wave -noupdate -label DATA0 -radix hexadecimal /_a_TofPetInterface_tb/Dut/Ch0/FifoDataGenerator/DATA0
add wave -noupdate -label DATA1 -radix hexadecimal /_a_TofPetInterface_tb/Dut/Ch0/FifoDataGenerator/DATA1
add wave -noupdate -label FIFO_DATA_OUT -radix hexadecimal /_a_TofPetInterface_tb/Dut/DATA_OUT0
add wave -noupdate -label FIFO_READ /_a_TofPetInterface_tb/Dut/READ0
add wave -noupdate -label DataFifoWr /_a_TofPetInterface_tb/Dut/Ch0/FifoWr
add wave -noupdate -label FifoDataIn -radix hexadecimal /_a_TofPetInterface_tb/Dut/Ch0/FifoDataIn
add wave -noupdate -label fsm_status -radix unsigned /_a_TofPetInterface_tb/Dut/Ch0/FifoDataGenerator/fsm_status
add wave -noupdate -label DATA_VALID /_a_TofPetInterface_tb/Dut/Ch0/FifoDataGenerator/DATA_VALID
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {58390225 ps} 0} {{Cursor 2} {114908941 ps} 0}
configure wave -namecolwidth 136
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
WaveRestoreZoom {76339190 ps} {78764074 ps}
