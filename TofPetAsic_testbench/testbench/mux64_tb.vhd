library ieee, gctrl_lib;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux64_tb is
end mux64_tb;

architecture behavioral of mux64_tb is

signal d : std_logic_vector(63 downto 0);
signal a : std_logic_vector(5 downto 0);
signal a_decoded : std_logic_vector(11 downto 0);
signal i : integer := 0;
signal j : integer;
signal q : std_logic;

begin

uut1 : entity gctrl_lib.mux64_decoder port map (x => a, y => a_decoded);
uut2 : entity gctrl_lib.mux64 port map (a => a_decoded, d => d, q => q);

tb : process
variable a : integer;
variable b : integer;
begin
	j <= 0;
	d <= (others => '0');
	wait for 10 ns;

	for a in 0 to 63 loop 
		d <= (others => '0');
		d(a) <= '1';
		j <= a;
		for b in 0 to 63 loop
			i <= b;
			wait for 1 ns;
			assert q = '0' or a = b severity warning;
		end loop;	
	end loop;	
	
	d <= (others => '0');

wait;
end process;

a <= std_logic_vector(to_unsigned(i, 6));

end behavioral;
