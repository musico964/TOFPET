library ieee, tdc_lib, worklib, gctrl_lib;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use gctrl_lib.asic_k.all;


entity channel_emulator is
generic (
	ID				: integer := 0;
	T				: time := 6.25 ns;
	M				: real := 64.0;
	RANDOM_FILE 	: STRING := "/dev/urandom";
	DARK_RATE		: real := 1_000_000.0;
	TPEAK_T			: real := 1.0E-9;
	ALPHA_T			: real := 1.0;	
	TPEAK_E			: real := 4.0E-9;
	ALPHA_E			: real := 0.5;
	EBDELAY			: time := 1 ns
);
port (
	
	event1_amplitude : in real;
	event2_amplitude : in real;
	dark_amplitude	: in real;	
	clk_i		: in std_logic;
	reset_bar_i	: in std_logic;
	
	test_pulse_i : in std_logic;
	refresh_pulse_i : in std_logic;
	
	frame_id_i	: in std_logic;	
	ctime_i		: in std_logic_vector(9 downto 0);
	
	ev_data_valid_o   : out std_logic;
	ev_data_o         : out std_logic_vector(52 downto 0);
	dark_strobe_o     : out std_logic;
	trig_err_strobe_o : out std_logic;
	config_i          : in std_logic_vector(CH_CONFIG_SIZE-1 downto 0);	
	tconfig_i         : in std_logic_vector(CH_TCONFIG_SIZE-1 downto 0)
);

end channel_emulator;

architecture behavioral of channel_emulator is


constant comp_clock_delay : time := 400 ps;

signal amplifier_gain : real := 1.0;

type pulse_array_t is array (0 to 10) of real;
signal dark_pulse_T_array : pulse_array_t := (0.0, 0.0, 0.0, 0.0, 0.0,0.0, 0.0, 0.0, 0.0, 0.0, 0.0); 
signal dark_pulse_T		: real := 0.0;
signal event1_pulse_T	: real := 0.0; 
signal event2_pulse_T	: real := 0.0;
signal pulse_T			: real := 0.0;
signal dark_pulse_E_array : pulse_array_t := (0.0, 0.0, 0.0, 0.0, 0.0,0.0, 0.0, 0.0, 0.0, 0.0, 0.0); 
signal dark_pulse_E		: real := 0.0;
signal event1_pulse_E	: real := 0.0; 
signal event2_pulse_E	: real := 0.0;
signal pulse_E_x		: real := 0.0;
signal pulse_E			: real := 0.0;

signal clk_O			: std_logic;
signal threshold_T		: real := 0.5;
signal threshold_E		: real := 2.0;
signal disc_out_T		: std_logic := '0';
signal disc_out_E		: std_logic := '0';
signal conv_comp_clk_T	: std_logic;
signal conv_comp_clk_E 	: std_logic;
signal conv_comp_T		: std_logic := '0';
signal conv_comp_E		: std_logic := '0';
signal wtac_T			: std_logic := '0';
signal wtac_E			: std_logic := '0';
signal nrst_tac			: std_logic_vector(3 downto 0);
signal wren_tac			: std_logic_vector(3 downto 0);
signal rden_tac			: std_logic_vector(3 downto 0);
signal qtx_T			: std_logic;
signal qtx_E			: std_logic;
signal qch_T			: std_logic;
signal qch_E			: std_logic;
signal rst_tdc_T		: std_logic;
signal rst_tdc_E		: std_logic;


type tacQ_array_t is array(3 downto 0) of real;
signal tacQ_T_array : tacQ_array_t;
signal tacQ_E_array : tacQ_array_t;

signal tdcQ_T : real;
signal tdcQ_E : real;

signal cgatecfg			: std_logic_vector(2 downto 0);
signal clkin_DELOUT		: std_logic;
signal delayed_DELOUT	: std_logic;
signal ngate_DELIN		: std_logic;
signal DOTL_asyn		: std_logic;
	

begin

amplifier_gain <= 1.0;

dark_generator : for n in 0 to 9 generate
	dg : process 
	variable tWait  : real;
	variable i      : integer;
	variable t      : real := 0.0;
 
 	type rnd_file_t is file of integer; 	
 	file rnd_file	: rnd_file_t is RANDOM_FILE;
	variable seed1  : integer;
	variable seed2  : integer;
	variable u      : real;
	variable A		: real;
	
	begin
		if dark_rate = 0.0 then
			-- No dark counts!
			wait;
		end if;
		
		-- Skip random seeds for other channels/generators
		-- so that the the channel/generators don't produce all
		-- the same sequence...
		for i in 0 to 10*ID+n loop
			read(rnd_file, seed1);
			read(rnd_file, seed2);		
		end loop;
		
		read(rnd_file, seed1);
		read(rnd_file, seed2);
		if seed1 < 0 then
			seed1 := -seed1;
		end if;
		if seed2 < 0 then
			seed2 := -seed2;
		end if;
		
		while true loop
			dark_pulse_T_array(n) <= 0.0;
			dark_pulse_E_array(n) <= 0.0;        
			uniform(seed1, seed2, u);
			tWait := -log(u)/(dark_rate/10.0);
			tWait := tWait - t;
			if tWait > 0.0 then
				wait for tWait * 1000 ms;
			else
				--assert false report "Overlapping dark count" severity warning;
			end if;
			A := amplifier_gain * dark_amplitude;
		
			-- Simulate pulse until it has passed the peak and has dropped to a very small value
			t := 0.0;    
			while ((t < tPeak_E) or (dark_pulse_E_array(n) > 0.1)) loop
				dark_pulse_T_array(n) <= A * ((t/tPeak_T)**alpha_T) * exp(-alpha_T * (t-tPeak_T)/tPeak_T);
				dark_pulse_E_array(n) <= A * ((t/tPeak_E)**alpha_E) * exp(-alpha_E * (t-tPeak_E)/tPeak_E);
				t := t + 10.0E-12;     
				wait for 10 ps;            
			end loop;
		end loop;
	end process dg;
