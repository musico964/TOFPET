library ieee, gctrl_lib;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux64 is
port (
	a	: in std_logic_vector(11 downto 0);
	d	: in std_logic_vector(63 downto 0);
	q	: out std_logic
);
end mux64;

architecture rtl of mux64 is

signal d16	: std_logic_vector(15 downto 0);
signal d4	: std_logic_vector(3 downto 0);

begin
g1: for i in 0 to 15 generate
	mux4 : entity gctrl_lib.mux4 port map (a => a(3 downto 0), d => d(4*i+3 downto 4*i+0), q => d16(i));
end generate;

g2: for i in 0 to 3 generate
	mux4 : entity gctrl_lib.mux4 port map (a => a(7 downto 4), d => d16(4*i+3 downto 4*i+0), q => d4(i));
end generate;

	mux4 : entity gctrl_lib.mux4 port map (a => a(11 downto 8), d => d4(3 downto 0), q => q);
end rtl;
