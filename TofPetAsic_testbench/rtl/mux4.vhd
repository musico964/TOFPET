library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux4 is
port (
	a	: in std_logic_vector(3 downto 0);
	d	: in std_logic_vector(3 downto 0);
	q	: out std_logic
);
end mux4;

architecture rtl of mux4 is

begin
q <= (d(0) and a(0)) or (d(1) and a(1)) or (d(2) and a(2)) or (d(3) and a(3));
end rtl;
