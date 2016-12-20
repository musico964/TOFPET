library ieee, worklib;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

--library modelsim_lib;
--use modelsim_lib.util.all;

library NCUTILS;
use NCUTILS.ncutilities.all;

entity gctrl_tb_data is
end gctrl_tb_data;

architecture rtl of gctrl_tb_data is
  constant N_CHANNELS : integer := 64;
  constant T1 : time := 6.25 ns;
  constant T2 : time := 100 ns;
  constant TX_MODE : std_logic_vector := b"00";
  constant FC_SATURATE : std_logic := '1';
  constant FC_SUB : std_logic_vector(7 downto 0) := x"B0";
  
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
  signal veto : std_logic;
  signal frame_id : std_logic;
  signal ctime : std_logic_vector(9 downto 0);
  signal dark_count_store : std_logic;
  signal global_tdc_dac : std_logic_vector(3 downto 0);
  signal tac_refresh_en : std_logic;
  signal tac_refresh_intv : std_logic_vector(3 downto 0);
  signal config_enable : std_logic;
  signal config_data : std_logic;
  signal test_pulse : std_logic;
  signal tdccal_pulse : std_logic;  
  signal token : std_logic_vector(0 to N_CHANNELS);
  signal data_avail : std_logic;
  signal data_valid : std_logic;
  signal data : std_logic_vector(58 downto 0);
  
  signal data_avail_v : std_logic_vector(0 to N_CHANNELS-1);
  
  signal global_config_r : std_logic_vector(19 downto 0);
  
  
  function or_reduce(x : std_logic_vector) return std_logic is
  variable d : std_logic_vector(x'length-1 downto 0);
  variable n : integer;
  begin
    d := x;
    if d'length = 1 then 
      return d(0);
    else
      n := d'length/2;
      return or_reduce(d(d'length - 1 downto n)) or or_reduce(d(n-1 downto 0));
    end if;
  end or_reduce;
  
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
    data : in std_logic_vector(19 downto 0)) is
    
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
  
  type channel_interface_t is record
    ev_valid : std_logic;
    ev_frame_id : std_logic;
    ev_tcoarse : std_logic_vector(9 downto 0);
    ev_teoc : std_logic_vector(9 downto 0);
    ev_soc : std_logic_vector(9 downto 0);
    ev_ecoarse : std_logic_vector(9 downto 0);
    ev_eeoc : std_logic_vector(9 downto 0);
    dark_count : std_logic;
    t_tdc_dac : std_logic_vector(3 downto 0);
    e_tdc_dac : std_logic_vector(3 downto 0);
    t_th_dac    : std_logic_vector(7 downto 0);
    e_th_dac    : std_logic_vector(7 downto 0);
    gain_dac    :  std_logic_vector(7 downto 0);
    ch_enable   :  std_logic;
    tp_amp_dac : std_logic_vector(5 downto 0);
    ch_test_mode : std_logic;   
    
  end record;
  
  type channel_interface_array_t is array (0 to N_CHANNELS-1) of channel_interface_t;
  
  signal cir : channel_interface_array_t;
  
 
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

dut : entity worklib.gctrl 
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
  veto_o => veto,
  frame_id_o => frame_id,
  ctime_o => ctime,
  dark_count_store_o => dark_count_store,
  global_tdc_dac_o => global_tdc_dac,
  tac_refresh_en_o => tac_refresh_en,
  tac_refresh_intv_o => tac_refresh_intv,
  config_enable_o => config_enable,
  config_data_io => config_data,
  test_pulse_o => test_pulse,
  tdccal_pulse_o => tdccal_pulse,
  token_o => token(0),
  token_i => token(N_CHANNELS),
  data_avail_i => data_avail,
  data_valid_i => data_valid,
  data_i => data
);
data_avail <= or_reduce(data_avail_v);

channel_gen :for i in 0 to N_CHANNELS-1 generate
  channel : entity worklib.ch_ctrl
  port map (
    clk => clk,
    sclk => sclk,
    reset => reset,
    sync => sync,
    address => std_logic_vector(to_unsigned(i, 7)),
    frame_id => frame_id,
    coarse_time => ctime,
    dark_count_store_i => dark_count_store,
    tac_refresh_en => tac_refresh_en,
    tac_refresh_intv => tac_refresh_intv,
    config_enable => config_enable,
    config_data => config_data,
    test_pulse => test_pulse,
    tdc_calibrate => tdccal_pulse,

    ev_valid => cir(i).ev_valid,
    ev_frame_id => cir(i).ev_frame_id,
    ev_tcoarse => cir(i).ev_tcoarse,
    ev_teoc => cir(i).ev_teoc,
    ev_soc => cir(i).ev_soc,
    ev_ecoarse => cir(i).ev_ecoarse,
    ev_eeoc => cir(i).ev_eeoc,
    dark_count_strobe => cir(i).dark_count,
    
    t_tdc_dac => cir(i).t_tdc_dac,
    e_tdc_dac => cir(i).e_tdc_dac,
    t_th_dac => cir(i).t_th_dac, 
    e_th_dac => cir(i).e_th_dac,
    gain_dac => cir(i).gain_dac,
    ch_enable => cir(i).ch_enable,
    
    ch_test_mode => cir(i).ch_test_mode,
    tp_amp_dac => cir(i).tp_amp_dac,
    
    token_in => token(i),
    token_out => token(i+1),
    data_available => data_avail_v(i),
    data_valid => data_valid,
    data => data,
    veto => veto
  );
  
tb : process
file stim_file : text is "tb/data/stimulus_" & integer'image(i) & ".dat";
variable l : line;
variable s: string(93 downto 1);
variable d : std_logic_vector(92 downto 0);
variable t0    : time;
variable eTime : time;
begin
  cir(i).ev_valid <= '0';
  cir(i).dark_count <= '0';
  cir(i).ch_enable <= 'Z';
  cir(i).gain_dac <= (others => 'Z');
  cir(i).e_th_dac <= (others => 'Z');
  cir(i).t_th_dac <= (others => 'Z');
  cir(i).e_tdc_dac <= (others => 'Z');
  cir(i).t_tdc_dac <= (others => 'Z');
  cir(i).ch_test_mode <= 'Z';
  cir(i).tp_amp_dac <= (others => 'Z');  
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
    
    cir(i).ev_frame_id <= d(50);    
    cir(i).ev_tcoarse <= binary_to_gray(d(49 downto 40));
    cir(i).ev_ecoarse <= binary_to_gray(d(39 downto 30));    
    cir(i).ev_soc <= binary_to_gray(d(29 downto 20));
    cir(i).ev_teoc <= binary_to_gray(d(19 downto 10));
    cir(i).ev_eeoc <= binary_to_gray(d(9 downto 0));
    cir(i).ev_valid <= '1';
    wait for T1;
    cir(i).ev_valid <= '0';        
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
  write_gcfg(cs, sdi, sdo, FC_SUB & FC_SATURATE & TX_MODE & b"00000_0000");
  
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

end rtl;

  
