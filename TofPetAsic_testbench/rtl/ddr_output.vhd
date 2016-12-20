library ieee;
use ieee.std_logic_1164.all;

entity ddr_output is
port (
	clk		: in std_logic;
	di_l	: in std_logic;
	di_h	: in std_logic;
	do		: out std_logic
);
end ddr_output;

architecture rtl of ddr_output is
signal di_h_latch : std_logic;

begin

process (clk, di_h) begin
if clk = '0' then
	di_h_latch <= di_h;
end if;
end process;

do <= di_l when clk = '0' else di_h_latch;

end rtl;

