//------------------------
// Title:       FirstApp.v
// Author:		Paolo Musico (INFN - Genova)
// Rev:         Rev 0.1
// Description: Pinout Test of HSMC-A connector for TOPEM
//				EndoProbe Control Card Pinout
//              inherited from hsmc_loopback.v
//------------------------

// Comment in for BTS GUI:

//`define	ddr2_dimm		// DO NOT USE DDR2 DIMM
//`define	pcie_edge_basic	// DO NOT USE PCI EXPRESS
//`define	hsma_xcvrs		// DO NOT USE HSMA TRANSCEIVERS
//`define	ddr3_dev	// USE DDR3 (128 MB)
`define	enet		// USE ETHERNET
`define	fsm			// USE FLASH-SSRAM-MAX
`define	hsma_lvds	// USE LVDS ON HSMA

// HSMB not present

//`define TEST_HYBRID

`ifdef	hsma_xcvrs
	`define	use_clkin_ref_q2
	`define	hsma_xcvr_refclk	 clkin_ref_q2_p
`endif

`ifdef	pcie_edge_basic
	`define	pcie_refclk	pcie_refclk_p
	`define	use_pcie_refclk	
`endif

`ifdef	hsma_lvds
	`define	lvds_refclk_a		 clkin_top_p
`endif	


module EthernetBoard (

`ifdef	use_clkin_ref_q1_1 
      input           clkin_ref_q1_1_p,     //LVDS    //default 125 MHz  //????adj. defaut 100.000 MHz osc
`endif												  //buffered copies to clkin_ref_q1_2, clkin_ref_q3, and clkin_top
`ifdef	use_clkin_ref_q1_2 
      input           clkin_ref_q1_2_p,     //LVDS    //default 125 MHz  //???? adj. defaut 125.000 MHz osc
`endif
`ifdef	use_clkin_ref_q2
      input           clkin_ref_q2_p,     //LVDS      //default 100 MHz osc // ??? default 125.000 MHz osc
													  //buffered copy to clkin_bot													  //Driven by sma ext_clk_p if clk_sel=1
`endif
`ifdef	use_clkin_ref_q3
      input           clkin_ref_q3_p,     //LVDS      //adj. default 125.000 MHz osc
`endif
`ifdef	use_refclk_155M
    input   	    clkin_155_p,	   //LVPECL    //155.520 MHz osc 
`endif
    input           clkin_bot_p,       //LVDS      //ADJ default 100.000 MHz osc or sma in (Requires external termination.)
    input           clkin_top_p,       //LVDS      //ADJ default 125.000 MHz osc (Requires external termination.)
    output          clkout_sma,        //1.8V      //PLL CLK sma out

	
////DDR3-SDRAM-PORTS  -> 64Mx16 Interface ---------------------//49 pins
`ifdef	ddr3_dev 
    output [14:0]  ddr3_a,          //SSTL15    //Address (1Gb max)
    output [2:0]   ddr3_ba,         //SSTL15    //Bank address
    inout  [15:0]  ddr3_dq,         //SSTL15    //Data
    inout  [1:0]   ddr3_dqs_p,      //SSTL15    //Strobe Pos
    inout  [1:0]   ddr3_dqs_n,      //SSTL15    //Strobe Neg
    output [1:0]   ddr3_dm,         //SSTL15    //Byte write mask
    output         ddr3_wen,        //SSTL15    //Write enable
    output         ddr3_rasn,       //SSTL15    //Row address select
    output         ddr3_casn,       //SSTL15    //Column address select
    inout          ddr3_ck_p,       //SSTL15    //System Clock Pos
    inout          ddr3_ck_n,       //SSTL15    //System Clock Neg
    output         ddr3_cke,        //SSTL15    //Clock Enable
    output         ddr3_csn,        //SSTL15    //Chip Select
    output         ddr3_resetn,     //SSTL15    //Reset
    output         ddr3_odt,        //SSTL15    //On-die termination enable
 `else
    output         ddr3_wen,        //SSTL15    //Write enable
    output         ddr3_cke,        //SSTL15    //Clock Enable
    output         ddr3_csn,        //SSTL15    //Chip Select
    output         ddr3_resetn,     //SSTL15    //Reset
    output         ddr3_odt,        //SSTL15    //On-die termination enable
 `endif
 //DDR2 SDRAM SoDIMM -------------------------------------//x64 -> 117 pins (Default)
	//x64 -> 125 pins
