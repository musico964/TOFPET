library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tac_refresh_generator is
port (
	clk		: in std_logic;
	reset	: in std_logic;
	time_tag	: in std_logic_vector(41 downto 0);
	intv	: in std_logic_vector(3 downto 0);
	strobe	: out std_logic
);
end tac_refresh_generator;

architecture rtl of tac_refresh_generator is
signal aux1	: std_logic;
signal aux2 : std_logic;
begin

aux1 <= time_tag(11 + to_integer(unsigned(intv))) when intv /= b"0000" else '0';
process(clk) begin
if rising_edge(clk) then
	aux2 <= aux1;
	strobe <= aux1 xor aux2;	  
end if;
end process;

end rtl;
