library ieee, gctrl_lib, worklib;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use worklib.asic_i2c.all;
use gctrl_lib.asic_k.all;

library std;
use std.textio.all;

--library modelsim_lib;
--use modelsim_lib.util.all;

library NCUTILS;
use NCUTILS.ncutilities.all;

entity gctrl_64mx_tb_cfg is
end gctrl_64mx_tb_cfg;

architecture behavioral of gctrl_64mx_tb_cfg is
  constant N_CHANNELS : integer := 64;
  constant T : time := 6.25 ns;
  constant TX_MODE : std_logic_vector := b"101";
  constant FC_SATURATE : std_logic := '0';
  constant FC_SUB : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(128, 8));
  
  -- ASIC main signals
  signal clk : std_logic := '0';
  signal sync_rst : std_logic := '1';
  
  signal sclk : std_logic := '0';
  signal cs : std_logic := '0';
  signal sdi : std_logic := '0';  
  signal sdo : std_logic;
  signal sdo_o : std_logic;
  signal sdo_oe : std_logic;
  
  signal clk_o : std_logic;
  signal tx0 : std_logic;
  signal tx1 : std_logic;
  signal tx2 : std_logic;
  signal tx3 : std_logic;
  
  signal test_pulse_i : std_logic := '0';
  
  signal gconfig : std_logic_vector(GE_CONFIG_SIZE - 1 downto 0);
  signal gtconfig : std_logic_vector(GE_TCONFIG_SIZE - 1 downto 0);
  
  -- ASIC Channel Interface!
  type channel_interface_t is record
  	clk				: std_logic;
  	reset_bar		: std_logic;
  	frame_id		: std_logic;
  	ctime			: std_logic_vector(9 downto 0);
  	tac_refresh_pulse : std_logic;
  	test_pulse		: std_logic;
    ev_data_valid	: std_logic;
    ev_data			: std_logic_vector(CH_DATA_SIZE-1 downto 0);
    dark_strobe		: std_logic;
    trig_err_strobe	: std_logic;
    config			: std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
    tconfig			: std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
  end record;
  
  type channel_interface_array_t is array (0 to N_CHANNELS-1) of channel_interface_t;  
  signal cir : channel_interface_array_t;

-- Test bench signals
  signal test_name : string(1 to 128);
 
  signal global_config : std_logic_vector (G_CONFIG_SIZE - 1 downto 0);
  signal global_tconfig : std_logic_vector(G_TCONFIG_SIZE - 1 downto 0);
  signal store_channel_counter : std_logic;
  
  function lfsr64 (d : std_logic_vector(63 downto 0)) return std_logic_vector is
  begin
  	return d(62 downto 0) & not (d(63) xor d(62) xor d(60) xor d(59));
  end lfsr64;
  
begin

nc_mirror(destination => "global_config", source => "gctrl_64mx:cfg_ctrl:global_config");
nc_mirror(destination => "global_tconfig", source => "gctrl_64mx:cfg_ctrl:global_tconfig");
nc_mirror(destination => "store_channel_counter", source => "gctrl_64mx:ch_count:strobe");

clk <= not clk after T/2;
process begin
sclk <= '0';
wait for T;
while true loop 
	wait for T_I2C/2;
	sclk <= not sclk;
end loop;
end process;	


tb : process
variable i : integer;
variable j : integer;
variable d : std_logic_vector(127 downto 0);
begin
for i in 0 to N_CHANNELS-1 loop
	cir(i).ev_data_valid <= '0';
	cir(i).ev_data <= (others => '0');
	cir(i).dark_strobe<= '0';
	cir(i).trig_err_strobe <= '0';
	cir(i).clk <= 'Z';
	cir(i).reset_bar <= 'Z';
	cir(i).frame_id <= 'Z';
	cir(i).ctime <= (others => 'Z');
	cir(i).tac_refresh_pulse <= 'Z';
	cir(i).test_pulse <= 'Z';  
	cir(i).config <= (others => 'Z');
	cir(i).tconfig <= (others => 'Z');    
end loop;

test_name <= xname("Reset");
wait for 1 us;
wait until rising_edge(clk); wait for 1.5 ns;
sync_rst <= '0';  
wait for 1 us;

test_name <= xname("Global test config");
assert gtconfig  = DEFAULT_G_TCONFIG(G_TCONFIG_SIZE-1 downto G_TCONFIG_SIZE-GE_TCONFIG_SIZE) 
	report "Failed to set GTEST" severity error;
check_gtcfg(sclk, cs, sdi, sdo,DEFAULT_G_TCONFIG);
assert gtconfig  = DEFAULT_G_TCONFIG(G_TCONFIG_SIZE-1 downto G_TCONFIG_SIZE-GE_TCONFIG_SIZE) 
	report "Destructive read on GTEST" severity error;
d := x"5555_5555_5555_5555_5555_5555_5555_5555";
write_gtcfg(sclk, cs, sdi, sdo, d(G_TCONFIG_SIZE-1 downto 0));
assert gtconfig  = d(G_TCONFIG_SIZE-1 downto G_TCONFIG_SIZE-GE_TCONFIG_SIZE) 
	report "Failed to set GTEST" severity error;
check_gtcfg(sclk, cs, sdi, sdo, d(G_TCONFIG_SIZE-1 downto 0));
assert gtconfig  = d(G_TCONFIG_SIZE-1 downto G_TCONFIG_SIZE-GE_TCONFIG_SIZE) 
	report "Destructive read on GTEST" severity error;

d := x"AAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA";
write_gtcfg(sclk, cs, sdi, sdo, d(G_TCONFIG_SIZE-1 downto 0));
assert gtconfig  = d(G_TCONFIG_SIZE-1 downto G_TCONFIG_SIZE-GE_TCONFIG_SIZE) 
	report "Failed to set GTEST" severity error;
check_gtcfg(sclk, cs, sdi, sdo, d(G_TCONFIG_SIZE-1 downto 0));
assert gtconfig  = d(G_TCONFIG_SIZE-1 downto G_TCONFIG_SIZE-GE_TCONFIG_SIZE) 
	report "Destructive read on GTEST" severity error;

d := x"FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF";
write_gtcfg(sclk, cs, sdi, sdo, d(G_TCONFIG_SIZE-1 downto 0));
assert gtconfig  = d(G_TCONFIG_SIZE-1 downto G_TCONFIG_SIZE-GE_TCONFIG_SIZE) 
	report "Failed to set GTEST" severity error;
check_gtcfg(sclk, cs, sdi, sdo, d(G_TCONFIG_SIZE-1 downto 0));
assert gtconfig  = d(G_TCONFIG_SIZE-1 downto G_TCONFIG_SIZE-GE_TCONFIG_SIZE) 
	report "Destructive read on GTEST" severity error;

d := x"0000_0000_0000_0000_0000_0000_0000_0000";
write_gtcfg(sclk, cs, sdi, sdo, d(G_TCONFIG_SIZE-1 downto 0));
assert gtconfig  = d(G_TCONFIG_SIZE-1 downto G_TCONFIG_SIZE-GE_TCONFIG_SIZE)
	report "Failed to set GCFG" severity error;
check_gtcfg(sclk, cs, sdi, sdo, d(G_TCONFIG_SIZE-1 downto 0));
assert gtconfig  = d(G_TCONFIG_SIZE-1 downto G_TCONFIG_SIZE-GE_TCONFIG_SIZE) 
	report "Destructive read on GCFG" severity error;

test_name <= xname("Global config");
assert gconfig  = DEFAULT_G_CONFIG(G_CONFIG_SIZE-1 downto G_CONFIG_SIZE-GE_CONFIG_SIZE) 
	report "Failed to set GCFG" severity error;
check_gcfg(sclk, cs, sdi, sdo, DEFAULT_G_CONFIG);
assert gconfig  = DEFAULT_G_CONFIG(G_CONFIG_SIZE-1 downto G_CONFIG_SIZE-GE_CONFIG_SIZE) 
	report "Destructive read on GCFG" severity error;