`ifdef	ddr2_dimm
    output [15:0]  ddr2_dimm_a,	    //SSTL18    //Address		OK
    output [2:0]   ddr2_dimm_ba,    //SSTL18    //Bank address  OK
    inout  [63:0]  ddr2_dimm_dq,         //SSTL18    //Data x64 SODIMM		OK
    inout  [7:0]   ddr2_dimm_dqs_p,      //SSTL18    //Strobe Pos			OK
    inout  [7:0]   ddr2_dimm_dqs_n,      //SSTL18    //Strobe Neg			OK
    output [7:0]   ddr2_dimm_dm,         //SSTL18    //Byte write mask  OK
    output [0:0]   ddr2_dimm_cke,    //SSTL18   //System Clock Enable  OK
    output [1:0]   ddr2_dimm_ck_p,   //SSTL18   //System Clock Pos     OK
 //   output [1:0]   ddr2_dimm_ck_n,   //SSTL18    //System Clock Neg		OK
    output         ddr2_dimm_wen,         //SSTL18    //Write enable		OK
    output         ddr2_dimm_rasn,       //SSTL18    //Row address select		OK
    output         ddr2_dimm_casn,       //SSTL18    //Column address select  OK
   output	[1:0]  ddr2_dimm_csn,        //SSTL18    //Chip Select           OK
    output         ddr2_dimm_resetn,     //SSTL18    //Reset
    output  [1:0]  ddr2_dimm_odt,        //SSTL18    //On-die termination enable	OK
`else
   output          ddr2_dimm_wen,         //SSTL18    //Write enable		OK
   output   [0:0]  ddr2_dimm_cke,    //SSTL18   //System Clock Enable  OK
   output	[1:0]  ddr2_dimm_csn,        //SSTL18    //Chip Select           OK
   output          ddr2_dimm_resetn,     //SSTL18    //Reset
   output   [1:0]  ddr2_dimm_odt,        //SSTL18    //On-die termination enable	OK
`endif
////////////////////////////////////////////////////////////////// 
`ifdef enet
//ETHERNET-10/100/1000-RGMII-----------
    output  	   enet_gtx_clk,      //2.5V  //RGMII Transmit Clock
    output [3:0]   enet_tx_d,        //2.5V  //TX to PHY
    input  [3:0]   enet_rx_d,        //2.5V  //RX from PHY
    output         enet_tx_en,       //2.5V  //RGMII Transmit Control
    input	       enet_rx_clk,      //2.5V  //Derived Received Clock
    input          enet_rx_dv,       //2.5V  //RGMII Receive Control 
    output         enet_resetn,        //2.5V      //Reset to PHY (TR=0)
    output         enet_mdc,           //2.5V      //MDIO Control (TR=0)
    inout          enet_mdio,          //2.5V      //MDIO Data (TR=0)
    input          enet_intn,           //2.5V      //MDIO Interrupt (TR=0)
`endif
///////////////////////////////////////////////////////////////////

//FLASH-SRAM-MAX-------------FSM-Bus---//90 pins
`ifdef fsm
    output [25:0]  fsm_a,              //2.5V      //FSM Address Bus (1Gb Flash)
    inout  [31:0]  fsm_d,              //2.5V      //FSM Data Bus
    output         flash_clk,          //2.5V  
    output         flash_cen,          //2.5V  
    output         flash_oen,          //2.5V
    output         flash_wen,          //2.5V
    output         flash_advn,         //2.5V
    input          flash_rdybsyn,      //2.5V
    output         flash_resetn,       //2.5V     // (TR=0)
    output         sram_clk,           //2.5V
    output         sram_cen,           //2.5V
    inout  [3:0]   sram_dqp,           //2.5V     //Parity bits only go to SRAM
    output [3:0]   sram_bwn,           //2.5V
    output         sram_gwn,           //2.5V
    output         sram_bwen,          //2.5V
    output         sram_oen,           //2.5V
    output         sram_advn,          //2.5V
    output         sram_adspn,         //2.5V
    output         sram_adscn,         //2.5V
    output         sram_zz,            //2.5V     // (TR=0)
    output         max2_clk,           //1.8V
    output         max2_csn,           //1.8V
    output [3:0]   max2_ben,           //1.8V
    output         max2_oen,           //1.8V
    output         max2_wen,           //1.8V
