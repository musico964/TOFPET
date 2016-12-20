library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package asic_k is
 
 	constant GE_CONFIG_SIZE : integer := 14*6;
 	constant GE_TCONFIG_SIZE : integer := 6;	
 	
 	
 	constant G_CONFIG_SIZE : integer := 26 + GE_CONFIG_SIZE;
 	constant G_TCONFIG_SIZE : integer := 1 + GE_TCONFIG_SIZE; 
 	
 	constant CH_CONFIG_SIZE : integer := 53;
 	constant CH_TCONFIG_SIZE : integer := 1;

 	constant CH_DATA_SIZE : integer := 53;
 	
 	constant CH_DARK_COUNT_SIZE : integer := 10;
 	
 	
 	constant DEFAULT_G_CONFIG : std_logic_vector(G_CONFIG_SIZE-1 downto 0) := 
			-- GE Config 
			b"100000" &
			b"100000" &
			b"100000" &
			b"100000" &
			b"001101" &
			b"000011" &
			b"000011" &
			b"000101" &
			b"101101" &
			b"110000" &
			b"100011" &
			b"101100" &
			b"101011" &
			b"100000" &
			
			'1' 	& -- clk_o enable
			'0' 	& -- Test pattern mode
			
			'0'		& -- external veto enable
			
			'1'		& -- full event mode
			
			b"0000"	& -- counter interval set to 1 frame
			'0'		& -- count trigger error
			
			-- In full event mode, these do not matter
			x"00" 	& -- fine counter kf
			'0' 	& -- fine counter saturante
			 
			b"0011"	& -- TAC refresh period set to 4 frames
			'1'		& -- External pulse enable
			"001";	  -- TX mode set to x1 SDR	
 	
	constant DEFAULT_G_TCONFIG : std_logic_vector(G_TCONFIG_SIZE-1 downto 0) := 
			b"111111" &
			'0';
	
	constant DEFAULT_CH_CONFIG : std_logic_vector(CH_CONFIG_SIZE-1 downto 0) := 
			b"00111000010000100001111111110111000011011111111000111";
	
	constant DEFAULT_CH_TCONFIG : std_logic_vector(CH_TCONFIG_SIZE-1 downto 0) := (others => '0');

end;