end generate dark_generator;
dark_pulse_T <= dark_pulse_T_array(0) +
				dark_pulse_T_array(1) +
				dark_pulse_T_array(2) + 
				dark_pulse_T_array(3) +
				dark_pulse_T_array(4) +
				dark_pulse_T_array(5) +
				dark_pulse_T_array(6) +
				dark_pulse_T_array(7) + 
				dark_pulse_T_array(8) +
				dark_pulse_T_array(9);

dark_pulse_E <= dark_pulse_E_array(0) +
				dark_pulse_E_array(1) +
				dark_pulse_E_array(2) + 
				dark_pulse_E_array(3) +
				dark_pulse_E_array(4) +
				dark_pulse_E_array(5) +
				dark_pulse_E_array(6) +
				dark_pulse_E_array(7) + 
				dark_pulse_E_array(8) +
				dark_pulse_E_array(9);

event1_generator : process 
	variable tWait  : real;
	variable i      : integer;
	variable t      : real := 0.0;
	variable A		: real;
	begin
	event1_pulse_T <= 0.0;
	event1_pulse_E <= 0.0;        
	wait until event1_amplitude'event and (event1_amplitude > 0.0);
	A := amplifier_gain * event1_amplitude;
	
	-- Simulate pulse until it has passed the peak and has dropped to a very small value
	t := 0.0;   
	while ((t < tPeak_E) or (event1_pulse_E > 0.1)) loop
		event1_pulse_T <= A * ((t/tPeak_T)**alpha_T) * exp(-alpha_T * (t-tPeak_T)/tPeak_T);
		event1_pulse_E <= A * ((t/tPeak_E)**alpha_E) * exp(-alpha_E * (t-tPeak_E)/tPeak_E);
		t := t + 10.0E-12;     
		wait for 10 ps;            
	end loop;
end process event1_generator;	

event2_generator : process 
	variable tWait  : real;
	variable i      : integer;
	variable t      : real := 0.0;
	variable A		: real;
	begin
	event2_pulse_T <= 0.0;
	event2_pulse_E <= 0.0;        
	wait until event2_amplitude'event and (event2_amplitude > 0.0);
	A := amplifier_gain * event2_amplitude;
	
	-- Simulate pulse until it has passed the peak and has dropped to a very small value
	t := 0.0;   
	while ((t < tPeak_E) or (event2_pulse_E > 0.1)) loop
		event2_pulse_T <= A * ((t/tPeak_T)**alpha_T) * exp(-alpha_T * (t-tPeak_T)/tPeak_T);
		event2_pulse_E <= A * ((t/tPeak_E)**alpha_E) * exp(-alpha_E * (t-tPeak_E)/tPeak_E);
		t := t + 10.0E-12;     
		wait for 10 ps;            
	end loop;
end process event2_generator;		
	
	
pulse_T <= dark_pulse_T + event1_pulse_T + event2_pulse_T when config_i(0) = '1' else 0.0;
pulse_E <= dark_pulse_E + event1_pulse_E + event2_pulse_E when config_i(0) = '1' else 0.0;

threshold_T <= 0.5;
threshold_E <= 10.0;
disc_out_T <= '1' when pulse_T > threshold_T else '0';
disc_out_E <= '1' when pulse_E > threshold_E else '0';

				
tdc : entity worklib.tdc_emulator
generic map (
	ID => ID,
	M => M
)
port map (
	dot => disc_out_T,
	doe => disc_out_E,
	
	clk_i => clk_i,
	reset_bar_i => reset_bar_i,
	test_pulse_i => test_pulse_i,
	refresh_pulse_i => refresh_pulse_i,
	frame_id_i	=> frame_id_i,
	ctime_i => ctime_i,	
	ev_data_valid_o => ev_data_valid_o,
	ev_data_o => ev_data_o,
	dark_strobe_o => dark_strobe_o,
	trig_err_strobe_o => trig_err_strobe_o,
	config_i => config_i,
	tconfig_i => tconfig_i
);

end behavioral;
