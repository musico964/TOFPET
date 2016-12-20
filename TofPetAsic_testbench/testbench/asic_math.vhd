library ieee, worklib;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use worklib.asic_i2c.all;

entity asic_math is
generic (
	M : real := 64.0
);
port (
  	B		: in integer;
  	event_st: in std_logic;
	event	: in event_t;
	t	 	: out real := 0.0;
	tot		: out real := 0.0
); 
end asic_math;

architecture behavioral of asic_math is

begin
process (event_st)

variable t_coarse_b : unsigned(9 downto 0);
variable t_fine_b : unsigned(9 downto 0);
variable t_coarse_r : real := 0.0;
variable t_fine_r : real := 0.0;
variable t_t 	: real := 0.0;

variable e_coarse_b : unsigned(9 downto 0);
variable e_fine_b : unsigned(9 downto 0);
variable e_coarse_r : real := 0.0;
variable e_fine_r : real := 0.0;
variable e_t 	: real := 0.0;



begin
if rising_edge(event_st) then
	t_coarse_b := to_unsigned(event.tcoarse, 10);
	t_coarse_r := real(event.tcoarse);
	t_fine_b := to_unsigned(event.tfine+B-1, 10);
	t_fine_r := real(event.tfine+B-1) / M;
	
	-- Ideal logic calculation
	if t_coarse_b(0) = '0' then
		if t_fine_r < 2.5 then
			t_t := t_coarse_r + (2.0 - t_fine_r);
		else 
			t_t := t_coarse_r + (4.0 - t_fine_r);
		end if;
	else
		t_t := t_coarse_r + (3.0 - t_fine_r);
	end if;
	
	e_coarse_b := to_unsigned(event.ecoarse + event.tcoarse, 10);
	e_coarse_r := real(event.ecoarse + event.tcoarse);
	e_fine_b := to_unsigned(event.efine+B-1, 10);
	e_fine_r := real(event.efine+B-1) / M;
	
	if e_coarse_b(0) = '0' then
		if e_fine_r < 2.5 then
			e_t := e_coarse_r + (2.0 - e_fine_r);
		else
			e_t := e_coarse_r + (4.0 - e_fine_r);
		end if;
	else
		e_t := e_coarse_r + (3.0 - e_fine_r);
	end if;
		
	t <= t_t;
	tot <= e_t - t_t;
	
end if;
end process;					
end behavioral;
