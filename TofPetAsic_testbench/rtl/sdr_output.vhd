library ieee;
use ieee.std_logic_1164.all;

entity sdr_output is
port (
	clk		: in std_logic;
	di	: in std_logic;
	do		: out std_logic
);
end sdr_output;

architecture rtl of sdr_output is

begin
do <= di;

end rtl;

