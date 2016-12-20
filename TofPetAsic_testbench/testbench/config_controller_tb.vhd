LIBRARY ieee  ; 
USE ieee.numeric_std.all  ; 
USE ieee.std_logic_1164.all  ; 
ENTITY config_controller_tb  IS 
END ; 
 
ARCHITECTURE config_controller_tb_arch OF config_controller_tb IS
  constant T : time := 1 us;
  
  
  COMPONENT config_controller  
    PORT ( 
    -- external interface
    sclk      : in std_logic;
    cs        : in std_logic;
    sdi       : in std_logic;
    sdo       : out std_logic;
    sdo_oe    : out std_logic;
    
    -- reset
    reset     : in std_logic;
    
    -- Global configuration registers
    global_tdc_coarse_ib: out std_logic_vector(3 downto 0);
    tx_mode         		  : out std_logic_vector(1 downto 0);
    tac_refresh_en      : out std_logic;
    tac_refresh_intv    : out std_logic_vector(3 downto 0);
    
    -- Channel configuration interface
    cfg_enable      : out std_logic;
    cfg_data        : inout std_logic;
      -- These signals will reuse the 10 bit frame/coarse time bus
    cfg_cmd         : out std_logic_vector(2 downto 0);
    cfg_address     : out std_logic_vector(6 downto 0);
    
    -- Pulse generator interface
    pulse_type      : out std_logic;
    pulse_length    : out std_logic_vector(1 downto 0);
    pulse_number    : out std_logic_vector(9 downto 0);
    pulse_intv      : out std_logic_vector(7 downto 0);
    pulse_strobe    : out std_logic

    
  );
  END COMPONENT ;  
  
  
  component ch_cfg_ctrl 
    port (
    sclk          : in std_logic;
    reset         : in std_logic;
    address       : in std_logic_vector(6 downto 0);
    cfg_enable    : in std_logic;
    cfg_address   : in std_logic_vector(6 downto 0);
    cfg_cmd       : in std_logic_vector(2 downto 0);
    cfg_data      : inout std_logic;
    --    
    cfg           : out std_logic_vector(32 downto 0);
    test_cfg      : out std_logic_vector(6 downto 0);
    dark_counter  : in std_logic_vector(7 downto 0)
    );
  end component;

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
    sdo <= d(i); wait for T;
  end loop;
end send_stream;


procedure write_gcfg (
  signal cs : out std_logic; 
  signal sdo : out std_logic;
  signal sdi : in std_logic;
  data : in std_logic_vector(10 downto 0)) is
  
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
  wait for T;
  cs <= '0';
  wait for T;
  
end write_gcfg;

procedure read_gcfg (
  signal cs : out std_logic; 
  signal sdo : out std_logic;
  signal sdi : in std_logic;
  data : in std_logic_vector(10 downto 0)) is

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
  wait for T;
  for i in d'length - 1 downto 0 loop
    assert sdi = d(i) report "RDGCFG: Data Failed" severity error;
    wait for T;
  end loop;
  crc := crc8_vector(data);
  for i in 7 downto 0 loop
    assert sdi = crc(i) report "RDGCFG: CRC Failed" severity error;
    wait for T;
  end loop;
  cs <= '0';   
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
  wait for T;
  cs <= '0';
  wait for 45*T;
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
  wait for T;
  for i in d'length - 1 downto 0 loop
    assert sdi = d(i) report "RDCHCFG Data Failed" severity error;
    wait for T;
  end loop;
  crc := crc8_vector(d);
  for i in 7 downto 0 loop
    assert sdi = crc(i) report "RDCHCFG CRC Failed" severity error;
    wait for T;
  end loop;
  cs <= '0';
  wait for T;
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
  wait for T;
  cs <= '0';
  wait for 10*T;
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
  wait for T;
  for i in d'length - 1 downto 0 loop
    assert sdi = d(i) report "RDCHTEST Data Failed" severity error;
    wait for T;
  end loop;
  crc := crc8_vector(d);
  for i in 7 downto 0 loop
    assert sdi = crc(i) report "RDCHTEST CRC Failed" severity error;
    wait for T;
  end loop;
  cs <= '0';
  wait for T;
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
  wait for T;
  for i in d'length - 1 downto 0 loop
    assert sdi = d(i) report "RDCHDARK: Data Failed" severity error;
    wait for T;
  end loop;
  crc := crc8_vector(d);
  for i in 7 downto 0 loop
    assert sdi = crc(i) report "RDCHDARK CRC Failed" severity error;
    wait for T;
  end loop;
  cs <= '0';
  wait for T;
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
  wait for T;
  cs <= '0';
  wait for T;
  
