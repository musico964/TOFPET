library ieee, gctrl_lib;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity frame_block is
  generic (
    BUFFER_SIZE : integer := 128;
    FIFO_AW     : integer := 12
  );
  port (
    clk       : in std_logic;
    reset     : in std_logic;
  
    ctime     : in std_logic_vector(41 downto 0);
    
    data_in         : in std_logic_vector(39 downto 0);
    data_in_frameid : in std_logic;
    data_in_valid   : in std_logic;
    
    q           : out std_logic_vector(17 downto 0);
    wrreq       : out std_logic;
    words_avail : in std_logic_vector(FIFO_AW downto 0);
    
    tx_speed	: in std_logic_vector(1 downto 0)
  );
    
end frame_block;

architecture rtl of frame_block is
  
  constant TX_TIME : integer := 5 * BUFFER_SIZE / 2 + 10;
  constant START_TIME : unsigned (9 downto 0) := to_unsigned(1023, 10);
  constant END_TIME : unsigned (9 downto 0) := to_unsigned(TX_TIME, 10);
  
  signal fb0_in_valid       : std_logic;
  signal fb0_read_mode      : std_logic;
  signal fb0_event_number   : std_logic_vector(7 downto 0);
  signal fb0_event_bytes    : std_logic_vector(10 downto 0);
  signal fb0_event_rdreq    : std_logic;
  signal fb0_event_data     : std_logic_vector(39 downto 0);
  signal fb0_frame_id       : std_logic_vector(31 downto 0);
  
  signal fb1_in_valid       : std_logic;
  signal fb1_read_mode      : std_logic;
  signal fb1_event_number   : std_logic_vector(7 downto 0);
  signal fb1_event_bytes    : std_logic_vector(10 downto 0);
  signal fb1_event_rdreq    : std_logic;
  signal fb1_event_data     : std_logic_vector(39 downto 0);
  signal fb1_frame_id       : std_logic_vector(31 downto 0);
  
  
  signal start              : std_logic;
  signal frame_id           : std_logic_vector(31 downto 0);
  signal event_number       : std_logic_vector(7 downto 0);
  signal event_bytes    : std_logic_vector(10 downto 0);
  signal event_rdreq        : std_logic;
  signal event_data         : std_logic_vector(39 downto 0);
  
  
begin
  
  fb0 : entity gctrl_lib.frame_buffer
  generic map (
    BUFFER_SIZE => BUFFER_SIZE
  )
  port map (
    clk => clk,
    reset => reset,
    data_in => data_in,
    data_in_valid => fb0_in_valid,
    read_mode => fb0_read_mode,
    event_number => fb0_event_number,
    event_bytes => fb0_event_bytes,
    event_rdreq => fb0_event_rdreq,
    event_data => fb0_event_data        
  );
  
  fb0_in_valid <= '1' when data_in_valid = '1' and data_in_frameid = '0' else '0';
  
  process (clk,reset) begin
  if reset = '1' then
    fb0_frame_id <= (others => '0');
  elsif rising_edge(clk) then
    if ctime(10 downto 0) = b"000_0000_0000" then
      fb0_frame_id <= ctime(41 downto 10);
    end if;
  end if;
  end process;
  
  fb1 : entity gctrl_lib.frame_buffer
    generic map (
	   BUFFER_SIZE => BUFFER_SIZE
	 )
    port map (
      clk => clk,
      reset => reset,
      data_in => data_in,
      data_in_valid => fb1_in_valid,
      read_mode => fb1_read_mode,
      event_number => fb1_event_number,
      event_bytes => fb1_event_bytes,
      event_rdreq => fb1_event_rdreq,
      event_data => fb1_event_data        
    );
    
    fb1_in_valid <= '1' when data_in_valid = '1' and data_in_frameid = '1' else '0';
    
    process (clk, reset) begin
    if reset = '1' then
      fb1_frame_id <= (others => '1');
    elsif rising_edge(clk) then
      if ctime(10 downto 0) = b"100_0000_0000" then
        fb1_frame_id <= ctime(41 downto 10);
      end if;
    end if;
    end process;
  
  
  fmt : entity gctrl_lib.frame_formater
  generic map (
	FIFO_AW => FIFO_AW
  )
  port map (
    clk => clk,
    reset => reset,
    start => start,
    frame_id => frame_id,
    event_number => event_number,
    event_bytes => event_bytes,
    event_rdreq => event_rdreq,
    event_data => event_data,
    
    q => q,
    wrreq => wrreq,
    words_avail => words_avail,
    tx_speed => tx_speed
  );

 
  
  start <= '1' when unsigned(ctime(9 downto  0)) = START_TIME else '0';
  
  
  fb0_read_mode <= 	'1' when ctime(10) = '1' and unsigned(ctime(9 downto 0)) >= START_TIME else
  					'1' when ctime(10) = '0' and unsigned(ctime(9 downto 0)) <= END_TIME else 
  					'0';
  fb0_event_rdreq <= event_rdreq when fb0_read_mode = '1' else '0';
  
  fb1_read_mode <= 	'1' when ctime(10) = '0' and unsigned(ctime(9 downto 0)) >= START_TIME else
  					'1' when ctime(10) = '1' and unsigned(ctime(9 downto 0)) <= END_TIME else 
  					'0';
  fb1_event_rdreq <= event_rdreq when fb1_read_mode = '1' else '0';
    
  frame_id <= 	fb0_frame_id when fb0_read_mode = '1' else 
  				fb1_frame_id;
  				
  event_number <=	fb0_event_number when fb0_read_mode = '1' else 
  					fb1_event_number;
 
  event_bytes <=	fb0_event_bytes when fb0_read_mode = '1' else 
  					fb1_event_bytes;
  					
  event_data <= 	fb0_event_data when fb0_read_mode = '1' else 
  					fb1_event_data;

  
end rtl;
