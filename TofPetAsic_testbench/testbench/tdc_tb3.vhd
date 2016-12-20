library ieee, gctrl_lib, worklib;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;
use gctrl_lib.asic_k.all;
use worklib.txt_util.all;
use worklib.asic_i2c.all;


entity tdc_tb3 is
end tdc_tb3; 

architecture behavioral of tdc_tb3 is
	constant T		: time := 6.25 ns;
	constant N_CHANNELS : integer := 1;
	constant M		: real := 127.0;
	constant B		: integer := 128;
	
  	
  signal dot : std_logic_vector(0 to N_CHANNELS-1) := (others => '0');
  signal doe : std_logic_vector(0 to N_CHANNELS-1) := (others => '0');
  
  signal clk			: std_logic := '0';
  signal reset_bar 		: std_logic := '0';
  signal ctime			: std_logic_vector(10 downto 0) := (others => '0');
  
  
begin
clk <= not clk after T/2;
ctime <= std_logic_vector(unsigned(ctime) + 1) after T;
reset_bar <= '1' after 10 * T;

channel_generator : for n in 0 to N_CHANNELS - 1 generate
channel : entity worklib.tdc_emulator
generic map (
	ID => n,
	M => M
)
port map (
	dot => dot(n),
	doe => doe(n),
	
	clk_i => clk,
	reset_bar_i => reset_bar,
	test_pulse_i => '0',
	refresh_pulse_i => '0',
	frame_id_i	=> ctime(10),
	ctime_i => ctime(9 downto 0),		
	ev_data_valid_o => open,
	ev_data_o => open,
	dark_strobe_o => open,
	trig_err_strobe_o => open,
	config_i => 	b"0" &
					b"01" &			-- 51..50	Metastability mode
					'1' &			-- 49		Praedictio		
					x"00" &			-- 48..41	FE Gain
					x"03_00" &		-- 40..25	E threshold & T threshold
					b"000" &		-- 24..22	latchcfg -- not used yet
					b"100" & 		-- 21..19 	cgatecfg
					'1' &			-- 18		synchronous event validation
					b"11" & 		-- 17..16	deadtime & deadtime_EN
					b"00_00_0" &	-- 15..11	test_E_en & test_T_en & testcfg2 & testcfg1 & gtest	
					b"00000" & 		-- 10..6	E TDC IB
					b"00000" & 		-- 5..1		T TDC IB
					'1',
	tconfig_i => "0"
);

t_reader : process
file stim_file : text is "asic_64_tb3_data/channel_" & integer'image(n) & "_T.dat";
variable l : line;
variable s : string (30 downto 1);
variable i : integer := 0;
variable t : time := 0 ps;

begin
t := now;
while not endfile(stim_file) loop
	readline(stim_file, l);
	read(l, s);
	i := integer'value(s);
	t := t + i * 1 ps;
	if t > now then
		wait for (t - now);
	end if;
	dot(n) <= not dot(n);	
end loop;
wait;
end process;

e_reader : process
file stim_file : text is "asic_64_tb3_data/channel_" & integer'image(n) & "_E.dat";
variable l : line;
variable s : string (30 downto 1); 
variable t : integer;
begin
while not endfile(stim_file) loop
	readline(stim_file, l);
	read(l, s);
	t := integer'value(s);
	wait for t * 1 ps;
	doe(n) <= not doe(n);	
end loop;
wait;
end process;

end generate;

end behavioral;