end write_testpulse;

procedure write_tdccalpulse (
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
  wait for T;
  cs <= '0';
  wait for T;
  
end write_tdccalpulse;



signal sclk      : std_logic := '0';
signal cs        : std_logic;
signal sdi       : std_logic;
signal sdo       : std_logic;
signal sdo_oe    : std_logic;
signal reset     : std_logic;
signal global_tdc_coarse_ib: std_logic_vector(3 downto 0);
signal tx_mode         		  : std_logic_vector(1 downto 0);
signal tac_refresh_en      : std_logic;
signal tac_refresh_intv    : std_logic_vector(3 downto 0);
signal cfg_enable      : std_logic;
signal cfg_data        : std_logic;
signal cfg_cmd         : std_logic_vector(2 downto 0);
signal cfg_address     : std_logic_vector(6 downto 0);
signal pulse_type      : std_logic;
signal pulse_length    : std_logic_vector(1 downto 0);
signal pulse_number    : std_logic_vector(9 downto 0);
signal pulse_intv      : std_logic_vector(7 downto 0);
signal pulse_strobe    : std_logic;


signal gcfg : std_logic_vector(10 downto 0);
signal pulse_data : std_logic_vector(20 downto 0);

type ch_cfg_array_t is array (0 to 127) of std_logic_vector(32 downto 0); 
signal ch_cfg_array : ch_cfg_array_t;

type ch_test_cfg_array_t is array(0 to 127) of std_logic_vector(6 downto 0);
signal ch_test_cfg_array : ch_test_cfg_array_t;

type ch_dark_array_t is array (0 to 127) of std_logic_vector(7 downto 0);
signal ch_dark_array : ch_dark_array_t;

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
  
BEGIN
  DUT  : config_controller  
    PORT MAP ( 
      sdi   => sdi  ,
      cfg_address   => cfg_address  ,
      cfg_data   => cfg_data  ,
      sclk   => sclk  ,
      cfg_enable   => cfg_enable  ,
      global_tdc_coarse_ib   => global_tdc_coarse_ib,
      sdo   => sdo  ,
      sdo_oe => sdo_oe,
      cs   => cs  ,
      cfg_cmd   => cfg_cmd  ,
      tx_mode => tx_mode,
      reset   => reset,
      tac_refresh_en => tac_refresh_en,
      tac_refresh_intv => tac_refresh_intv,
      pulse_type => pulse_type,
      pulse_length => pulse_length,
      pulse_number => pulse_number,
      pulse_intv => pulse_intv,
      pulse_strobe => pulse_strobe
    ) ; 
    
  
  channel_gen : for n in 0 to 127 generate
    
    ch_array : ch_cfg_ctrl 
    port map (
      sclk => sclk,
      reset => reset,
      address => std_logic_vector(to_unsigned(n, 7)),
      cfg_enable => cfg_enable,
      cfg_address => cfg_address,
      cfg_cmd => cfg_cmd,
      cfg_data => cfg_data,
      
      dark_counter => ch_dark_array(n),
      cfg => ch_cfg_array(n),
      test_cfg => ch_test_cfg_array(n)
    );
  end generate channel_gen;
    
  sclk <= not sclk after T/2;
  
  
  gcfg <= tx_mode & tac_refresh_en & tac_refresh_intv & global_tdc_coarse_ib;
  
  pulse_data <= pulse_type & pulse_length & pulse_intv & pulse_number;
  
  tb : process
  
  variable i : integer;
  variable ch_config : std_logic_vector(32 downto 0);
  variable ch_test_config : std_logic_vector(6 downto 0);
  begin
    test_name <= xname("Reset");
    cfg_data <= 'Z';
    reset <= '1';
    cs  <= '0';
    wait for 2*T;
    reset <= '0';    
    
    
    test_name <= xname("Test pulse 1");
    write_testpulse(cs, sdi, sdo, "01" & x"5555");
    assert pulse_data = '0' & "01" & "01" & x"5555" report "TEST Failed" severity error;
    wait for 50*T;
    
    test_name <= xname("Test pulse 2");
    write_testpulse(cs, sdi, sdo, "10" & x"AAAA");
    assert pulse_data = '0' & "01" & "10" & x"AAAA" report "TEST Failed" severity error;    
    wait for 50*T;
    
    test_name <= xname("TDC CAL 1");
    write_tdccalpulse(cs, sdi, sdo, "1001" & x"5555");
    assert pulse_data = '1' & "1001" & x"5555" report "TDCCAL Failed" severity error;    
    wait for 50*T;
    
    test_name <= xname("TDC CAL 2");
    write_tdccalpulse(cs, sdi, sdo, "0110" & x"AAAA");
    assert pulse_data = '1' & "0110" & x"AAAA" report "TDCCAL Failed" severity error;    
    wait for 50*T;
    
    
    
    test_name <= xname("Write Global Config");
    write_gcfg(cs, sdi, sdo, "10101010101");
    assert gcfg = "10101010101" report "WRGCFG Failed" severity error;
    wait for 50*T;
    
    test_name <= xname("Read back Global Config");
    read_gcfg(cs, sdi, sdo, "10101010101");
    assert gcfg = "10101010101" report "RDGCFG Failed" severity error;
    wait for 50*T;
    
    test_name <= xname("Write Global Config");
    write_gcfg(cs, sdi, sdo, "01010101010");
    assert gcfg = "01010101010" report "WRGCFG Failed" severity error;
    wait for 50*T;
    
    test_name <= xname("Read back Global Config");
    read_gcfg(cs, sdi, sdo, "01010101010");
    assert gcfg = "01010101010" report "RDGCFG Failed" severity error;
    wait for 50*T;
    
    
    
    test_name <= xname("Write Channel Config");
    write_chcfg(cs, sdi, sdo, 127, '1' & x"AAAA5555");
    assert ch_cfg_array(127) = '1' & x"AAAA5555" report "WRCHCFG Failed" severity error;
    wait for 50*T;

    test_name <= xname("Read back Channel  Config");
    read_chcfg(cs, sdi, sdo, 127, '1' & x"AAAA5555");
    assert ch_cfg_array(127) = '1' & x"AAAA5555" report "RDCHCFG Failed" severity error;
    wait for 50*T;
    
    
    test_name <= xname("Write Channel  Test Config");
    write_chtest(cs, sdi, sdo, 1, "1000101");
    assert ch_test_cfg_array(1) = "1000101" report "WRCHTEST Failed" severity error;
    wait for 50*T;
    
    test_name <= xname("Read back Channel  Test Config");
    read_chtest(cs, sdi, sdo, 1, "1000101");
    assert ch_test_cfg_array(1) = "1000101" report "RDCHTEST Failed" severity error;
    wait for 50*T;
    
    
    test_name <= xname("Read Channel  Dark Count");
    ch_dark_array(2) <= x"4F";
    read_chdark(cs, sdi, sdo, 2, x"4F");
    wait for 50*T;
    
    
    test_name <= xname("Batch Channel Config 1");
    for i in 0 to 127 loop
      ch_config := '1' & x"AAA" & std_logic_vector(to_unsigned(i, 8)) & x"555";
      write_chcfg(cs, sdi, sdo, i, ch_config);
    end loop;
    for i in 127 downto 0 loop
      ch_config := '1' & x"AAA" & std_logic_vector(to_unsigned(i, 8)) & x"555";
      assert ch_cfg_array(i) = ch_config report "Batch write failed" severity error;
    end loop;
    for i in 127 downto 0 loop
      ch_config := '1' & x"AAA" & std_logic_vector(to_unsigned(i, 8)) & x"555";
      read_chcfg(cs, sdi, sdo, i, ch_config);
    end loop;
    for i in 0 to 127  loop
      ch_config := '1' & x"AAA" & std_logic_vector(to_unsigned(i, 8)) & x"555";
      assert ch_cfg_array(i) = ch_config report "Batch write failed" severity error;
    end loop;
    
    test_name <= xname("Batch Channel Config 2");
    for i in 0 to 127 loop
      ch_config := '0' & x"555" & std_logic_vector(to_unsigned(i, 8)) & x"AAA";
      write_chcfg(cs, sdi, sdo, i, ch_config);
    end loop;
    for i in 127 downto 0 loop
      ch_config := '0' & x"555" & std_logic_vector(to_unsigned(i, 8)) & x"AAA";
      assert ch_cfg_array(i) = ch_config report "Batch write failed" severity error;
    end loop;
    for i in 127 downto 0 loop
      ch_config := '0' & x"555" & std_logic_vector(to_unsigned(i, 8)) & x"AAA";
      read_chcfg(cs, sdi, sdo, i, ch_config);
    end loop;
    for i in 0 to 127  loop
      ch_config := '0' & x"555" & std_logic_vector(to_unsigned(i, 8)) & x"AAA";
      assert ch_cfg_array(i) = ch_config report "Batch write failed" severity error;
    end loop;
    
    
    test_name <= xname("Batch Channel Test Config 1");
    for i in 0 to 127 loop
      ch_test_config := std_logic_vector(to_unsigned(i, 7));
      write_chtest(cs, sdi, sdo, i, ch_test_config);
    end loop;
    for i in 0 to 127 loop
      ch_test_config := std_logic_vector(to_unsigned(i, 7));
      assert ch_test_cfg_array(i) = ch_test_config report "Batch Write failed" severity error;
    end loop;
    for i in 0 to 127 loop
      ch_test_config := std_logic_vector(to_unsigned(i, 7));
      read_chtest(cs, sdi, sdo, i, ch_test_config);
    end loop;
    for i in 0 to 127 loop
      ch_test_config := std_logic_vector(to_unsigned(i, 7));
      assert ch_test_cfg_array(i) = ch_test_config report "Batch Write failed" severity error;
    end loop;

    test_name <= xname("Batch Channel Test Config 2");
    for i in 0 to 127 loop
      ch_test_config := std_logic_vector(to_unsigned(127-i, 7));
      write_chtest(cs, sdi, sdo, i, ch_test_config);
    end loop;
    for i in 0 to 127 loop
      ch_test_config := std_logic_vector(to_unsigned(127-i, 7));
      assert ch_test_cfg_array(i) = ch_test_config report "Batch Write failed" severity error;
    end loop;
    for i in 0 to 127 loop
      ch_test_config := std_logic_vector(to_unsigned(127-i, 7));
      read_chtest(cs, sdi, sdo, i, ch_test_config);
    end loop;
    for i in 0 to 127 loop
      ch_test_config := std_logic_vector(to_unsigned(127-i, 7));
      assert ch_test_cfg_array(i) = ch_test_config report "Batch Write failed" severity error;
    end loop;

      
    wait for T; wait;
  end process;
  


  
END ; 

