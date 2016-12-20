`timescale 1ns/100ps

`define OUT_DATA_SIZE 32
`define CTRL_DATA_SIZE 32
`define HEADER_WORD	32'h48445230	// ASCII "HDR0"

`define FINE_BIT	5	// Fine delay bit count
`define DELAY_BIT	(1<<`FINE_BIT)	// Tapped delay line bit count

//`define TOFPET_DDR_ENABLED

module TofPetInterface(
	input TOFPET_CK,	// 160 MHz
	input CK,	// 100 MHz
	input LFCK,	// 10 MHz
	input RESETb,

// Processor Interface	
	output [`OUT_DATA_SIZE-1:0] DATA_OUT0,
	output EMPTY0,
	output FULL0,
	input READ0,
	output [10:0] USED_WORDS0,
	output [`OUT_DATA_SIZE-1:0] DATA_OUT1,
	output EMPTY1,
	output FULL1,
	input READ1,
	output [10:0] USED_WORDS1,
	output [`OUT_DATA_SIZE-1:0] DATA_OUT2,
	output EMPTY2,
	output FULL2,
	input READ2,
	output [10:0] USED_WORDS2,
	output [`OUT_DATA_SIZE-1:0] DATA_OUT3,
	output EMPTY3,
	output FULL3,
	input READ3,
	output [10:0] USED_WORDS3,
	output [`OUT_DATA_SIZE-1:0] DATA_OUT4,
	output EMPTY4,
	output FULL4,
	input READ4,
	output [10:0] USED_WORDS4,
	output [`OUT_DATA_SIZE-1:0] DATA_OUT5,
	output EMPTY5,
	output FULL5,
	input READ5,
	output [10:0] USED_WORDS5,
	
	output [`CTRL_DATA_SIZE-1:0] CTRL_FIFO_OUT,
	input CTRL_FIFO_OUT_RE,
	input [`CTRL_DATA_SIZE-1:0] CTRL_FIFO_IN,
	input CTRL_FIFO_IN_WE,
	input [`CTRL_DATA_SIZE-1:0] NBIT_INOUT,
	input [`CTRL_DATA_SIZE-1:0] COMMAND,
	output [`CTRL_DATA_SIZE-1:0] STATUS,
	
// TofPet ASIC interface
	input CLKO_0,
	input TX0_0,
	input TX1_0,
	input CLKO_1,
	input TX0_1,
	input TX1_1,
	input CLKO_2,
	input TX0_2,
	input TX1_2,
	input CLKO_3,
	input TX0_3,
	input TX1_3,
	input CLKO_4,
	input TX0_4,
	input TX1_4,
	input CLKO_5,
	input TX0_5,
	input TX1_5,

	output SYNC_RST,
	output TEST_PULSE,
	output [5:0] CS,
	output SCLK,
	output SDI,
	input SDO,
	
// FrontEnd selector
	output [2:0] FE_SELECT,
	output FE_ENABLEb,
	output DEBUG0,
	output DEBUG1
	);

wire CtrlFifo_IN_empty, CtrlFifo_IN_full, CtrlFifo_OUT_empty, CtrlFifo_OUT_full;
wire CtrlFifoRst, CtrlFifoRd, CtrlFifoWr, DataFifoRst;
wire CommandCfgRead, CommandCfgWrite, CommandRst, CommandWideRst, CommandTest, CommandCtrlFifoRst, CommandDataFifoRst;
wire [7:0] n1, n2;
wire [9:0] test_pulse_delay;
wire [6:0] test_pulse_width_low;
wire [5:0] ChipSelect, synced0, synced1, DataFifoWrEnable;
wire [31:0] FifoDataIn, FifoDataOut, CTRL_FIFO_OUT_xxx;
wire DdrMode, SclkEnable, SkipEmptyEvents, GotAck, RWrunning, StartFrame0, TestRunning, test_pulse_polarity;
wire [1:0] TxMode;
reg we_dly, re_dly;
wire local_test_pulse;
wire [`DELAY_BIT-1:0] test_pulse_tapped;
wire [`FINE_BIT-1:0] test_pulse_tap_select;

assign DEBUG0 = StartFrame0;
assign DEBUG1 = TEST_PULSE;

assign n1 = NBIT_INOUT[7:0];
assign n2 = NBIT_INOUT[23:16];
assign test_pulse_delay = NBIT_INOUT[17:8];
assign test_pulse_width_low = NBIT_INOUT[30:24];
assign test_pulse_polarity = NBIT_INOUT[31];
assign CommandCfgRead = COMMAND[0];
assign CommandCfgWrite = COMMAND[1];
assign CommandRst = COMMAND[2];
assign CommandWideRst = COMMAND[3];
assign CommandTest = COMMAND[4];
assign CommandCtrlFifoRst = COMMAND[5];
assign CommandDataFifoRst = COMMAND[6];
assign ChipSelect = COMMAND[13:8];
assign FE_SELECT = COMMAND[18:16];
assign FE_ENABLEb = COMMAND[19];
assign SclkEnable = COMMAND[20];
assign DdrMode = COMMAND[21];		// Same as G_CONFIG DDR Mode bit
assign TxMode = COMMAND[23:22];		// Same as G_CONFIG TX Mode bits
assign DataFifoWrEnable = COMMAND[29:24];
//assign SkipEmptyEvents = COMMAND[31];
assign SkipEmptyEvents = 1'b1;
assign test_pulse_tap_select = {COMMAND[31:30],COMMAND[15:14],COMMAND[7]};

assign SCLK = ~LFCK & SclkEnable;

assign STATUS = {GotAck, RWrunning, TestRunning, 5'b0,
				2'b0, synced1,
				2'b0, synced0,
				4'b0, CtrlFifo_OUT_full, CtrlFifo_OUT_empty, CtrlFifo_IN_full, CtrlFifo_IN_empty};

always @(posedge CK)
begin
	we_dly <= CTRL_FIFO_IN_WE;
	re_dly <= CTRL_FIFO_OUT_RE;
end
/*
always @(posedge CK)
begin
	if( CTRL_FIFO_OUT_RE & ~re_dly )
		CTRL_FIFO_OUT <= CTRL_FIFO_OUT_xxx;
end
*/
CtrlFifo_32x32 CtrlFifo_IN(
	.clock(CK),
	.data(CTRL_FIFO_IN),		// from Avalon MM interface
	.wrreq(CTRL_FIFO_IN_WE),	// from Avalon MM interface
//	.wrreq(CTRL_FIFO_IN_WE & ~we_dly),	// from Avalon MM interface
	.rdreq(CtrlFifoRd),
	.sclr(CtrlFifoRst),
	.empty(CtrlFifo_IN_empty),	// to Avalon MM interface
	.full(CtrlFifo_IN_full),	// to Avalon MM interface
	.q(FifoDataIn));

CtrlFifo_32x32 CtrlFifo_OUT(
	.clock(CK),
	.data(FifoDataOut),
	.wrreq(CtrlFifoWr),
	.rdreq(CTRL_FIFO_OUT_RE),	// from Avalon MM interface
//	.rdreq(CTRL_FIFO_OUT_RE & re_dly),	// from Avalon MM interface
	.sclr(CtrlFifoRst),
	.empty(CtrlFifo_OUT_empty),	// to Avalon MM interface
	.full(CtrlFifo_OUT_full),	// to Avalon MM interface
//	.q(CTRL_FIFO_OUT_xxx));			// to Avalon MM interface
	.q(CTRL_FIFO_OUT));			// to Avalon MM interface

RstMachine RstGenerator(.CK(TOFPET_CK), .RSTb(RESETb),
	.RST_CMD(CommandRst), .WRST_CMD(CommandWideRst), .RST_OUT(SYNC_RST));

TestMachine TestGenerator(.CK(TOFPET_CK), .RSTb(RESETb), .SYNC_TIMEBASE(StartFrame0),
	.DELAY(test_pulse_delay), .POLARITY(test_pulse_polarity), .WIDTH_HI(8'h80), .WIDTH_LO(test_pulse_width_low),
	.TEST_CMD(CommandTest), .RUNNING(TestRunning), .TEST_OUT(local_test_pulse));
DelayChain TestPulseDelay(.DIN(local_test_pulse), .DOUT(test_pulse_tapped));
mux TestPulseOutSel(.DIN(test_pulse_tapped), .DOUT(TEST_PULSE), .SEL(test_pulse_tap_select));

FifoRstMachine CtrlFifoRstGenerator(.CK(CK), .RSTb(RESETb), .FIFO_RST_CMD(CommandCtrlFifoRst), .FIFO_RST_OUT(CtrlFifoRst));
FifoRstMachine DataFifoRstGenerator(.CK(CK), .RSTb(RESETb), .FIFO_RST_CMD(CommandDataFifoRst), .FIFO_RST_OUT(DataFifoRst));

ReadWriteMachine ReadWriteSequencer(.CK(CK), .LFCK(LFCK), .RSTb(RESETb),
	.RD_CMD(CommandCfgRead), .WR_CMD(CommandCfgWrite),
	.SELECT(ChipSelect), .N1(n1), .N2(n2), .FIFO_DATA_IN(FifoDataIn), .SDO(SDO), .GOT_ACK(GotAck), .RUNNING(RWrunning),
	.CS(CS), .SDI(SDI), .FIFO_RD(CtrlFifoRd), .FIFO_WR(CtrlFifoWr), .FIFO_DATA_OUT(FifoDataOut));

ChannelReadout Ch0(.CK(CK), .RSTb(RESETb), .CLKO(CLKO_0), .TX0(TX0_0), .TX1(TX1_0),
	.DDRMODE(DdrMode), .TXMODE(TxMode), .ID(3'd0), .CH_ENABLE(DataFifoWrEnable[0]),
	.FIFO_DATA(DATA_OUT0), .FIFO_FULL(FULL0), .FIFO_EMPTY(EMPTY0), .FIFO_RD(READ0), .FIFO_RST(DataFifoRst),
	.SYNCED({synced1[0], synced0[0]}), .START_FRAME(StartFrame0),
	.USED_WORDS(USED_WORDS0), .SKIP_EMPTY_EVENTS(SkipEmptyEvents));

ChannelReadout Ch1(.CK(CK), .RSTb(RESETb), .CLKO(CLKO_1), .TX0(TX0_1), .TX1(TX1_1),
	.DDRMODE(DdrMode), .TXMODE(TxMode), .ID(3'd1), .CH_ENABLE(DataFifoWrEnable[1]),
	.FIFO_DATA(DATA_OUT1), .FIFO_FULL(FULL1), .FIFO_EMPTY(EMPTY1), .FIFO_RD(READ1), .FIFO_RST(DataFifoRst),
	.SYNCED({synced1[1], synced0[1]}), .START_FRAME(),
	.USED_WORDS(USED_WORDS1), .SKIP_EMPTY_EVENTS(SkipEmptyEvents));

ChannelReadout Ch2(.CK(CK), .RSTb(RESETb), .CLKO(CLKO_2), .TX0(TX0_2), .TX1(TX1_2),
	.DDRMODE(DdrMode), .TXMODE(TxMode), .ID(3'd2), .CH_ENABLE(DataFifoWrEnable[2]),
	.FIFO_DATA(DATA_OUT2), .FIFO_FULL(FULL2), .FIFO_EMPTY(EMPTY2), .FIFO_RD(READ2), .FIFO_RST(DataFifoRst),
	.SYNCED({synced1[2], synced0[2]}), .START_FRAME(),
	.USED_WORDS(USED_WORDS2), .SKIP_EMPTY_EVENTS(SkipEmptyEvents));

ChannelReadout Ch3(.CK(CK), .RSTb(RESETb), .CLKO(CLKO_3), .TX0(TX0_3), .TX1(TX1_3),
	.DDRMODE(DdrMode), .TXMODE(TxMode), .ID(3'd3), .CH_ENABLE(DataFifoWrEnable[3]),
	.FIFO_DATA(DATA_OUT3), .FIFO_FULL(FULL3), .FIFO_EMPTY(EMPTY3), .FIFO_RD(READ3), .FIFO_RST(DataFifoRst),
	.SYNCED({synced1[3], synced0[3]}), .START_FRAME(),
	.USED_WORDS(USED_WORDS3), .SKIP_EMPTY_EVENTS(SkipEmptyEvents));

ChannelReadout Ch4(.CK(CK), .RSTb(RESETb), .CLKO(CLKO_4), .TX0(TX0_4), .TX1(TX1_4),
	.DDRMODE(DdrMode), .TXMODE(TxMode), .ID(3'd4), .CH_ENABLE(DataFifoWrEnable[4]),
	.FIFO_DATA(DATA_OUT4), .FIFO_FULL(FULL4), .FIFO_EMPTY(EMPTY4), .FIFO_RD(READ4), .FIFO_RST(DataFifoRst),
	.SYNCED({synced1[4], synced0[4]}), .START_FRAME(),
	.USED_WORDS(USED_WORDS4), .SKIP_EMPTY_EVENTS(SkipEmptyEvents));

ChannelReadout Ch5(.CK(CK), .RSTb(RESETb), .CLKO(CLKO_5), .TX0(TX0_5), .TX1(TX1_5),
	.DDRMODE(DdrMode), .TXMODE(TxMode), .ID(3'd5), .CH_ENABLE(DataFifoWrEnable[5]),
	.FIFO_DATA(DATA_OUT5), .FIFO_FULL(FULL5), .FIFO_EMPTY(EMPTY5), .FIFO_RD(READ5), .FIFO_RST(DataFifoRst),
	.SYNCED({synced1[5], synced0[5]}), .START_FRAME(),
	.USED_WORDS(USED_WORDS5), .SKIP_EMPTY_EVENTS(SkipEmptyEvents));

endmodule

module ChannelReadout(input CK, input RSTb, input CLKO, input TX0, input TX1,
	input DDRMODE, input [1:0] TXMODE, input [2:0] ID, input CH_ENABLE,
	output [31:0] FIFO_DATA, output FIFO_FULL, output FIFO_EMPTY, input FIFO_RD, input FIFO_RST,
	output [1:0] SYNCED, output START_FRAME,
	output [10:0] USED_WORDS, input SKIP_EMPTY_EVENTS);

	wire FifoWr, k_0, k_1, load_reg, txmode_x1, txmode_x2, data_valid0, data_valid1;
	wire [31:0] FifoDataIn, FifoDataOut;
	wire [1:0] tx_h, tx_l;
	reg [9:0] sdr0_shreg, sdr1_shreg, reg0, reg1;
`ifdef TOFPET_DDR_ENABLED
	reg [9:0] ddr0_shreg, ddr1_shreg;
`endif
	wire [7:0] reg8_0, reg8_1;
	wire [9:0] reg0_swap, reg1_swap;
	reg [7:0] reg0_l, reg1_l;
	reg all_synced, k28_5, k28_1, data_valid, dv0, dv1, dv2, dv3;
	reg k28_5_0, k28_5_1, k28_1_0, k28_1_1, re_dly;

assign txmode_x1 = (TXMODE == 2'b00) ? 1 : 0;
assign txmode_x2 = (TXMODE == 2'b01) ? 1 : 0;
assign reg0_swap = {reg0[0],reg0[1],reg0[2],reg0[3],reg0[4],reg0[5],reg0[6],reg0[7],reg0[8],reg0[9]};
assign reg1_swap = {reg1[0],reg1[1],reg1[2],reg1[3],reg1[4],reg1[5],reg1[6],reg1[7],reg1[8],reg1[9]};
assign START_FRAME = k28_1_0;

/*
always @(posedge CK)
begin
	re_dly <= FIFO_RD;
	if( FIFO_RD & ~re_dly )
//	if( FIFO_RD )
		FIFO_DATA <= FifoDataOut;
end
*/

DataFifo_2048x32 DataFifo(
	.clock(CK),
	.data(FifoDataIn),
	.wrreq(FifoWr & CH_ENABLE),
//	.rdreq(FIFO_RD & ~re_dly),	// from Avalon MM interface
	.rdreq(FIFO_RD),	// from Avalon MM interface
	.sclr(FIFO_RST),
	.empty(FIFO_EMPTY),	// to Avalon MM interface
	.full(FIFO_FULL),	// to Avalon MM interface
//	.q(FifoDataOut),		// to Avalon MM interface
	.q(FIFO_DATA),		// to Avalon MM interface
	.usedw(USED_WORDS));		// to Avalon MM interface

`ifdef TOFPET_DDR_ENABLED
	Ddr_In Ddr_In_instance(.datain({TX1,TX0}), .inclock(CLKO), .dataout_h(tx_h), .dataout_l(tx_l));
`endif


`ifdef ALTERA_IP
	dec_8b_10b dec0(.clk(CLKO), .reset_n(RSTb), .idle_del(1'b0), .ena(1'b1),
		.datain(reg0_swap), .rdforce(1'b0), .rdin(1'b0), .valid(), .dataout(reg8_0),
		.kout(k_0), .kerr(), .rdcascade(), .rdout(), .rderr());
	dec_8b_10b dec1(.clk(CLKO), .reset_n(RSTb), .idle_del(1'b0), .ena(1'b1),
		.datain(reg1_swap), .rdforce(1'b0), .rdin(1'b0), .valid(), .dataout(reg8_1),
		.kout(k_1), .kerr(), .rdcascade(), .rdout(), .rderr());
`else	// OpenCores IP
	dec_8b10b_oc dec0(
			.RESET(~RSTb),
			.RBYTECLK(CLKO),
			.AI(reg0_swap[0]), .BI(reg0_swap[1]), .CI(reg0_swap[2]), .DI(reg0_swap[3]), .EI(reg0_swap[4]),
			.II(reg0_swap[5]), .FI(reg0_swap[6]), .GI(reg0_swap[7]), .HI(reg0_swap[8]), .JI(reg0_swap[9]),		
			.KO(k_0),
			.HO(reg8_0[7]), .GO(reg8_0[6]), .FO(reg8_0[5]), .EO(reg8_0[4]),
			.DO(reg8_0[3]), .CO(reg8_0[2]), .BO(reg8_0[1]), .AO(reg8_0[0])
	);
	dec_8b10b_oc dec1(
			.RESET(~RSTb),
			.RBYTECLK(CLKO),
			.AI(reg1_swap[0]), .BI(reg1_swap[1]), .CI(reg1_swap[2]), .DI(reg1_swap[3]), .EI(reg1_swap[4]),
			.II(reg1_swap[5]), .FI(reg1_swap[6]), .GI(reg1_swap[7]), .HI(reg1_swap[8]), .JI(reg1_swap[9]),		
			.KO(k_1),
			.HO(reg8_1[7]), .GO(reg8_1[6]), .FO(reg8_1[5]), .EO(reg8_1[4]),
			.DO(reg8_1[3]), .CO(reg8_1[2]), .BO(reg8_1[1]), .AO(reg8_1[0])
	);

`endif

	SyncMachine SyncGenerator0(.CK(CLKO), .RSTb(RSTb), .LOAD_REG(load_reg), .VALID(data_valid0),
		.K28_5(k28_5_0), .K28_1(k28_1_0), .RUNNING(PackRunning), .SYNCED(SYNCED[0]));
	SyncMachine SyncGenerator1(.CK(CLKO), .RSTb(RSTb), .LOAD_REG(), .VALID(data_valid1),
		.K28_5(k28_5_1), .K28_1(k28_1_1), .RUNNING(PackRunning), .SYNCED(SYNCED[1]));

	PackMachine FifoDataGenerator(.CK(CK), .RSTb(RSTb), .K28_5(k28_5), .K28_1(k28_1), .SYNCED(all_synced),
		.TXMODE_X1(txmode_x1), .TXMODE_X2(txmode_x2), .DATA_VALID(data_valid), .ID(ID),
		.DATA0(reg0_l), .DATA1(reg1_l), .FIFO_WR(FifoWr), .FIFO_DATA(FifoDataIn), .RUNNING(PackRunning),
		.SKIP_EMPTY_EVENTS(SKIP_EMPTY_EVENTS));

	always @(posedge CLKO)		// deserializer shift registers
	begin
		sdr0_shreg <= {sdr0_shreg[8:0], TX0};
		sdr1_shreg <= {sdr1_shreg[8:0], TX1};
`ifdef TOFPET_DDR_ENABLED
		ddr0_shreg <= {ddr0_shreg[7:0], tx_h[0], tx_l[0]};
		ddr1_shreg <= {ddr1_shreg[7:0], tx_h[1], tx_l[1]};
`endif
	end

	always @(posedge CLKO)
	begin
		if( RSTb == 0 )
		begin
			reg0 <= 0;
			reg1 <= 0;
			k28_5_0 <= 0;
			k28_5_1 <= 0;
			k28_1_0 <= 0;
			k28_1_1 <= 0;
		end
		else
		begin
			k28_5_0 <= (k_0 & (reg8_0 == 8'b101_11100)) ? 1 : 0;
			k28_1_0 <= (k_0 & (reg8_0 == 8'b001_11100)) ? 1 : 0;
			k28_5_1 <= (k_1 & (reg8_1 == 8'b101_11100)) ? 1 : 0;
			k28_1_1 <= (k_1 & (reg8_1 == 8'b001_11100)) ? 1 : 0;
			if( load_reg == 1 )
				begin
`ifdef TOFPET_DDR_ENABLED
					reg0 <= DDRMODE ? ddr0_shreg : sdr0_shreg;
					reg1 <= DDRMODE ? ddr1_shreg : sdr1_shreg;
`else
					reg0 <= DDRMODE ? 0 : sdr0_shreg;
					reg1 <= DDRMODE ? 0 : sdr1_shreg;
`endif
				end
		end
	end

	always @(posedge CK)	// changing clock domain
	begin
		reg0_l <= reg8_0;
		reg1_l <= reg8_1;
		all_synced <= txmode_x1 ? SYNCED[0] : (SYNCED[0] & SYNCED[1]);

		k28_5 <= txmode_x1 ? (k_0 & (reg8_0 == 8'b101_11100)) : ((k_0 & (reg8_0 == 8'b101_11100)) & (k_1 & (reg8_1 == 8'b101_11100)));
		k28_1 <= txmode_x1 ? (k_0 & (reg8_0 == 8'b001_11100)) : ((k_0 & (reg8_0 == 8'b001_11100)) & (k_1 & (reg8_1 == 8'b001_11100)));

		dv0 <= data_valid0;
		dv1 <= data_valid1;
		dv2 <= dv0;
		dv3 <= dv1;
		data_valid <= txmode_x1 ? (dv0 & ~dv2) : ((dv0 & ~dv2) & (dv1 & ~dv3));
	end
	
endmodule

module PackMachine (input CK, input RSTb, input K28_5, input K28_1, input SYNCED, input DATA_VALID, input [2:0] ID,
	input TXMODE_X1, input TXMODE_X2, input [7:0] DATA0, input [7:0] DATA1,
	output reg FIFO_WR, output reg [31:0] FIFO_DATA, output reg RUNNING, input SKIP_EMPTY_EVENTS);

reg [7:0] fsm_status;
reg [15:0] temp_data;
reg event_is_empty, wr_hdr;

	always @(posedge CK)
	begin
		if( RSTb == 0 )
		begin
			fsm_status <= 0;
			temp_data <= 0;
			event_is_empty <= 0;
			wr_hdr <= 0;
			RUNNING <= 0;
			FIFO_WR <= 0;
			FIFO_DATA <= 0;
		end
		else
		begin
			case( fsm_status )
			0:	begin
					FIFO_WR <= 0;
					RUNNING <= 0;
					event_is_empty <= 0;
					if( SYNCED & K28_1 & DATA_VALID & TXMODE_X1 )
					begin
						FIFO_DATA <= `HEADER_WORD + {29'h0, ID};
//						FIFO_WR <= 1;
						wr_hdr <= 1;
						fsm_status <= 1;
					end
					if( SYNCED & K28_1 & DATA_VALID & TXMODE_X2 )
					begin
						FIFO_DATA <= `HEADER_WORD + {29'h0, ID};
//						FIFO_WR <= 1;
						wr_hdr <= 1;
						fsm_status <= 8;
					end
				end
				
			1:	begin
					RUNNING <= 1;
					FIFO_WR <= 0;
					if( DATA_VALID && K28_1 == 0 )
					begin
//						FIFO_DATA[31:24] <= DATA0;
						temp_data[7:0] <= DATA0;
						if( wr_hdr )
							event_is_empty <= (DATA0 == 8'b0) ? 1 : 0;
						if( ((DATA0 == 0 && SKIP_EMPTY_EVENTS == 0) || (DATA0 != 0)) && wr_hdr == 1 )
						begin
							FIFO_WR <= 1;
							$display("Writing Header@%0t",$stime);
						end
						wr_hdr <= 0;
						fsm_status <= 2;
					end
					if( DATA_VALID & K28_5 )
					begin
						fsm_status <= 0;
					end
				end
			2:	begin
					FIFO_WR <= 0;
					if( DATA_VALID  && K28_1 == 0)
					begin
//						FIFO_DATA[23:16] <= DATA0;
						FIFO_DATA[31:16] <= {temp_data[7:0],DATA0};
						fsm_status <= 3;
					end
					if( DATA_VALID & K28_5 )
					begin
						fsm_status <= 0;
					end
				end
			3:	begin
					if( DATA_VALID  && K28_1 == 0)
					begin
						FIFO_DATA[15:8] <= DATA0;
						fsm_status <= 4;
					end
					if( DATA_VALID & K28_5 )
					begin
						fsm_status <= 0;
					end
				end
			4:	begin
					if( DATA_VALID  && K28_1 == 0)
					begin
						FIFO_DATA[7:0] <= DATA0;
						if( (event_is_empty == 1 && SKIP_EMPTY_EVENTS == 0) || (event_is_empty == 0) )
						begin
							FIFO_WR <= 1;
							$display("Writing Data@%0t: 0x%0x", $stime, {FIFO_DATA[31:8],DATA0});
						end
						fsm_status <= 5;
					end
					if( DATA_VALID & K28_5 )
					begin
						fsm_status <= 0;
					end
				end
			5:	begin
					FIFO_WR <= 0;
					fsm_status <= 1;
				end

			8:	begin
					RUNNING <= 1;
					FIFO_WR <= 0;
					if( DATA_VALID && K28_1 == 0 )
					begin
//						FIFO_DATA[31:16] <= {DATA0,DATA1};
						temp_data <= {DATA0,DATA1};
						if( wr_hdr )
							event_is_empty <= (DATA0 == 8'b0) ? 1 : 0;
						if( ((DATA0 == 0 && SKIP_EMPTY_EVENTS == 0) || (DATA0 != 0)) && wr_hdr == 1 )
						begin
							FIFO_WR <= 1;
							$display("Writing Header@%0t", $stime);
						end
						wr_hdr <= 0;
						fsm_status <= 9;
					end
					if( DATA_VALID & K28_5 )
					begin
						fsm_status <= 0;
					end
				end
			9:	begin
					FIFO_WR <= 0;
					if( DATA_VALID && K28_1 == 0 )
					begin
//						FIFO_DATA[15:0] <= {DATA0,DATA1};
						FIFO_DATA <= {temp_data,DATA0,DATA1};
						if( (event_is_empty == 1 && SKIP_EMPTY_EVENTS == 0) || (event_is_empty == 0) )
						begin
							FIFO_WR <= 1;
							$display("Writing Data@%0t: 0x%0x", $stime, {temp_data,DATA0,DATA1});
						end
						fsm_status <= 10;
					end
					if( DATA_VALID & K28_5 )
					begin
						fsm_status <= 0;
					end
				end
			10:	begin
					FIFO_WR <= 0;
					fsm_status <= 8;
				end

			default: fsm_status <= 0;
			endcase
		end
	end
	
endmodule

module SyncMachine (input CK, input RSTb, output reg LOAD_REG, output reg VALID,
	input K28_5, input K28_1, input RUNNING, output SYNCED);

reg [3:0] bit_count, bit_value, valid_count;
reg [4:0] sync_count, wait_count;
reg [7:0] fsm_status;

assign SYNCED = (sync_count > 7) ? 1 : 0;

	always @(posedge CK)
	begin
		if( RSTb == 0 )
			bit_count <= 0;
		else
			if( bit_count < 9 )
				bit_count <= bit_count + 1;
			else
				bit_count <= 0;
	end

	always @(posedge CK)
	begin
		if( RSTb == 0 )
			LOAD_REG <= 0;
		else
			LOAD_REG <= (bit_count == bit_value) ? 1 : 0;
	end

	always @(posedge CK)
	begin
		if( RSTb == 0 )
		begin
			VALID <= 0;
			valid_count <= 0;
		end
		else
		begin
			if( LOAD_REG )
				valid_count <= 0;
			else
				valid_count <= valid_count + 1;

			VALID <= (valid_count == 1 || valid_count == 2 || valid_count == 3) ? 1 : 0;
		end
	end

	always @(posedge CK)
	begin
		if( RSTb == 0 )
		begin
			bit_value <= 0;
			sync_count <= 0;
			wait_count <= 0;
			fsm_status <= 0;
		end
		else
		begin
			case( fsm_status )
			0:	begin
					if( ~RUNNING )
					begin
						if( K28_5 | K28_1 )
						begin
							if( sync_count < 15 )
								sync_count <= sync_count + 1;
							wait_count <= 0;
							fsm_status <= 1;
						end
						else
						begin
							sync_count <= 0;
							fsm_status <= 2;
						end
					end
				end
			1:	begin
					if( LOAD_REG )
					begin
						if( wait_count < 3 )
							wait_count <= wait_count + 1;
						else
							fsm_status <= 0;
					end
				end
			2:	begin
					wait_count <= 0;
					if( bit_value < 9 )
						bit_value <= bit_value + 1;
					else
						bit_value <= 0;
					fsm_status <= 1;
				end
			default: fsm_status <= 0;
			endcase
		end
	end

endmodule

module ReadWriteMachine(input CK, input LFCK, input RSTb, input RD_CMD, input WR_CMD, input [5:0] SELECT,
	input [7:0] N1, input [7:0] N2, input [31:0] FIFO_DATA_IN, input SDO, output reg GOT_ACK, output reg RUNNING,
	output reg [5:0] CS, output SDI, output reg FIFO_RD, output reg FIFO_WR, output reg [31:0] FIFO_DATA_OUT);
	
reg fifo_read, fifo_write, old_fifo_read, old_fifo_write;
reg read, write, old_read, old_write, start_read, start_write;
reg [31:0] shreg;
reg [15:0] fsm_status;
reg [7:0] n1_counter, n2_counter;
reg [5:0] bit_counter;

assign #1 SDI = shreg[31];

// Synchronizers: FIFO is running at high speed
always @(posedge CK)
begin
	if( RSTb == 0 )
	begin
		FIFO_RD <= 0; FIFO_WR <= 0;
		old_fifo_read <= 0; old_fifo_write <= 0;
	end
	else
	begin
		old_fifo_read <= fifo_read;
		old_fifo_write <= fifo_write;
		if( fifo_read == 1'b1 && old_fifo_read == 1'b0 )
			FIFO_RD <= 1'b1;
		else
			FIFO_RD <= 1'b0;
		if( fifo_write == 1'b1 && old_fifo_write == 1'b0 )
			FIFO_WR <= 1'b1;
		else
			FIFO_WR <= 1'b0;
	end
end

always @(posedge LFCK)
begin
	if( RSTb == 0 )
	begin
		read <= 0; write <= 0;
		old_read <= 0; old_write <= 0;
		start_read <= 0; start_write <= 0;
	end
	else
	begin
		read <= RD_CMD;
		write <= WR_CMD;
		old_read <= read;
		old_write <= write;
		if( read == 1'b1 && old_read == 1'b0 )
			start_read <= 1'b1;
		else
			start_read <= 1'b0;
		if( write == 1'b1 && old_write == 1'b0 )
			start_write <= 1'b1;
		else
			start_write <= 1'b0;
	end
end

// Main FSM to handle read and write sequences
always @(posedge LFCK)
begin
	if( RSTb == 0 )
	begin
		fsm_status <= 0;
		fifo_read <= 0;
		fifo_write <= 0;
		n1_counter <= 0;
		n2_counter <= 0;
		bit_counter <= 0;
		shreg <= 0;
		CS <= 0;
		FIFO_DATA_OUT <= 0;
		GOT_ACK <= 0;
		RUNNING <= 0;
	end
	else
	begin
		case( fsm_status )
		0:	begin
				CS <= 0;
				RUNNING <= 0;
				fifo_write <= 0;
				if( start_write )
					fsm_status <= 1;
				if( start_read )
					fsm_status <= 8;
			end

		1:	begin	// Handle write sequence
				RUNNING <= 1;
				GOT_ACK <= 0;
				n1_counter <= N1;	// N1 can be 53+7+4+8, 1+7+4+8, 10+7+4+8, 110+4+8, 7+4+8, 26+4+8 
				n2_counter <= N2;	// N2 can be 1 or 53
				bit_counter <= 6'd32;
				shreg <= FIFO_DATA_IN;
				CS <= SELECT;
				fsm_status <= 2;
			end
		2:	begin
				if( n1_counter == 1 )
				begin
					if( SDO == 1 && GOT_ACK == 0 )	// Acknowledged
						GOT_ACK <= 1;
					fsm_status <= 4;
				end
				else
				begin
					n1_counter <= n1_counter - 1;
					shreg <= shreg << 1;
					if( bit_counter == 6'd2 )	
					begin
						bit_counter <= 6'd32;
						fifo_read <= 1;
						fsm_status <= 3;
					end
					else
					begin
						bit_counter <= bit_counter - 1;
						fsm_status <= 2;
					end
				end
			end
		3:	begin
				fifo_read <= 0;
				n1_counter <= n1_counter - 1;
				shreg <= FIFO_DATA_IN;
				fsm_status <= 2;
			end
		4:	begin
				if( n2_counter == 1 )
					fsm_status <= 0;
				else
				begin
					n2_counter <= n2_counter - 1;
					fsm_status <= 4;
				end
			end

		8:	begin	// Handle read sequence
				RUNNING <= 1;
				GOT_ACK <= 0;
				n1_counter <= N1;	// N1 can be only 4+8=12 or 4+7+8=19
				n2_counter <= N2;	// N2 can be 53+8, 1+8, 10+8, 110+8, 7+8
				bit_counter <= 6'd31;
				shreg <= FIFO_DATA_IN;
				CS <= SELECT;
				fsm_status <= 9;
			end
		9:	begin
				if( n1_counter == 1 )
				begin
					shreg <= 0;
					if( SDO == 1 && GOT_ACK == 0 )	// Acknowledged
							GOT_ACK <= 1;
					fsm_status <= 10;
				end
				else
				begin
					n1_counter <= n1_counter - 1;
					shreg <= shreg << 1;
					fsm_status <= 9;
				end
			end
		10:	begin
				shreg <= {31'b0, SDO};
				n2_counter <= n2_counter - 1;
				fsm_status <= 11;
			end
		11:	begin
				shreg <= shreg << 1;
				shreg[0] <= SDO;
				fifo_write <= 0;
				if( n2_counter == 1 )
				begin
					fsm_status <= 13;
				end				
				else
				begin
					n2_counter <= n2_counter - 1;
					if( bit_counter == 6'd1 )	
					begin
						FIFO_DATA_OUT <= {shreg[30:0], SDO};
						bit_counter <= 6'd32;
						fsm_status <= 12;
					end
					else
					begin
						bit_counter <= bit_counter - 1;
						fsm_status <= 11;
					end
				end				
			end
		12:	begin
//				FIFO_DATA_OUT <= {shreg[30:0], SDO};
//				shreg <= shreg << 1;
//				shreg[0] <= SDO;
				shreg <= {31'b0, SDO};
				fifo_write <= 1;
				bit_counter <= bit_counter - 1;
				n2_counter <= n2_counter - 1;
				fsm_status <= 11;
			end
		13:	begin
//				FIFO_DATA_OUT <= {shreg[30:0], SDO};
				FIFO_DATA_OUT <= shreg;
				fifo_write <= 1;
				CS <= 0;
				fsm_status <= 0;
			end

		default: fsm_status <= 0;
		endcase
	end
end

endmodule	
	
module RstMachine(input CK, input RSTb, input RST_CMD, input WRST_CMD, output reg RST_OUT);

reg old_rst, old_wrst, rst, wrst, hold_line, old_hold_line;

always @(posedge CK)
begin
	if( RSTb == 0 )
	begin
		RST_OUT <= 0;
		rst <= 0;
		wrst <= 0;
		old_rst <= 0;
		old_wrst <= 0;
		hold_line <= 0;
		old_hold_line <= 0;
	end
	else
	begin
		rst <= RST_CMD;
		wrst <= WRST_CMD;
		old_rst <= rst;
		old_wrst <= wrst;
		old_hold_line <= hold_line;
		if( rst == 1'b1 && old_rst == 1'b0 )
			RST_OUT <= 1'b1;
		else
			if( hold_line == 1'b0 )
				RST_OUT <= 1'b0;
		if( wrst == 1'b1 && old_wrst == 1'b0 && hold_line == 1'b0 )
		begin
			hold_line <= 1'b1;
			RST_OUT <= 1'b1;
		end
		if( old_hold_line == 1'b1 )
		begin
			hold_line <= 1'b0;
			RST_OUT <= 1'b0;
		end
	end
end

endmodule

module FifoRstMachine(input CK, input RSTb, input FIFO_RST_CMD, output reg FIFO_RST_OUT);

reg old_rst, rst;

always @(posedge CK)
begin
	if( RSTb == 0 )
	begin
		FIFO_RST_OUT <= 0;
		rst <= 0;
		old_rst <= 0;
	end
	else
	begin
		rst <= FIFO_RST_CMD;
		old_rst <= rst;
		if( rst == 1'b1 && old_rst == 1'b0 )
			FIFO_RST_OUT <= 1'b1;
		else
			FIFO_RST_OUT <= 1'b0;
	end
end

endmodule

module TestMachine(input CK, input RSTb, input SYNC_TIMEBASE,
	input [9:0] DELAY,		// in CK period
	input POLARITY,			// 1 = active high
	input [7:0] WIDTH_HI,	// in CK period (6.25 ns)
	input [6:0] WIDTH_LO,	// in SYNC_TIMEBASE period (6.4 us) If WIDTH_LO == 0 only 1 pulse is issued
	input TEST_CMD, output reg RUNNING, output reg TEST_OUT);

reg test, old_test, sync_test_cmd;
reg time0, old_time0, sync_time0;
reg [7:0] fsm_status;
reg [9:0] delay_counter;
reg [7:0] width1_counter;
reg [6:0] width0_counter;

// Leading edge finder
always @(posedge CK or negedge RSTb)
begin
	if( RSTb == 0 )
	begin
		test <= 0; old_test <= 0; sync_test_cmd <= 0;
		time0 <= 0; old_time0 <= 0; sync_time0 <= 0;
	end
	else
	begin
		test <= TEST_CMD;
		old_test <= test;
		if( old_test == 0 && test == 1 )
			sync_test_cmd <= 1;
		else
			sync_test_cmd <= 0;
		time0 <= SYNC_TIMEBASE;
		old_time0 <= time0;
		if( old_time0 == 0 && time0 == 1 )
			sync_time0 <= 1;
		else
			sync_time0 <= 0;
	end
end

// Delay counter
always @(posedge CK or negedge RSTb)
begin
	if( RSTb == 0 )
	begin
		delay_counter <= 0;
	end
	else
	begin
		if( sync_time0 == 1 )
		begin
			delay_counter <= DELAY;
		end
		else
		begin
			if( delay_counter > 0 )
				delay_counter <= delay_counter - 1;
		end
	end
end

// Control FSM
always @(posedge CK or negedge RSTb)
begin
	if( RSTb == 0 )
	begin
		fsm_status <= 0;
		RUNNING <= 0;
		width1_counter <= 0;
		width0_counter <= 0;
		TEST_OUT <= 0;
	end
	else
	begin
		case( fsm_status )
			0:	begin
					TEST_OUT <= ~POLARITY;
					RUNNING <= 0;
					if( sync_test_cmd == 1 )
						fsm_status <= 1;
				end
			1:	begin
					width1_counter <= WIDTH_HI;
					width0_counter <= WIDTH_LO;
					RUNNING <= 1;
					if( sync_time0 == 1 )
						fsm_status <= 2;
				end
			2:	begin
					width0_counter <= WIDTH_LO;
					if( delay_counter == 0 )
					begin
						TEST_OUT <= POLARITY;
//						if( sync_time0 == 1 )
							width1_counter <= width1_counter - 1;
						if( width1_counter == 0 )
							fsm_status <= 3;
					end
				end
			3:	begin
					width1_counter <= WIDTH_HI;
					TEST_OUT <= ~POLARITY;
					if( WIDTH_LO != 0 )
					begin
						if( sync_time0 == 1 )
							width0_counter <= width0_counter - 1;
						if( width0_counter == 0 )
							fsm_status <= 2;
					end
					else
						fsm_status <= 0;
				end
			default: fsm_status <= 0;
		endcase
	end
end

endmodule
/*
module DelayChain(DIN, DOUT);
input DIN;
output [`DELAY_BIT-1:0] DOUT;

	carry_sum dly_bit0 (.sin(1'b0), .cin(DIN), .sout(), .cout(DOUT[0]));
	
	genvar i;
	generate
		for(i=1; i<`DELAY_BIT; i=i+1)
		begin: dly_generate
			carry_sum dly_biti (.sin(1'b0), .cin(DOUT[i-1]), .sout(), .cout(DOUT[i]));
		end
	endgenerate

//	carry_sum dly0 (.sin(1'b0), .cin(DIN),     .sout(), .cout(DOUT[0]);
//	carry_sum dly1 (.sin(1'b0), .cin(DOUT[0]), .sout(), .cout(DOUT[1]);
//	carry_sum dly2 (.sin(1'b0), .cin(DOUT[1]), .sout(), .cout(DOUT[2]);
//	carry_sum dly3 (.sin(1'b0), .cin(DOUT[2]), .sout(), .cout(DOUT[3]);

endmodule
*/
module DelayChain(DIN, DOUT);
input DIN;
output [`DELAY_BIT-1:0] DOUT;

	arriaii_lcell_comb #(.lut_mask(64'hFFFFFFFFFFFFFFFF), .dont_touch("on"))
		dly_bit0(.dataa(1'b0), .datab(1'b0), .datac(1'b0), .datad(1'b0), .datae(1'b0), .dataf(1'b0), .datag(1'b0), 
			.cin(DIN), .cout(DOUT[0])
		);
	
	genvar i;
	generate
		for(i=1; i<`DELAY_BIT; i=i+1)
		begin: dly_generate
			arriaii_lcell_comb #(.lut_mask(64'hFFFFFFFFFFFFFFFF), .dont_touch("on"))
				dly_biti(.dataa(1'b0), .datab(1'b0), .datac(1'b0), .datad(1'b0), .datae(1'b0), .dataf(1'b0), .datag(1'b0), 
					.cin(DOUT[i-1]), .cout(DOUT[i])
				);
		end
	endgenerate
endmodule

module mux(DIN, DOUT, SEL);
input [`DELAY_BIT-1:0] DIN;
input [`FINE_BIT-1:0] SEL;
output reg DOUT;

	always @(*)
		DOUT <= DIN[SEL];
endmodule

