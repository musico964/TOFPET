library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity frame_formater is
  generic (
    FIFO_AW   : integer := 12
  );
  port (
    clk       : in std_logic;
    reset     : in std_logic;
    
    start     : in std_logic;
    frame_id  : in std_logic_vector(31 downto 0);
    event_number : in std_logic_vector(7 downto 0);
    event_bytes : in std_logic_vector(10 downto 0);
    event_rdreq : out std_logic;
    event_data  : in std_logic_vector(39 downto 0);    
    
    q           : out std_logic_vector(17 downto 0);
    wrreq       : out std_logic;
    words_avail : in std_logic_vector(FIFO_AW downto 0);
    
    tx_speed 	: in std_logic_vector(1 downto 0)
  );
    
end frame_formater;


architecture rtl of frame_formater is
  
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
  
  type state_t is (
    S_START, S_FRAMEID, 
    S_EVEN_0, S_EVEN_1, S_EVEN_2, 
    S_ODD_0, S_ODD_1, 
    S_ODD_END, 
    S_CRC);
  signal state : state_t;
    
  signal fifo_almost_full : std_logic;
  signal pkt_event_value : unsigned(7 downto 0);
  signal pkt_event_count : unsigned(7 downto 0);
  signal count            : unsigned(7 downto 0);
  
  signal data_reg_c : std_logic_vector(47 downto 0);
  signal data_reg_r : std_logic_vector(47 downto 0);
  
  signal bytes_required : unsigned(10 downto 0);
  signal words_required : unsigned(9 downto 0);
  
  signal crc            : std_logic_vector(15 downto 0);
  signal q_c            : std_logic_vector(17 downto 0);
  signal wrreq_c        : std_logic;
  
  signal q_r				: std_logic_vector(17 downto 0);
  signal wrreq_r			: std_logic;
  
  signal words_avail_u	: unsigned(FIFO_AW downto 0);
  signal words_avail_tx : unsigned(FIFO_AW downto 0);
    
  signal words_required_adj : unsigned(9 downto 0);
begin
  

  -- Very long combinational path but it should be fast enough in an ASIC. 
  bytes_required <= 
    -- Frame overhead
    to_unsigned(6, 11) + 
    -- Events
    unsigned(event_bytes) + 
    -- Make sure there's at least space for another empty frame
    to_unsigned(6, 11);
  words_required <= bytes_required(10 downto 1);
  
  -- (Partially) take into account the output FIFO draining: 0.1, 0.2 or 0.4 per clock
  words_avail_u <= unsigned(words_avail);
--   words_avail_tx <=	words_avail_u + words_avail_u(FIFO_AW downto 5) + words_avail_u(FIFO_AW downto 6) when tx_speed = "00" else
--   					words_avail_u + words_avail_u(FIFO_AW downto 4) + words_avail_u(FIFO_AW downto 5) when tx_speed = "01" else
--   					words_avail_u + words_avail_u(FIFO_AW downto 4) + words_avail_u(FIFO_AW downto 6);

	words_required_adj <= 	words_required - words_required(9 downto 5) when tx_speed = "00" else
							words_required - words_required(9 downto 4) when tx_speed = "01" else
							words_required - words_required(9 downto 3);
  					
  
--   process (clk, reset) begin
--   if reset = '1' then
--     fifo_almost_full <= '0';
--   elsif rising_edge(clk) then
--     if words_avail_u < words_required_adj then
--       fifo_almost_full <= '1';
--     else
--       fifo_almost_full <= '0';
--     end if;
--   end if;
--   end process;

	fifo_almost_full <= '1' when words_avail_u < words_required_adj else '0';

  -- Event count = 255 is used as a special case to signal a fifo full condition.
  -- The actual frame size will be 0 events.
  pkt_event_count <=    unsigned(event_number) when fifo_almost_full = '0' else 
                        to_unsigned(0, 8);
  
  pkt_event_value <=   unsigned(event_number) when fifo_almost_full = '0' else 
                        to_unsigned(255, 8);
  process (clk, reset) begin
  if reset = '1' then
    count <= to_unsigned(0, 8);
  elsif rising_edge(clk) then
    if state = S_START then
      count <= pkt_event_count;      
    elsif count /= to_unsigned(0, 8) then
      if state = S_EVEN_1 or state = S_ODD_0 then 
        count <= count - to_unsigned(1,8);
      end if;
    end if;    
  end if;    
  end process;
  
  
  process (clk, reset) begin
  if reset = '1' then
    state <= S_START;
  elsif rising_edge(clk) then
    if state = S_START then
      if start = '1' then
        state <= S_FRAMEID;
        
        -- SYNOPSYS translate_off
        assert unsigned(event_number) = 0 or fifo_almost_full = '0'
          report "Frame lost due to full FIFO" severity warning;
        -- SYNOPSYS translate_on              
      end if;
      
    elsif state =  S_FRAMEID then
      if count = to_unsigned(0, 8) then
        state <= S_ODD_END;
      else
        state <= S_EVEN_0;
      end if;
        
    elsif state = S_EVEN_0 then
      state <= S_EVEN_1;
    elsif state = S_EVEN_1 then
      state <= S_EVEN_2;
      
    elsif state = S_EVEN_2 then
      if count = to_unsigned(0, 8) then
        state <= S_CRC;
      else
        state <= S_ODD_0;
      end if;
      
    
    elsif state = S_ODD_0 then
      state <= S_ODD_1;
    elsif state = S_ODD_1 then
      if count = to_unsigned(0, 8) then
        state <= S_ODD_END;
      else
        state <= S_EVEN_0;
      end if;
      
    elsif state = S_ODD_END then
      state <= S_CRC;
      
    elsif state = S_CRC then
      state <= S_START;
    end if;
  end if;
  end process;


  event_rdreq <= '1' when state = S_EVEN_1 or state = S_ODD_0 else '0';

  data_reg_c <= 
      std_logic_vector(pkt_event_value) & frame_id & x"00"  when state = S_START else
      data_reg_r(31 downto 24) & event_data when state = S_EVEN_0 else
      event_data & x"00" when state = S_ODD_0 else    
      data_reg_r(31 downto 0) & x"0000"; 
      
      
  
  process (clk, reset) begin
  if reset = '1' then
    data_reg_r <= (others => '0');
    
  elsif rising_edge(clk) then
    data_reg_r <= data_reg_c;
  end if;    
  end process;

  
  q_c(15 downto 0) <= data_reg_c(47 downto 32);
  q_c(16) <= '1' when state = S_START else '0';
  q_c(17) <= '1' when state = S_CRC else '0';
  wrreq_c <= '0' when state = S_START and start = '0' else '1';
  
  process (clk, reset) begin
  if reset = '1' then
    q_r <= (others => '0');
    wrreq_r <= '0';
    
  elsif rising_edge(clk) then
    q_r <= q_c;
	 wrreq_r <= wrreq_c;
  end if;
  end process;
  
  process (clk, reset) begin
  if reset = '1' then
    crc <= x"0F4A";
    
  elsif rising_edge(clk) then
    if wrreq_r = '0' then
      crc <= x"0F4A";
    elsif wrreq_r = '1' then
      crc <= crc16(crc, q_r(15 downto 0));
    end if;
  end if;    
  end process;
  
  wrreq <= wrreq_r;
  q(17 downto 16) <= q_r(17 downto 16);
  q(15 downto  0) <= crc when q_r(17 downto 16) = b"10" else q_r(15 downto 0);
  
  
end rtl;