`endif
////LCD----------------------------------//11 pins
    inout  [7:0]   lcd_data,           //2.5V
    output         lcd_d_cn,           //2.5V
    output         lcd_wen,            //2.5V
    output         lcd_csn,            //2.5V
//
////User-IO------------------------------//22 pins
    input  [3:0]   user_dipsw,         //1.8V/2.5V     // (TR=0)
//    output [7:0]   user_led,           //2.5V
    output [3:0]   user_led,           //2.5V
    input  [1:0]   user_pb,            //1.8V/2.5V     // (TR=0)
//    input  [1:0]   user_pb,            //1.8V/2.5V     // (TR=0)
    input          cpu_resetn,         //2.5V (DEV_CLRn)    // (TR=0)
  
// //PCI-EXPRESS-EDGE---------------------
/*
`ifdef	use_pcie_refclk
    input          pcie_refclk_p,      //HCSL
`endif
`ifdef	pcie_edge_basic
    output [7:0]   pcie_tx_p,          //1.4V PCML
    input  [7:0]   pcie_rx_p,          //1.4V PCML
`endif
    input          pcie_smbclk,        //2.5V     // (TR=0)
    inout          pcie_smbdat,        //2.5V     // (TR=0)
    input          pcie_perstn,        //2.5V     // (TR=0)
    output         pcie_waken,         //2.5V     // (TR=0)
    output         pcie_led_x1,        //2.5V
    output         pcie_led_x4,        //2.5V
    output         pcie_led_x8,        //2.5V
//    output         pcie_led_g2,        //2.5V
*/

// HIGH-SPEED-MEZZANINE-CARD------------//198 pins (HSMB is not connected)
// Application specific pinout for TOPEM Test Card
//Port A -->   single samtec conn  //107 pins  //------------------

    output [3:0]   hsma_tx_p,    	   //1.4V PCML
    input  [3:0]   hsma_rx_p,    	   //1.4V PCML

	output [16:0]  hsma_tx_d_p,        //LVDS  //69 pins
    input  [16:0]   hsma_rx_d_p,        //LVDS
    input          hsma_clk_in_p1,     //LVDS //Requires external termination  
    output         hsma_clk_out_p1,    //LVDS
    input          hsma_clk_in_p2,     //LVDS //Requires external termination
    output         hsma_clk_out_p2,    //LVDS    

//    input [3:0]	   hsma_user_in,       //2.5V
    output [3:0]   hsma_user_out,      //2.5V
    input          hsma_clk_in0,       //2.5V
//    output reg     hsma_clk_out0,      //2.5V

//  input		   hsma_sda,
    inout          hsma_sda,           //2.5V     // (TR=0)
    output         hsma_scl,           //2.5V     // (TR=0)
    output         hsma_tx_led,        //2.5V
    output         hsma_rx_led,        //2.5V
    input          hsma_prsntn         //2.5V     // (TR=0)
);  

	wire	[3:0]	user_led_w;	
	wire enet_mdio_en, enet_mdio_out;
	wire eth_mode, ena_10, reset_n;
	wire tx_clk, enet_tx_125, enet_tx_25, enet_tx_2p5;
	wire clkin_parallel;
	reg ck2;

// Application I/O
wire tofpet_clk;	// LVDS
wire ck_10MHz;

wire [31:0] data_out0, data_out1, data_out2, data_out3, data_out4, data_out5;
wire [31:0] ctrl_fifo_out, ctrl_fifo_in, nbit_inout, command_word, status_word;
wire empty0,empty1,empty2,empty3,empty4,empty5, full0,full1,full2,full3,full4,full5, read0,read1,read2,read3,read4,read5;
wire ctrl_fifo_out_re, ctrl_fifo_in_we;
wire [10:0] UsedWords0, UsedWords1, UsedWords2, UsedWords3, UsedWords4, UsedWords5;

// Remapping application I/O

assign hsma_clk_out_p2 = ~tofpet_clk;	// J2.155, J2.157

	assign hsma_scl = 1;

	assign	  hsma_tx_led	=	user_led_w[0];   
	assign	  hsma_rx_led	=	user_led_w[1];   
								
	assign	clkin_parallel		=	clkin_bot_p;                                

`ifdef TEST_HYBRID
	assign clkout_sma	= hsma_clk_in_p1;	// CLKO_0
	assign user_led[0]	= hsma_rx_d_p[0];	// SDO
	assign user_led[1]	= hsma_rx_d_p[1];	// TX0_0
	assign user_led[2]	= hsma_rx_d_p[2];	// TX1_0
