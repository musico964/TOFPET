library ieee, worklib;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

--library modelsim_lib;
--use modelsim_lib.util.all;

library NCUTILS;
use NCUTILS.ncutilities.all;

entity asic_64mx_tb_data is
end asic_64mx_tb_data;

architecture behavioral of asic_64mx_tb_data is
  constant N_CHANNELS : integer := 64;
  constant T1 : time := 6.25 ns;
  constant T2 : time := 100 ns;
  constant TX_MODE : std_logic_vector := b"00";
  constant FC_SATURATE : std_logic := '1';
  constant FC_SUB : std_logic_vector(7 downto 0) := x"B0";
  constant CH_CONFIG_SIZE : integer := 33;
  constant CH_TCONFIG_SIZE : integer := 7;
  constant GLOBAL_CONFIG_SIZE : integer := 17;
  
  
  function crc8(crc_in : std_logic_vector(7 downto 0); data : std_logic) 
    return std_logic_vector is
  variable crc_out : std_logic_vector(7 downto 0);
  begin
    crc_out(0) := data xor crc_in(7); 
    crc_out(1) := data xor crc_in(0) xor crc_in(7); 
    crc_out(2) := data xor crc_in(1) xor crc_in(7); 
    crc_out(3) := crc_in(2);
    crc_out(4) := crc_in(3); 
    crc_out(5) := crc_in(4); 
    crc_out(6) := crc_in(5); 
    crc_out(7) := crc_in(6); 
    return crc_out;  
  end crc8;
  
  
  function crc8_vector(data : std_logic_vector) return std_logic_vector is 
  variable crc_out : std_logic_vector(7 downto 0);
  variable i : integer;
  variable d : std_logic_vector(data'length - 1 downto 0);
  begin
    d := data;
    crc_out := x"8A";
    for i in d'length - 1 downto 0 loop
      crc_out := crc8(crc_out, d(i));
    end loop;
    return crc_out;
  end crc8_vector;
  
  procedure send_stream(signal sdo : out std_logic; data : in std_logic_vector) is
  variable i : integer;
  variable d : std_logic_vector(data'length - 1 downto 0);
  begin
    d := data;
    for i in d'length - 1 downto 0 loop
      sdo <= d(i); wait for T2;
    end loop;
  end send_stream;

procedure write_gcfg (
    signal cs : out std_logic; 
    signal sdo : out std_logic;
    signal sdi : in std_logic;
    data : in std_logic_vector(GLOBAL_CONFIG_SIZE-1 downto 0)) is
    
  variable cmd : std_logic_vector(3 downto 0);
  variable d : std_logic_vector(data'length - 1 downto 0);
  variable crc : std_logic_vector(7 downto 0);
  variable i : integer;
  begin
    cmd := "1000";
    d := data;
    crc := crc8_vector(cmd & d);
    cs <= '1';
    send_stream(sdo, cmd & d & crc);
    assert sdi = '1' report "WRGCFG: Ack Failed" severity error;
    wait for T2;
    cs <= '0';
    wait for 2*T2;    
  end write_gcfg;
  
  signal test_name : string(1 to 128);
  function xname (s : string) return string is 
  variable ss : string(1 to 128);
  begin
    for i in 1 to 128 loop
      ss(i) := ' ';
    end loop;
    for i in 1 to s'length loop
      ss(i) := s(i);
    end loop;
    return ss;
  end xname; 
  
  function to_std_logic_vector(s: string) return std_logic_vector is
  variable slv: std_logic_vector(s'high-s'low downto 0);
  variable k: integer;
  begin
  k := s'high-s'low;
  for i in s'range loop
    if s(i) = '1' then 
      slv(k) := '1';
    else
      slv(k) := '0';
    end if;
  k := k - 1;
  end loop;
  return slv;
  end to_std_logic_vector;  
  
  function crc16(crc_i : std_logic_vector(15 downto 0); data_i: std_logic_vector(15 downto 0))
    return std_logic_vector is
    variable crc_o : std_logic_vector(15 downto 0);
    begin
      crc_o(0) := data_i(0) xor data_i(4) xor data_i(11) xor crc_i(0) xor crc_i(11) xor data_i(8) xor crc_i(4) xor data_i(12) xor crc_i(8) xor crc_i(12); 
      crc_o(1) := data_i(1) xor data_i(5) xor data_i(12) xor crc_i(1) xor crc_i(12) xor data_i(9) xor crc_i(5) xor data_i(13) xor crc_i(9) xor crc_i(13); 
      crc_o(2) := data_i(2) xor data_i(6) xor data_i(13) xor crc_i(2) xor crc_i(13) xor data_i(10) xor crc_i(6) xor data_i(14) xor crc_i(10) xor crc_i(14); 
      crc_o(3) := data_i(3) xor data_i(7) xor data_i(14) xor crc_i(3) xor crc_i(14) xor data_i(11) xor crc_i(7) xor data_i(15) xor crc_i(11) xor crc_i(15); 
      crc_o(4) := data_i(4) xor data_i(8) xor data_i(15) xor crc_i(4) xor crc_i(15) xor data_i(12) xor crc_i(8) xor crc_i(12); 
      crc_o(5) := data_i(0) xor data_i(5) xor data_i(9) xor crc_i(5) xor data_i(13) xor crc_i(9) xor crc_i(13) xor data_i(4) xor data_i(11) xor crc_i(0) xor crc_i(11) xor data_i(8) xor crc_i(4) xor data_i(12) xor crc_i(8) xor crc_i(12); 
      crc_o(6) := data_i(1) xor data_i(6) xor data_i(10) xor crc_i(6) xor data_i(14) xor crc_i(10) xor crc_i(14) xor data_i(5) xor data_i(12) xor crc_i(1) xor crc_i(12) xor data_i(9) xor crc_i(5) xor data_i(13) xor crc_i(9) xor crc_i(13); 
      crc_o(7) := data_i(2) xor data_i(7) xor data_i(11) xor crc_i(7) xor data_i(15) xor crc_i(11) xor crc_i(15) xor data_i(6) xor data_i(13) xor crc_i(2) xor crc_i(13) xor data_i(10) xor crc_i(6) xor data_i(14) xor crc_i(10) xor crc_i(14); 
      crc_o(8) := data_i(3) xor data_i(8) xor data_i(12) xor crc_i(8) xor crc_i(12) xor data_i(7) xor data_i(14) xor crc_i(3) xor crc_i(14) xor data_i(11) xor crc_i(7) xor data_i(15) xor crc_i(11) xor crc_i(15); 
      crc_o(9) := data_i(4) xor data_i(9) xor data_i(13) xor crc_i(9) xor crc_i(13) xor data_i(8) xor data_i(15) xor crc_i(4) xor crc_i(15) xor data_i(12) xor crc_i(8) xor crc_i(12); 
      crc_o(10) := data_i(5) xor data_i(10) xor data_i(14) xor crc_i(10) xor crc_i(14) xor data_i(9) xor crc_i(5) xor data_i(13) xor crc_i(9) xor crc_i(13); 
      crc_o(11) := data_i(6) xor data_i(11) xor data_i(15) xor crc_i(11) xor crc_i(15) xor data_i(10) xor crc_i(6) xor data_i(14) xor crc_i(10) xor crc_i(14); 
      crc_o(12) := data_i(0) xor data_i(7) xor crc_i(7) xor data_i(15) xor crc_i(15) xor data_i(4) xor crc_i(0) xor data_i(8) xor crc_i(4) xor crc_i(8); 
      crc_o(13) := data_i(1) xor data_i(8) xor crc_i(8) xor data_i(5) xor crc_i(1) xor data_i(9) xor crc_i(5) xor crc_i(9); 
      crc_o(14) := data_i(2) xor data_i(9) xor crc_i(9) xor data_i(6) xor crc_i(2) xor data_i(10) xor crc_i(6) xor crc_i(10); 
      crc_o(15) := data_i(3) xor data_i(10) xor crc_i(10) xor data_i(7) xor crc_i(3) xor data_i(11) xor crc_i(7) xor crc_i(11); 
      return crc_o;
    end crc16;  
    
    function binary_to_gray(x: std_logic_vector) return std_logic_vector is
    begin
      return x xor ('0' & x(x'high downto x'low+1));
    end binary_to_gray;    
  
function odd_parity(x : std_logic_vector) return std_logic is
  variable d: std_logic_vector(x'length - 1 downto 0);
  variable p : std_logic;
  variable i : integer;
  begin
	 d := x;
    p := '0';
    for i in d'length - 1 downto 0 loop
      p := p xor d(i);
    end loop;
    return p;
  end odd_parity;  
  
  -- ASIC main signals
  signal clk : std_logic := '0';
  signal sclk : std_logic := '0';
  signal sync_rst : std_logic := '1';
  signal cs : std_logic := '0';
  signal sdi : std_logic := '0';  
  signal sdo : std_logic;
  signal tx0 : std_logic;
  signal tx1 : std_logic;
  signal tx2 : std_logic;
  signal tx3 : std_logic;
  
  signal sync : std_logic;
  signal reset : std_logic;
  signal frame_id : std_logic;
  signal ctime : std_logic_vector(9 downto 0);
  signal tac_refresh_en : std_logic;
  signal tac_refresh_intv : std_logic_vector(3 downto 0);
  
  -- ASIC Channel Interface!
  type channel_interface_t is record
    ev_data_valid	: std_logic;
    ev_data			: std_logic_vector(50 downto 0);
    dark_strobe		: std_logic;
    config			: std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
    tconfig			: std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
  end record;
  
  type channel_interface_array_t is array (0 to N_CHANNELS-1) of channel_interface_t;  
  signal cir : channel_interface_array_t;

-- Test bench signals

 
  signal rx0_word : std_logic_vector(9 downto 0);
  signal rx1_word : std_logic_vector(9 downto 0);
  signal rx2_word : std_logic_vector(9 downto 0);
  signal rx3_word : std_logic_vector(9 downto 0); 
  
  signal dec0_reset : std_logic := '1';
  signal dec1_reset : std_logic := '1';
  signal dec2_reset : std_logic := '1';
  signal dec3_reset : std_logic := '1';

  signal byte_clk : std_logic := '0';

  signal rx0_byte : std_logic_vector(7 downto 0);
  signal rx0_ko   : std_logic;
  signal rx1_byte : std_logic_vector(7 downto 0);
  signal rx1_ko   : std_logic;  
  signal rx2_byte : std_logic_vector(7 downto 0);
  signal rx2_ko   : std_logic;
  signal rx3_byte : std_logic_vector(7 downto 0);  
  signal rx3_ko   : std_logic;
  
  type rx_frame_data_t is array(0 to 1023) of std_logic_vector(7 downto 0);
  signal rx_frame_data : rx_frame_data_t;
  signal rx_frame_bytes : integer;
  signal rx_frame_nevents : std_logic_vector(7 downto 0);
  signal rx_frame_id   : std_logic_vector(31 downto 0);
  signal rx_frame_crc  : std_logic_vector(15 downto 0);
  signal rx_events_received : integer := 0;
  signal rx_events_expected : integer := 0;
  signal rx_event_loss : real := 0.0;
  signal rx_events_lost : integer := 0;
  
  type event_t is record
    channel : integer;
    tcoarse : integer;
    ecoarse : integer;
    tfine   : integer;
    efine   : integer;
    matched : boolean;
  end record;
  
  type event_array_t is array (0 to 255) of event_t;
  signal rx_frame_events : event_array_t;
  signal xx_frame_events : event_array_t;
  
  signal start_stimulus : std_logic := '0';
  
  signal global_config_r : std_logic_vector(GLOBAL_CONFIG_SIZE-1 downto 0); 
  signal spy_fb0_nevents : std_logic_vector(7 downto 0);
  signal spy_fb1_nevents : std_logic_vector(7 downto 0);
  signal max_fb_nevents  : integer := 0;
  
  signal spy_fifo_words_avail : std_logic_vector(9 downto 0);
  signal min_fifo_words_avail : integer := 32768;
  
  
begin
  
--  spy : process begin
--    init_signal_spy("/gctrl_tb_data/dut/fb/fb0/event_number_r", "/gctrl_tb_data/spy_fb0_nevents", 1);
--    init_signal_spy("/gctrl_tb_data/dut/fb/fb1/event_number_r", "/gctrl_tb_data/spy_fb1_nevents", 1);
--    init_signal_spy("/gctrl_tb_data/dut/fifo/words_avail_r", "/gctrl_tb_data/spy_fifo_words_avail", 1);
--    wait;
--  end process spy;

  nc_mirror(destination => "spy_fb0_nevents", source => "dut:fb:fb0:event_number_r");
  nc_mirror(destination => "spy_fb1_nevents", source => "dut:fb:fb1:event_number_r");
  nc_mirror(destination => "spy_fifo_words_avail", source => "dut:fifo:words_avail_r");
  
  process (spy_fb0_nevents, spy_fb1_nevents) 
    variable nfb0 : integer;
    variable nfb1 : integer;
  begin
    nfb0 := to_integer(unsigned(spy_fb0_nevents));
    nfb1 := to_integer(unsigned(spy_fb1_nevents));
    
    if (nfb0 > nfb1) and (nfb0 > max_fb_nevents) then
      max_fb_nevents <= nfb0;
    elsif (nfb1 > nfb0) and (nfb1 > max_fb_nevents) then
      max_fb_nevents <= nfb1;
    end if;
  end process;
  
  process (spy_fifo_words_avail, reset)
    variable w : integer;
  begin
    w := to_integer(unsigned(spy_fifo_words_avail));
    
    if sync_rst = '1' then   
      min_fifo_words_avail <= 32768;
    elsif(w < min_fifo_words_avail) then
      min_fifo_words_avail <= w;
    end if;
  end process;

dut : entity worklib.asic_64mx
port map (
  clk_i => clk,
  sclk_i => sclk,
  sync_rst_i => sync_rst,
  cs_i => cs,
  sdi_i => sdi,
  sdo_o => sdo,
  tx0_o => tx0,
  tx1_o => tx1,
  tx2_o => tx2,
  tx3_o => tx3,
  sync_o => sync,
  reset_o => reset,
  test_pulse_i => '0',
  frame_id_o => frame_id,
  ctime_o => ctime,
  tac_refresh_en_o => tac_refresh_en,
  tac_refresh_intv_o => tac_refresh_intv,
  
  ch0_ev_data_valid => cir(0).ev_data_valid,
  ch0_ev_data => cir(0).ev_data,
  ch0_dark_strobe => cir(0).dark_strobe,
  ch0_config => cir(0).config,
  ch0_tconfig => cir(0).tconfig,
  
  ch1_ev_data_valid => cir(1).ev_data_valid,
  ch1_ev_data => cir(1).ev_data,
  ch1_dark_strobe => cir(1).dark_strobe,
  ch1_config => cir(1).config,
  ch1_tconfig => cir(1).tconfig,

  ch2_ev_data_valid => cir(2).ev_data_valid,
  ch2_ev_data => cir(2).ev_data,
  ch2_dark_strobe => cir(2).dark_strobe,
  ch2_config => cir(2).config,
  ch2_tconfig => cir(2).tconfig,

  ch3_ev_data_valid => cir(3).ev_data_valid,
  ch3_ev_data => cir(3).ev_data,
  ch3_dark_strobe => cir(3).dark_strobe,
  ch3_config => cir(3).config,
  ch3_tconfig => cir(3).tconfig,

  ch4_ev_data_valid => cir(4).ev_data_valid,
  ch4_ev_data => cir(4).ev_data,
  ch4_dark_strobe => cir(4).dark_strobe,
  ch4_config => cir(4).config,
  ch4_tconfig => cir(4).tconfig,

  ch5_ev_data_valid => cir(5).ev_data_valid,
  ch5_ev_data => cir(5).ev_data,
  ch5_dark_strobe => cir(5).dark_strobe,
  ch5_config => cir(5).config,
  ch5_tconfig => cir(5).tconfig,

  ch6_ev_data_valid => cir(6).ev_data_valid,
  ch6_ev_data => cir(6).ev_data,
  ch6_dark_strobe => cir(6).dark_strobe,
  ch6_config => cir(6).config,
  ch6_tconfig => cir(6).tconfig,

  ch7_ev_data_valid => cir(7).ev_data_valid,
  ch7_ev_data => cir(7).ev_data,
  ch7_dark_strobe => cir(7).dark_strobe,
  ch7_config => cir(7).config,
  ch7_tconfig => cir(7).tconfig,

  ch8_ev_data_valid => cir(8).ev_data_valid,
  ch8_ev_data => cir(8).ev_data,
  ch8_dark_strobe => cir(8).dark_strobe,
  ch8_config => cir(8).config,
  ch8_tconfig => cir(8).tconfig,

  ch9_ev_data_valid => cir(9).ev_data_valid,
  ch9_ev_data => cir(9).ev_data,
  ch9_dark_strobe => cir(9).dark_strobe,
  ch9_config => cir(9).config,
  ch9_tconfig => cir(9).tconfig,

  ch10_ev_data_valid => cir(10).ev_data_valid,
  ch10_ev_data => cir(10).ev_data,
  ch10_dark_strobe => cir(10).dark_strobe,
  ch10_config => cir(10).config,
  ch10_tconfig => cir(10).tconfig,

  ch11_ev_data_valid => cir(11).ev_data_valid,
  ch11_ev_data => cir(11).ev_data,
  ch11_dark_strobe => cir(11).dark_strobe,
  ch11_config => cir(11).config,
  ch11_tconfig => cir(11).tconfig,

  ch12_ev_data_valid => cir(12).ev_data_valid,
  ch12_ev_data => cir(12).ev_data,
  ch12_dark_strobe => cir(12).dark_strobe,
  ch12_config => cir(12).config,
  ch12_tconfig => cir(12).tconfig,

  ch13_ev_data_valid => cir(13).ev_data_valid,
  ch13_ev_data => cir(13).ev_data,
  ch13_dark_strobe => cir(13).dark_strobe,
  ch13_config => cir(13).config,
  ch13_tconfig => cir(13).tconfig,

  ch14_ev_data_valid => cir(14).ev_data_valid,
  ch14_ev_data => cir(14).ev_data,
  ch14_dark_strobe => cir(14).dark_strobe,
  ch14_config => cir(14).config,
  ch14_tconfig => cir(14).tconfig,

  ch15_ev_data_valid => cir(15).ev_data_valid,
  ch15_ev_data => cir(15).ev_data,
  ch15_dark_strobe => cir(15).dark_strobe,
  ch15_config => cir(15).config,
  ch15_tconfig => cir(15).tconfig,

  ch16_ev_data_valid => cir(16).ev_data_valid,
  ch16_ev_data => cir(16).ev_data,
  ch16_dark_strobe => cir(16).dark_strobe,
  ch16_config => cir(16).config,
  ch16_tconfig => cir(16).tconfig,

  ch17_ev_data_valid => cir(17).ev_data_valid,
  ch17_ev_data => cir(17).ev_data,
  ch17_dark_strobe => cir(17).dark_strobe,
  ch17_config => cir(17).config,
  ch17_tconfig => cir(17).tconfig,

  ch18_ev_data_valid => cir(18).ev_data_valid,
  ch18_ev_data => cir(18).ev_data,
  ch18_dark_strobe => cir(18).dark_strobe,
  ch18_config => cir(18).config,
  ch18_tconfig => cir(18).tconfig,

  ch19_ev_data_valid => cir(19).ev_data_valid,
  ch19_ev_data => cir(19).ev_data,
  ch19_dark_strobe => cir(19).dark_strobe,
  ch19_config => cir(19).config,
  ch19_tconfig => cir(19).tconfig,

  ch20_ev_data_valid => cir(20).ev_data_valid,
  ch20_ev_data => cir(20).ev_data,
  ch20_dark_strobe => cir(20).dark_strobe,
  ch20_config => cir(20).config,
  ch20_tconfig => cir(20).tconfig,

  ch21_ev_data_valid => cir(21).ev_data_valid,
  ch21_ev_data => cir(21).ev_data,
  ch21_dark_strobe => cir(21).dark_strobe,
  ch21_config => cir(21).config,
  ch21_tconfig => cir(21).tconfig,

  ch22_ev_data_valid => cir(22).ev_data_valid,
  ch22_ev_data => cir(22).ev_data,
  ch22_dark_strobe => cir(22).dark_strobe,
  ch22_config => cir(22).config,
  ch22_tconfig => cir(22).tconfig,

  ch23_ev_data_valid => cir(23).ev_data_valid,
  ch23_ev_data => cir(23).ev_data,
  ch23_dark_strobe => cir(23).dark_strobe,
  ch23_config => cir(23).config,
  ch23_tconfig => cir(23).tconfig,

  ch24_ev_data_valid => cir(24).ev_data_valid,
  ch24_ev_data => cir(24).ev_data,
  ch24_dark_strobe => cir(24).dark_strobe,
  ch24_config => cir(24).config,
  ch24_tconfig => cir(24).tconfig,

  ch25_ev_data_valid => cir(25).ev_data_valid,
  ch25_ev_data => cir(25).ev_data,
  ch25_dark_strobe => cir(25).dark_strobe,
  ch25_config => cir(25).config,
  ch25_tconfig => cir(25).tconfig,

  ch26_ev_data_valid => cir(26).ev_data_valid,
  ch26_ev_data => cir(26).ev_data,
  ch26_dark_strobe => cir(26).dark_strobe,
  ch26_config => cir(26).config,
  ch26_tconfig => cir(26).tconfig,

  ch27_ev_data_valid => cir(27).ev_data_valid,
  ch27_ev_data => cir(27).ev_data,
  ch27_dark_strobe => cir(27).dark_strobe,
  ch27_config => cir(27).config,
  ch27_tconfig => cir(27).tconfig,

  ch28_ev_data_valid => cir(28).ev_data_valid,
  ch28_ev_data => cir(28).ev_data,
  ch28_dark_strobe => cir(28).dark_strobe,
  ch28_config => cir(28).config,
  ch28_tconfig => cir(28).tconfig,

  ch29_ev_data_valid => cir(29).ev_data_valid,
  ch29_ev_data => cir(29).ev_data,
  ch29_dark_strobe => cir(29).dark_strobe,
  ch29_config => cir(29).config,
  ch29_tconfig => cir(29).tconfig,

  ch30_ev_data_valid => cir(30).ev_data_valid,
  ch30_ev_data => cir(30).ev_data,
  ch30_dark_strobe => cir(30).dark_strobe,
  ch30_config => cir(30).config,
  ch30_tconfig => cir(30).tconfig,

  ch31_ev_data_valid => cir(31).ev_data_valid,
  ch31_ev_data => cir(31).ev_data,
  ch31_dark_strobe => cir(31).dark_strobe,
  ch31_config => cir(31).config,
  ch31_tconfig => cir(31).tconfig,

  ch32_ev_data_valid => cir(32).ev_data_valid,
  ch32_ev_data => cir(32).ev_data,
  ch32_dark_strobe => cir(32).dark_strobe,
  ch32_config => cir(32).config,
  ch32_tconfig => cir(32).tconfig,

  ch33_ev_data_valid => cir(33).ev_data_valid,
  ch33_ev_data => cir(33).ev_data,
  ch33_dark_strobe => cir(33).dark_strobe,
  ch33_config => cir(33).config,
  ch33_tconfig => cir(33).tconfig,

  ch34_ev_data_valid => cir(34).ev_data_valid,
  ch34_ev_data => cir(34).ev_data,
  ch34_dark_strobe => cir(34).dark_strobe,
  ch34_config => cir(34).config,
  ch34_tconfig => cir(34).tconfig,

  ch35_ev_data_valid => cir(35).ev_data_valid,
  ch35_ev_data => cir(35).ev_data,
  ch35_dark_strobe => cir(35).dark_strobe,
  ch35_config => cir(35).config,
  ch35_tconfig => cir(35).tconfig,

  ch36_ev_data_valid => cir(36).ev_data_valid,
  ch36_ev_data => cir(36).ev_data,
  ch36_dark_strobe => cir(36).dark_strobe,
  ch36_config => cir(36).config,
  ch36_tconfig => cir(36).tconfig,

  ch37_ev_data_valid => cir(37).ev_data_valid,
  ch37_ev_data => cir(37).ev_data,
  ch37_dark_strobe => cir(37).dark_strobe,
  ch37_config => cir(37).config,
  ch37_tconfig => cir(37).tconfig,

  ch38_ev_data_valid => cir(38).ev_data_valid,
  ch38_ev_data => cir(38).ev_data,
  ch38_dark_strobe => cir(38).dark_strobe,
  ch38_config => cir(38).config,
  ch38_tconfig => cir(38).tconfig,

  ch39_ev_data_valid => cir(39).ev_data_valid,
  ch39_ev_data => cir(39).ev_data,
  ch39_dark_strobe => cir(39).dark_strobe,
  ch39_config => cir(39).config,
  ch39_tconfig => cir(39).tconfig,

  ch40_ev_data_valid => cir(40).ev_data_valid,
  ch40_ev_data => cir(40).ev_data,
  ch40_dark_strobe => cir(40).dark_strobe,
  ch40_config => cir(40).config,
  ch40_tconfig => cir(40).tconfig,

  ch41_ev_data_valid => cir(41).ev_data_valid,
  ch41_ev_data => cir(41).ev_data,
  ch41_dark_strobe => cir(41).dark_strobe,
  ch41_config => cir(41).config,
  ch41_tconfig => cir(41).tconfig,

  ch42_ev_data_valid => cir(42).ev_data_valid,
  ch42_ev_data => cir(42).ev_data,
  ch42_dark_strobe => cir(42).dark_strobe,
  ch42_config => cir(42).config,
  ch42_tconfig => cir(42).tconfig,

  ch43_ev_data_valid => cir(43).ev_data_valid,
  ch43_ev_data => cir(43).ev_data,
  ch43_dark_strobe => cir(43).dark_strobe,
  ch43_config => cir(43).config,
  ch43_tconfig => cir(43).tconfig,

  ch44_ev_data_valid => cir(44).ev_data_valid,
  ch44_ev_data => cir(44).ev_data,
  ch44_dark_strobe => cir(44).dark_strobe,
  ch44_config => cir(44).config,
  ch44_tconfig => cir(44).tconfig,

  ch45_ev_data_valid => cir(45).ev_data_valid,
  ch45_ev_data => cir(45).ev_data,
  ch45_dark_strobe => cir(45).dark_strobe,
  ch45_config => cir(45).config,
  ch45_tconfig => cir(45).tconfig,

  ch46_ev_data_valid => cir(46).ev_data_valid,
  ch46_ev_data => cir(46).ev_data,
  ch46_dark_strobe => cir(46).dark_strobe,
  ch46_config => cir(46).config,
  ch46_tconfig => cir(46).tconfig,

  ch47_ev_data_valid => cir(47).ev_data_valid,
  ch47_ev_data => cir(47).ev_data,
  ch47_dark_strobe => cir(47).dark_strobe,
  ch47_config => cir(47).config,
  ch47_tconfig => cir(47).tconfig,

  ch48_ev_data_valid => cir(48).ev_data_valid,
  ch48_ev_data => cir(48).ev_data,
  ch48_dark_strobe => cir(48).dark_strobe,
  ch48_config => cir(48).config,
  ch48_tconfig => cir(48).tconfig,

  ch49_ev_data_valid => cir(49).ev_data_valid,
  ch49_ev_data => cir(49).ev_data,
  ch49_dark_strobe => cir(49).dark_strobe,
  ch49_config => cir(49).config,
  ch49_tconfig => cir(49).tconfig,

  ch50_ev_data_valid => cir(50).ev_data_valid,
  ch50_ev_data => cir(50).ev_data,
  ch50_dark_strobe => cir(50).dark_strobe,
  ch50_config => cir(50).config,
  ch50_tconfig => cir(50).tconfig,

  ch51_ev_data_valid => cir(51).ev_data_valid,
  ch51_ev_data => cir(51).ev_data,
  ch51_dark_strobe => cir(51).dark_strobe,
  ch51_config => cir(51).config,
  ch51_tconfig => cir(51).tconfig,

  ch52_ev_data_valid => cir(52).ev_data_valid,
  ch52_ev_data => cir(52).ev_data,
  ch52_dark_strobe => cir(52).dark_strobe,
  ch52_config => cir(52).config,
  ch52_tconfig => cir(52).tconfig,

  ch53_ev_data_valid => cir(53).ev_data_valid,
  ch53_ev_data => cir(53).ev_data,
  ch53_dark_strobe => cir(53).dark_strobe,
  ch53_config => cir(53).config,
  ch53_tconfig => cir(53).tconfig,

  ch54_ev_data_valid => cir(54).ev_data_valid,
  ch54_ev_data => cir(54).ev_data,
  ch54_dark_strobe => cir(54).dark_strobe,
  ch54_config => cir(54).config,
  ch54_tconfig => cir(54).tconfig,

  ch55_ev_data_valid => cir(55).ev_data_valid,
  ch55_ev_data => cir(55).ev_data,
  ch55_dark_strobe => cir(55).dark_strobe,
  ch55_config => cir(55).config,
  ch55_tconfig => cir(55).tconfig,

  ch56_ev_data_valid => cir(56).ev_data_valid,
  ch56_ev_data => cir(56).ev_data,
  ch56_dark_strobe => cir(56).dark_strobe,
  ch56_config => cir(56).config,
  ch56_tconfig => cir(56).tconfig,

  ch57_ev_data_valid => cir(57).ev_data_valid,
  ch57_ev_data => cir(57).ev_data,
  ch57_dark_strobe => cir(57).dark_strobe,
  ch57_config => cir(57).config,
  ch57_tconfig => cir(57).tconfig,

  ch58_ev_data_valid => cir(58).ev_data_valid,
  ch58_ev_data => cir(58).ev_data,
  ch58_dark_strobe => cir(58).dark_strobe,
  ch58_config => cir(58).config,
  ch58_tconfig => cir(58).tconfig,

  ch59_ev_data_valid => cir(59).ev_data_valid,
  ch59_ev_data => cir(59).ev_data,
  ch59_dark_strobe => cir(59).dark_strobe,
  ch59_config => cir(59).config,
  ch59_tconfig => cir(59).tconfig,

  ch60_ev_data_valid => cir(60).ev_data_valid,
  ch60_ev_data => cir(60).ev_data,
  ch60_dark_strobe => cir(60).dark_strobe,
  ch60_config => cir(60).config,
  ch60_tconfig => cir(60).tconfig,

  ch61_ev_data_valid => cir(61).ev_data_valid,
  ch61_ev_data => cir(61).ev_data,
  ch61_dark_strobe => cir(61).dark_strobe,
  ch61_config => cir(61).config,
  ch61_tconfig => cir(61).tconfig,

  ch62_ev_data_valid => cir(62).ev_data_valid,
  ch62_ev_data => cir(62).ev_data,
  ch62_dark_strobe => cir(62).dark_strobe,
  ch62_config => cir(62).config,
  ch62_tconfig => cir(62).tconfig,

  ch63_ev_data_valid => cir(63).ev_data_valid,
  ch63_ev_data => cir(63).ev_data,
  ch63_dark_strobe => cir(63).dark_strobe,
  ch63_config => cir(63).config,
  ch63_tconfig => cir(63).tconfig
);

channel_gen :for i in 0 to N_CHANNELS-1 generate
tb : process
file stim_file : text is "tb/data/stimulus_" & integer'image(i) & ".dat";
variable l : line;
variable s: string(93 downto 1);
variable d : std_logic_vector(92 downto 0);
variable t0    : time;
variable eTime : time;
begin
  cir(i).ev_data_valid <= '0';
  cir(i).ev_data <= (others => '0');
  cir(i).dark_strobe<= '0';
  cir(i).config <= (others => 'Z');
  cir(i).tconfig <= (others => 'Z');    
  wait until start_stimulus = '1';
  
  t0 := now;
  while not endfile(stim_file) loop
    readline(stim_file, l);
    read(l,s);
    d := to_std_logic_vector(s);
  
    eTime := to_integer(unsigned(d(92 downto 51))) * T1 + t0;
    if (now < eTime) then
      wait for eTime - now;
    end if;
    
    cir(i).ev_data <= 
    	d(50) & 						 -- frame ID
    	binary_to_gray(d(49 downto 40)) & -- tcoarse
    	binary_to_gray(d(39 downto 30)) & -- ecoarse 
    	binary_to_gray(d(29 downto 20)) & -- soc
    	binary_to_gray(d(19 downto 10)) & -- teoc
    	binary_to_gray(d(9 downto 0)); 	  -- eeoc
    cir(i).ev_data_valid <= '1';
    wait for T1;
    cir(i).ev_data_valid <= '0';        
  end loop;    
  wait;
  
  end process tb;  
  
  
end generate channel_gen;

clk <= not clk after T1/2;
sclk <= not sclk after T2/2;

tb : process
begin
  test_name <= xname("Reset");
  wait for 1 us;
  sync_rst <= '0';
  
  wait for 1 us;
  
  test_name <= xname("Set operation mode");
  write_gcfg(cs, sdi, sdo, FC_SUB & FC_SATURATE & b"0000" & '0' & '0' & TX_MODE);
  
  test_name <= xname("Sync");
  sync_rst <= '1';
  wait for T1;
  sync_rst <= '0';

  test_name <= xname("Stimulus");  
  start_stimulus <= '1';
  wait;  
end process tb;


  byte_clk <= not byte_clk after 5*T1;

  rx0 : process
  variable i : integer;
  variable rx_tmp : std_logic_vector(9 downto 0);
  begin
    rx_tmp := (others => '0');
    rx0_word <= (others => '0');
    while rx_tmp(9 downto 3) /= "0011111" and rx_tmp(9 downto 3) /= "1100000" loop
      rx_tmp := rx_tmp(8 downto 0) & tx0;
      wait for T1;
    end loop;
	 dec0_reset <= '0';

  
    while true loop
      rx0_word <= rx_tmp;
      for i in 0 to 9 loop
        rx_tmp := rx_tmp(8 downto 0) & tx0;
        wait for T1;
      end loop;
    end loop;
  end process;
  
  
  decoder0 : entity worklib.dec_8b10b 
    port map (
      RBYTECLK => byte_clk,
      RESET => dec0_reset,
      JI => rx0_word(0),
      HI => rx0_word(1),
      GI => rx0_word(2),
      FI => rx0_word(3),
      II => rx0_word(4),
      EI => rx0_word(5),
      DI => rx0_word(6),
      CI => rx0_word(7),
      BI => rx0_word(8),
      AI => rx0_word(9),
      
      KO => rx0_ko,
      AO => rx0_byte(0),
      BO => rx0_byte(1),
      CO => rx0_byte(2),
      DO => rx0_byte(3),
      EO => rx0_byte(4),
      FO => rx0_byte(5),
      GO => rx0_byte(6),
      HO => rx0_byte(7)
    );


rx1 : process
variable i : integer;
variable rx_tmp : std_logic_vector(9 downto 0);
begin
  rx_tmp := (others => '0');
  rx1_word <= (others => '0');
  while rx_tmp(9 downto 3) /= "0011111" and rx_tmp(9 downto 3) /= "1100000" loop
    rx_tmp := rx_tmp(8 downto 0) & tx1;
    wait for T1;
  end loop;
 dec1_reset <= '0';


  while true loop
    rx1_word <= rx_tmp;
    for i in 0 to 9 loop
      rx_tmp := rx_tmp(8 downto 0) & tx1;
      wait for T1;
    end loop;
  end loop;
end process;


decoder1 : entity worklib.dec_8b10b 
  port map (
    RBYTECLK => byte_clk,
    RESET => dec1_reset,
    JI => rx1_word(0),
    HI => rx1_word(1),
    GI => rx1_word(2),
    FI => rx1_word(3),
    II => rx1_word(4),
    EI => rx1_word(5),
    DI => rx1_word(6),
    CI => rx1_word(7),
    BI => rx1_word(8),
    AI => rx1_word(9),
    
    KO => rx1_ko,
    AO => rx1_byte(0),
    BO => rx1_byte(1),
    CO => rx1_byte(2),
    DO => rx1_byte(3),
    EO => rx1_byte(4),
    FO => rx1_byte(5),
    GO => rx1_byte(6),
    HO => rx1_byte(7)
  );
  
  rx2 : process
  variable i : integer;
  variable rx_tmp : std_logic_vector(9 downto 0);
  begin
    rx_tmp := (others => '0');
    rx2_word <= (others => '0');
    while rx_tmp(9 downto 3) /= "0011111" and rx_tmp(9 downto 3) /= "1100000" loop
      rx_tmp := rx_tmp(8 downto 0) & tx2;
      wait for T1;
    end loop;
	 dec2_reset <= '0';

  
    while true loop
      rx2_word <= rx_tmp;
      for i in 0 to 9 loop
        rx_tmp := rx_tmp(8 downto 0) & tx2;
        wait for T1;
      end loop;
    end loop;
  end process;
  
  
  decoder2 : entity worklib.dec_8b10b 
    port map (
      RBYTECLK => byte_clk,
      RESET => dec2_reset,
      JI => rx2_word(0),
      HI => rx2_word(1),
      GI => rx2_word(2),
      FI => rx2_word(3),
      II => rx2_word(4),
      EI => rx2_word(5),
      DI => rx2_word(6),
      CI => rx2_word(7),
      BI => rx2_word(8),
      AI => rx2_word(9),
      
      KO => rx2_ko,
      AO => rx2_byte(0),
      BO => rx2_byte(1),
      CO => rx2_byte(2),
      DO => rx2_byte(3),
      EO => rx2_byte(4),
      FO => rx2_byte(5),
      GO => rx2_byte(6),
      HO => rx2_byte(7)
    );
  
  rx3 : process
    variable i : integer;
    variable rx_tmp : std_logic_vector(9 downto 0);
    begin
      rx_tmp := (others => '0');
      rx3_word <= (others => '0');
      while rx_tmp(9 downto 3) /= "0011111" and rx_tmp(9 downto 3) /= "1100000" loop
        rx_tmp := rx_tmp(8 downto 0) & tx3;
        wait for T1;
      end loop;
     dec3_reset <= '0';
  
    
      while true loop
        rx3_word <= rx_tmp;
        for i in 0 to 9 loop
          rx_tmp := rx_tmp(8 downto 0) & tx3;
          wait for T1;
        end loop;
      end loop;
    end process;
    
    
    decoder3 : entity worklib.dec_8b10b 
      port map (
        RBYTECLK => byte_clk,
        RESET => dec3_reset,
        JI => rx3_word(0),
        HI => rx3_word(1),
        GI => rx3_word(2),
        FI => rx3_word(3),
        II => rx3_word(4),
        EI => rx3_word(5),
        DI => rx3_word(6),
        CI => rx3_word(7),
        BI => rx3_word(8),
        AI => rx3_word(9),
        
        KO => rx3_ko,
        AO => rx3_byte(0),
        BO => rx3_byte(1),
        CO => rx3_byte(2),
        DO => rx3_byte(3),
        EO => rx3_byte(4),
        FO => rx3_byte(5),
        GO => rx3_byte(6),
        HO => rx3_byte(7)
      );
  

  frame_verify : process
  file ver_file : text is "tb/data/verification.dat";
  variable l : line;
  variable s32: string(32 downto 1);
  variable d32 : std_logic_vector(31 downto 0);
  variable s16 : string(16 downto 1);
  variable d16 : std_logic_vector(15 downto 0);
  variable s57 : string(47 downto 1);
  variable d57 : std_logic_vector(46 downto 0);
  variable expected_frame_nevents : integer := 0;
  variable expected_frame_id : std_logic_vector(31 downto 0) := x"FFFF_FFFF";
  variable expected_frame_events : event_array_t;
  
  
  variable cf_nevents : integer;
  variable cf_bytes : integer;
  variable cf_words : integer;
  variable cf_crc16 : std_logic_vector(15 downto 0);
  variable i : integer;
  variable j : integer;
  variable d40 : std_logic_vector(39 downto 0);
  
  variable v_channel : integer;
  variable v_tcoarse : integer;
  variable v_ecoarse : integer;
  variable v_tfine : integer;
  variable v_efine : integer;
  
  variable rx_matched : integer;
  variable expected_matched : integer;
  

  begin
    rx_frame_bytes <= 0;
    -- Wait for operation mode to be set
    wait for 50*T2; wait for 500*T1;
    
    while not endfile(ver_file) loop      
      if TX_MODE = "00" then
      assert rx0_ko = '1' and rx0_byte = x"BC"
        report "K28.5 expected" severity error;
    
      wait until rx0_byte'event;
      assert rx0_ko = '1' and rx0_byte = x"3C"
        report "K28.1 expected" severity error;

      wait for 15*T1;
      assert rx0_ko = '0'
        report "Data expected" severity error;

      cf_nevents := to_integer(unsigned(rx0_byte));
      if cf_nevents = 255 then 
        cf_nevents := 0;
      end if;
      
      if cf_nevents mod 2 = 0 then
        cf_bytes := 5 + 5 * cf_nevents + 2 + 1;
      else
        cf_bytes := 5 + 5 * cf_nevents + 2;
      end if;
      
      cf_words := cf_bytes;
      
       for i in 0 to cf_words - 1 loop
        rx_frame_data(i + 0) <= rx0_byte;
        wait for 10*T1;
      end loop;              
        
      elsif TX_MODE = "01" then
        assert rx0_ko = '1' and rx0_byte = x"BC"
          and rx1_ko = '1' and rx1_byte = x"BC"
          report "K28.5 expected" severity error;
      
        wait until rx0_byte'event;
        assert rx0_ko = '1' and rx0_byte = x"3C"
          and rx1_ko = '1' and rx1_byte = x"3C"
          report "K28.1 expected" severity error;

        wait for 15*T1;
        assert rx0_ko = '0' and rx1_ko = '0' 
          report "Data expected" severity error;

        cf_nevents := to_integer(unsigned(rx0_byte));
        if cf_nevents = 255 then 
          cf_nevents := 0;
        end if;
        
        if cf_nevents mod 2 = 0 then
          cf_bytes := 5 + 5 * cf_nevents + 2 + 1;
        else
          cf_bytes := 5 + 5 * cf_nevents + 2;
        end if;
        
        cf_words := cf_bytes / 2;
        
         for i in 0 to cf_words - 1 loop
          rx_frame_data(2*i + 0) <= rx0_byte;
          rx_frame_data(2*i + 1) <= rx1_byte;
          wait for 10*T1;
        end loop;              
      else
        assert rx0_ko = '1' and rx0_byte = x"BC"
          and rx1_ko = '1' and rx1_byte = x"BC"
          and rx2_ko = '1' and rx2_byte = x"BC"
          and rx3_ko = '1' and rx3_byte = x"BC"
          report "K28.5 expected" severity error;
        
        wait until rx0_byte'event;
        assert rx0_ko = '1' and rx0_byte = x"3C"
          and rx1_ko = '1' and rx1_byte = x"3C"
          and rx2_ko = '1' and rx2_byte = x"3C"
          and rx3_ko = '1' and rx3_byte = x"3C"
          report "K28.1 expected" severity error;

        wait for 15*T1;
        assert rx0_ko = '0' and rx1_ko = '0' and rx2_ko = '0' and rx3_ko = '0'
          report "Data expected" severity error;
        
        cf_nevents := to_integer(unsigned(rx0_byte));
        if cf_nevents = 255 then 
          cf_nevents := 0;
        end if;
        
        if cf_nevents mod 2 = 0 then
          cf_bytes := 5 + 5 * cf_nevents + 2 + 1;
        else
          cf_bytes := 5 + 5 * cf_nevents + 2;
        end if;
        
        if cf_bytes mod 4 = 0 then
          cf_words := cf_bytes / 4;
        else
          cf_words := cf_bytes / 4 + 1;
        end if;
        
        for i in 0 to cf_words - 1 loop
          rx_frame_data(4*i + 0) <= rx0_byte;
          rx_frame_data(4*i + 1) <= rx1_byte;
          rx_frame_data(4*i + 2) <= rx2_byte;
          rx_frame_data(4*i + 3) <= rx3_byte;
          wait for 10*T1;
        end loop; 
      end if;
       
        
      rx_frame_nevents <= rx_frame_data(0);
      rx_frame_id <= rx_frame_data(1) & rx_frame_data(2) & rx_frame_data(3) & rx_frame_data(4);
      rx_frame_crc <= rx_frame_data(cf_bytes - 2) &  rx_frame_data(cf_bytes - 1); 
      for i in 0 to cf_nevents - 1 loop
        d40 := rx_frame_data(5*i+5) & rx_frame_data(5*i+6) 
              & rx_frame_data(5*i+7) & rx_frame_data(5*i+8) & rx_frame_data(5*i+9);
        
        assert odd_parity(d40(39 downto 1)) = d40(0) 
          report "Parity check failed" severity error;
              
        rx_frame_events(i).channel <= to_integer(unsigned(d40(7 downto 1)));
        rx_frame_events(i).efine <= to_integer(unsigned(d40(15 downto 8)));
        rx_frame_events(i).tfine <= to_integer(unsigned(d40(23 downto 16)));
        rx_frame_events(i).ecoarse <= to_integer(unsigned(d40(29 downto 24)));
        rx_frame_events(i).tcoarse <= to_integer(unsigned(d40(39 downto 30)));
        rx_frame_events(i).matched <= false;
      end loop;
      xx_frame_events <= expected_frame_events;      
      wait for T1;
      
      cf_crc16 := x"0F4A";
      for i in 0 to cf_bytes/2 - 2 loop
        cf_crc16 := crc16(cf_crc16, rx_frame_data(2*i+0) & rx_frame_data(2*i+1));
      end loop;
      assert cf_crc16 = rx_frame_crc 
        report "CRC16 check failed" severity error;
      
      assert rx_frame_id = expected_frame_id 
        report "Unexpected frame ID" severity error;
          
      assert cf_nevents <= expected_frame_nevents 
        report "Frame has more events than expected" severity error;

      rx_events_expected <= rx_events_expected + expected_frame_nevents;          
      if cf_nevents <= expected_frame_nevents then
        rx_events_received <= rx_events_received + cf_nevents;
      else
        rx_events_received <= rx_events_received + expected_frame_nevents;
      end if;

      rx_matched := 0;
      expected_matched := 0;
      
      for j in 0 to expected_frame_nevents - 1 loop
        for i in 0 to cf_nevents - 1 loop
          if (expected_frame_events(j).channel = rx_frame_events(i).channel) 
            and (expected_frame_events(j).tcoarse = rx_frame_events(i).tcoarse) 
            and (expected_frame_events(j).ecoarse = rx_frame_events(i).ecoarse)
            and (expected_frame_events(j).tfine = rx_frame_events(i).tfine)
            and (expected_frame_events(j).efine = rx_frame_events(i).efine) then
            expected_frame_events(j).matched := true;
            rx_frame_events(i).matched <= true;
            rx_matched := rx_matched + 1;
            expected_matched := expected_matched + 1;
          end if;          
        end loop;
      end loop;

      if cf_nevents = expected_frame_nevents then
        assert rx_matched = cf_nevents report "Event matching failed A" severity error;
      elsif cf_nevents < expected_frame_nevents then
        assert rx_matched = cf_nevents report "Event matching failed B" severity error;
      else
        assert rx_matched = expected_frame_nevents report "Event matching failed C" severity error;
      end if;
      
      --
      -- Load next frame events        
      --
      readline(ver_file, l);
      read(l, s32);
      expected_frame_id := to_std_logic_vector(s32);
      readline(ver_file, l);
      read(l, s16);
      expected_frame_nevents := to_integer(unsigned(to_std_logic_vector(s16)));
      for i in 0 to expected_frame_nevents - 1 loop
        readline(ver_file, l);
        read(l, s57);
        d57 := to_std_logic_vector(s57);
        v_channel := to_integer(unsigned(d57(6 downto 0)));
        v_efine := to_integer(unsigned(d57(16 downto 7)));
        v_tfine := to_integer(unsigned(d57(26 downto 17)));
        v_ecoarse := to_integer(unsigned(d57(36 downto 27)));
        v_tcoarse := to_integer(unsigned(d57(46 downto 37)));
        
        if v_ecoarse > 63 then
          v_ecoarse := 63;          
        end if;

        v_tfine := v_tfine - to_integer(unsigned(FC_SUB));
        v_efine := v_efine - to_integer(unsigned(FC_SUB));        
        
        if FC_SATURATE = '1' then
          if v_tfine < 0 then
            v_tfine := 0;
          elsif v_tfine > 255 then
            v_tfine := 255;
          end if;
          
          if v_efine < 0 then
            v_efine := 0;
          elsif v_efine > 255 then
            v_efine := 255;
          end if;
          
        else
          if v_tfine > 255 then
            v_tfine := v_tfine - 256;
          elsif v_tfine < 0 then
            v_tfine := v_tfine + 256;
          end if;

          if v_efine > 255 then
            v_efine := v_efine - 256;
          elsif v_efine < 0 then
            v_efine := v_efine + 256;
          end if;
          
        end if;
        
        assert (v_tfine >= 0) and (v_tfine <= 255)
          report "Failed to wrap time fine counter" severity error;         
        assert (v_efine >= 0) and (v_efine <= 255) 
          report "Failed to wrap energy fine counter" severity error;   
         
         expected_frame_events(i).channel := v_channel;
         expected_frame_events(i).tcoarse := v_tcoarse;
         expected_frame_events(i).ecoarse := v_ecoarse;
         expected_frame_events(i).tfine := v_tfine;
         expected_frame_events(i).efine := v_efine;
         expected_frame_events(i).matched := false;         
      end loop;
      
     
            
    end loop;
    assert false report "Simulation complete" severity failure;
    wait;
  end process frame_verify;
  
  rx_event_loss <= 100.0 * real(rx_events_expected - rx_events_received)/real(rx_events_expected) when rx_events_expected > 0 else 0.0;
  rx_events_lost <= rx_events_expected - rx_events_received;

end behavioral;

  
