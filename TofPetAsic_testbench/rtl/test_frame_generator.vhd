library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity test_frame_generator is
port (
	clk		: in std_logic;
	reset	: in std_logic;
	ctime 	: in std_logic_vector(41 downto 0);
	data_out : out std_logic_vector(39 downto 0);
	data_out_frameid : out std_logic;
	data_out_valid : out std_logic
);
end test_frame_generator;
 
 architecture rtl of test_frame_generator is
 
 signal frame_id : std_logic_vector(31 downto 0);
  
 begin
 
 frame_id <= ctime(41 downto 10);
 
 data_out_frameid <= frame_id(0);
 data_out_valid <= '1' when ctime(5 downto 0) = "000000" else '0';
 data_out <= ctime(39 downto 0); 
 
 end rtl;
 