`else
//	assign user_led[0]	= hsma_tx_d_p[12];	// CS0
//	assign user_led[1]	= hsma_tx_d_p[16];	// SCLK
	assign user_led[2]	= hsma_tx_d_p[15];	// SDI
	assign user_led[3]	= hsma_rx_d_p[0];	// SDO
`endif	


	parameter	debounce_prd			=	200000;
	switch_debouncer	#(0,debounce_prd)	switch_debouncer_reset_n
	(
		.reset_n	(1'b1),
		.clk		(!clkin_parallel),
		.data_in	(cpu_resetn),
		.data_out	(reset_n)
	);
		
	defparam		heartbeat_x4_i.heartbeat_mode	=	1;	// Selects LED pattern
	heartbeat_x4	heartbeat_x4_i
	(
		.reset_n		(cpu_resetn),
		.clk			(clkin_parallel),
		.led_pattern	(user_led_w[3:0])
	);

	
// Disable unused interfaces:
`ifndef	ddr3_dev
    assign	ddr3_wen		=	1'b1;
    assign	ddr3_cke		=	1'b0;
	assign	ddr3_csn		=	1'b1;
    assign	ddr3_resetn		=	1'b0;
    assign	ddr3_odt		=	1'b0;
`endif

`ifndef	ddr2_dimm
   assign       ddr2_dimm_wen    = 1'b1;   //SSTL18    //Write enable		OK
   assign   	ddr2_dimm_cke    = 1'b0;   //SSTL18    //System Clock Enable  OK
   assign	  	ddr2_dimm_csn    = 2'b11;  //SSTL18    //Chip Select           OK
   assign       ddr2_dimm_resetn = 1'b0;   //SSTL18    //Reset
   assign		ddr2_dimm_odt    = 2'b00;  //SSTL18    //On-die termination enable	OK
`endif

`ifdef	ddr3_dev
assign ddr3_a[14:13] = 2'b00;
`endif

assign sram_clk = 1'b0;
assign sram_cen = 1'b1;
assign sram_gwn = 1'b1;
assign sram_oen = 1'b1;
assign sram_advn = 1'b1;
assign sram_adspn = 1'b1;
assign sram_adscn = 1'b1;
assign sram_zz = 1'b1;
assign sram_bwn = 4'b1111;
assign max2_clk = 1'b0;
assign max2_csn = 1'b1;
assign max2_ben = 4'b1111;
assign max2_wen = 1'b1;
assign max2_oen = 1'b1;

	always @(posedge clkin_parallel)
	if( cpu_resetn == 0 )
		ck2 <= 0;
	else
		ck2 <= ~ck2;

TofPetPll TofPetPll_Instance(.inclk0(clkin_parallel),
	.c0(tofpet_clk), .c1(ck_10MHz), .locked());

EthernetSystem EthernetSystem_Instance(
        .reset_n                              (cpu_resetn),               //             clkin_100_clk_in_reset.reset_n
        .clkin_100                            (clkin_parallel),           //                   clkin_100_clk_in.clk
//        .clkin_100                            (ck2),           //                   clkin_100_clk_in.clk

        .LCD_RS_from_the_lcd                  (lcd_d_cn),                 //                       lcd_external.RS
        .LCD_RW_from_the_lcd                  (lcd_wen),                  //                                   .RW
        .LCD_data_to_and_from_the_lcd         (lcd_data),                 //                                   .data
        .LCD_E_from_the_lcd                   (lcd_csn),                  //                                   .E
`ifdef	ddr3_dev
        .sdram_global_reset_n_reset_n                   (cpu_resetn),     //               sdram_global_reset_n.reset_n
        .sdram_phy_clk_out                    			(),               //                     sysclk_out_clk.clk
        .sdram_auxfull_clk          					(),               //                      sdram_auxfull.clk
        .sdram_auxhalf_clk          					(),               //                      sdram_auxhalf.clk
        .sdram_memory_mem_odt               			(ddr3_odt),       //                       sdram_memory.mem_odt
        .sdram_memory_mem_clk        					(ddr3_ck_p),      //                                   .mem_clk
        .sdram_memory_mem_clk_n      					(ddr3_ck_n),      //                                   .mem_clk_n
        .sdram_memory_mem_cs_n              			(ddr3_csn),       //                                   .mem_cs_n
        .sdram_memory_mem_cke               			(ddr3_cke),       //                                   .mem_cke
        .sdram_memory_mem_addr              			(ddr3_a[12:0]),   //                                   .mem_addr
        .sdram_memory_mem_ba                			(ddr3_ba),        //                                   .mem_ba
        .sdram_memory_mem_ras_n             			(ddr3_rasn),      //                                   .mem_ras_n
        .sdram_memory_mem_cas_n             			(ddr3_casn),      //                                   .mem_cas_n
        .sdram_memory_mem_we_n             				(ddr3_wen),       //                                   .mem_we_n
        .sdram_memory_mem_dq         					(ddr3_dq),        //                                   .mem_dq
        .sdram_memory_mem_dqs        					(ddr3_dqs_p),     //                                   .mem_dqs
        .sdram_memory_mem_dqsn       					(ddr3_dqs_n),     //                                   .mem_dqsn
        .sdram_memory_mem_dm                			(ddr3_dm),        //                                   .mem_dm
        .sdram_memory_mem_reset_n           			(ddr3_resetn),    //                                   .mem_reset_n
        .sdram_external_connection_local_refresh_ack    (),               //          sdram_external_connection.local_refresh_ack
        .sdram_external_connection_local_init_done      (),               //                                   .local_init_done
        .sdram_external_connection_reset_phy_clk_n      (),               //                                   .reset_phy_clk_n
        .sdram_external_connection_dll_reference_clk    (),               //                                   .dll_reference_clk
        .sdram_external_connection_dqs_delay_ctrl_export(),               //                                   .dqs_delay_ctrl_export
`endif 
        .flash_tristate_bridge_data           (fsm_d),           //                                   .flash_tristate_bridge_data
        .flash_tristate_bridge_address        (fsm_a),        //                                   .flash_tristate_bridge_address
        .read_n_to_the_ext_flash              (flash_oen),              // flash_tristate_bridge_bridge_0_out.read_n_to_the_ext_flash
        .select_n_to_the_ext_flash            (flash_cen),            //                                   .select_n_to_the_ext_flash
        .write_n_to_the_ext_flash             (flash_wen),             //                                   .write_n_to_the_ext_flash
        .be_n_to_the_maxII_interface          (),          //                                   .be_n_to_the_maxII_interface
        .oe_n_to_the_maxII_interface          (),          //                                   .oe_n_to_the_maxII_interface
        .cs_n_to_the_maxII_interface          (),          //                                   .cs_n_to_the_maxII_interface
        .we_n_to_the_maxII_interface          (),          //                                   .we_n_to_the_maxII_interface

//        .out_port_from_the_led_pio            (user_led),                         // led_pio_external_connection.export
        .out_port_from_the_led_pio            (),                                 // led_pio_external_connection.export
        .in_port_to_the_button_pio            (user_pb),                          // button_pio_external_connection.export

        .tse_mac_mac_rgmii_connection_rgmii_in           (enet_rx_d),             // .rgmii_in
        .tse_mac_mac_rgmii_connection_rgmii_out          (enet_tx_d),             // .rgmii_out
        .tse_mac_mac_rgmii_connection_rx_control         (enet_rx_dv),            // .rx_control
        .tse_mac_mac_rgmii_connection_tx_control         (enet_tx_en),            // .tx_control
        .tse_mac_pcs_mac_tx_clock_connection_clk         (tx_clk),                // .tx_clk
        .tse_mac_pcs_mac_rx_clock_connection_clk         (enet_rx_clk),           // .rx_clk
        .tse_mac_mac_status_connection_set_10            (),                      // .set_10
        .tse_mac_mac_status_connection_set_1000          (),                      // .set_1000
        .tse_mac_mac_status_connection_ena_10            (ena_10),                // .ena_10
        .tse_mac_mac_status_connection_eth_mode          (eth_mode),              // .eth_mode
        .tse_mac_mac_mdio_connection_mdio_out            (enet_mdio_out),         // .mdio_out
        .tse_mac_mac_mdio_connection_mdio_oen            (enet_mdio_en),          // .mdio_oen
        .tse_mac_mac_mdio_connection_mdio_in             (enet_mdio),             // .mdio_in
        .tse_mac_mac_mdio_connection_mdc                 (enet_mdc),              // .mdc
        .tse_mac_mac_misc_connection_xon_gen             (1'b0),                  // .xon_gen
        .tse_mac_mac_misc_connection_xoff_gen            (1'b0),                  // .xoff_gen
        .tse_mac_mac_misc_connection_magic_wakeup        (),                      // .magic_wakeup
        .tse_mac_mac_misc_connection_magic_sleep_n       (1'b1),                  // .magic_sleep_n
        .tse_mac_mac_misc_connection_ff_tx_crc_fwd       (1'b0),                  // .ff_tx_crc_fwd
        .tse_mac_mac_misc_connection_ff_tx_septy         (),                      // .ff_tx_septy
        .tse_mac_mac_misc_connection_tx_ff_uflow         (),                      // .tx_ff_uflow
        .tse_mac_mac_misc_connection_ff_tx_a_full        (),                      // .ff_tx_a_full
        .tse_mac_mac_misc_connection_ff_tx_a_empty       (),                      // .ff_tx_a_empty
        .tse_mac_mac_misc_connection_rx_err_stat         (),                      // .rx_err_stat
        .tse_mac_mac_misc_connection_rx_frm_type         (),                      // .rx_frm_type
        .tse_mac_mac_misc_connection_ff_rx_dsav          (),                      // .ff_rx_dsav
        .tse_mac_mac_misc_connection_ff_rx_a_full        (),                      // .ff_rx_a_full
        .tse_mac_mac_misc_connection_ff_rx_a_empty       (),                      // .ff_rx_a_empty

		.tofpet_avalon_mm_if_0_tofpet_conduit_DATA_OUT0        (data_out0),       // .DATA_OUT0
        .tofpet_avalon_mm_if_0_tofpet_conduit_EMPTY0           (empty0),          // .EMPTY0
        .tofpet_avalon_mm_if_0_tofpet_conduit_FULL0            (full0),           // .FULL0
        .tofpet_avalon_mm_if_0_tofpet_conduit_DATA_OUT1        (data_out1),       // .DATA_OUT1
        .tofpet_avalon_mm_if_0_tofpet_conduit_EMPTY1           (empty1),          // .EMPTY1
        .tofpet_avalon_mm_if_0_tofpet_conduit_FULL1            (full1),           // .FULL1
        .tofpet_avalon_mm_if_0_tofpet_conduit_DATA_OUT2        (data_out2),       // .DATA_OUT2
        .tofpet_avalon_mm_if_0_tofpet_conduit_EMPTY2           (empty2),          // .EMPTY2
        .tofpet_avalon_mm_if_0_tofpet_conduit_FULL2            (full2),           // .FULL2
        .tofpet_avalon_mm_if_0_tofpet_conduit_DATA_OUT3        (data_out3),       // .DATA_OUT3
        .tofpet_avalon_mm_if_0_tofpet_conduit_EMPTY3           (empty3),          // .EMPTY3
        .tofpet_avalon_mm_if_0_tofpet_conduit_FULL3            (full3),           // .FULL3
        .tofpet_avalon_mm_if_0_tofpet_conduit_DATA_OUT4        (data_out4),       // .DATA_OUT4
        .tofpet_avalon_mm_if_0_tofpet_conduit_EMPTY4           (empty4),          // .EMPTY4
        .tofpet_avalon_mm_if_0_tofpet_conduit_DATA_OUT5        (data_out5),       // .DATA_OUT5
        .tofpet_avalon_mm_if_0_tofpet_conduit_EMPTY5           (empty5),          // .EMPTY5
        .tofpet_avalon_mm_if_0_tofpet_conduit_FULL5            (full5),           // .FULL5
        .tofpet_avalon_mm_if_0_tofpet_conduit_CTRL_FIFO_OUT    (ctrl_fifo_out),   // .CTRL_FIFO_OUT
        .tofpet_avalon_mm_if_0_tofpet_conduit_CTRL_FIFO_OUT_RE (ctrl_fifo_out_re),// .CTRL_FIFO_OUT_RE
        .tofpet_avalon_mm_if_0_tofpet_conduit_CTRL_FIFO_IN     (ctrl_fifo_in),    // .CTRL_FIFO_IN
        .tofpet_avalon_mm_if_0_tofpet_conduit_CTRL_FIFO_IN_WE  (ctrl_fifo_in_we), // .CTRL_FIFO_IN_WE
        .tofpet_avalon_mm_if_0_tofpet_conduit_NBIT_INOUT       (nbit_inout),      // .NBIT_INOUT
        .tofpet_avalon_mm_if_0_tofpet_conduit_COMMAND          (command_word),    // .COMMAND
        .tofpet_avalon_mm_if_0_tofpet_conduit_FULL4            (full4),           // .FULL4
		.tofpet_avalon_mm_if_0_tofpet_conduit_STATUS_WORD      (status_word),
        .tofpet_avalon_mm_if_0_tofpet_conduit_READ0            (read0),           // .READ0
        .tofpet_avalon_mm_if_0_tofpet_conduit_READ1            (read1),           // .READ1
        .tofpet_avalon_mm_if_0_tofpet_conduit_READ2            (read2),           // .READ2
        .tofpet_avalon_mm_if_0_tofpet_conduit_READ3            (read3),           // .READ3
        .tofpet_avalon_mm_if_0_tofpet_conduit_READ4            (read4),           // .READ4
        .tofpet_avalon_mm_if_0_tofpet_conduit_READ5            (read5),           // .READ5
        .tofpet_avalon_mm_if_0_tofpet_conduit_USED_WORDS0      (UsedWords0),      // .USED_WORDS0
        .tofpet_avalon_mm_if_0_tofpet_conduit_USED_WORDS1      (UsedWords1),      // .USED_WORDS1
        .tofpet_avalon_mm_if_0_tofpet_conduit_USED_WORDS2      (UsedWords2),      // .USED_WORDS2
        .tofpet_avalon_mm_if_0_tofpet_conduit_USED_WORDS3      (UsedWords3),      // .USED_WORDS3
        .tofpet_avalon_mm_if_0_tofpet_conduit_USED_WORDS4      (UsedWords4),      // .USED_WORDS4
        .tofpet_avalon_mm_if_0_tofpet_conduit_USED_WORDS5      (UsedWords5)       // .USED_WORDS5
		);

TofPetInterface TofPetInterface_Instance(
	.TOFPET_CK(tofpet_clk),
	.CK(clkin_parallel),	// 100 MHz
	.LFCK(ck_10MHz),
	.RESETb(cpu_resetn),

// Processor Interface	
	.DATA_OUT0(data_out0),
	.EMPTY0(empty0),
	.FULL0(full0),
	.READ0(read0),
	.USED_WORDS0(UsedWords0),
	.DATA_OUT1(data_out1),
	.EMPTY1(empty1),
	.FULL1(full1),
	.READ1(read1),
	.USED_WORDS1(UsedWords1),
	.DATA_OUT2(data_out2),
	.EMPTY2(empty2),
	.FULL2(full2),
	.READ2(read2),
	.USED_WORDS2(UsedWords2),
	.DATA_OUT3(data_out3),
	.EMPTY3(empty3),
	.FULL3(full3),
	.READ3(read3),
	.USED_WORDS3(UsedWords3),
	.DATA_OUT4(data_out4),
	.EMPTY4(empty4),
	.FULL4(full4),
	.READ4(read4),
	.USED_WORDS4(UsedWords4),
	.DATA_OUT5(data_out5),
	.EMPTY5(empty5),
	.FULL5(full5),
	.READ5(read5),
	.USED_WORDS5(UsedWords5),
	
	.CTRL_FIFO_OUT(ctrl_fifo_out),
	.CTRL_FIFO_OUT_RE(ctrl_fifo_out_re),
	.CTRL_FIFO_IN(ctrl_fifo_in),
	.CTRL_FIFO_IN_WE(ctrl_fifo_in_we),
	.NBIT_INOUT(nbit_inout),
	.COMMAND(command_word),
	.STATUS(status_word),
	
// TofPet ASIC interface
`ifdef TEST_HYBRID
	.CLKO_0(hsma_clk_in_p1),// J2.96, J2.98
	.TX0_0(hsma_rx_d_p[1]),	// J2.54, J2.56
	.TX1_0(hsma_rx_d_p[2]),	// J2.60, J2.62
	.CLKO_1(1'b0),// NOT USED
	.TX0_1(1'b0),// NOT USED
	.TX1_1(1'b0),// NOT USED
	.CLKO_2(1'b0),// NOT USED
	.TX0_2(1'b0),	// NOT USED
	.TX1_2(1'b0),	// NOT USED
	.CLKO_3(1'b0),// NOT USED
	.TX0_3(1'b0),// NOT USED
	.TX1_3(1'b0),// NOT USED
	.CLKO_4(1'b0),// NOT USED
	.TX0_4(1'b0),	// NOT USED
	.TX1_4(1'b0),	// NOT USED
	.CLKO_5(1'b0),// NOT USED
	.TX0_5(1'b0),	// NOT USED
	.TX1_5(1'b0),	// NOT USED
	.SYNC_RST(hsma_tx_d_p[13]),	// J2.131, J2.133
	.TEST_PULSE(hsma_tx_d_p[12]),	// J2.125, J2.127
	.SCLK(hsma_tx_d_p[15]),	// J2.143, J2.145
	.SDI(hsma_tx_d_p[16]),	// J2.149, J2.151
	.CS({hsma_tx_d_p[7],	// J2.89, J2.91
		hsma_tx_d_p[8],		// J2.101, J2.103
		hsma_tx_d_p[9],		// J2.107, J2.109
		hsma_tx_d_p[10],	// J2.113, J2.115
		hsma_tx_d_p[11],	// J2.119, J2.121
		hsma_tx_d_p[14]}),	// J2.137, J2.139
`else
	.CLKO_0(hsma_clk_in_p2),// J2.156, J2.158
	.TX0_0(hsma_rx_d_p[16]),// J2.150, J2.152
	.TX1_0(hsma_rx_d_p[15]),// J2.144, J2.146
	.CLKO_1(hsma_rx_d_p[14]),// J2.138, J2.140
	.TX0_1(hsma_rx_d_p[13]),// J2.132, J2.134
	.TX1_1(hsma_rx_d_p[12]),// J2.126, J2.128
	.CLKO_2(hsma_rx_d_p[11]),// J2.120, J2.122
	.TX0_2(hsma_rx_d_p[7]),	// J2.90, J2.92
	.TX1_2(hsma_rx_d_p[9]),	// J2.108, J2.110
	.CLKO_3(hsma_clk_in_p1),// J2.96, J2.98
	.TX0_3(hsma_rx_d_p[8]),// J2.102, J2.104
	.TX1_3(hsma_rx_d_p[10]),// J2.114, J2.116
	.CLKO_4(hsma_rx_d_p[6]),// J2.84, J2.86
	.TX0_4(hsma_rx_d_p[5]),	// J2.78, J2.80
	.TX1_4(hsma_rx_d_p[4]),	// J2.72, J2.74
	.CLKO_5(hsma_rx_d_p[3]),// J2.66, J2.68
	.TX0_5(hsma_rx_d_p[2]),	// J2.60, J2.62
	.TX1_5(hsma_rx_d_p[1]),	// J2.54, J2.56
	.SYNC_RST(hsma_tx_d_p[14]),	// J2.137, J2.139
	.TEST_PULSE(hsma_tx_d_p[13]),	// J2.131, J2.133
	.SCLK(hsma_tx_d_p[16]),	// J2.149, J2.151
	.SDI(hsma_tx_d_p[15]),	// J2.143, J2.145
	.CS({hsma_tx_d_p[7],	// J2.89, J2.91
		hsma_tx_d_p[8],		// J2.101, J2.103
		hsma_tx_d_p[9],		// J2.107, J2.109
		hsma_tx_d_p[10],	// J2.113, J2.115
		hsma_tx_d_p[11],	// J2.119, J2.121
		hsma_tx_d_p[12]}),	// J2.125, J2.127
`endif

	.SDO(hsma_rx_d_p[0]),	// J2.48, J2.50
	
// FrontEnd selector
	.FE_SELECT(hsma_user_out[2:0]),	// J2.44 J2.43 J2.41
	.FE_ENABLEb(hsma_user_out[3]),	// J2.42
	.DEBUG0(user_led[0]),
	.DEBUG1(user_led[1])
);	
		
assign flash_advn = 1'b1;
assign flash_clk = clkin_parallel;
assign flash_resetn = reset_n;
assign tx_clk    =   (eth_mode) ? (enet_tx_125) :       // GbE Mode = 125MHz clock
                     (ena_10) ? (enet_tx_2p5) :         // 10Mb Mode = 2.5MHz clock
                     (enet_tx_25);                      // 100Mb Mode = 25MHz clock

tx_clk_pll tx_clk_inst
(
	.areset (!reset_n),
	.inclk0 (clkin_parallel),
	.c0     (enet_tx_125),
	.c1     (enet_tx_25),
	.c2     (enet_tx_2p5),
	.locked ()
);

altddio_out     altddio_out_component (
                    .outclock ( tx_clk ),
                    .dataout ( enet_gtx_clk ),
                    .aclr (!reset_n),
                    .datain_h (1'b1),
                    .datain_l (1'b0),
                    .outclocken (1'b1),
                    .aset (1'b0),
                    .sclr (1'b0),
                    .sset (1'b0),
                    .oe_out (),
                    .oe (1'b1)
                    );
        defparam
                altddio_out_component.extend_oe_disable = "UNUSED",
                altddio_out_component.intended_device_family = "Arria II GX",
                altddio_out_component.invert_output = "OFF",
                altddio_out_component.lpm_type = "altddio_out",
                altddio_out_component.oe_reg = "UNUSED",
                altddio_out_component.width = 1;

parameter MSB = 21; // was 20 in 9.1sp2 but doesn't seem to improve reset success or avert crash

reg [MSB:0] epcount; // 21 bits (2 exp 21) * 20ns = ~42ms
 
always @(posedge clkin_parallel)
begin 
	if (reset_n == 1'b0)
		epcount <= MSB+1'b0;
	else
	if (epcount[MSB] == 1'b0)
		epcount <= epcount +1;
	else
		epcount <= epcount;
	end
 
assign enet_resetn = !epcount[MSB-1]; // phy held low for ~21 msec after cpu_reset
assign enet_mdio = enet_mdio_en == 0 ? enet_mdio_out : 1'bz;

	
endmodule

