`define OUT_DATA_SIZE 32
`define CTRL_DATA_SIZE 32

module TofPetInterface_AvalonIF(
	input CK,	// 100 MHz
	input RESETb,

// TofPet module Interface	
	input [`OUT_DATA_SIZE-1:0] DATA_OUT0,
	input EMPTY0,
	input FULL0,
	output reg READ0,
	input [10:0] USED_WORDS0,
	input [`OUT_DATA_SIZE-1:0] DATA_OUT1,
	input EMPTY1,
	input FULL1,
	output reg READ1,
	input [10:0] USED_WORDS1,
	input [`OUT_DATA_SIZE-1:0] DATA_OUT2,
	input EMPTY2,
	input FULL2,
	output reg READ2,
	input [10:0] USED_WORDS2,
	input [`OUT_DATA_SIZE-1:0] DATA_OUT3,
	input EMPTY3,
	input FULL3,
	output reg READ3,
	input [10:0] USED_WORDS3,
	input [`OUT_DATA_SIZE-1:0] DATA_OUT4,
	input EMPTY4,
	input FULL4,
	output reg READ4,
	input [10:0] USED_WORDS4,
	input [`OUT_DATA_SIZE-1:0] DATA_OUT5,
	input EMPTY5,
	input FULL5,
	output reg READ5,
	input [10:0] USED_WORDS5,
	
	input [`CTRL_DATA_SIZE-1:0] CTRL_FIFO_OUT,
	output reg CTRL_FIFO_OUT_RE,
	output [`CTRL_DATA_SIZE-1:0] CTRL_FIFO_IN,
	output reg CTRL_FIFO_IN_WE,
	output reg [`CTRL_DATA_SIZE-1:0] NBIT_INOUT,
	output reg [`CTRL_DATA_SIZE-1:0] COMMAND,
	input [`CTRL_DATA_SIZE-1:0] STATUS_WORD,
	
// Avalon MM interface
	input [3:0] avalon_addr,
	input [31:0] avalon_data_in,
	output reg [31:0] avalon_data_out,
	input avalon_cs,
	input avalon_readn,
	input avalon_writen
	);
	
	wire [31:0] fifo_status;
	
	assign fifo_status = {16'b0,
		2'b0,FULL5,FULL4,FULL3,FULL2,FULL1,FULL0,
		2'b0,EMPTY5,EMPTY4,EMPTY3,EMPTY2,EMPTY1,EMPTY0};
	assign CTRL_FIFO_IN = avalon_data_in;
	
// address decoder
	always @(*)
	begin
		READ0 <= 0; READ1 <= 0; READ2 <= 0; READ3 <= 0; READ4 <= 0; READ5 <= 0;
		CTRL_FIFO_OUT_RE <= 0; CTRL_FIFO_IN_WE <= 0;
		case( avalon_addr )
			4'h0: begin
					avalon_data_out <= DATA_OUT0;
					if( avalon_cs == 1 && avalon_readn == 0 )
						READ0 <= 1;
				end
			4'h1: begin
					avalon_data_out <= DATA_OUT1;
					if( avalon_cs == 1 && avalon_readn == 0 )
						READ1 <= 1;
				end
			4'h2: begin
					avalon_data_out <= DATA_OUT2;
					if( avalon_cs == 1 && avalon_readn == 0 )
						READ2 <= 1;
				end
			4'h3: begin
					avalon_data_out <= DATA_OUT3;
					if( avalon_cs == 1 && avalon_readn == 0 )
						READ3 <= 1;
				end
			4'h4: begin
					avalon_data_out <= DATA_OUT4;
					if( avalon_cs == 1 && avalon_readn == 0 )
						READ4 <= 1;
				end
			4'h5: begin
					avalon_data_out <= DATA_OUT5;
					if( avalon_cs == 1 && avalon_readn == 0 )
						READ5 <= 1;
				end
			4'h6: avalon_data_out <= fifo_status;
			4'h7: avalon_data_out <= 32'hF1CA_CAFE;
			4'h8: begin
					avalon_data_out <= CTRL_FIFO_OUT;
					if( avalon_cs == 1 && avalon_readn == 0 )
						CTRL_FIFO_OUT_RE <= 1;
				end
			4'h9: if( avalon_cs == 1 && avalon_writen == 0 )
					CTRL_FIFO_IN_WE <= 1;
			4'hA: avalon_data_out <= NBIT_INOUT;
			4'hB: avalon_data_out <= COMMAND;
			4'hC: avalon_data_out <= STATUS_WORD;
			4'hD: avalon_data_out <= {5'h0,USED_WORDS1,5'h0,USED_WORDS0};
			4'hE: avalon_data_out <= {5'h0,USED_WORDS3,5'h0,USED_WORDS2};
			4'hF: avalon_data_out <= {5'h0,USED_WORDS5,5'h0,USED_WORDS4};
		endcase
	end

// registers
	always @(posedge CK)
	begin
		if( RESETb == 0 )
		begin
			NBIT_INOUT <= 32'b0;
			COMMAND <= 32'b0;
		end
		else
		begin
			if( avalon_cs == 1 && avalon_writen == 0 )
			begin
				case( avalon_addr )
					4'hA: NBIT_INOUT <= avalon_data_in;
					4'hB: COMMAND <= avalon_data_in;
				endcase
			end
		end
	end
	
endmodule