d := x"5555_5555_5555_5555_5555_5555_5555_5555";
write_gcfg(sclk, cs, sdi, sdo, d(G_CONFIG_SIZE-1 downto 0));
assert gconfig  = d(G_CONFIG_SIZE-1 downto G_CONFIG_SIZE-GE_CONFIG_SIZE) 
	report "Failed to set GCFG" severity error;
check_gcfg(sclk, cs, sdi, sdo, d(G_CONFIG_SIZE-1 downto 0));
assert gconfig  = d(G_CONFIG_SIZE-1 downto G_CONFIG_SIZE-GE_CONFIG_SIZE) 
	report "Destructive read on GCFG" severity error;

d := x"AAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA";
write_gcfg(sclk, cs, sdi, sdo, d(G_CONFIG_SIZE-1 downto 0));
assert gconfig  = d(G_CONFIG_SIZE-1 downto G_CONFIG_SIZE-GE_CONFIG_SIZE) 
	report "Failed to set GCFG" severity error;
check_gcfg(sclk, cs, sdi, sdo, d(G_CONFIG_SIZE-1 downto 0));
assert gconfig  = d(G_CONFIG_SIZE-1 downto G_CONFIG_SIZE-GE_CONFIG_SIZE) 
	report "Destructive read on GCFG" severity error;

d := x"FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF";
write_gcfg(sclk, cs, sdi, sdo, d(G_CONFIG_SIZE-1 downto 0));
assert gconfig  = d(G_CONFIG_SIZE-1 downto G_CONFIG_SIZE-GE_CONFIG_SIZE) 
	report "Failed to set GCFG" severity error;
check_gcfg(sclk, cs, sdi, sdo, d(G_CONFIG_SIZE-1 downto 0));
assert gconfig  = d(G_CONFIG_SIZE-1 downto G_CONFIG_SIZE-GE_CONFIG_SIZE) 
	report "Destructive read on GCFG" severity error;

d := x"0000_0000_0000_0000_0000_0000_0000_0000";
write_gcfg(sclk, cs, sdi, sdo, d(G_CONFIG_SIZE-1 downto 0));
assert gconfig  = d(G_CONFIG_SIZE-1 downto G_CONFIG_SIZE-GE_CONFIG_SIZE) 
	report "Failed to set GCFG" severity error;
check_gcfg(sclk, cs, sdi, sdo, d(G_CONFIG_SIZE-1 downto 0));
assert gconfig  = d(G_CONFIG_SIZE-1 downto G_CONFIG_SIZE-GE_CONFIG_SIZE) 
	report "Destructive read on GCFG" severity error;
	
	
test_name <= xname("Channel test config");
for i in 0 to N_CHANNELS-1 loop
	assert cir(i).tconfig  = DEFAULT_CH_TCONFIG
		report "Failed to set CHCFG" severity error;
	check_chtcfg(sclk, cs, sdi, sdo, i, DEFAULT_CH_TCONFIG);
	assert cir(i).tconfig  = DEFAULT_CH_TCONFIG
		report "Destructive read on CHCFG" severity error;
		
	d := x"5555_5555_5555_5555_5555_5555_5555_5555";
	write_chtcfg(sclk, cs, sdi, sdo, i, d(CH_TCONFIG_SIZE-1 downto 0));
	assert cir(i).tconfig  = d(CH_TCONFIG_SIZE-1 downto 0) 
		report "Failed to set CHCFG" severity error;
	check_chtcfg(sclk, cs, sdi, sdo, i, d(CH_TCONFIG_SIZE-1 downto 0));
	assert cir(i).tconfig  = d(CH_TCONFIG_SIZE-1 downto 0) 
		report "Destructive read on CHCFG" severity error;
	
	d := x"AAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA";
	write_chtcfg(sclk, cs, sdi, sdo, i, d(CH_TCONFIG_SIZE-1 downto 0));
	assert cir(i).tconfig  = d(CH_TCONFIG_SIZE-1 downto 0) 
		report "Failed to set CHCFG" severity error;
	check_chtcfg(sclk, cs, sdi, sdo, i, d(CH_TCONFIG_SIZE-1 downto 0));
	assert cir(i).tconfig  = d(CH_TCONFIG_SIZE-1 downto 0) 
		report "Destructive read on CHCFG" severity error;
	
	d := x"FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF";
	write_chtcfg(sclk, cs, sdi, sdo, i, d(CH_TCONFIG_SIZE-1 downto 0));
	assert cir(i).tconfig  = d(CH_TCONFIG_SIZE-1 downto 0) 
		report "Failed to set CHCFG" severity error;
	check_chtcfg(sclk, cs, sdi, sdo, i, d(CH_TCONFIG_SIZE-1 downto 0));
	assert cir(i).tconfig  = d(CH_TCONFIG_SIZE-1 downto 0) 
		report "Destructive read on CHCFG" severity error;
	
	d := x"0000_0000_0000_0000_0000_0000_0000_0000";
	write_chtcfg(sclk, cs, sdi, sdo, i, d(CH_TCONFIG_SIZE-1 downto 0));
	assert cir(i).tconfig  = d(CH_TCONFIG_SIZE-1 downto 0) 
		report "Failed to set CHCFG" severity error;
	check_chtcfg(sclk, cs, sdi, sdo, i, d(CH_TCONFIG_SIZE-1 downto 0));
	assert cir(i).tconfig  = d(CH_TCONFIG_SIZE-1 downto 0) 
		report "Destructive read on CHCFG" severity error;

end loop;


test_name <= xname("Channel config");
for i in 0 to N_CHANNELS-1 loop
	assert cir(i).config  = DEFAULT_CH_CONFIG
		report "Failed to set CHCFG" severity error;
	check_chcfg(sclk, cs, sdi, sdo, i, DEFAULT_CH_CONFIG);
	assert cir(i).config  = DEFAULT_CH_CONFIG 
		report "Destructive read on CHCFG" severity error;
		
	d := x"5555_5555_5555_5555_5555_5555_5555_5555";
	write_chcfg(sclk, cs, sdi, sdo, i, d(CH_CONFIG_SIZE-1 downto 0));
	assert cir(i).config  = d(CH_CONFIG_SIZE-1 downto 0) 
		report "Failed to set CHCFG" severity error;
	check_chcfg(sclk, cs, sdi, sdo, i, d(CH_CONFIG_SIZE-1 downto 0));
	assert cir(i).config  = d(CH_CONFIG_SIZE-1 downto 0) 
		report "Destructive read on CHCFG" severity error;
	
	d := x"AAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA";
	write_chcfg(sclk, cs, sdi, sdo, i, d(CH_CONFIG_SIZE-1 downto 0));
	assert cir(i).config  = d(CH_CONFIG_SIZE-1 downto 0) 
		report "Failed to set CHCFG" severity error;
	check_chcfg(sclk, cs, sdi, sdo, i, d(CH_CONFIG_SIZE-1 downto 0));
	assert cir(i).config  = d(CH_CONFIG_SIZE-1 downto 0) 
		report "Destructive read on CHCFG" severity error;
	
	d := x"FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF";
	write_chcfg(sclk, cs, sdi, sdo, i, d(CH_CONFIG_SIZE-1 downto 0));
	assert cir(i).config  = d(CH_CONFIG_SIZE-1 downto 0) 
		report "Failed to set CHCFG" severity error;
	check_chcfg(sclk, cs, sdi, sdo, i, d(CH_CONFIG_SIZE-1 downto 0));
	assert cir(i).config  = d(CH_CONFIG_SIZE-1 downto 0) 
		report "Destructive read on CHCFG" severity error;
	
	d := x"0000_0000_0000_0000_0000_0000_0000_0000";
	write_chcfg(sclk, cs, sdi, sdo, i, d(CH_CONFIG_SIZE-1 downto 0));
	assert cir(i).config  = d(CH_CONFIG_SIZE-1 downto 0) 
		report "Failed to set CHCFG" severity error;
	check_chcfg(sclk, cs, sdi, sdo, i, d(CH_CONFIG_SIZE-1 downto 0));
	assert cir(i).config  = d(CH_CONFIG_SIZE-1 downto 0) 
		report "Destructive read on CHCFG" severity error;

