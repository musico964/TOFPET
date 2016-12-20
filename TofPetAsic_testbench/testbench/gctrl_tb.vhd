library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gctrl_tb is
end gctrl_tb;

architecture behavioral of gctrl_tb is
  
  
constant T : time := 6.25 ns;
signal clk_i : std_logic := '0';
signal sync_rst_i : std_logic;

signal sclk_i : std_logic := '0';
signal sdi_i : std_logic := '0';
signal sdo_o : std_logic;
signal cs_i : std_logic := '0';

signal tx0_o : std_logic;
signal tx1_o : std_logic;
signal tx2_o : std_logic;
signal tx3_o : std_logic;

signal sync_o : std_logic;
signal reset_o : std_logic;
signal frame_id_o : std_logic;
signal ctime_o : std_logic_vector(9 downto 0);
signal dark_count_store_o : std_logic;

signal global_tdc_dac_o : std_logic_vector(3 downto 0);
signal tac_refresh_en_o : std_logic;
signal tac_refresh_intv_o : std_logic_vector(3 downto 0);

signal config_enable_o : std_logic;
signal config_data_io : std_logic;

signal token_o : std_logic;
signal token_i : std_logic := '0';
signal data_avail_i : std_logic := '0';
signal data_i : std_logic_vector(58 downto 0);
signal data_valid_i : std_logic;

signal test_pulse_o : std_logic;
signal tdccal_pulse_o : std_logic;

signal rx_tmp : std_logic_vector(9 downto 0);
signal rx_word : std_logic_vector(9 downto 0);
signal byte_clk : std_logic := '0';
signal ko : std_logic;
signal byte : std_logic_vector(7 downto 0);

signal frame_size : std_logic_vector(7 downto 0);
signal frame_id : std_logic_vector(31 downto 0);
signal event_data : std_logic_vector(39 downto 0);

signal enc_reset : std_logic := '1';
  
begin
  
  dut : entity worklib.gctrl 
  port map (
    clk_i => clk_i,
    sync_rst_i => sync_rst_i,
    sclk_i => sclk_i,
    sdi_i => sdi_i,
    sdo_o => sdo_o,
    cs_i => cs_i,
    tx0_o => tx0_o,
    tx1_o => tx1_o,
    tx2_o => tx2_o,
    tx3_o => tx3_o,
    sync_o => sync_o,
    reset_o => reset_o,
    frame_id_o => frame_id_o,
    ctime_o => ctime_o,
    dark_count_store_o => dark_count_store_o,
    global_tdc_dac_o => global_tdc_dac_o,
    tac_refresh_en_o => tac_refresh_en_o,
    tac_refresh_intv_o => tac_refresh_intv_o,
    config_enable_o => config_enable_o,
    config_data_io => config_data_io,
    token_o => token_o,
    token_i => token_i,
    data_avail_i => data_avail_i,
    data_i => data_i,
    data_valid_i => data_valid_i,
    test_pulse_o => test_pulse_o,
    tdccal_pulse_o => tdccal_pulse_o
  );
  
  
  clk_i <= not clk_i after T/2;
  
  tb : process
  begin
    sync_rst_i <= '1';
    wait for 20*T;
    sync_rst_i <= '0';
    
    wait;    
  end process;
  
  
  rx : process
  variable i : integer;
  begin
    rx_tmp <= (others => '0');
    rx_word <= (others => '0');
    while rx_tmp(9 downto 3) /= "0011111" and rx_tmp(9 downto 3) /= "1100000" loop
      rx_tmp <= rx_tmp(8 downto 0) & tx0_o;
      wait for T;
    end loop;
	 enc_reset <= '0';

  
    while true loop
      rx_word <= rx_tmp;
      for i in 0 to 9 loop
        rx_tmp <= rx_tmp(8 downto 0) & tx0_o;
        wait for T;
      end loop;
    end loop;
  end process;
  
  byte_clk <= not byte_clk after 5*T;
  
  decoder : entity worklib.dec_8b10b 
  port map (
    RBYTECLK => byte_clk,
    RESET => enc_reset,
    JI => rx_word(0),
    HI => rx_word(1),
    GI => rx_word(2),
    FI => rx_word(3),
    II => rx_word(4),
    EI => rx_word(5),
    DI => rx_word(6),
    CI => rx_word(7),
    BI => rx_word(8),
    AI => rx_word(9),
    
    KO => ko,
    AO => byte(0),
    BO => byte(1),
    CO => byte(2),
    DO => byte(3),
    EO => byte(4),
    FO => byte(5),
    GO => byte(6),
    HO => byte(7)
  );
  
  frame_decode : process 
  variable i : integer;
  variable j : integer;
  variable frame_id_tmp : std_logic_vector(31 downto 0);
  variable event_data_tmp : std_logic_vector(39 downto 0);
  begin
    wait for 512 * T;
    while true loop
      if ko /= '0' then 
        wait until ko = '0';
        wait for T/2;
      end if;
      
      
      event_data <= (others => '0');
      if byte = x"FF" then
        frame_size <= x"00";
      else
        frame_size <= byte;
      end if;
      wait for 10*T;

        
      for i in 4 downto 1 loop
        frame_id_tmp := frame_id_tmp(23 downto 0) & byte;
        wait for 10*T;
      end loop;
      frame_id <= frame_id_tmp;
      
      for j in to_integer(unsigned(frame_size)) - 1 downto 0 loop
        for i in 5 downto 1 loop
          event_data_tmp := event_data_tmp(31 downto 0) & byte;
          wait for 10*T;
        end loop;
        event_data <= event_data_tmp;
      end loop;
      
      if to_integer(unsigned(frame_size)) mod 2 = 0 then
        wait for 10 * T;
      end if;
      wait for 20 * T;
       
    end loop;    
  end process;
  
  
  send_events  : process
  variable i : integer;
  begin
    token_i <= '0';
    data_i <= (others => 'Z');    
    data_valid_i <= 'Z';
    data_avail_i <= '0';
    wait for 20*T;

    wait for 2048 * T;
    data_avail_i <= '1';
    wait until token_o = '1';
    wait for T;
    data_i <= (others => '0');
    data_valid_i <= '0';
    wait for T;
    data_i <= "101" & x"A5A5_A5A5_A5A5_A5";
    data_valid_i <= '1' ;
    data_avail_i <= '0';
    wait for T;
    token_i <= '1';
    data_i <= (others => '0');
    data_valid_i <= '0';
    wait for T;
    token_i <= '0';
    
    wait for 2048 *T;
    data_avail_i <= '1';
    wait until token_o = '1';
    wait for T;
    data_i <= (others => '0');
    data_valid_i <= '0';
    wait for T;
    for i in 0 to 127 loop 
      data_i <= std_logic_vector(to_unsigned(i, 7)) & x"0_01_02_03_04_05_06";
      data_valid_i <= '1' ;
      data_avail_i <= '0';
      wait for T;
    end loop;
    token_i <= '1';
    data_i <= (others => '0');
    data_valid_i <= '0';
    wait for T;
    token_i <= '0';
    
    
    wait;
  end process;
  
end behavioral;
