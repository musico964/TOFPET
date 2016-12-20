// (C) 2001-2013 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// $Id: //acds/rel/13.0sp1/ip/merlin/altera_tristate_conduit_bridge/altera_tristate_conduit_bridge.sv.terp#1 $
// $Revision: #1 $
// $Date: 2013/03/07 $
// $Author: swbranch $

//Defined Terp Parameters


			    

`timescale 1 ns / 1 ns
  				      
module EthernetSystem_flash_tristate_bridge_bridge_0 (
     input  logic clk
    ,input  logic reset
    ,input  logic request
    ,output logic grant
    ,input  logic[ 0 :0 ] tcs_read_n_to_the_ext_flash
    ,output  wire [ 0 :0 ] read_n_to_the_ext_flash
    ,input  logic[ 0 :0 ] tcs_select_n_to_the_ext_flash
    ,output  wire [ 0 :0 ] select_n_to_the_ext_flash
    ,input  logic[ 3 :0 ] tcs_be_n_to_the_maxII_interface
    ,output  wire [ 3 :0 ] be_n_to_the_maxII_interface
    ,input  logic[ 0 :0 ] tcs_oe_n_to_the_maxII_interface
    ,output  wire [ 0 :0 ] oe_n_to_the_maxII_interface
    ,input  logic[ 0 :0 ] tcs_cs_n_to_the_maxII_interface
    ,output  wire [ 0 :0 ] cs_n_to_the_maxII_interface
    ,output logic[ 31 :0 ] tcs_flash_tristate_bridge_data_in
    ,input  logic[ 31 :0 ] tcs_flash_tristate_bridge_data
    ,input  logic tcs_flash_tristate_bridge_data_outen
    ,inout  wire [ 31 :0 ]  flash_tristate_bridge_data
    ,input  logic[ 0 :0 ] tcs_we_n_to_the_maxII_interface
    ,output  wire [ 0 :0 ] we_n_to_the_maxII_interface
    ,input  logic[ 0 :0 ] tcs_write_n_to_the_ext_flash
    ,output  wire [ 0 :0 ] write_n_to_the_ext_flash
    ,input  logic[ 25 :0 ] tcs_flash_tristate_bridge_address
    ,output  wire [ 25 :0 ] flash_tristate_bridge_address
		     
   );
   reg grant_reg;
   assign grant = grant_reg;
   
   always@(posedge clk) begin
      if(reset)
	grant_reg <= 0;
      else
	grant_reg <= request;      
   end
   


 // ** Output Pin read_n_to_the_ext_flash 
 
    reg                       read_n_to_the_ext_flashen_reg;     
  
    always@(posedge clk) begin
	 if( reset ) begin
	   read_n_to_the_ext_flashen_reg <= 'b0;
	 end
	 else begin
	   read_n_to_the_ext_flashen_reg <= 'b1;
	 end
     end		     
   
 
    reg [ 0 : 0 ] read_n_to_the_ext_flash_reg;   

     always@(posedge clk) begin
	 read_n_to_the_ext_flash_reg   <= tcs_read_n_to_the_ext_flash[ 0 : 0 ];
      end
          
 
    assign 	read_n_to_the_ext_flash[ 0 : 0 ] = read_n_to_the_ext_flashen_reg ? read_n_to_the_ext_flash_reg : 'z ;
        


 // ** Output Pin select_n_to_the_ext_flash 
 
    reg                       select_n_to_the_ext_flashen_reg;     
  
    always@(posedge clk) begin
	 if( reset ) begin
	   select_n_to_the_ext_flashen_reg <= 'b0;
	 end
	 else begin
	   select_n_to_the_ext_flashen_reg <= 'b1;
	 end
     end		     
   
 
    reg [ 0 : 0 ] select_n_to_the_ext_flash_reg;   

     always@(posedge clk) begin
	 select_n_to_the_ext_flash_reg   <= tcs_select_n_to_the_ext_flash[ 0 : 0 ];
      end
          
 
    assign 	select_n_to_the_ext_flash[ 0 : 0 ] = select_n_to_the_ext_flashen_reg ? select_n_to_the_ext_flash_reg : 'z ;
        


 // ** Output Pin be_n_to_the_maxII_interface 
 
    reg                       be_n_to_the_maxII_interfaceen_reg;     
  
    always@(posedge clk) begin
	 if( reset ) begin
	   be_n_to_the_maxII_interfaceen_reg <= 'b0;
	 end
	 else begin
	   be_n_to_the_maxII_interfaceen_reg <= 'b1;
	 end
     end		     
   
 
    reg [ 3 : 0 ] be_n_to_the_maxII_interface_reg;   

     always@(posedge clk) begin
	 be_n_to_the_maxII_interface_reg   <= tcs_be_n_to_the_maxII_interface[ 3 : 0 ];
      end
          
 
    assign 	be_n_to_the_maxII_interface[ 3 : 0 ] = be_n_to_the_maxII_interfaceen_reg ? be_n_to_the_maxII_interface_reg : 'z ;
        


 // ** Output Pin oe_n_to_the_maxII_interface 
 
    reg                       oe_n_to_the_maxII_interfaceen_reg;     
  
    always@(posedge clk) begin
	 if( reset ) begin
	   oe_n_to_the_maxII_interfaceen_reg <= 'b0;
	 end
	 else begin
	   oe_n_to_the_maxII_interfaceen_reg <= 'b1;
	 end
     end		     
   
 
    reg [ 0 : 0 ] oe_n_to_the_maxII_interface_reg;   

     always@(posedge clk) begin
	 oe_n_to_the_maxII_interface_reg   <= tcs_oe_n_to_the_maxII_interface[ 0 : 0 ];
      end
          
 
    assign 	oe_n_to_the_maxII_interface[ 0 : 0 ] = oe_n_to_the_maxII_interfaceen_reg ? oe_n_to_the_maxII_interface_reg : 'z ;
        


 // ** Output Pin cs_n_to_the_maxII_interface 
 
    reg                       cs_n_to_the_maxII_interfaceen_reg;     
  
    always@(posedge clk) begin
	 if( reset ) begin
	   cs_n_to_the_maxII_interfaceen_reg <= 'b0;
	 end
	 else begin
	   cs_n_to_the_maxII_interfaceen_reg <= 'b1;
	 end
     end		     
   
 
    reg [ 0 : 0 ] cs_n_to_the_maxII_interface_reg;   

     always@(posedge clk) begin
	 cs_n_to_the_maxII_interface_reg   <= tcs_cs_n_to_the_maxII_interface[ 0 : 0 ];
      end
          
 
    assign 	cs_n_to_the_maxII_interface[ 0 : 0 ] = cs_n_to_the_maxII_interfaceen_reg ? cs_n_to_the_maxII_interface_reg : 'z ;
        


 // ** Bidirectional Pin flash_tristate_bridge_data 
   
    reg                       flash_tristate_bridge_data_outen_reg;
  
    always@(posedge clk) begin
	 flash_tristate_bridge_data_outen_reg <= tcs_flash_tristate_bridge_data_outen;
     end
  
  
    reg [ 31 : 0 ] flash_tristate_bridge_data_reg;   

     always@(posedge clk) begin
	 flash_tristate_bridge_data_reg   <= tcs_flash_tristate_bridge_data[ 31 : 0 ];
      end
         
  
    assign 	flash_tristate_bridge_data[ 31 : 0 ] = flash_tristate_bridge_data_outen_reg ? flash_tristate_bridge_data_reg : 'z ;
       
  
    reg [ 31 : 0 ] 	flash_tristate_bridge_data_in_reg;
								    
    always@(posedge clk) begin
	 flash_tristate_bridge_data_in_reg <= flash_tristate_bridge_data[ 31 : 0 ];
    end
    
  
    assign      tcs_flash_tristate_bridge_data_in[ 31 : 0 ] = flash_tristate_bridge_data_in_reg[ 31 : 0 ];
        


 // ** Output Pin we_n_to_the_maxII_interface 
 
    reg                       we_n_to_the_maxII_interfaceen_reg;     
  
    always@(posedge clk) begin
	 if( reset ) begin
	   we_n_to_the_maxII_interfaceen_reg <= 'b0;
	 end
	 else begin
	   we_n_to_the_maxII_interfaceen_reg <= 'b1;
	 end
     end		     
   
 
    reg [ 0 : 0 ] we_n_to_the_maxII_interface_reg;   

     always@(posedge clk) begin
	 we_n_to_the_maxII_interface_reg   <= tcs_we_n_to_the_maxII_interface[ 0 : 0 ];
      end
          
 
    assign 	we_n_to_the_maxII_interface[ 0 : 0 ] = we_n_to_the_maxII_interfaceen_reg ? we_n_to_the_maxII_interface_reg : 'z ;
        


 // ** Output Pin write_n_to_the_ext_flash 
 
    reg                       write_n_to_the_ext_flashen_reg;     
  
    always@(posedge clk) begin
	 if( reset ) begin
	   write_n_to_the_ext_flashen_reg <= 'b0;
	 end
	 else begin
	   write_n_to_the_ext_flashen_reg <= 'b1;
	 end
     end		     
   
 
    reg [ 0 : 0 ] write_n_to_the_ext_flash_reg;   

     always@(posedge clk) begin
	 write_n_to_the_ext_flash_reg   <= tcs_write_n_to_the_ext_flash[ 0 : 0 ];
      end
          
 
    assign 	write_n_to_the_ext_flash[ 0 : 0 ] = write_n_to_the_ext_flashen_reg ? write_n_to_the_ext_flash_reg : 'z ;
        


 // ** Output Pin flash_tristate_bridge_address 
 
    reg                       flash_tristate_bridge_addressen_reg;     
  
    always@(posedge clk) begin
	 if( reset ) begin
	   flash_tristate_bridge_addressen_reg <= 'b0;
	 end
	 else begin
	   flash_tristate_bridge_addressen_reg <= 'b1;
	 end
     end		     
   
 
    reg [ 25 : 0 ] flash_tristate_bridge_address_reg;   

     always@(posedge clk) begin
	 flash_tristate_bridge_address_reg   <= tcs_flash_tristate_bridge_address[ 25 : 0 ];
      end
          
 
    assign 	flash_tristate_bridge_address[ 25 : 0 ] = flash_tristate_bridge_addressen_reg ? flash_tristate_bridge_address_reg : 'z ;
        

endmodule


