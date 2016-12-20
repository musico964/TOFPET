library ieee;
use ieee.std_logic_1164.all;

entity latched_comparator is
generic (
	delay : time := 400 ps
);
port (
	u 	: in real;			-- input "voltage"
	qch : in std_logic;		-- qch sinal
	clk	: in std_logic;		-- clock
	q 	: out std_logic;	-- comparator output
	q_bar 	: out std_logic
);
end latched_comparator;

architecture behavioral of latched_comparator is

signal delayed_clk : std_logic;
signal clock_enable : std_logic;

begin
	delayed_clk <= clk after delay;
	
	process(delayed_clk, qch, u) begin
	if delayed_clk = '1' then
		if qch = '1' and u <= 0.0 then
			clock_enable <= '1';
		else
			clock_enable <= '0';
		end if;
	end if;
	end process;

	q <= not delayed_clk when clock_enable = '1' else '0';
	q_bar <= not delayed_clk when clock_enable = '0' else '0';
	
end behavioral;
