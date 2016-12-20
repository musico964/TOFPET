library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity frame_block_tb is
end frame_block_tb;

architecture behavioral of frame_block_tb is
  
  component frame_block is
  generic (
    BUFFER_SIZE :  integer := 128;
    FIFO_AW : integer := 12
  );
  port (
    clk       : in std_logic;
    reset     : in std_logic;
    sync      : in std_logic;
    
    ctime     : in std_logic_vector(41 downto 0);
    
    data_in         : in std_logic_vector(39 downto 0);
    data_in_frameid : in std_logic;
    data_in_valid   : in std_logic;
    
    q           : out std_logic_vector(17 downto 0);
    wrreq       : out std_logic;
    words_avail : in std_logic_vector(9 downto 0)
  );
    
end component;

constant T : time := 6.25 ns;
constant BUFFER_SIZE : integer := 128;
constant START_TIME : integer := 1024 - (BUFFER_SIZE * 5 / 2) - 10;

signal clk : std_logic := '0';
signal reset     : std_logic;
signal sync      : std_logic;
signal ctime     : std_logic_vector(41 downto 0);
signal data_in         : std_logic_vector(39 downto 0);
signal data_in_frameid : std_logic;
signal data_in_valid   : std_logic;
signal q           : std_logic_vector(17 downto 0);
signal wrreq       : std_logic;
signal words_avail : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(1023, 10));

signal ctime_r    : unsigned(41 downto 0);
  
begin
  
  clk <= not clk after T/2;
  
  process (clk) begin
  if rising_edge(clk) then
    if reset = '1' or sync = '1' then
      ctime_r <= to_unsigned(0, 42);
    else
      ctime_r <= ctime_r + to_unsigned(1, 42);
    end if;
  end if;
  end process;
  ctime <= std_logic_vector(ctime_r);  
  
  
  dut : frame_block 
  generic map (
    BUFFER_SIZE => BUFFER_SIZE,
    FIFO_AW => 12
  )
  port map (
    clk => clk,
    reset => reset,
    sync => sync,
    ctime => ctime,
    data_in => data_in,
    data_in_frameid => data_in_frameid,
    data_in_valid => data_in_valid,
    q => q,
    wrreq => wrreq,
    words_avail => words_avail
    );
    
    
  
  tb : process
  begin
    reset <= '1';
    sync <= '0';
    data_in_valid <= '0';    
    wait for 2*T;
    reset <= '0';
    
    wait for (4096+100) *T;
    data_in <= x"AA_AAAA_AAAA";
    data_in_frameid <= '0';
    data_in_valid <= '1';
    wait for T;
    data_in <= x"BB_BBBB_BBBB";
    wait for T;
    data_in <= x"CC_CCCC_CCCC";
    wait for T;   
    data_in <= (others => '0');
    data_in_valid <= '0';
    
    wait for 4096*T;
    
    
  assert false report "Simulation completed" severity failure; 
  end process;
  
  check_output_time : process
  begin
    wait for 1024*T;
    while true loop
      wait for (START_TIME+3)*T;
      assert wrreq = '1' report "wrreq not active";
      assert q(17 downto 16) = b"01" report "Not start of frame";
      wait for (1024 - START_TIME-3)*T;
    end loop;
  end process;
    
end behavioral;