end loop;



test_name <= xname("Dark count read");
write_gcfg(sclk, cs, sdi, sdo,
  	x"0000_0000_0000_0000_0000_0"	& -- GE_CONFIG
  	'0'		& -- clk_o enable
  	'0' 	& -- Test pattern mode
  	'0'		& -- external veto enable
    '0'		& -- full event mode
	b"0001"	& -- counter interval
	'0'		& -- count trigger error
	x"00" 	& -- fine counter kf
	'0' & -- fine counter saturante 
	b"0000"	& -- TAC refresh 
	'0'		& -- External pulse enable
	"000"	  -- TX mode
);

for i in 0 to 15 loop
	wait until store_channel_counter'event;
	wait for 2*T;
	for j in 1 to 64*i loop
		cir(i).dark_strobe <= '1';
		wait for T;
		cir(i).dark_strobe <= '0';
		wait for T;	
	end loop;
	
	wait until store_channel_counter'event;
	wait for 2*T;
	
	read_dark(sclk, cs, sdi, sdo, i, d(9 downto 0));
	assert to_integer(unsigned(d(9 downto 0))) = 64*i
		report "Wrong dark count: read = " & integer'image(to_integer(unsigned(d(9 downto 0)))) severity error;
end loop;

test_name <= xname("Test pulse length");

for i in 0 to 16 loop
	write_tp(sclk, cs, sdi, sdo, 3, i, 0);
	wait for 5 * (i+1 + 128) * T; 
end loop;

test_name <= xname("Test pulse intv");
for i in 0 to 16 loop
	write_tp(sclk, cs, sdi, sdo, 3, 0, i);
	wait for 5 * (1 + (i+1)*128) * T; 
end loop;

test_name <= xname("Test pulse repeat");
for i in 0 to 16 loop 
	write_tp(sclk, cs, sdi, sdo, 64*i, 0, 0);
	wait for 64*(i+1) * (1 + 1 * 128) * T;
end loop;







assert false report "Simulation complete" severity failure;
wait;  
end process tb;

sdo <= sdo_o when sdo_oe = '1' else 'Z';

