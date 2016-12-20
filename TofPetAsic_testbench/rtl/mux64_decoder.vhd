library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux64_decoder is
port (
	x	: in std_logic_vector(5 downto 0);
	y 	: out std_logic_vector(11 downto 0)
);
end mux64_decoder;

architecture rtl of mux64_decoder is

begin
g:	for i in 0 to 2 generate
		y(4*i+3 downto 4*i+0) <= 
			b"0001" when x(2*i+1 downto 2*i+0) = b"00" else
			b"0010" when x(2*i+1 downto 2*i+0) = b"01" else
			b"0100" when x(2*i+1 downto 2*i+0) = b"10" else
			b"1000";								
	end generate;
end rtl;
