library ieee, worklib, modelsim_lib;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use modelsim_lib.util.all;

entity gctrl_tb_cfg is
end gctrl_tb_cfg;

architecture rtl of gctrl_tb_cfg is
  constant T1 : time := 6.25 ns;
  constant T2 : time := 100 ns;
  
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
  signal dark_count_store : std_logic;
  signal global_tdc_dac : std_logic_vector(3 downto 0);
  signal tac_refresh_en : std_logic;
  signal tac_refresh_intv : std_logic_vector(3 downto 0);
  signal config_enable : std_logic;
  signal config_data : std_logic;
  signal test_pulse : std_logic;
  signal tdccal_pulse : std_logic;  
  signal token : std_logic_vector(0 to 128);
  signal data_avail : std_logic;
  signal data_valid : std_logic;
  signal data : std_logic_vector(58 downto 0);
  
  signal data_avail_v : std_logic_vector(0 to 127);
  
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
  
  procedure read_gcfg (
    signal cs : out std_logic; 
    signal sdo : out std_logic;
    signal sdi : in std_logic;
    data : in std_logic_vector(19 downto 0)) is
  
  variable cmd : std_logic_vector(3 downto 0);
  variable d : std_logic_vector(data'length - 1 downto 0);
  variable crc : std_logic_vector(7 downto 0);
  variable i : integer;
  begin
    cmd := "1001";
    d := data;
    crc := crc8_vector(cmd);
    cs <= '1';
    send_stream(sdo, cmd & crc);  
    assert sdi = '1' report "RDCFG: Ack Failed" severity error;
    wait for T2;
    for i in d'length - 1 downto 0 loop
      assert sdi = d(i) report "RDGCFG: Data Failed" severity error;
      wait for T2;
    end loop;
    crc := crc8_vector(data);
    for i in 7 downto 0 loop
      assert sdi = crc(i) report "RDGCFG: CRC Failed" severity error;
      wait for T2;
    end loop;
    cs <= '0';
    wait for 2*T2;   
  end read_gcfg;
  
  procedure write_chcfg (
    signal cs : out std_logic; 
    signal sdo : out std_logic;
    signal sdi : in std_logic;
    channel : in integer;
    data : in std_logic_vector(32 downto 0)) is
    
  variable d : std_logic_vector(data'length - 1 downto 0);
  variable addr : std_logic_vector(6 downto 0);
  variable crc : std_logic_vector(7 downto 0);
  variable cmd : std_logic_vector(3 downto 0);
  variable i : integer;
  begin
    d := data;
    addr := std_logic_vector(to_unsigned(channel, 7));
    cmd := "0000";
    crc := crc8_vector(cmd & addr & d);
    cs <= '1';
    send_stream(sdo, cmd & addr & data & crc);
    assert sdi = '1' report "WRCHCFG: Ack Failed" severity error;
    wait for T2;
    wait for (d'length*T2);
    cs <= '0';
    wait for 2*T2;
  end write_chcfg;
  
  procedure read_chcfg (
    signal cs : out std_logic; 
    signal sdo : out std_logic;
    signal sdi : in std_logic;
    channel : in integer;
    data : in std_logic_vector(32 downto 0)) is
    
  variable d : std_logic_vector(data'length - 1 downto 0);
  variable addr : std_logic_vector(6 downto 0);
  variable crc : std_logic_vector(7 downto 0);
  variable cmd : std_logic_vector(3 downto 0);
  variable i : integer;
  begin
    d := data;
    addr := std_logic_vector(to_unsigned(channel, 7));
    cmd := "0001";
    crc := crc8_vector(cmd & addr);
    cs <= '1';
    send_stream(sdo, cmd & addr & crc);
    assert sdi = '1' report "RDCHCFG: Ack Failed" severity error;
    wait for T2;
    for i in d'length - 1 downto 0 loop
      assert sdi = d(i) report "RDCHCFG Data Failed" severity error;
      wait for T2;
    end loop;
    crc := crc8_vector(d);
    for i in 7 downto 0 loop
      assert sdi = crc(i) report "RDCHCFG CRC Failed" severity error;
      wait for T2;
    end loop;
    cs <= '0';
    wait for 2*T2;
  end read_chcfg;
  
  procedure write_chtest (
    signal cs : out std_logic; 
    signal sdo : out std_logic;
    signal sdi : in std_logic;
    channel : in integer;
    data : in std_logic_vector(6 downto 0)) is
    
  variable d : std_logic_vector(data'length - 1 downto 0);
  variable addr : std_logic_vector(6 downto 0);
  variable crc : std_logic_vector(7 downto 0);
  variable cmd : std_logic_vector(3 downto 0);
  variable i : integer;
  begin
    d := data;
    addr := std_logic_vector(to_unsigned(channel, 7));
    cmd := "0010";
    crc := crc8_vector(cmd & addr & d);
    cs <= '1';
    send_stream(sdo, cmd & addr & data & crc);
    assert sdi = '1' report "WRCHTEST: Ack Failed" severity error;
    wait for T2;
    cs <= '0';
    wait for 10*T2;
  end write_chtest;
  
  procedure read_chtest (
    signal cs : out std_logic; 
    signal sdo : out std_logic;
    signal sdi : in std_logic;
    channel : in integer;
    data : in std_logic_vector(6 downto 0)) is
    
  variable d : std_logic_vector(data'length - 1 downto 0);
  variable addr : std_logic_vector(6 downto 0);
  variable crc : std_logic_vector(7 downto 0);
  variable cmd : std_logic_vector(3 downto 0);
  variable i : integer;
  begin
    d := data;
    addr := std_logic_vector(to_unsigned(channel, 7));
    cmd := "0011";
    crc := crc8_vector(cmd & addr);
    cs <= '1';
    send_stream(sdo, cmd & addr & crc);
    assert sdi = '1' report "RDCHTEST: Ack Failed" severity error;
    wait for T2;
    for i in d'length - 1 downto 0 loop
      assert sdi = d(i) report "RDCHTEST Data Failed" severity error;
      wait for T2;
    end loop;
    crc := crc8_vector(d);
    for i in 7 downto 0 loop
      assert sdi = crc(i) report "RDCHTEST CRC Failed" severity error;
      wait for T2;
    end loop;
    cs <= '0';
    wait for T2;
  end read_chtest;  
  
  procedure read_chdark (
    signal cs : out std_logic; 
    signal sdo : out std_logic;
    signal sdi : in std_logic;
    channel : in integer;
    data : in std_logic_vector(7 downto 0)) is
    
  variable d : std_logic_vector(data'length - 1 downto 0);
  variable addr : std_logic_vector(6 downto 0);
  variable crc : std_logic_vector(7 downto 0);
  variable cmd : std_logic_vector(3 downto 0);
  variable i : integer;
  begin
    d := data;
    addr := std_logic_vector(to_unsigned(channel, 7));
    cmd := "0100";
    crc := crc8_vector(cmd & addr);
    cs <= '1';
    send_stream(sdo, cmd & addr & crc);
    assert sdi = '1' report "RDCHTDARK: Ack Failed" severity error;
    wait for T2;
    for i in d'length - 1 downto 0 loop
      assert sdi = d(i) report "RDCHDARK: Data Failed" severity error;
      wait for T2;
    end loop;
    crc := crc8_vector(d);
    for i in 7 downto 0 loop
      assert sdi = crc(i) report "RDCHDARK CRC Failed" severity error;
      wait for T2;
    end loop;
    cs <= '0';
    wait for T2;
  end read_chdark;
  
  procedure write_testpulse (
    signal cs : out std_logic; 
    signal sdo : out std_logic;
    signal sdi : in std_logic;
    data : in std_logic_vector(17 downto 0)) is
    
  variable cmd : std_logic_vector(3 downto 0);
  variable d : std_logic_vector(data'length - 1 downto 0);
  variable crc : std_logic_vector(7 downto 0);
  variable i : integer;
  begin
    cmd := "1010";
    d := data;
    crc := crc8_vector(cmd & d);
    cs <= '1';
    send_stream(sdo, cmd & d & crc);
    assert sdi = '1' report "TEST: Ack Failed" severity error;
    wait for T2;
    cs <= '0';
    wait for 2*T2;
    
  end write_testpulse;
  
  procedure write_tdcpulse (
      signal cs : out std_logic; 
      signal sdo : out std_logic;
      signal sdi : in std_logic;
      data : in std_logic_vector(19 downto 0)) is
      
    variable cmd : std_logic_vector(3 downto 0);
    variable d : std_logic_vector(data'length - 1 downto 0);
    variable crc : std_logic_vector(7 downto 0);
    variable i : integer;
    begin
      cmd := "1011";
      d := data;
      crc := crc8_vector(cmd & d);
      cs <= '1';
      send_stream(sdo, cmd & d & crc);
      assert sdi = '1' report "TEST: Ack Failed" severity error;
      wait for T2;
      cs <= '0';
      wait for 2*T2;
      
    end write_tdcpulse;
  
  
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
  
  type channel_interface_array_t is array (0 to 127) of channel_interface_t;
  
  signal cir : channel_interface_array_t;
  
  
begin
  
  setup_signal_spy : process
  begin
    init_signal_spy("/gctrl_tb_cfg/dut/cfg_ctrl/global_cfg", "/gctrl_tb_cfg/global_config_r", 1);
    wait;
  end process setup_signal_spy;
  
  
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
    token_i => token(128),
    data_avail_i => data_avail,
    data_valid_i => data_valid,
    data_i => data
  );
  data_avail <= or_reduce(data_avail_v);
  
  channel_gen :for i in 0 to 127 generate
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
      ev_ecoarse => cir(i).ev_tcoarse,
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
      veto => '0'
    );
  end generate channel_gen;
  
  clk <= not clk after T1/2;
  sclk <= not sclk after T2/2;
  
  tb : process
  variable i : integer;
  variable ch_config : std_logic_vector(32 downto 0);
  variable ch_test_config : std_logic_vector(6 downto 0);
  begin
    test_name <= xname("Reset");
    for i in 0 to 127 loop
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
    end loop;
    wait for 10*T1; 
    sync_rst <= '0';
    
    test_name <= xname("Test pulse 1/1");
    write_testpulse(cs, sdi, sdo, x"00" & b"00" & x"00");
    wait for 1*(1+1)*T1; wait for 10*T2;

    test_name <= xname("Test pulse 16/1");
    write_testpulse(cs, sdi, sdo, x"00" & b"00" & x"0F");
    wait for 16*(1+1)*T1; wait for 10*T2;

    test_name <= xname("Test pulse 4/8");
    write_testpulse(cs, sdi, sdo, x"07" & b"00" & x"03");
    wait for 4*(1+8*128+1)*T1; wait for 10*T2;
    
    test_name <= xname("TDC cal pulse 1/1/1");
    write_tdcpulse(cs, sdi, sdo, x"00" & b"00" & x"00" & b"00");
    wait for 1*(1+1)*T1; wait for 10*T2;

    test_name <= xname("TDC cal pulse 1/1/3");
    write_tdcpulse(cs, sdi, sdo, x"00" & b"00" & x"00" & b"10");
    wait for 1*(3+1)*T1; wait for 10*T2;
    
    test_name <= xname("TDC cal pulse 16/4/3");
    write_tdcpulse(cs, sdi, sdo, x"03" & b"00" & x"0F" & b"10");
    wait for 16*(3 + 4*128+1)*T1; wait for 10*T2;
    

    
    test_name <= xname("Write Channel Config");
    i := 1;
    write_chcfg(cs, sdi, sdo, i, '1' & x"AAAA5555");
    assert (cir(i).t_tdc_dac & cir(i).e_tdc_dac & cir(i).t_th_dac & cir(i).e_th_dac & cir(i).gain_dac & cir(i).ch_enable) = ('1' & x"AAAA5555")
      report "Failed to set channel configuration" severity error; 
    wait for T2;
    read_chcfg(cs, sdi, sdo, i, '1' & x"AAAA5555");    
    wait for 50*T2;
    
    test_name <= xname("Set Training mode");
    write_gcfg(cs, sdi, sdo, b"0000_0000_0_11_00000_0000");
    wait for 50*T2;
    test_name <= xname("Set x2 Operation");
    write_gcfg(cs, sdi, sdo, b"0000_0000_0_01_00000_0000");
    wait for 50*T2;
    test_name <= xname("Set x4 Operation");
    write_gcfg(cs, sdi, sdo, b"0000_0000_0_10_00000_0000");
    wait for 50*T2;
    test_name <= xname("Set x1 Operation");
    write_gcfg(cs, sdi, sdo, b"0000_0000_0_00_00000_0000");
    wait for 50*T2;

    test_name <= xname("Set Global Config");
    write_gcfg(cs, sdi, sdo, b"0000_0000_0_00_01111_1100");
    read_gcfg(cs, sdi, sdo, b"0000_0000_0_00_01111_1100");
    assert tac_refresh_en & tac_refresh_intv & global_tdc_dac = b"01111_1100" 
      report "Failed to set global config" severity error;
    assert global_config_r = b"0000_0000_0_00_01111_1100" 
      report "Failed to set global config" severity error;
    write_gcfg(cs, sdi, sdo, b"0000_0000_0_00_10011_1001");
    read_gcfg(cs, sdi, sdo, b"0000_0000_0_00_10011_1001");
    assert tac_refresh_en & tac_refresh_intv & global_tdc_dac = b"10011_1001" 
      report "Failed to set global config" severity error;
    assert global_config_r = b"0000_0000_0_00_10011_1001"
      report "Failed to set global config" severity error;
    wait for 50*T2;
    
    test_name <= xname("Dark count read");
    cir(0).dark_count <= '1';
    wait for 9*T1;
    cir(0).dark_count <= '0';
    wait until dark_count_store = '1';
    read_chdark(cs, sdi, sdo, 0, std_logic_vector(to_unsigned(9, 8)));
    wait for 50*T2;
    
        
    test_name <= xname("Batch Channel Config 1");
    for i in 0 to 127 loop
      ch_config := '1' & x"AAA" & std_logic_vector(to_unsigned(i, 8)) & x"555";
      write_chcfg(cs, sdi, sdo, i, ch_config);
      read_chcfg(cs, sdi, sdo, i, ch_config);
    end loop;
    for i in 0 to 127 loop
      ch_config := '1' & x"AAA" & std_logic_vector(to_unsigned(i, 8)) & x"555";
      assert cir(i).t_tdc_dac & cir(i).e_tdc_dac & cir(i).t_th_dac & cir(i).e_th_dac & cir(i).gain_dac & cir(i).ch_enable = ch_config
        report "Failed to set channel configuration" severity error;      
    end loop;
    
    test_name <= xname("Batch Channel Config 2");
    for i in 0 to 127 loop
      ch_config := '0' & x"555" & std_logic_vector(to_unsigned(i, 8)) & x"AAA";
      write_chcfg(cs, sdi, sdo, i, ch_config);
      read_chcfg(cs, sdi, sdo, i, ch_config);
    end loop;
    for i in 0 to 127 loop
      ch_config := '0' & x"555" & std_logic_vector(to_unsigned(i, 8)) & x"AAA";
      assert cir(i).t_tdc_dac & cir(i).e_tdc_dac & cir(i).t_th_dac & cir(i).e_th_dac & cir(i).gain_dac & cir(i).ch_enable = ch_config
        report "Failed to set channel configuration" severity error;      
    end loop;
    
    test_name <= xname("Batch Channel Test Config 1");
    for i in 0 to 127 loop
      ch_test_config := std_logic_vector(to_unsigned(i, 7));
      write_chtest(cs, sdi, sdo, i, ch_test_config);
      read_chtest(cs, sdi, sdo, i, ch_test_config);
      assert cir(i).tp_amp_dac & cir(i).ch_test_mode = ch_test_config 
        report "Failed to set channel test configuration" severity error;      
    end loop;
    test_name <= xname("Batch Channel Test Config 2");
    for i in 0 to 127 loop
      ch_test_config := not std_logic_vector(to_unsigned(i, 7));
      write_chtest(cs, sdi, sdo, i, ch_test_config);
      read_chtest(cs, sdi, sdo, i, ch_test_config);
      assert cir(i).tp_amp_dac & cir(i).ch_test_mode = ch_test_config 
        report "Failed to set channel test configuration" severity error;      
    end loop;
    
    assert false report "Simulation completed" severity failure;
    wait;
  end process tb;
  
end rtl;