gctrl_64mx : entity gctrl_lib.gctrl_64mx
port map (
  clk_i => clk,
  sync_rst_i => sync_rst,
  
  sclk_i => sclk,
  cs_i => cs,
  sdi_i => sdi,
  sdo_o => sdo_o,
  sdo_oe => sdo_oe,
  
  test_pulse_i => test_pulse_i,
  
  clk_o => clk_o,  
  tx0_o => tx0,
  tx1_o => tx1,
  
  gconfig_o => gconfig,
  gtconfig_o => gtconfig,
  
  
  -- Channel 0
  ch0_clk => cir(0).clk,
  ch0_reset_bar => cir(0).reset_bar,
  ch0_frame_id => cir(0).frame_id,
  ch0_ctime => cir(0).ctime,
  ch0_tac_refresh_pulse => cir(0).tac_refresh_pulse,
  ch0_test_pulse => cir(0).test_pulse,
  ch0_ev_data_valid => cir(0).ev_data_valid,
  ch0_ev_data => cir(0).ev_data,
  ch0_dark_strobe => cir(0).dark_strobe,
  ch0_trig_err_strobe => cir(0).trig_err_strobe,
  ch0_config => cir(0).config,
  ch0_tconfig => cir(0).tconfig,

  -- Channel 1
  ch1_clk => cir(1).clk,
  ch1_reset_bar => cir(1).reset_bar,
  ch1_frame_id => cir(1).frame_id,
  ch1_ctime => cir(1).ctime,
  ch1_tac_refresh_pulse => cir(1).tac_refresh_pulse,
  ch1_test_pulse => cir(1).test_pulse,
  ch1_ev_data_valid => cir(1).ev_data_valid,
  ch1_ev_data => cir(1).ev_data,
  ch1_dark_strobe => cir(1).dark_strobe,
  ch1_trig_err_strobe => cir(1).trig_err_strobe,
  ch1_config => cir(1).config,
  ch1_tconfig => cir(1).tconfig,

  -- Channel 2
  ch2_clk => cir(2).clk,
  ch2_reset_bar => cir(2).reset_bar,
  ch2_frame_id => cir(2).frame_id,
  ch2_ctime => cir(2).ctime,
  ch2_tac_refresh_pulse => cir(2).tac_refresh_pulse,
  ch2_test_pulse => cir(2).test_pulse,
  ch2_ev_data_valid => cir(2).ev_data_valid,
  ch2_ev_data => cir(2).ev_data,
  ch2_dark_strobe => cir(2).dark_strobe,
  ch2_trig_err_strobe => cir(2).trig_err_strobe,
  ch2_config => cir(2).config,
  ch2_tconfig => cir(2).tconfig,

  -- Channel 3
  ch3_clk => cir(3).clk,
  ch3_reset_bar => cir(3).reset_bar,
  ch3_frame_id => cir(3).frame_id,
  ch3_ctime => cir(3).ctime,
  ch3_tac_refresh_pulse => cir(3).tac_refresh_pulse,
  ch3_test_pulse => cir(3).test_pulse,
  ch3_ev_data_valid => cir(3).ev_data_valid,
  ch3_ev_data => cir(3).ev_data,
  ch3_dark_strobe => cir(3).dark_strobe,
  ch3_trig_err_strobe => cir(3).trig_err_strobe,
  ch3_config => cir(3).config,
  ch3_tconfig => cir(3).tconfig,

  -- Channel 4
  ch4_clk => cir(4).clk,
  ch4_reset_bar => cir(4).reset_bar,
  ch4_frame_id => cir(4).frame_id,
  ch4_ctime => cir(4).ctime,
  ch4_tac_refresh_pulse => cir(4).tac_refresh_pulse,
  ch4_test_pulse => cir(4).test_pulse,
  ch4_ev_data_valid => cir(4).ev_data_valid,
  ch4_ev_data => cir(4).ev_data,
  ch4_dark_strobe => cir(4).dark_strobe,
  ch4_trig_err_strobe => cir(4).trig_err_strobe,
  ch4_config => cir(4).config,
  ch4_tconfig => cir(4).tconfig,

  -- Channel 5
  ch5_clk => cir(5).clk,
  ch5_reset_bar => cir(5).reset_bar,
  ch5_frame_id => cir(5).frame_id,
  ch5_ctime => cir(5).ctime,
  ch5_tac_refresh_pulse => cir(5).tac_refresh_pulse,
  ch5_test_pulse => cir(5).test_pulse,
  ch5_ev_data_valid => cir(5).ev_data_valid,
  ch5_ev_data => cir(5).ev_data,
  ch5_dark_strobe => cir(5).dark_strobe,
  ch5_trig_err_strobe => cir(5).trig_err_strobe,
  ch5_config => cir(5).config,
  ch5_tconfig => cir(5).tconfig,

  -- Channel 6
  ch6_clk => cir(6).clk,
  ch6_reset_bar => cir(6).reset_bar,
  ch6_frame_id => cir(6).frame_id,
  ch6_ctime => cir(6).ctime,
  ch6_tac_refresh_pulse => cir(6).tac_refresh_pulse,
  ch6_test_pulse => cir(6).test_pulse,
  ch6_ev_data_valid => cir(6).ev_data_valid,
  ch6_ev_data => cir(6).ev_data,
  ch6_dark_strobe => cir(6).dark_strobe,
  ch6_trig_err_strobe => cir(6).trig_err_strobe,
  ch6_config => cir(6).config,
  ch6_tconfig => cir(6).tconfig,

  -- Channel 7
  ch7_clk => cir(7).clk,
  ch7_reset_bar => cir(7).reset_bar,
  ch7_frame_id => cir(7).frame_id,
  ch7_ctime => cir(7).ctime,
  ch7_tac_refresh_pulse => cir(7).tac_refresh_pulse,
  ch7_test_pulse => cir(7).test_pulse,
  ch7_ev_data_valid => cir(7).ev_data_valid,
  ch7_ev_data => cir(7).ev_data,
  ch7_dark_strobe => cir(7).dark_strobe,
  ch7_trig_err_strobe => cir(7).trig_err_strobe,
  ch7_config => cir(7).config,
  ch7_tconfig => cir(7).tconfig,

  -- Channel 8
  ch8_clk => cir(8).clk,
  ch8_reset_bar => cir(8).reset_bar,
  ch8_frame_id => cir(8).frame_id,
  ch8_ctime => cir(8).ctime,
  ch8_tac_refresh_pulse => cir(8).tac_refresh_pulse,
  ch8_test_pulse => cir(8).test_pulse,
  ch8_ev_data_valid => cir(8).ev_data_valid,
  ch8_ev_data => cir(8).ev_data,
  ch8_dark_strobe => cir(8).dark_strobe,
  ch8_trig_err_strobe => cir(8).trig_err_strobe,
  ch8_config => cir(8).config,
  ch8_tconfig => cir(8).tconfig,

  -- Channel 9
  ch9_clk => cir(9).clk,
  ch9_reset_bar => cir(9).reset_bar,
  ch9_frame_id => cir(9).frame_id,
  ch9_ctime => cir(9).ctime,
  ch9_tac_refresh_pulse => cir(9).tac_refresh_pulse,
  ch9_test_pulse => cir(9).test_pulse,
  ch9_ev_data_valid => cir(9).ev_data_valid,
  ch9_ev_data => cir(9).ev_data,
  ch9_dark_strobe => cir(9).dark_strobe,
  ch9_trig_err_strobe => cir(9).trig_err_strobe,
  ch9_config => cir(9).config,
  ch9_tconfig => cir(9).tconfig,

  -- Channel 10
  ch10_clk => cir(10).clk,
  ch10_reset_bar => cir(10).reset_bar,
  ch10_frame_id => cir(10).frame_id,
  ch10_ctime => cir(10).ctime,
  ch10_tac_refresh_pulse => cir(10).tac_refresh_pulse,
  ch10_test_pulse => cir(10).test_pulse,
  ch10_ev_data_valid => cir(10).ev_data_valid,
  ch10_ev_data => cir(10).ev_data,
  ch10_dark_strobe => cir(10).dark_strobe,
  ch10_trig_err_strobe => cir(10).trig_err_strobe,
  ch10_config => cir(10).config,
  ch10_tconfig => cir(10).tconfig,

  -- Channel 11
  ch11_clk => cir(11).clk,
  ch11_reset_bar => cir(11).reset_bar,
  ch11_frame_id => cir(11).frame_id,
  ch11_ctime => cir(11).ctime,
  ch11_tac_refresh_pulse => cir(11).tac_refresh_pulse,
  ch11_test_pulse => cir(11).test_pulse,
  ch11_ev_data_valid => cir(11).ev_data_valid,
  ch11_ev_data => cir(11).ev_data,
  ch11_dark_strobe => cir(11).dark_strobe,
  ch11_trig_err_strobe => cir(11).trig_err_strobe,
  ch11_config => cir(11).config,
  ch11_tconfig => cir(11).tconfig,

  -- Channel 12
  ch12_clk => cir(12).clk,
  ch12_reset_bar => cir(12).reset_bar,
  ch12_frame_id => cir(12).frame_id,
  ch12_ctime => cir(12).ctime,
  ch12_tac_refresh_pulse => cir(12).tac_refresh_pulse,
  ch12_test_pulse => cir(12).test_pulse,
  ch12_ev_data_valid => cir(12).ev_data_valid,
  ch12_ev_data => cir(12).ev_data,
  ch12_dark_strobe => cir(12).dark_strobe,
  ch12_trig_err_strobe => cir(12).trig_err_strobe,
  ch12_config => cir(12).config,
  ch12_tconfig => cir(12).tconfig,

  -- Channel 13
  ch13_clk => cir(13).clk,
  ch13_reset_bar => cir(13).reset_bar,
  ch13_frame_id => cir(13).frame_id,
  ch13_ctime => cir(13).ctime,
  ch13_tac_refresh_pulse => cir(13).tac_refresh_pulse,
  ch13_test_pulse => cir(13).test_pulse,
  ch13_ev_data_valid => cir(13).ev_data_valid,
  ch13_ev_data => cir(13).ev_data,
  ch13_dark_strobe => cir(13).dark_strobe,
  ch13_trig_err_strobe => cir(13).trig_err_strobe,
  ch13_config => cir(13).config,
  ch13_tconfig => cir(13).tconfig,

  -- Channel 14
  ch14_clk => cir(14).clk,
  ch14_reset_bar => cir(14).reset_bar,
  ch14_frame_id => cir(14).frame_id,
  ch14_ctime => cir(14).ctime,
  ch14_tac_refresh_pulse => cir(14).tac_refresh_pulse,
  ch14_test_pulse => cir(14).test_pulse,
  ch14_ev_data_valid => cir(14).ev_data_valid,
  ch14_ev_data => cir(14).ev_data,
  ch14_dark_strobe => cir(14).dark_strobe,
  ch14_trig_err_strobe => cir(14).trig_err_strobe,
  ch14_config => cir(14).config,
  ch14_tconfig => cir(14).tconfig,

  -- Channel 15
  ch15_clk => cir(15).clk,
  ch15_reset_bar => cir(15).reset_bar,
  ch15_frame_id => cir(15).frame_id,
  ch15_ctime => cir(15).ctime,
  ch15_tac_refresh_pulse => cir(15).tac_refresh_pulse,
  ch15_test_pulse => cir(15).test_pulse,
  ch15_ev_data_valid => cir(15).ev_data_valid,
  ch15_ev_data => cir(15).ev_data,
  ch15_dark_strobe => cir(15).dark_strobe,
  ch15_trig_err_strobe => cir(15).trig_err_strobe,
  ch15_config => cir(15).config,
  ch15_tconfig => cir(15).tconfig,

  -- Channel 16
  ch16_clk => cir(16).clk,
  ch16_reset_bar => cir(16).reset_bar,
  ch16_frame_id => cir(16).frame_id,
  ch16_ctime => cir(16).ctime,
  ch16_tac_refresh_pulse => cir(16).tac_refresh_pulse,
  ch16_test_pulse => cir(16).test_pulse,
  ch16_ev_data_valid => cir(16).ev_data_valid,
  ch16_ev_data => cir(16).ev_data,
  ch16_dark_strobe => cir(16).dark_strobe,
  ch16_trig_err_strobe => cir(16).trig_err_strobe,
  ch16_config => cir(16).config,
  ch16_tconfig => cir(16).tconfig,

  -- Channel 17
  ch17_clk => cir(17).clk,
  ch17_reset_bar => cir(17).reset_bar,
  ch17_frame_id => cir(17).frame_id,
  ch17_ctime => cir(17).ctime,
  ch17_tac_refresh_pulse => cir(17).tac_refresh_pulse,
  ch17_test_pulse => cir(17).test_pulse,
  ch17_ev_data_valid => cir(17).ev_data_valid,
  ch17_ev_data => cir(17).ev_data,
  ch17_dark_strobe => cir(17).dark_strobe,
  ch17_trig_err_strobe => cir(17).trig_err_strobe,
  ch17_config => cir(17).config,
  ch17_tconfig => cir(17).tconfig,

  -- Channel 18
  ch18_clk => cir(18).clk,
  ch18_reset_bar => cir(18).reset_bar,
  ch18_frame_id => cir(18).frame_id,
  ch18_ctime => cir(18).ctime,
  ch18_tac_refresh_pulse => cir(18).tac_refresh_pulse,
  ch18_test_pulse => cir(18).test_pulse,
  ch18_ev_data_valid => cir(18).ev_data_valid,
  ch18_ev_data => cir(18).ev_data,
  ch18_dark_strobe => cir(18).dark_strobe,
  ch18_trig_err_strobe => cir(18).trig_err_strobe,
  ch18_config => cir(18).config,
  ch18_tconfig => cir(18).tconfig,

  -- Channel 19
  ch19_clk => cir(19).clk,
  ch19_reset_bar => cir(19).reset_bar,
  ch19_frame_id => cir(19).frame_id,
  ch19_ctime => cir(19).ctime,
  ch19_tac_refresh_pulse => cir(19).tac_refresh_pulse,
  ch19_test_pulse => cir(19).test_pulse,
  ch19_ev_data_valid => cir(19).ev_data_valid,
  ch19_ev_data => cir(19).ev_data,
  ch19_dark_strobe => cir(19).dark_strobe,
  ch19_trig_err_strobe => cir(19).trig_err_strobe,
  ch19_config => cir(19).config,
  ch19_tconfig => cir(19).tconfig,

  -- Channel 20
  ch20_clk => cir(20).clk,
  ch20_reset_bar => cir(20).reset_bar,
  ch20_frame_id => cir(20).frame_id,
  ch20_ctime => cir(20).ctime,
  ch20_tac_refresh_pulse => cir(20).tac_refresh_pulse,
  ch20_test_pulse => cir(20).test_pulse,
  ch20_ev_data_valid => cir(20).ev_data_valid,
  ch20_ev_data => cir(20).ev_data,
  ch20_dark_strobe => cir(20).dark_strobe,
  ch20_trig_err_strobe => cir(20).trig_err_strobe,
  ch20_config => cir(20).config,
  ch20_tconfig => cir(20).tconfig,

  -- Channel 21
  ch21_clk => cir(21).clk,
  ch21_reset_bar => cir(21).reset_bar,
  ch21_frame_id => cir(21).frame_id,
  ch21_ctime => cir(21).ctime,
  ch21_tac_refresh_pulse => cir(21).tac_refresh_pulse,
  ch21_test_pulse => cir(21).test_pulse,
  ch21_ev_data_valid => cir(21).ev_data_valid,
  ch21_ev_data => cir(21).ev_data,
  ch21_dark_strobe => cir(21).dark_strobe,
  ch21_trig_err_strobe => cir(21).trig_err_strobe,
  ch21_config => cir(21).config,
  ch21_tconfig => cir(21).tconfig,

  -- Channel 22
  ch22_clk => cir(22).clk,
  ch22_reset_bar => cir(22).reset_bar,
  ch22_frame_id => cir(22).frame_id,
  ch22_ctime => cir(22).ctime,
  ch22_tac_refresh_pulse => cir(22).tac_refresh_pulse,
  ch22_test_pulse => cir(22).test_pulse,
  ch22_ev_data_valid => cir(22).ev_data_valid,
  ch22_ev_data => cir(22).ev_data,
  ch22_dark_strobe => cir(22).dark_strobe,
  ch22_trig_err_strobe => cir(22).trig_err_strobe,
  ch22_config => cir(22).config,
  ch22_tconfig => cir(22).tconfig,

  -- Channel 23
  ch23_clk => cir(23).clk,
  ch23_reset_bar => cir(23).reset_bar,
  ch23_frame_id => cir(23).frame_id,
  ch23_ctime => cir(23).ctime,
  ch23_tac_refresh_pulse => cir(23).tac_refresh_pulse,
  ch23_test_pulse => cir(23).test_pulse,
  ch23_ev_data_valid => cir(23).ev_data_valid,
  ch23_ev_data => cir(23).ev_data,
  ch23_dark_strobe => cir(23).dark_strobe,
  ch23_trig_err_strobe => cir(23).trig_err_strobe,
  ch23_config => cir(23).config,
  ch23_tconfig => cir(23).tconfig,

  -- Channel 24
  ch24_clk => cir(24).clk,
  ch24_reset_bar => cir(24).reset_bar,
  ch24_frame_id => cir(24).frame_id,
  ch24_ctime => cir(24).ctime,
  ch24_tac_refresh_pulse => cir(24).tac_refresh_pulse,
  ch24_test_pulse => cir(24).test_pulse,
  ch24_ev_data_valid => cir(24).ev_data_valid,
  ch24_ev_data => cir(24).ev_data,
  ch24_dark_strobe => cir(24).dark_strobe,
  ch24_trig_err_strobe => cir(24).trig_err_strobe,
  ch24_config => cir(24).config,
  ch24_tconfig => cir(24).tconfig,

  -- Channel 25
  ch25_clk => cir(25).clk,
  ch25_reset_bar => cir(25).reset_bar,
  ch25_frame_id => cir(25).frame_id,
  ch25_ctime => cir(25).ctime,
  ch25_tac_refresh_pulse => cir(25).tac_refresh_pulse,
  ch25_test_pulse => cir(25).test_pulse,
  ch25_ev_data_valid => cir(25).ev_data_valid,
  ch25_ev_data => cir(25).ev_data,
  ch25_dark_strobe => cir(25).dark_strobe,
  ch25_trig_err_strobe => cir(25).trig_err_strobe,
  ch25_config => cir(25).config,
  ch25_tconfig => cir(25).tconfig,

  -- Channel 26
  ch26_clk => cir(26).clk,
  ch26_reset_bar => cir(26).reset_bar,
  ch26_frame_id => cir(26).frame_id,
  ch26_ctime => cir(26).ctime,
  ch26_tac_refresh_pulse => cir(26).tac_refresh_pulse,
  ch26_test_pulse => cir(26).test_pulse,
  ch26_ev_data_valid => cir(26).ev_data_valid,
  ch26_ev_data => cir(26).ev_data,
  ch26_dark_strobe => cir(26).dark_strobe,
  ch26_trig_err_strobe => cir(26).trig_err_strobe,
  ch26_config => cir(26).config,
  ch26_tconfig => cir(26).tconfig,

  -- Channel 27
  ch27_clk => cir(27).clk,
  ch27_reset_bar => cir(27).reset_bar,
  ch27_frame_id => cir(27).frame_id,
  ch27_ctime => cir(27).ctime,
  ch27_tac_refresh_pulse => cir(27).tac_refresh_pulse,
  ch27_test_pulse => cir(27).test_pulse,
  ch27_ev_data_valid => cir(27).ev_data_valid,
  ch27_ev_data => cir(27).ev_data,
  ch27_dark_strobe => cir(27).dark_strobe,
  ch27_trig_err_strobe => cir(27).trig_err_strobe,
  ch27_config => cir(27).config,
  ch27_tconfig => cir(27).tconfig,

  -- Channel 28
  ch28_clk => cir(28).clk,
  ch28_reset_bar => cir(28).reset_bar,
  ch28_frame_id => cir(28).frame_id,
  ch28_ctime => cir(28).ctime,
  ch28_tac_refresh_pulse => cir(28).tac_refresh_pulse,
  ch28_test_pulse => cir(28).test_pulse,
  ch28_ev_data_valid => cir(28).ev_data_valid,
  ch28_ev_data => cir(28).ev_data,
  ch28_dark_strobe => cir(28).dark_strobe,
  ch28_trig_err_strobe => cir(28).trig_err_strobe,
  ch28_config => cir(28).config,
  ch28_tconfig => cir(28).tconfig,

  -- Channel 29
  ch29_clk => cir(29).clk,
  ch29_reset_bar => cir(29).reset_bar,
  ch29_frame_id => cir(29).frame_id,
  ch29_ctime => cir(29).ctime,
  ch29_tac_refresh_pulse => cir(29).tac_refresh_pulse,
  ch29_test_pulse => cir(29).test_pulse,
  ch29_ev_data_valid => cir(29).ev_data_valid,
  ch29_ev_data => cir(29).ev_data,
  ch29_dark_strobe => cir(29).dark_strobe,
  ch29_trig_err_strobe => cir(29).trig_err_strobe,
  ch29_config => cir(29).config,
  ch29_tconfig => cir(29).tconfig,

  -- Channel 30
  ch30_clk => cir(30).clk,
  ch30_reset_bar => cir(30).reset_bar,
  ch30_frame_id => cir(30).frame_id,
  ch30_ctime => cir(30).ctime,
  ch30_tac_refresh_pulse => cir(30).tac_refresh_pulse,
  ch30_test_pulse => cir(30).test_pulse,
  ch30_ev_data_valid => cir(30).ev_data_valid,
  ch30_ev_data => cir(30).ev_data,
  ch30_dark_strobe => cir(30).dark_strobe,
  ch30_trig_err_strobe => cir(30).trig_err_strobe,
  ch30_config => cir(30).config,
  ch30_tconfig => cir(30).tconfig,

  -- Channel 31
  ch31_clk => cir(31).clk,
  ch31_reset_bar => cir(31).reset_bar,
  ch31_frame_id => cir(31).frame_id,
  ch31_ctime => cir(31).ctime,
  ch31_tac_refresh_pulse => cir(31).tac_refresh_pulse,
  ch31_test_pulse => cir(31).test_pulse,
  ch31_ev_data_valid => cir(31).ev_data_valid,
  ch31_ev_data => cir(31).ev_data,
  ch31_dark_strobe => cir(31).dark_strobe,
  ch31_trig_err_strobe => cir(31).trig_err_strobe,
  ch31_config => cir(31).config,
  ch31_tconfig => cir(31).tconfig,

  -- Channel 32
  ch32_clk => cir(32).clk,
  ch32_reset_bar => cir(32).reset_bar,
  ch32_frame_id => cir(32).frame_id,
  ch32_ctime => cir(32).ctime,
  ch32_tac_refresh_pulse => cir(32).tac_refresh_pulse,
  ch32_test_pulse => cir(32).test_pulse,
  ch32_ev_data_valid => cir(32).ev_data_valid,
  ch32_ev_data => cir(32).ev_data,
  ch32_dark_strobe => cir(32).dark_strobe,
  ch32_trig_err_strobe => cir(32).trig_err_strobe,
  ch32_config => cir(32).config,
  ch32_tconfig => cir(32).tconfig,

  -- Channel 33
  ch33_clk => cir(33).clk,
  ch33_reset_bar => cir(33).reset_bar,
  ch33_frame_id => cir(33).frame_id,
  ch33_ctime => cir(33).ctime,
  ch33_tac_refresh_pulse => cir(33).tac_refresh_pulse,
  ch33_test_pulse => cir(33).test_pulse,
  ch33_ev_data_valid => cir(33).ev_data_valid,
  ch33_ev_data => cir(33).ev_data,
  ch33_dark_strobe => cir(33).dark_strobe,
  ch33_trig_err_strobe => cir(33).trig_err_strobe,
  ch33_config => cir(33).config,
  ch33_tconfig => cir(33).tconfig,

  -- Channel 34
  ch34_clk => cir(34).clk,
  ch34_reset_bar => cir(34).reset_bar,
  ch34_frame_id => cir(34).frame_id,
  ch34_ctime => cir(34).ctime,
  ch34_tac_refresh_pulse => cir(34).tac_refresh_pulse,
  ch34_test_pulse => cir(34).test_pulse,
  ch34_ev_data_valid => cir(34).ev_data_valid,
  ch34_ev_data => cir(34).ev_data,
  ch34_dark_strobe => cir(34).dark_strobe,
  ch34_trig_err_strobe => cir(34).trig_err_strobe,
  ch34_config => cir(34).config,
  ch34_tconfig => cir(34).tconfig,

  -- Channel 35
  ch35_clk => cir(35).clk,
  ch35_reset_bar => cir(35).reset_bar,
  ch35_frame_id => cir(35).frame_id,
  ch35_ctime => cir(35).ctime,
  ch35_tac_refresh_pulse => cir(35).tac_refresh_pulse,
  ch35_test_pulse => cir(35).test_pulse,
  ch35_ev_data_valid => cir(35).ev_data_valid,
  ch35_ev_data => cir(35).ev_data,
  ch35_dark_strobe => cir(35).dark_strobe,
  ch35_trig_err_strobe => cir(35).trig_err_strobe,
  ch35_config => cir(35).config,
  ch35_tconfig => cir(35).tconfig,

  -- Channel 36
  ch36_clk => cir(36).clk,
  ch36_reset_bar => cir(36).reset_bar,
  ch36_frame_id => cir(36).frame_id,
  ch36_ctime => cir(36).ctime,
  ch36_tac_refresh_pulse => cir(36).tac_refresh_pulse,
  ch36_test_pulse => cir(36).test_pulse,
  ch36_ev_data_valid => cir(36).ev_data_valid,
  ch36_ev_data => cir(36).ev_data,
  ch36_dark_strobe => cir(36).dark_strobe,
  ch36_trig_err_strobe => cir(36).trig_err_strobe,
  ch36_config => cir(36).config,
  ch36_tconfig => cir(36).tconfig,

  -- Channel 37
  ch37_clk => cir(37).clk,
  ch37_reset_bar => cir(37).reset_bar,
  ch37_frame_id => cir(37).frame_id,
  ch37_ctime => cir(37).ctime,
  ch37_tac_refresh_pulse => cir(37).tac_refresh_pulse,
  ch37_test_pulse => cir(37).test_pulse,
  ch37_ev_data_valid => cir(37).ev_data_valid,
  ch37_ev_data => cir(37).ev_data,
  ch37_dark_strobe => cir(37).dark_strobe,
  ch37_trig_err_strobe => cir(37).trig_err_strobe,
  ch37_config => cir(37).config,
  ch37_tconfig => cir(37).tconfig,

  -- Channel 38
  ch38_clk => cir(38).clk,
  ch38_reset_bar => cir(38).reset_bar,
  ch38_frame_id => cir(38).frame_id,
  ch38_ctime => cir(38).ctime,
  ch38_tac_refresh_pulse => cir(38).tac_refresh_pulse,
  ch38_test_pulse => cir(38).test_pulse,
  ch38_ev_data_valid => cir(38).ev_data_valid,
  ch38_ev_data => cir(38).ev_data,
  ch38_dark_strobe => cir(38).dark_strobe,
  ch38_trig_err_strobe => cir(38).trig_err_strobe,
  ch38_config => cir(38).config,
  ch38_tconfig => cir(38).tconfig,

  -- Channel 39
  ch39_clk => cir(39).clk,
  ch39_reset_bar => cir(39).reset_bar,
  ch39_frame_id => cir(39).frame_id,
  ch39_ctime => cir(39).ctime,
  ch39_tac_refresh_pulse => cir(39).tac_refresh_pulse,
  ch39_test_pulse => cir(39).test_pulse,
  ch39_ev_data_valid => cir(39).ev_data_valid,
  ch39_ev_data => cir(39).ev_data,
  ch39_dark_strobe => cir(39).dark_strobe,
  ch39_trig_err_strobe => cir(39).trig_err_strobe,
  ch39_config => cir(39).config,
  ch39_tconfig => cir(39).tconfig,

  -- Channel 40
  ch40_clk => cir(40).clk,
  ch40_reset_bar => cir(40).reset_bar,
  ch40_frame_id => cir(40).frame_id,
  ch40_ctime => cir(40).ctime,
  ch40_tac_refresh_pulse => cir(40).tac_refresh_pulse,
  ch40_test_pulse => cir(40).test_pulse,
  ch40_ev_data_valid => cir(40).ev_data_valid,
  ch40_ev_data => cir(40).ev_data,
  ch40_dark_strobe => cir(40).dark_strobe,
  ch40_trig_err_strobe => cir(40).trig_err_strobe,
  ch40_config => cir(40).config,
  ch40_tconfig => cir(40).tconfig,

  -- Channel 41
  ch41_clk => cir(41).clk,
  ch41_reset_bar => cir(41).reset_bar,
  ch41_frame_id => cir(41).frame_id,
  ch41_ctime => cir(41).ctime,
  ch41_tac_refresh_pulse => cir(41).tac_refresh_pulse,
  ch41_test_pulse => cir(41).test_pulse,
  ch41_ev_data_valid => cir(41).ev_data_valid,
  ch41_ev_data => cir(41).ev_data,
  ch41_dark_strobe => cir(41).dark_strobe,
  ch41_trig_err_strobe => cir(41).trig_err_strobe,
  ch41_config => cir(41).config,
  ch41_tconfig => cir(41).tconfig,

  -- Channel 42
  ch42_clk => cir(42).clk,
  ch42_reset_bar => cir(42).reset_bar,
  ch42_frame_id => cir(42).frame_id,
  ch42_ctime => cir(42).ctime,
  ch42_tac_refresh_pulse => cir(42).tac_refresh_pulse,
  ch42_test_pulse => cir(42).test_pulse,
  ch42_ev_data_valid => cir(42).ev_data_valid,
  ch42_ev_data => cir(42).ev_data,
  ch42_dark_strobe => cir(42).dark_strobe,
  ch42_trig_err_strobe => cir(42).trig_err_strobe,
  ch42_config => cir(42).config,
  ch42_tconfig => cir(42).tconfig,

  -- Channel 43
  ch43_clk => cir(43).clk,
  ch43_reset_bar => cir(43).reset_bar,
  ch43_frame_id => cir(43).frame_id,
  ch43_ctime => cir(43).ctime,
  ch43_tac_refresh_pulse => cir(43).tac_refresh_pulse,
  ch43_test_pulse => cir(43).test_pulse,
  ch43_ev_data_valid => cir(43).ev_data_valid,
  ch43_ev_data => cir(43).ev_data,
  ch43_dark_strobe => cir(43).dark_strobe,
  ch43_trig_err_strobe => cir(43).trig_err_strobe,
  ch43_config => cir(43).config,
  ch43_tconfig => cir(43).tconfig,

  -- Channel 44
  ch44_clk => cir(44).clk,
  ch44_reset_bar => cir(44).reset_bar,
  ch44_frame_id => cir(44).frame_id,
  ch44_ctime => cir(44).ctime,
  ch44_tac_refresh_pulse => cir(44).tac_refresh_pulse,
  ch44_test_pulse => cir(44).test_pulse,
  ch44_ev_data_valid => cir(44).ev_data_valid,
  ch44_ev_data => cir(44).ev_data,
  ch44_dark_strobe => cir(44).dark_strobe,
  ch44_trig_err_strobe => cir(44).trig_err_strobe,
  ch44_config => cir(44).config,
  ch44_tconfig => cir(44).tconfig,

  -- Channel 45
  ch45_clk => cir(45).clk,
  ch45_reset_bar => cir(45).reset_bar,
  ch45_frame_id => cir(45).frame_id,
  ch45_ctime => cir(45).ctime,
  ch45_tac_refresh_pulse => cir(45).tac_refresh_pulse,
  ch45_test_pulse => cir(45).test_pulse,
  ch45_ev_data_valid => cir(45).ev_data_valid,
  ch45_ev_data => cir(45).ev_data,
  ch45_dark_strobe => cir(45).dark_strobe,
  ch45_trig_err_strobe => cir(45).trig_err_strobe,
  ch45_config => cir(45).config,
  ch45_tconfig => cir(45).tconfig,

  -- Channel 46
  ch46_clk => cir(46).clk,
  ch46_reset_bar => cir(46).reset_bar,
  ch46_frame_id => cir(46).frame_id,
  ch46_ctime => cir(46).ctime,
  ch46_tac_refresh_pulse => cir(46).tac_refresh_pulse,
  ch46_test_pulse => cir(46).test_pulse,
  ch46_ev_data_valid => cir(46).ev_data_valid,
  ch46_ev_data => cir(46).ev_data,
  ch46_dark_strobe => cir(46).dark_strobe,
  ch46_trig_err_strobe => cir(46).trig_err_strobe,
  ch46_config => cir(46).config,
  ch46_tconfig => cir(46).tconfig,

  -- Channel 47
  ch47_clk => cir(47).clk,
  ch47_reset_bar => cir(47).reset_bar,
  ch47_frame_id => cir(47).frame_id,
  ch47_ctime => cir(47).ctime,
  ch47_tac_refresh_pulse => cir(47).tac_refresh_pulse,
  ch47_test_pulse => cir(47).test_pulse,
  ch47_ev_data_valid => cir(47).ev_data_valid,
  ch47_ev_data => cir(47).ev_data,
  ch47_dark_strobe => cir(47).dark_strobe,
  ch47_trig_err_strobe => cir(47).trig_err_strobe,
  ch47_config => cir(47).config,
  ch47_tconfig => cir(47).tconfig,

  -- Channel 48
  ch48_clk => cir(48).clk,
  ch48_reset_bar => cir(48).reset_bar,
  ch48_frame_id => cir(48).frame_id,
  ch48_ctime => cir(48).ctime,
  ch48_tac_refresh_pulse => cir(48).tac_refresh_pulse,
  ch48_test_pulse => cir(48).test_pulse,
  ch48_ev_data_valid => cir(48).ev_data_valid,
  ch48_ev_data => cir(48).ev_data,
  ch48_dark_strobe => cir(48).dark_strobe,
  ch48_trig_err_strobe => cir(48).trig_err_strobe,
  ch48_config => cir(48).config,
  ch48_tconfig => cir(48).tconfig,

  -- Channel 49
  ch49_clk => cir(49).clk,
  ch49_reset_bar => cir(49).reset_bar,
  ch49_frame_id => cir(49).frame_id,
  ch49_ctime => cir(49).ctime,
  ch49_tac_refresh_pulse => cir(49).tac_refresh_pulse,
  ch49_test_pulse => cir(49).test_pulse,
  ch49_ev_data_valid => cir(49).ev_data_valid,
  ch49_ev_data => cir(49).ev_data,
  ch49_dark_strobe => cir(49).dark_strobe,
  ch49_trig_err_strobe => cir(49).trig_err_strobe,
  ch49_config => cir(49).config,
  ch49_tconfig => cir(49).tconfig,

  -- Channel 50
  ch50_clk => cir(50).clk,
  ch50_reset_bar => cir(50).reset_bar,
  ch50_frame_id => cir(50).frame_id,
  ch50_ctime => cir(50).ctime,
  ch50_tac_refresh_pulse => cir(50).tac_refresh_pulse,
  ch50_test_pulse => cir(50).test_pulse,
  ch50_ev_data_valid => cir(50).ev_data_valid,
  ch50_ev_data => cir(50).ev_data,
  ch50_dark_strobe => cir(50).dark_strobe,
  ch50_trig_err_strobe => cir(50).trig_err_strobe,
  ch50_config => cir(50).config,
  ch50_tconfig => cir(50).tconfig,

  -- Channel 51
  ch51_clk => cir(51).clk,
  ch51_reset_bar => cir(51).reset_bar,
  ch51_frame_id => cir(51).frame_id,
  ch51_ctime => cir(51).ctime,
  ch51_tac_refresh_pulse => cir(51).tac_refresh_pulse,
  ch51_test_pulse => cir(51).test_pulse,
  ch51_ev_data_valid => cir(51).ev_data_valid,
  ch51_ev_data => cir(51).ev_data,
  ch51_dark_strobe => cir(51).dark_strobe,
  ch51_trig_err_strobe => cir(51).trig_err_strobe,
  ch51_config => cir(51).config,
  ch51_tconfig => cir(51).tconfig,

  -- Channel 52
  ch52_clk => cir(52).clk,
  ch52_reset_bar => cir(52).reset_bar,
  ch52_frame_id => cir(52).frame_id,
  ch52_ctime => cir(52).ctime,
  ch52_tac_refresh_pulse => cir(52).tac_refresh_pulse,
  ch52_test_pulse => cir(52).test_pulse,
  ch52_ev_data_valid => cir(52).ev_data_valid,
  ch52_ev_data => cir(52).ev_data,
  ch52_dark_strobe => cir(52).dark_strobe,
  ch52_trig_err_strobe => cir(52).trig_err_strobe,
  ch52_config => cir(52).config,
  ch52_tconfig => cir(52).tconfig,

  -- Channel 53
  ch53_clk => cir(53).clk,
  ch53_reset_bar => cir(53).reset_bar,
  ch53_frame_id => cir(53).frame_id,
  ch53_ctime => cir(53).ctime,
  ch53_tac_refresh_pulse => cir(53).tac_refresh_pulse,
  ch53_test_pulse => cir(53).test_pulse,
  ch53_ev_data_valid => cir(53).ev_data_valid,
  ch53_ev_data => cir(53).ev_data,
  ch53_dark_strobe => cir(53).dark_strobe,
  ch53_trig_err_strobe => cir(53).trig_err_strobe,
  ch53_config => cir(53).config,
  ch53_tconfig => cir(53).tconfig,

  -- Channel 54
  ch54_clk => cir(54).clk,
  ch54_reset_bar => cir(54).reset_bar,
  ch54_frame_id => cir(54).frame_id,
  ch54_ctime => cir(54).ctime,
  ch54_tac_refresh_pulse => cir(54).tac_refresh_pulse,
  ch54_test_pulse => cir(54).test_pulse,
  ch54_ev_data_valid => cir(54).ev_data_valid,
  ch54_ev_data => cir(54).ev_data,
  ch54_dark_strobe => cir(54).dark_strobe,
  ch54_trig_err_strobe => cir(54).trig_err_strobe,
  ch54_config => cir(54).config,
  ch54_tconfig => cir(54).tconfig,

  -- Channel 55
  ch55_clk => cir(55).clk,
  ch55_reset_bar => cir(55).reset_bar,
  ch55_frame_id => cir(55).frame_id,
  ch55_ctime => cir(55).ctime,
  ch55_tac_refresh_pulse => cir(55).tac_refresh_pulse,
  ch55_test_pulse => cir(55).test_pulse,
  ch55_ev_data_valid => cir(55).ev_data_valid,
  ch55_ev_data => cir(55).ev_data,
  ch55_dark_strobe => cir(55).dark_strobe,
  ch55_trig_err_strobe => cir(55).trig_err_strobe,
  ch55_config => cir(55).config,
  ch55_tconfig => cir(55).tconfig,

  -- Channel 56
  ch56_clk => cir(56).clk,
  ch56_reset_bar => cir(56).reset_bar,
  ch56_frame_id => cir(56).frame_id,
  ch56_ctime => cir(56).ctime,
  ch56_tac_refresh_pulse => cir(56).tac_refresh_pulse,
  ch56_test_pulse => cir(56).test_pulse,
  ch56_ev_data_valid => cir(56).ev_data_valid,
  ch56_ev_data => cir(56).ev_data,
  ch56_dark_strobe => cir(56).dark_strobe,
  ch56_trig_err_strobe => cir(56).trig_err_strobe,
  ch56_config => cir(56).config,
  ch56_tconfig => cir(56).tconfig,

  -- Channel 57
  ch57_clk => cir(57).clk,
  ch57_reset_bar => cir(57).reset_bar,
  ch57_frame_id => cir(57).frame_id,
  ch57_ctime => cir(57).ctime,
  ch57_tac_refresh_pulse => cir(57).tac_refresh_pulse,
  ch57_test_pulse => cir(57).test_pulse,
  ch57_ev_data_valid => cir(57).ev_data_valid,
  ch57_ev_data => cir(57).ev_data,
  ch57_dark_strobe => cir(57).dark_strobe,
  ch57_trig_err_strobe => cir(57).trig_err_strobe,
  ch57_config => cir(57).config,
  ch57_tconfig => cir(57).tconfig,

  -- Channel 58
  ch58_clk => cir(58).clk,
  ch58_reset_bar => cir(58).reset_bar,
  ch58_frame_id => cir(58).frame_id,
  ch58_ctime => cir(58).ctime,
  ch58_tac_refresh_pulse => cir(58).tac_refresh_pulse,
  ch58_test_pulse => cir(58).test_pulse,
  ch58_ev_data_valid => cir(58).ev_data_valid,
  ch58_ev_data => cir(58).ev_data,
  ch58_dark_strobe => cir(58).dark_strobe,
  ch58_trig_err_strobe => cir(58).trig_err_strobe,
  ch58_config => cir(58).config,
  ch58_tconfig => cir(58).tconfig,

  -- Channel 59
  ch59_clk => cir(59).clk,
  ch59_reset_bar => cir(59).reset_bar,
  ch59_frame_id => cir(59).frame_id,
  ch59_ctime => cir(59).ctime,
  ch59_tac_refresh_pulse => cir(59).tac_refresh_pulse,
  ch59_test_pulse => cir(59).test_pulse,
  ch59_ev_data_valid => cir(59).ev_data_valid,
  ch59_ev_data => cir(59).ev_data,
  ch59_dark_strobe => cir(59).dark_strobe,
  ch59_trig_err_strobe => cir(59).trig_err_strobe,
  ch59_config => cir(59).config,
  ch59_tconfig => cir(59).tconfig,

  -- Channel 60
  ch60_clk => cir(60).clk,
  ch60_reset_bar => cir(60).reset_bar,
  ch60_frame_id => cir(60).frame_id,
  ch60_ctime => cir(60).ctime,
  ch60_tac_refresh_pulse => cir(60).tac_refresh_pulse,
  ch60_test_pulse => cir(60).test_pulse,
  ch60_ev_data_valid => cir(60).ev_data_valid,
  ch60_ev_data => cir(60).ev_data,
  ch60_dark_strobe => cir(60).dark_strobe,
  ch60_trig_err_strobe => cir(60).trig_err_strobe,
  ch60_config => cir(60).config,
  ch60_tconfig => cir(60).tconfig,

  -- Channel 61
  ch61_clk => cir(61).clk,
  ch61_reset_bar => cir(61).reset_bar,
  ch61_frame_id => cir(61).frame_id,
  ch61_ctime => cir(61).ctime,
  ch61_tac_refresh_pulse => cir(61).tac_refresh_pulse,
  ch61_test_pulse => cir(61).test_pulse,
  ch61_ev_data_valid => cir(61).ev_data_valid,
  ch61_ev_data => cir(61).ev_data,
  ch61_dark_strobe => cir(61).dark_strobe,
  ch61_trig_err_strobe => cir(61).trig_err_strobe,
  ch61_config => cir(61).config,
  ch61_tconfig => cir(61).tconfig,

  -- Channel 62
  ch62_clk => cir(62).clk,
  ch62_reset_bar => cir(62).reset_bar,
  ch62_frame_id => cir(62).frame_id,
  ch62_ctime => cir(62).ctime,
  ch62_tac_refresh_pulse => cir(62).tac_refresh_pulse,
  ch62_test_pulse => cir(62).test_pulse,
  ch62_ev_data_valid => cir(62).ev_data_valid,
  ch62_ev_data => cir(62).ev_data,
  ch62_dark_strobe => cir(62).dark_strobe,
  ch62_trig_err_strobe => cir(62).trig_err_strobe,
  ch62_config => cir(62).config,
  ch62_tconfig => cir(62).tconfig,

  -- Channel 63
  ch63_clk => cir(63).clk,
  ch63_reset_bar => cir(63).reset_bar,
  ch63_frame_id => cir(63).frame_id,
  ch63_ctime => cir(63).ctime,
  ch63_tac_refresh_pulse => cir(63).tac_refresh_pulse,
  ch63_test_pulse => cir(63).test_pulse,
  ch63_ev_data_valid => cir(63).ev_data_valid,
  ch63_ev_data => cir(63).ev_data,
  ch63_dark_strobe => cir(63).dark_strobe,
  ch63_trig_err_strobe => cir(63).trig_err_strobe,
  ch63_config => cir(63).config,
  ch63_tconfig => cir(63).tconfig
);


end behavioral;

  
