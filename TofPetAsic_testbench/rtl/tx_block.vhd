library ieee, gctrl_lib;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx_block is
  port (
    clk         : in std_logic;
    reset       : in std_logic;
    
    tx_mode     : in std_logic_vector(1 downto 0);
    ddr_mode 	: in std_logic;
    tx0         : out std_logic;
    tx1         : out std_logic;
    tx2         : out std_logic;
    tx3         : out std_logic;
    
    fifo_q      : in std_logic_vector(17 downto 0);
    fifo_rdreq  : out std_logic;
    fifo_empty  : in std_logic   
  );
end tx_block;

architecture rtl of tx_block is

  signal counter : std_logic_vector(9 downto 0);  
  signal byte_strobe1 : std_logic;
  signal byte_strobe2 : std_logic;
  
  signal training_mode : std_logic;
  
  type state_x1_t  is (
    S1_IDLE,
    S1_START,
    S1_DATA_BYTE0, S1_DATA_BYTE1
  );
  signal state_x1 : state_x1_t;
  signal rdreq_x1 : std_logic;
  
  
  type state_x2_t is (
    S2_IDLE,
    S2_START,
    S2_DATA
  );
  signal state_x2 : state_x2_t;
  signal rdreq_x2 : std_logic;
  
  type state_x4_t is (
    S4_IDLE,   
    S4_START,
    S4_DATA_WORD01, S4_DATA_WORD23,
    S4_END_WORD23
  );  
  signal state_x4 : state_x4_t;
  signal rdreq_x4 : std_logic;

  constant K28_1 : std_logic_vector(7 downto 0) := "00111100";
  constant K28_5 : std_logic_vector(7 downto 0) := "10111100";

  signal eof : std_logic;

  signal enable_x2 : std_logic;
  signal enable_x4 : std_logic;
  signal di : std_logic_vector(31 downto 0);
  signal ki : std_logic_vector(3 downto 0);

  begin
   
    process (clk, reset) begin
      if reset = '1' then
        counter <= b"00_0000_0001";
      elsif rising_edge(clk) then
        counter <= counter(8 downto 0) & counter(9);
      end if;        
    end process;
    
    byte_strobe1 <= '1' when ddr_mode = '0' and counter(8) = '1' else
    				'1' when ddr_mode = '1' and (counter(8) = '1' or counter(3) = '1') else 
    				'0';
    byte_strobe2 <= '1' when ddr_mode = '0' and counter(9) = '1' else
    				'1' when ddr_mode = '1' and (counter(9) = '1' or counter(4) = '1') else 
    				'0';
          
    training_mode <= '1' when tx_mode = "11" else '0';
    
    eof <= fifo_q(17);
     
    sm_x1: process(clk,reset) begin
    if reset = '1' then
      state_x1 <= S1_IDLE;

    elsif rising_edge(clk) then
      if byte_strobe2 = '1' then
        
        if tx_mode /= "00" then
        	state_x1 <= S1_IDLE;
        	
        elsif state_x1 = S1_IDLE then
          if fifo_empty = '0' then
            state_x1 <= S1_START;
          else
            state_x1 <= S1_IDLE;
          end if;
          
        elsif state_x1 = S1_START then
          state_x1 <= S1_DATA_BYTE0; 

        elsif state_x1 = S1_DATA_BYTE0 then
          state_x1 <= S1_DATA_BYTE1;
          
        elsif state_x1 = S1_DATA_BYTE1 then
          if fifo_empty = '1' or eof = '1' then
            state_x1 <= S1_IDLE;
          else
            state_x1 <= S1_DATA_BYTE0;
          end if;          
          
        else
          state_x1 <= S1_IDLE;
        end if;        
      end if;
    end if;
    end process;
    
    process (clk,reset) begin
    if reset = '1' then
      rdreq_x1 <= '0';
    elsif rising_edge(clk) then
      if state_x1 = S1_DATA_BYTE1 and byte_strobe1 = '1' then
        rdreq_x1 <= '1';
      else
        rdreq_x1 <= '0';
      end if;
    end if;
    end process;
                
                
    sm_x2 : process(clk, reset) begin
    if reset = '1' then
      state_x2 <= S2_IDLE;
    elsif rising_edge(clk) then
      if byte_strobe2 = '1' then
        
        if tx_mode /= "01" then
        	state_x2 <= S2_IDLE;
        
        elsif state_x2 = S2_IDLE then
          if fifo_empty = '0' then
            state_x2 <= S2_START;
          else
            state_x2 <= S2_IDLE;
          end if;
          
        elsif state_x2 = S2_START then
          state_x2 <= S2_DATA;
          
        elsif state_x2 = S2_DATA then
          if fifo_empty = '1' or eof = '1' then
            state_x2 <= S2_IDLE;
          else
            state_x2 <= S2_DATA;
          end if;
          
        else
          state_x2 <= S2_IDLE;
        end if;
        
      end if;      
    end if;
    end process;
    
    process (clk,reset) begin
    if reset = '1' then
      rdreq_x2 <= '0';
    elsif rising_edge(clk) then
      if state_x2 = S2_DATA and byte_strobe1 = '1' then
        rdreq_x2 <= '1';
      else
        rdreq_x2 <= '0';
      end if;
    end if;
    end process;
    
    
    sm_x4 : process(clk,reset) begin
    if reset = '1' then
        state_x4 <= S4_IDLE;
    elsif rising_edge(clk) then
    
      if tx_mode /= "10" then
      	state_x4 <= S4_IDLE;
        
      elsif state_x4 = S4_IDLE then
        if byte_strobe2 = '1' then
          if fifo_empty = '0' then
            state_x4 <= S4_START;
          end if;
        end if;       
        
      elsif state_x4 = S4_START then
        if byte_strobe2 = '1' then
          state_x4 <= S4_DATA_WORD01;
        end if;
        
      elsif state_x4 = S4_DATA_WORD01 then
        if fifo_empty = '1' or eof = '1' then
           state_x4 <= S4_END_WORD23;
         else
           state_x4 <= S4_DATA_WORD23;
         end if;
        
      elsif state_x4 = S4_DATA_WORD23 then
        if byte_strobe2 = '1' then
          if fifo_empty = '1' or eof = '1' then
            state_x4 <= S4_IDLE;
          else
            state_x4 <= S4_DATA_WORD01;
          end if;
        end if;
        
      elsif state_x4 = S4_END_WORD23 then
        if byte_strobe2 = '1' then
          state_x4 <= S4_IDLE;
        end if;
        
      else
        state_x4 <= S4_IDLE;
        
      end if;
    end if;
    end process;
 
 
    rdreq_x4 <= '1' when state_x4 = S4_DATA_WORD01 else
                '1' when state_x4 = S4_DATA_WORD23 and byte_strobe2 = '1' else
                '0';
                
            
    fifo_rdreq <= rdreq_x1 when tx_mode = "00" else
                  rdreq_x2 when tx_mode = "01" else
                  rdreq_x4 when tx_mode = "10" else
                  '0';
    
    process (clk, reset) begin
    if reset = '1' then
      di <= (others => '0');
      ki <= (others => '0');
    elsif rising_edge(clk) then
      if tx_mode = "00" then
        if state_x1 = S1_START then
          di(31 downto 24) <= K28_1;
          ki(3) <= '1';
        elsif state_x1 = S1_DATA_BYTE0 then
          di(31 downto 24) <= fifo_q(15 downto 8);
          ki(3) <= '0';
        elsif state_x1 = S1_DATA_BYTE1 then
          di(31 downto 24) <= fifo_q(7 downto 0);
          ki(3) <= '0';          
        else
          di(31 downto 24) <= K28_5;
          ki(3) <= '1';
        end if;
        di(23 downto 0) <= K28_5 & K28_5 & K28_5;
        ki(2 downto 0) <= "111";
        
      elsif tx_mode = "01" then
        if state_x2 = S2_START then
          di(31 downto 16) <= K28_1 & K28_1;
          ki(3 downto 2) <= "11";
        elsif state_x2 = S2_DATA then
          di(31 downto 16) <= fifo_q(15 downto 0);
          ki(3 downto 2) <= "00";
        else
          di(31 downto 16) <= K28_5 & K28_5;
          ki(3 downto 2) <= "11";
        end if;
        di (15 downto 0) <= K28_5 & K28_5;
        ki(1 downto 0) <= "11";
          
      elsif tx_mode = "10" then
        if state_x4 = S4_START then
          di <= K28_1 & K28_1 & K28_1 & K28_1;
          ki <= "1111";
        elsif state_x4 = S4_DATA_WORD01 then
          di(31 downto 16) <= fifo_q(15 downto 0);
          ki(3 downto 2) <= "00";
        elsif state_x4 = S4_DATA_WORD23 then
          di(15 downto 0) <= fifo_q(15 downto 0);
          ki (1 downto 0) <= "00";
        elsif state_x4 = S4_END_WORD23 then
          di(15 downto 0) <= K28_5 & K28_5;
          ki(1 downto 0) <= "11";
        else
          di <= K28_5 & K28_5 & K28_5 & K28_5;
          ki <= "1111";
        end if;
      else
        di <= K28_5 & K28_5 & K28_5 & K28_5;
        ki <= "1111";
      end if;
    end if;
    end process;            
            
    
    enable_x2 <= '1' when tx_mode /= "00" else '0';
    enable_x4 <= '1' when tx_mode = "10" or tx_mode = "11" else '0';
    
    tx_lane0 : entity gctrl_lib.tx_lane 
    port map (
      clk => clk,
      reset => reset,
      byte_strobe => byte_strobe2,
      
      enable => '1',
      training_mode => training_mode,
      ddr_mode => ddr_mode,
      
      di => di(31 downto 24),
      ki => ki(3),
      tx => tx0
    );
    
    tx_lane1 : entity gctrl_lib.tx_lane 
    port map (
      clk => clk,
      reset => reset,
      byte_strobe => byte_strobe2,
      ddr_mode => ddr_mode,
      
      enable => enable_x2,
      training_mode => training_mode,
      
      di => di(23 downto 16),
      ki => ki(2),
      tx => tx1
    );
     
    tx_lane2 : entity gctrl_lib.tx_lane 
    port map (
      clk => clk,
      reset => reset,
      byte_strobe => byte_strobe2,
      
      enable => enable_x4,
      training_mode => training_mode,
      ddr_mode => ddr_mode,
      
      di => di(15 downto 8),
      ki => ki(1),
      tx => tx2
    ); 
      
    tx_lane3 : entity gctrl_lib.tx_lane 
    port map (
      clk => clk,
      reset => reset,
      byte_strobe => byte_strobe2,
      
      enable => enable_x4,
      training_mode => training_mode,
      ddr_mode => ddr_mode,
      
      di => di(7 downto 0),
      ki => ki(0),
      tx => tx3
    ); 
    
    
  end rtl;
  