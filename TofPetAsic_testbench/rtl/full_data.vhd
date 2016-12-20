library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity full_data is 
  port(
    clk         : in std_logic;
    reset       : in std_logic;
    enable		: in std_logic;
    
    data_in     : in std_logic_vector(60 downto 0);
    data_in_valid : in std_logic;
    
    data_out         : out std_logic_vector(39 downto 0);
    data_out_frameid : out std_logic;
    data_out_valid   : out std_logic
  );
end full_data;


architecture rtl of full_data is

type state_t is (IDLE, BUSY);
signal state : state_t;

signal a_ch_id		: std_logic_vector(6 downto 0);
signal a_tac		: std_logic_vector(1 downto 0);
signal a_frameid	: std_logic;
signal a_tcoarse	: std_logic_vector(9 downto 0);
signal a_ecoarse 	: std_logic_vector(9 downto 0);
signal a_soc		: std_logic_vector(9 downto 0);
signal a_teoc		: std_logic_vector(9 downto 0);
signal a_eeoc		: std_logic_vector(9 downto 0);

signal b_ch_id		: std_logic_vector(6 downto 0);
signal b_tac		: std_logic_vector(1 downto 0);
signal b_frameid	: std_logic;
signal b_ecoarse 	: std_logic_vector(9 downto 0);
signal b_soc		: std_logic_vector(9 downto 0);
signal b_eeoc		: std_logic_vector(9 downto 0);

begin

	a_ch_id	<= data_in(60 downto 54);
	a_tac <= data_in(53 downto 52);
	a_frameid <= data_in(51);
	a_tcoarse <= data_in(50 downto 41);
	a_ecoarse <= data_in(40 downto 31);
	a_soc <= data_in(30 downto 21);
	a_teoc <= data_in(20 downto 11);
	a_eeoc <= data_in(10 downto 1);

	process(clk, reset) begin
	if reset = '1' then
		state <= IDLE;
	elsif rising_edge(clk) and enable = '1' then
		if state = IDLE and data_in_valid = '1' then
			state <= BUSY;
		else
			state <= IDLE;
		end if;		
	end if;
	end process;

	process (clk, reset) begin
	if rising_edge(clk) and enable = '1' then
		if state = IDLE and data_in_valid = '1'then
			b_ch_id <= a_ch_id;
			b_tac <= a_tac;
			b_frameid <= a_frameid;
			b_ecoarse <= a_ecoarse;
			b_soc <= a_soc;
			b_eeoc <= a_eeoc;
		end if;
	end if;
	end process;
	
	data_out_valid <=	'1' when state = IDLE and data_in_valid = '1' else
						'1' when state = BUSY else
						'0';
						
	data_out_frameid <= a_frameid when state = IDLE else
						b_frameid;
	data_out <= a_tcoarse &
				a_soc &
				a_teoc &
				"0" &
				a_ch_id &
				a_tac 
				when state = IDLE else
				b_ecoarse &
				b_soc &
				b_eeoc &
				"0" &
				b_ch_id &
				b_tac;
	
	
end rtl;