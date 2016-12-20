library ieee, gctrl_lib;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity frame_buffer is
  generic (
    BUFFER_SIZE : integer := 128
  );
  port (
    clk     : in std_logic;
    reset   : in std_logic;
    
    data_in         : in std_logic_vector(39 downto 0);
    data_in_valid   : in std_logic;
    
    
    read_mode       : in std_logic;
    event_number    : out std_logic_vector(7 downto 0);
    event_bytes     : out std_logic_vector(10 downto 0);
    event_rdreq     : in std_logic;
    event_data      : out std_logic_vector(39 downto 0)
  );
end frame_buffer;

architecture rtl of frame_buffer is
  
  type event_mem_t is array(0 to BUFFER_SIZE - 1) of std_logic_vector(39 downto 0);
  signal event_mem : event_mem_t;
  signal event_mem_d : std_logic_vector(39 downto 0);
  signal event_mem_q : std_logic_vector(39 downto 0);
  signal event_mem_addr : unsigned(7 downto 0);
  signal event_mem_wrreq : std_logic;  

  signal buffer_full		  : std_logic;

  signal prev_read_mode : std_logic;
  
  signal event_number_r : unsigned(7 downto 0);
  signal event_bytes_r : unsigned(10 downto 0);
  
  signal fifo_q			: std_logic_vector(39 downto 0);
  signal fifo_empty		: std_logic;
  signal fifo_rdreq		: std_logic;
  signal fifo_data_valid : std_logic;

  begin
  
  fifo : entity gctrl_lib.word_fifo
  generic map (
  	FIFO_WIDTH => 40,
  	FIFO_AW => 3,
  	FIFO_SIZE => 8
  )
  port map (
  	clk => clk,
  	reset => reset,
  	d => data_in,
  	wrreq => data_in_valid,
  	words_avail => open,
  	
  	q => fifo_q,
  	empty => fifo_empty,
  	rdreq => fifo_rdreq
  );
  
  fifo_rdreq <= '1' when read_mode = '0' and prev_read_mode = '0' and fifo_empty = '0' else '0';
  fifo_data_valid <= '1' when fifo_rdreq = '1' else '0';
  
  
  -- Event Memory
  memory : process (clk) begin
  if rising_edge(clk) then  
    if to_integer(event_mem_addr) < BUFFER_SIZE then
      event_mem_q <= event_mem(to_integer(event_mem_addr));
      if event_mem_wrreq = '1' then
        event_mem(to_integer(event_mem_addr)) <= event_mem_d;
      end if;
    else
        event_mem_q <= (others => 'X');
    end if;
  end if;
  end process;

  buffer_full <= '1' when event_mem_addr >= to_unsigned(BUFFER_SIZE, 8) else '0';
  event_mem_d <= fifo_q;
  event_mem_wrreq   <= '1' when read_mode = '0' and fifo_data_valid = '1' and buffer_full = '0' else '0'; 
  event_data <= event_mem_q;
  
  -- SYNOPSYS translate_off
  assert fifo_data_valid = '0' or buffer_full = '0'
    report "Lost event due to full frame buffer" severity warning;
  assert fifo_data_valid = '0' or read_mode = '0'
    report "Lost event due to frame buffer in read mode" severity warning;    
  -- SYNOPSYS translate_on

  
  -- Mem address generation
  process (clk, reset) begin
  if reset = '1' then
    event_mem_addr <= to_unsigned(0, 8);
    prev_read_mode <= '0';
  elsif rising_edge(clk) then 
	prev_read_mode <= read_mode;  
   	if read_mode /= prev_read_mode then
		event_mem_addr <= to_unsigned(0, 8);
	elsif event_mem_wrreq = '1' or event_rdreq = '1' then
	   event_mem_addr <= event_mem_addr + to_unsigned(1, 8);		
  	end if;	
  end if;
  end process;
  

  
  -- Event number book keeping
  process (clk, reset) begin
  if reset = '1' then
    event_number_r <= to_unsigned(0, 8);
    event_bytes_r <= to_unsigned(0, 11);
    
  elsif rising_edge(clk) then 		  
	  if prev_read_mode = '1' and read_mode = '0' then
		  event_number_r <= to_unsigned(0, 8);
      	  event_bytes_r <= to_unsigned(0, 11);
	  elsif event_mem_wrreq = '1' then
		  event_number_r <= event_number_r + to_unsigned(1, 8);
		  event_bytes_r <= event_bytes_r + to_unsigned(5, 11);
	  end if;
  end if;
  end process;
  
  event_number <= std_logic_vector(event_number_r);
  event_bytes <= std_logic_vector(event_bytes_r);
 

  end rtl;

