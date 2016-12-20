`timescale 1ns/100ps

module _a_TofPetInterface_tb;

parameter master_ck_period = 10;	// 100 MHz
parameter master_ck_half_period = master_ck_period / 2;
parameter master_ck_hold  = 1;	// data hold time

parameter slow_ck_period = 100;	// 10 MHz
parameter slow_ck_half_period = slow_ck_period / 2;
parameter slow_ck_hold  = 1;	// data hold time

//parameter tofpet_ck_period = 12.5;	// 80 MHz
parameter tofpet_ck_period = 6.25;	// 160 MHz
parameter tofpet_ck_half_period = tofpet_ck_period / 2;
parameter tofpet_tco  = 1;	// clock to output time

integer i, j;
reg echo;
reg Master_clock, Slow_clock, TofPet_clock, Master_resetB;
wire read0, read1, read2, read3, read4, read5;
wire [31:0] ctrl_fifo_in, nbit_inout, command_word;
wire ctrl_fifo_out_re, ctrl_fifo_in_we;
reg [5:0] tx0, tx1;
reg [3:0]	avalon_addr;
reg [31:0]	avalon_din;
wire [31:0]	avalon_dout;
reg	avalon_cs, avalon_readB, avalon_writeB;

wire [31:0] data_out0, data_out1, data_out2, data_out3, data_out4, data_out5;
wire [31:0] status_word, ctrl_fifo_out;
wire [10:0] usedw0, usedw1, usedw2, usedw3, usedw4, usedw5;
wire empty0, empty1, empty2, empty3, empty4, empty5;
wire full0, full1, full2, full3, full4, full5;
wire sync_rst, test_pulse, fe_enableB, sclk, sdi;
wire [5:0] clko, chip_select;
wire [2:0] fe_select;
wire clko_gctrl, tx0_gctrl, tx1_gctrl, clk_oe, tx1_oe, sdo_oe, sdo;
assign clko = {TofPet_clock,TofPet_clock,TofPet_clock,TofPet_clock,TofPet_clock,TofPet_clock};

gctrl_64mx TofPetAsic_Controller(
    .clk_i(TofPet_clock),    
    .sync_rst_i(sync_rst),
    .test_pulse_i(test_pulse),
    .clk_o(clko_gctrl),
    .clk_oe(clk_oe),
    .tx0_o(tx0_gctrl),
    .tx1_o(tx1_gctrl),
    .tx1_oe(tx1_oe),
    .sclk_i(sclk),
    .cs_i(chip_select[0]),
    .sdi_i(sdi),
    .sdo_o(sdo),
    .sdo_oe(sdo_oe),
	
	.gconfig_o(),
	.gtconfig_o(),
	.global_cal_en_o(),
	.test_pulse_o(),
	
	.ch0_clk(),
	.ch0_reset_bar(),
	.ch0_frame_id(),
	.ch0_ctime(),
	.ch0_tac_refresh_pulse(),
	.ch0_test_pulse(),
	.ch0_ev_data_valid(1'b0),
	.ch0_ev_data(53'b0),
	.ch0_dark_strobe(1'b0),
	.ch0_trig_err_strobe(1'b0),
	.ch0_config(),
	.ch0_tconfig()
// other 63 channel interface here...

);

TofPetInterface Dut(
	.TOFPET_CK(TofPet_clock),	// 160 MHz
	.CK(Master_clock),	// 100 MHz
	.LFCK(Slow_clock),
	.RESETb(Master_resetB),

// Processor Interface	
	.DATA_OUT0(data_out0),
	.EMPTY0(empty0),
	.FULL0(full0),
	.READ0(read0),
	.USED_WORDS0(usedw0),
	.DATA_OUT1(data_out1),
	.EMPTY1(empty1),
	.FULL1(full1),
	.READ1(read1),
	.USED_WORDS1(usedw1),
	.DATA_OUT2(data_out2),
	.EMPTY2(empty2),
	.FULL2(full2),
	.READ2(read2),
	.USED_WORDS2(usedw2),
	.DATA_OUT3(data_out3),
	.EMPTY3(empty3),
	.FULL3(full3),
	.READ3(read3),
	.USED_WORDS3(usedw3),
	.DATA_OUT4(data_out4),
	.EMPTY4(empty4),
	.FULL4(full4),
	.READ4(read4),
	.USED_WORDS4(usedw4),
	.DATA_OUT5(data_out5),
	.EMPTY5(empty5),
	.FULL5(full5),
	.READ5(read5),
	.USED_WORDS5(usedw5),
	
	.CTRL_FIFO_OUT(ctrl_fifo_out),
	.CTRL_FIFO_OUT_RE(ctrl_fifo_out_re),
	.CTRL_FIFO_IN(ctrl_fifo_in),
	.CTRL_FIFO_IN_WE(ctrl_fifo_in_we),
	.NBIT_INOUT(nbit_inout),
	.COMMAND(command_word),
	.STATUS(status_word),
	
// TofPet ASIC interface
//	.CLKO_0(clko[0]),
//	.TX0_0(tx0[0]),
//	.TX1_0(tx1[0]),
	.CLKO_0(clko_gctrl),
	.TX0_0(tx0_gctrl),
	.TX1_0(tx1_gctrl),
	.CLKO_1(clko[1]),
	.TX0_1(tx0[1]),
	.TX1_1(tx1[1]),
	.CLKO_2(clko[2]),
	.TX0_2(tx0[2]),
	.TX1_2(tx1[2]),
	.CLKO_3(clko[3]),
	.TX0_3(tx0[3]),
	.TX1_3(tx1[3]),
	.CLKO_4(clko[4]),
	.TX0_4(tx0[4]),
	.TX1_4(tx1[4]),
	.CLKO_5(clko[5]),
	.TX0_5(tx0[5]),
	.TX1_5(tx1[5]),

	.SYNC_RST(sync_rst),
	.TEST_PULSE(test_pulse),
	.CS(chip_select),
	.SCLK(sclk),
	.SDI(sdi),
	.SDO(sdo),
	
// FrontEnd selector
	.FE_SELECT(fe_select),
	.FE_ENABLEb(fe_enableB)

);

TofPetInterface_AvalonIF MM_IF(
	.CK(Master_clock),	// 100 MHz
	.RESETb(Master_resetB),

// TofPet module Interface	
	.DATA_OUT0(data_out0),
	.EMPTY0(empty0),
	.FULL0(full0),
	.READ0(read0),
	.USED_WORDS0(usedw0),
	.DATA_OUT1(data_out1),
	.EMPTY1(empty1),
	.FULL1(full1),
	.READ1(read1),
	.USED_WORDS1(usedw1),
	.DATA_OUT2(data_out2),
	.EMPTY2(empty2),
	.FULL2(full2),
	.READ2(read2),
	.USED_WORDS2(usedw2),
	.DATA_OUT3(data_out3),
	.EMPTY3(empty3),
	.FULL3(full3),
	.READ3(read3),
	.USED_WORDS3(usedw3),
	.DATA_OUT4(data_out4),
	.EMPTY4(empty4),
	.FULL4(full4),
	.READ4(read4),
	.USED_WORDS4(usedw4),
	.DATA_OUT5(data_out5),
	.EMPTY5(empty5),
	.FULL5(full5),
	.READ5(read5),
	.USED_WORDS5(usedw5),
	
	.CTRL_FIFO_OUT(ctrl_fifo_out),
	.CTRL_FIFO_OUT_RE(ctrl_fifo_out_re),
	.CTRL_FIFO_IN(ctrl_fifo_in),
	.CTRL_FIFO_IN_WE(ctrl_fifo_in_we),
	.NBIT_INOUT(nbit_inout),
	.COMMAND(command_word),
	.STATUS_WORD(status_word),
	
// Avalon MM interface
	.avalon_addr(avalon_addr),
	.avalon_data_in(avalon_din),
	.avalon_data_out(avalon_dout),
	.avalon_cs(avalon_cs),
	.avalon_readn(avalon_readB),
	.avalon_writen(avalon_writeB)
	);

// Time 0 values
initial
begin
	echo = 1;
	Master_clock = 0;
	Slow_clock = 0;
	TofPet_clock = 0;
	Master_resetB = 1;
	avalon_addr = 0;
	avalon_din = 0;
	avalon_cs = 0;
	avalon_readB = 1;
	avalon_writeB = 1;
	
end

// Main test vectors
initial
begin
	Sleep(2);
	issue_RESET;
	Sleep(100);

	TofPet_Reset;
	Sleep(10);
	TofPet_WideReset;
	Sleep(10);
	CtrlFifo_Reset;
	Sleep(10);
	DataFifo_Reset;
	Sleep(10);

// Global configuration Write: 110+1 bit: TX_MODE = 0, DDR_MODE = 0, TEST_PATTERN = 0 -- OK
	CtrlFifo_Write(32'h88208203);
	Sleep(5);
	CtrlFifo_Write(32'h430C5B40);
	Sleep(5);
	CtrlFifo_Write(32'h8ECAE090);
	Sleep(5);
	CtrlFifo_Write(32'h000E0D00);
	Sleep(5);
	TofPet_Write(8'h7A,8'h1,6'd1);
	Sleep(10);
	while(status_word[30] == 1'b1)
		Sleep(1);
	Sleep(10);

/*
// Global configuration Write: 110+1 bit: TX_MODE = 1, DDR_MODE = 0, TEST_PATTERN = 0 -- OK
	CtrlFifo_Write(32'h88208203);
	Sleep(5);
	CtrlFifo_Write(32'h430C5B40);
	Sleep(5);
	CtrlFifo_Write(32'h8ECAE090);
	Sleep(5);
	CtrlFifo_Write(32'h000E4CC0);
	Sleep(5);
	TofPet_Write(8'h7A,8'h1,6'd1);
	Sleep(10);
	while(status_word[30] == 1'b1)
		Sleep(1);
	Sleep(10);
*/
/*
// Global configuration Write: 110+1 bit: TX_MODE = 0, DDR_MODE = 0, TEST_PATTERN = 1 -- OK
	CtrlFifo_Write(32'h88208203);
	Sleep(5);
	CtrlFifo_Write(32'h430C5B40);
	Sleep(5);
	CtrlFifo_Write(32'h8ECAE0D0);
	Sleep(5);
	CtrlFifo_Write(32'h000C0680);
	Sleep(5);
	TofPet_Write(8'h7A,8'h1,6'd1);
	Sleep(10);
	while(status_word[30] == 1'b1)
		Sleep(1);
	Sleep(10);
*/
/*
// Global configuration Write: 110+1 bit: TX_MODE = 1, DDR_MODE = 0, TEST_PATTERN = 1 -- OK
	CtrlFifo_Write(32'h88208203);
	Sleep(5);
	CtrlFifo_Write(32'h430C5B40);
	Sleep(5);
	CtrlFifo_Write(32'h8ECAE0D0);
	Sleep(5);
	CtrlFifo_Write(32'h000C4740);
	Sleep(5);
	TofPet_Write(8'h7A,8'h1,6'd1);
	Sleep(10);
	while(status_word[30] == 1'b1)
		Sleep(1);
	Sleep(10);
*/
//	TofPet_Reset;
//	Sleep(100);
/*
// Global Test Config Write: 7+1 bit -- OK
	CtrlFifo_Write(32'hCFDC0000);
	Sleep(5);
	CtrlFifo_Write(32'h00000000);
	Sleep(5);
	CtrlFifo_Write(32'h00000000);
	Sleep(5);
	CtrlFifo_Write(32'h00000000);
	Sleep(5);
	TofPet_Write(8'h13,8'h1,6'd1);
	Sleep(10);
	while(status_word[30] == 1'b1)
		Sleep(1);
	Sleep(10);
*/
// Channel 0 Config Write: 53+53 bit -- OK
	Sleep(500);
	CtrlFifo_Reset;
	Sleep(10);
	CtrlFifo_Write(32'h00070843);
	Sleep(5);
	CtrlFifo_Write(32'hBE8FDFA0);
	Sleep(5);
	CtrlFifo_Write(32'h33000000);
	Sleep(5);
	CtrlFifo_Write(32'h00000000);
	Sleep(5);
	TofPet_Write(8'h48,8'h35,6'd1);
	Sleep(10);
	while(status_word[30] == 1'b1)
		Sleep(1);
	Sleep(10);
/*
// Channel 0 Test Config Write: 1+1 bit -- OK
	CtrlFifo_Write(32'h201EC000);
	Sleep(5);
	CtrlFifo_Write(32'h00000000);
	Sleep(5);
	CtrlFifo_Write(32'h00000000);
	Sleep(5);
	CtrlFifo_Write(32'h00000000);
	Sleep(5);
	TofPet_Write(8'h14,8'h1,6'd1);
	Sleep(10);
	while(status_word[30] == 1'b1)
		Sleep(1);
	Sleep(10);

// Channel 0 Config Read: 19+61 bit -- OK
	Sleep(10);
	CtrlFifo_Reset;
	Sleep(10);
	CtrlFifo_Write(32'h100D4000);
	Sleep(5);
	TofPet_Read(8'd19,8'd61,6'd1);
	Sleep(100);
	CtrlFifo_Read;
	Sleep(10);
	CtrlFifo_Read;
	Sleep(10);
	while(status_word[30] == 1'b1)
		Sleep(1);
	Sleep(10);
*/
// Global Config Read: 12+118 bit -- OK
	Sleep(10);
	CtrlFifo_Reset;
	Sleep(10);
	CtrlFifo_Write(32'h9A700000);
	Sleep(5);
	TofPet_Read(8'd12,8'd118,6'd1);
	Sleep(10);
	while(status_word[30] == 1'b1)
		Sleep(1);
	Sleep(10);
	CtrlFifo_Read;
	Sleep(10);
	CtrlFifo_Read;
	Sleep(10);
	CtrlFifo_Read;
	Sleep(10);
	CtrlFifo_Read;
	Sleep(10);

// Dark counter channel 0 read
	Sleep(10);
	CtrlFifo_Reset;
	Sleep(10);
	CtrlFifo_Write(32'h40192000);
	Sleep(5);
	TofPet_Read(8'd19,8'd18,6'd1);
	Sleep(10);
	while(status_word[30] == 1'b1)
		Sleep(1);
	Sleep(10);
	CtrlFifo_Read;
	Sleep(100);
	

// TEST pulse generator
//assign test_pulse_delay = NBIT_INOUT[17:8];
//assign test_pulse_width_low = NBIT_INOUT[30:24];
//assign test_pulse_polarity = NBIT_INOUT[31];
//assign test_pulse_tap_select = {COMMAND[31:30],COMMAND[15:14],COMMAND[7]};
	Avalon_MM_Write(4'hA, {1'b1, 7'h02, 6'h0, 10'h008, 8'h00});
	TofPet_Test;
	Sleep(1000);

/*	
//	TofPet_Read(8'd12,8'd15,6'd2);
//	TofPet_Read(8'd12,8'd61,6'd2);
	Sleep(2000);

	repeat(5)
	begin
		Avalon_MM_Read(4'h0);	// FIFO 0
		Sleep(2);
		Avalon_MM_Read(4'hD);	// Used Words 1, 0
		Sleep(20);
	end
*/


	Sleep(1000);
	
	Sleep(10);
	$stop();
end

// Free running clock generators
  initial
  begin
    #(master_ck_period-master_ck_hold)	Master_clock <= ~Master_clock;
    forever
      #master_ck_half_period	Master_clock <= ~Master_clock;
  end

  initial
  begin
    #(slow_ck_period-slow_ck_hold)	Slow_clock <= ~Slow_clock;
    forever
      #slow_ck_half_period	Slow_clock <= ~Slow_clock;
  end

  initial
  begin
    #(tofpet_ck_period-tofpet_tco)	TofPet_clock <= ~TofPet_clock;
    forever
      #tofpet_ck_half_period	TofPet_clock <= ~TofPet_clock;
  end

  
always @(posedge TofPet_clock)
begin
	#1					tx0 <= 0; tx1 <= 1;
	#tofpet_ck_period 	tx0 <= 1; tx1 <= 0;
	#tofpet_ck_period 	tx0 <= 0; tx1 <= 1;
	#tofpet_ck_period 	tx0 <= 1; tx1 <= 0;
	#tofpet_ck_period 	tx0 <= 1; tx1 <= 0;
	#tofpet_ck_period 	tx0 <= 1; tx1 <= 0;
	#tofpet_ck_period 	tx0 <= 1; tx1 <= 0;
	#tofpet_ck_period 	tx0 <= 1; tx1 <= 0;
	#tofpet_ck_period 	tx0 <= 0; tx1 <= 1;
	#tofpet_ck_period 	tx0 <= 0; tx1 <= 1;
	
	#tofpet_ck_period	tx1 <= 0; tx0 <= 1;
	#tofpet_ck_period 	tx1 <= 1; tx0 <= 0;
	#tofpet_ck_period 	tx1 <= 0; tx0 <= 1;
	#tofpet_ck_period 	tx1 <= 1; tx0 <= 0;
	#tofpet_ck_period 	tx1 <= 1; tx0 <= 0;
	#tofpet_ck_period 	tx1 <= 1; tx0 <= 0;
	#tofpet_ck_period 	tx1 <= 1; tx0 <= 0;
	#tofpet_ck_period 	tx1 <= 1; tx0 <= 0;
	#tofpet_ck_period 	tx1 <= 0; tx0 <= 1;
	#tofpet_ck_period 	tx1 <= 0; tx0 <= 1;
	
end

// Utility tasks
task Sleep;
input [31:0] waittime;
begin
	repeat(waittime)
		#master_ck_period;
end
endtask // Sleep
 
task issue_RESET;
begin
	if( echo == 1 )
		$display("# Reset @%0t",$stime);
	#master_ck_period Master_resetB = 0;
	repeat(20)
		#master_ck_period;
	Master_resetB = 1;
	#master_ck_period;
end
endtask // issue_RESET

task CtrlFifo_Write;
input [31:0] wr_data;
begin
	if( echo == 1 )
		$display("# CtrlFifo_Write @%0t: data=0x%0x",$stime, wr_data);
	Avalon_MM_Write(4'h9, wr_data);
end
endtask // CtrlFifo_Write

task CtrlFifo_Read;
begin
	Avalon_MM_Read(4'h8);
	if( echo == 1 )
		$display("# CtrlFifo_Read @%0t: data=0x%0x",$stime, avalon_dout);	
end
endtask // CtrlFifo_Read

task TofPet_Read;
input [7:0] n1, n2;
input [5:0] select;
begin
	if( echo == 1 )
		$display("# TofPet_Read @%0t",$stime);	
	Avalon_MM_Write(4'hB, {8'h00,8'h10,2'h0,select,8'h01});
	Avalon_MM_Write(4'hA, {8'h00, n2, 8'h00, n1});
	repeat(20)
		#master_ck_period;
	Avalon_MM_Write(4'hB, {8'h00,8'h10,2'h0,select,8'h00});
	repeat(n1+n2+5)
		repeat(10)
			#master_ck_period;
end
endtask // TofPet_Read

task TofPet_Write;
input [7:0] n1, n2;
input [5:0] select;
begin
	if( echo == 1 )
		$display("# TofPet_Write @%0t: n1 = %d, n2 = %d",$stime, n1, n2);	
//	Avalon_MM_Write(4'hB, {8'h81,8'h58,2'h0,select,8'h02});	// TX_MODE = 1
	Avalon_MM_Write(4'hB, {8'h01,8'h18,2'h0,select,8'h02});	// TX_MODE = 0
	Avalon_MM_Write(4'hA, {8'h00, n2, 8'h00, n1});
	repeat(20)
		#master_ck_period;
//	Avalon_MM_Write(4'hB, {8'h81,8'h58,2'h0,select,8'h00});	// TX_MODE = 1
	Avalon_MM_Write(4'hB, {8'h01,8'h18,2'h0,select,8'h00});	// TX_MODE = 0
	repeat(n1+n2+5)
		repeat(10)
			#master_ck_period;
end
endtask // TofPet_Write

task TofPet_Reset;
begin
	if( echo == 1 )
		$display("# TofPet_Reset @%0t",$stime);	
	Avalon_MM_Write(4'hB, 32'h0210_0004);
	repeat(20)
		#master_ck_period;
	Avalon_MM_Write(4'hB, 32'h0210_0000);
end
endtask // TofPet_Reset

task TofPet_WideReset;
begin
	if( echo == 1 )
		$display("# TofPet_WideReset @%0t",$stime);	
	Avalon_MM_Write(4'hB, 32'h0210_0008);
	repeat(20)
		#master_ck_period;
	Avalon_MM_Write(4'hB, 32'h0210_0000);
end
endtask // TofPet_WideReset

task TofPet_Test;
begin
	if( echo == 1 )
		$display("# TofPet_Test @%0t",$stime);	
	Avalon_MM_Write(4'hB, 32'h0210_0010);
	repeat(20)
		#master_ck_period;
	Avalon_MM_Write(4'hB, 32'h0210_0000);
end
endtask // TofPet_Test

task CtrlFifo_Reset;
begin
	if( echo == 1 )
		$display("# CtrlFifo_Reset @%0t",$stime);	
	Avalon_MM_Write(4'hB, 32'h0018_0120);
	repeat(20)
		#master_ck_period;
	Avalon_MM_Write(4'hB, 32'h0018_0100);
end
endtask // CtrlFifo_Reset

task DataFifo_Reset;
begin
	if( echo == 1 )
		$display("# DataFifo_Reset @%0t",$stime);	
	Avalon_MM_Write(4'hB, 32'h0210_0040);
	repeat(20)
		#master_ck_period;
	Avalon_MM_Write(4'hB, 32'h0210_0000);
end
endtask // DataFifo_Reset

task Avalon_MM_Write;
input [3:0] a;
input [31:0] d;
begin
	avalon_addr = a;
	avalon_din = d;
	avalon_cs = 1;
	avalon_writeB = 0;
	#master_ck_period;
	avalon_cs = 0;
	avalon_writeB = 1;
	#master_ck_period;
end
endtask // Avalon_MM_Write

task Avalon_MM_Read;
input [3:0] a;
begin
	avalon_addr = a;
	avalon_cs = 1;
	avalon_readB = 0;
	#master_ck_period;
	avalon_cs = 0;
	avalon_readB = 1;
	#master_ck_period;
end
endtask // Avalon_MM_Read

/* TofPet Avalon Interface Memory Map
			4'h0: Data FIFO 0
			4'h1: Data FIFO 1
			4'h2: Data FIFO 2
			4'h3: Data FIFO 3
			4'h4: Data FIFO 4
			4'h5: Data FIFO 5
			4'h6: fifo_status =	{16'b0,
								2'b0,FULL5,FULL4,FULL3,FULL2,FULL1,FULL0,
								2'b0,EMPTY5,EMPTY4,EMPTY3,EMPTY2,EMPTY1,EMPTY0};

			4'h7: Dummy register (read returns 32'hF1CA_CAFE)
			4'h8: Control FIFO OUT (read only)
			4'h9: Control FIFO IN (write only)
			4'hA: NBIT_INOUT register
			4'hB: COMMAND register
			4'hC: STATUS_WORD =		{GotAck, RWrunning, TestRunning, 5'b0,
									2'b0, synced1,
									2'b0, synced0,
									4'b0, CtrlFifo_OUT_full, CtrlFifo_OUT_empty, CtrlFifo_IN_full, CtrlFifo_IN_empty};
			4'hD: {5'h0,USED_WORDS1,5'h0,USED_WORDS0};
			4'hE: {5'h0,USED_WORDS3,5'h0,USED_WORDS2};
			4'hF: {5'h0,USED_WORDS5,5'h0,USED_WORDS4};
*/
endmodule
