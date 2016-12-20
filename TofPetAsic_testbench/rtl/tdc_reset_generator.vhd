library ieee, gctrl_lib;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tdc_reset_generator is
port (
	clk		: in std_logic;	
	reset	: in std_logic;
	ctime_parity : in std_logic;	
	veto : in std_logic;		
	reset_bar : out std_logic
);
end tdc_reset_generator;

architecture rtl of tdc_reset_generator is

signal do_reset_tdc : std_logic;

begin

process (clk, reset, veto) begin
if reset = '1' or veto = '1' then
	do_reset_tdc <= '1';
elsif rising_edge(clk) then
	if ctime_parity = '1' then
		do_reset_tdc <= '0';
	end if; 
end if;
end process;

reset_bar <= not do_reset_tdc;

end rtl;