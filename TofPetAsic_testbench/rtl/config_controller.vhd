library ieee, gctrl_lib;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use gctrl_lib.asic_k.all;

entity config_controller is 
  generic (
    GLOBAL_CONFIG_SIZE : integer;
    GLOBAL_TCONFIG_SIZE : integer;
    CH_CONFIG_SIZE : integer;
    CH_TCONFIG_SIZE : integer;
    DARK_COUNT_SIZE : integer
  );
  port (
    -- external interface
    sclk      : in std_logic;
    cs        : in std_logic;
    sdi       : in std_logic;
    sdo       : out std_logic;
    sdo_oe    : out std_logic;
    
    -- reset
    reset     : in std_logic;
    
    -- Global configuration registers
    global_config : out std_logic_vector(GLOBAL_CONFIG_SIZE - 1 downto 0); 
    global_tconfig : out std_logic_vector(GLOBAL_TCONFIG_SIZE - 1 downto 0);
   
    -- Channel configuration interface
    ch_cfg_enable      : out std_logic;
    ch_cfg_data_i      : in std_logic;
    ch_cfg_data_o      : out std_logic;
    ch_cfg_cmd         : out std_logic_vector(2 downto 0);
    ch_cfg_address     : out std_logic_vector(6 downto 0);
    
    -- Pulse generator interface
    pulse_number    : out std_logic_vector(9 downto 0);
    pulse_length 	: out std_logic_vector(7 downto 0);
    pulse_intv      : out std_logic_vector(7 downto 0);
    pulse_strobe    : out std_logic
  );
end config_controller;

architecture rtl of config_controller is
  
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
  
  
  constant CMD_WRCHCFG  : std_logic_vector(3 downto 0) := b"0000";
  constant CMD_RDCHCFG  : std_logic_vector(3 downto 0) := b"0001";
  constant CMD_WRCHTEST : std_logic_vector(3 downto 0) := b"0010";
  constant CMD_RDCHTEST : std_logic_vector(3 downto 0) := b"0011";    
  constant CMD_RDDARK   : std_logic_vector(3 downto 0) := b"0100";

  constant CMD_WRGCFG   : std_logic_vector(3 downto 0) := b"1000";
  constant CMD_RDGCFG   : std_logic_vector(3 downto 0) := b"1001";  
  constant CMD_PULSE     : std_logic_vector(3 downto 0) := b"1010";  
  constant CMD_WRGTEST	: std_logic_vector(3 downto 0) := b"1100";
  constant CMD_RDGTEST	: std_logic_vector(3 downto 0) := b"1101";
  
  constant TP_CONFIG_SIZE		: integer := 10+8+8;
  
  type state_t is (SSLEEP, SIDLE, SCMD1, SCMD2, SCMD3,
      S_GET_ADDR,
      S_GET_PAYLOAD,
      S_GET_CRC,
      S_ACK,
      S_DO_WRCHCFG,
      S_DO_RDCHCFG,
      S_DO_WRCHTEST,
      S_DO_RDCHTEST,
      S_DO_RDDARK, 
      S_DO_WRGCFG, 
      S_DO_RDGCFG,
      S_DO_WRGTEST,
      S_DO_RDGTEST,
      S_DO_PULSE,
      S_TX_CRC
      );
      
    signal cmd_r  : std_logic_vector(3 downto 0);
    signal cmd_c  : std_logic_vector(3 downto 0);
    
    signal addr_r   : std_logic_vector(6 downto 0); 

	constant PAYLOAD_SIZE : integer := 128;
    signal payload_r : std_logic_vector(PAYLOAD_SIZE-1 downto 0);
    
    signal state : state_t;
	 
    signal bit_counter : unsigned(7 downto 0);
	  signal bit_counter_preload : unsigned(7 downto 0);
	  signal bit_counter_preload0 : unsigned(7 downto 0);
	  signal bit_counter_preload1 : unsigned(7 downto 0);
	  signal bit_counter_preload2 : unsigned(7 downto 0);
	  signal bit_counter_stop : std_logic;
    
    
	  signal crc_read_r : std_logic_vector(7 downto 0);
    signal crc_calc : std_logic_vector(7 downto 0);    
  
    signal global_config_r : std_logic_vector(GLOBAL_CONFIG_SIZE-1 downto 0);
    signal global_tconfig_r : std_logic_vector(GLOBAL_TCONFIG_SIZE-1 downto 0);
    
  begin     
  
    cmd_c <= cmd_r(2 downto 0) & sdi;    
    process (sclk, reset) begin
    if reset = '1' then
      cmd_r <= (others => '0');
    elsif rising_edge(sclk) then
      if state = SIDLE or state = SCMD1 or state = SCMD2 or state = SCMD3 then
        cmd_r <= cmd_c;
      end if;
    end if;
    end process;
    
    process (sclk,reset) begin
    if reset = '1' then
      addr_r <= (others => '0');
    elsif rising_edge(sclk) then        
      if state = S_GET_ADDR then
        addr_r <= addr_r(5 downto 0) & sdi;
      end if;
    end if;
    end process;
    
    process (sclk,reset) begin
    if reset = '1' then
      payload_r <= (others => '0');
    elsif rising_edge(sclk) then
      if state = S_GET_PAYLOAD then
        -- Read the payload of an incoming command
        payload_r <= payload_r(PAYLOAD_SIZE-2 downto 0) & sdi;
      elsif state = S_DO_WRCHCFG or state = S_DO_WRCHTEST then
        -- Dump the payload from a command into the channel bus
        payload_r <= payload_r(PAYLOAD_SIZE-2 downto 0) & '0';
      end if;
    end if;
    end process;
    
    process (sclk, reset) begin
    if reset = '1' then
      crc_read_r <= x"00";      
    elsif rising_edge(sclk) then
      if state = S_GET_CRC then
        -- Read the CRC from an incomming command
        crc_read_r <= crc_read_r(6 downto 0) & sdi;
      end if;        
    end if;
    end process;

    process (sclk, reset) begin
    if reset = '1' then
      crc_calc <= x"8A";
    elsif rising_edge(sclk) then      
      if state = SIDLE and cs = '0' then
        crc_calc <= x"8A";
      elsif state = SIDLE or state = SCMD1 or state = SCMD2 or state = SCMD3 or
        -- Calculate the CRC of an incoming command  
        state = S_GET_ADDR or state = S_GET_PAYLOAD then
        crc_calc <= crc8(crc_calc, sdi);
        
      elsif state = S_ACK then
        crc_calc <= x"8A";        
      elsif state = S_DO_RDCHCFG or state = S_DO_RDCHTEST or state = S_DO_RDDARK then
        -- Calculate the CRC of a channel readback reply
        crc_calc <= crc8(crc_calc, ch_cfg_data_i);
      elsif state = S_DO_RDGCFG then
        -- Calculate the CRC of a global config readback reply
        crc_calc <= crc8(crc_calc, global_config_r(GLOBAL_CONFIG_SIZE-1));
        
      elsif state = S_DO_RDGTEST then
      	crc_calc <= crc8(crc_calc, global_tconfig_r(GLOBAL_TCONFIG_SIZE-1));
        
      elsif state = S_TX_CRC then
        -- Dump the CRC of a readback reply
        crc_calc <= crc_calc(6 downto 0) & '0';
        
      elsif state = SSLEEP then
        crc_calc <= x"8A";
      end if;  
    end if;
    end process;
    
    
    --
    -- This use of global_config_r/global_tconfig_r would be best replaced by using only payload_r!
    --
    process (sclk,reset) begin
    if reset = '1' then
      global_config_r <= DEFAULT_G_CONFIG;
      global_tconfig_r <= DEFAULT_G_TCONFIG;
    elsif rising_edge(sclk) then
      if state = S_DO_WRGCFG then
        -- Read global config
        global_config_r <= payload_r(GLOBAL_CONFIG_SIZE-1 downto 0);
      elsif state = S_DO_RDGCFG then
        -- Rotate the global config over itself, in order to dump it to SDO
        global_config_r <= global_config_r(GLOBAL_CONFIG_SIZE-2 downto 0) & global_config_r(GLOBAL_CONFIG_SIZE-1);
        
      elsif state = S_DO_WRGTEST then
      	global_tconfig_r <= payload_r(GLOBAL_TCONFIG_SIZE-1 downto 0);
      elsif state = S_DO_RDGTEST then
      	global_tconfig_r <= global_tconfig_r(GLOBAL_TCONFIG_SIZE-2 downto 0) & global_tconfig_r(GLOBAL_TCONFIG_SIZE-1);             	
      end if;
    end if;
    end process;
    
    
    -- Main FSM
    process (sclk,reset) begin
    if reset = '1' then
      state <= SIDLE;
    elsif rising_edge(sclk) then 
      if state = SIDLE and cs = '0' then
        -- IDLE and CS is 0, keep idling
        state <= SIDLE;
      elsif state = SIDLE and cs = '1' then
        -- IDLE and CS is 1, let's read the 3 command bits
        state <= SCMD1;        
      elsif state = SCMD1 then
        state <= SCMD2;
      elsif state = SCMD2 then
			state <= SCMD3;
	  elsif state = SCMD3 then
		-- OK, we have a command, let's see how to proceed
		
		-- These commands have a channel ID
		if cmd_c(3) = '0' then
			state <= S_GET_ADDR;
			
		-- These don't have a channel ID, let's go straight for the payload
		elsif cmd_c = CMD_WRGCFG then
			state <= S_GET_PAYLOAD;			
		elsif cmd_c = CMD_PULSE then
			state <= S_GET_PAYLOAD;			
		elsif cmd_c = CMD_WRGTEST then
			state <= S_GET_PAYLOAD;
					
		-- These don't even have a payload, let's go straight for the CRC
		elsif cmd_c = CMD_RDGCFG then
			state <= S_GET_CRC;
		elsif cmd_c = CMD_RDGTEST then
			state <= S_GET_CRC;
		else
			state <= SSLEEP;
		end if;
		
		-- Channel address reading for commands with channel ID
		elsif state = S_GET_ADDR then        
		if bit_counter_stop = '1' then
				-- The address had been read, let's see how to proceed        
			if cmd_r = CMD_WRCHCFG then
			state <= S_GET_PAYLOAD;
			elsif cmd_r = CMD_WRCHTEST then 
			state <= S_GET_PAYLOAD;
			elsif cmd_r = CMD_RDCHCFG or cmd_r = CMD_RDCHTEST or cmd_r = CMD_RDDARK then           
			state <= S_GET_CRC;
			else
			state <= SSLEEP;            
			end if;
		end if;
          
      
      -- Payload reading for commands with payload
      elsif state = S_GET_PAYLOAD then
        if bit_counter_stop = '1' then
          state <= S_GET_CRC;
        end if;
      
      -- CRC8 reading
      elsif state = S_GET_CRC then
        if bit_counter_stop = '1' then
          state <= S_ACK;
        end if;   

      -- ACK and proceed to command handling             
      elsif state = S_ACK then
        if crc_calc /= crc_read_r then
          state <= SSLEEP;
        elsif cmd_r = CMD_WRCHCFG then
          state <= S_DO_WRCHCFG;
          
        elsif cmd_r = CMD_RDCHCFG then
          state <= S_DO_RDCHCFG;
          
        elsif cmd_r = CMD_WRCHTEST then
          state <= S_DO_WRCHTEST;
          
        elsif cmd_r = CMD_RDCHTEST then
          state <= S_DO_RDCHTEST;
          
        elsif cmd_r = CMD_RDDARK then
          state <= S_DO_RDDARK;
          
        elsif cmd_r = CMD_WRGCFG then
          state <= S_DO_WRGCFG;
          
        elsif cmd_r = CMD_RDGCFG then
          state <= S_DO_RDGCFG;
          
        elsif cmd_r = CMD_PULSE then
          state <= S_DO_PULSE;
          
        elsif cmd_r = CMD_WRGTEST then
        	state <= S_DO_WRGTEST;
        elsif cmd_r = CMD_RDGTEST then
        	state <= S_DO_RDGTEST;
          
        else 
          state <= SSLEEP;
        end if;
        
      
      elsif state = S_DO_WRCHCFG then
        if bit_counter_stop = '1' then
          state <= SSLEEP;
        end if;
        
      elsif state = S_DO_RDCHCFG then
        if bit_counter_stop = '1' then
          state <= S_TX_CRC;
        end if;

      elsif state = S_DO_WRCHTEST then
        if bit_counter_stop = '1' then
          state <= SSLEEP;
        end if;
        
      elsif state = S_DO_RDCHTEST then
        if bit_counter_stop = '1' then
          state <= S_TX_CRC;
        end if;
        
      elsif state = S_DO_RDDARK then
        if bit_counter_stop = '1' then
          state <= S_TX_CRC;
        end if;
        
        
      elsif state = S_DO_WRGCFG then
        state <= SSLEEP;
        
      elsif state = S_DO_RDGCFG then
        if bit_counter_stop = '1' then
          state <= S_TX_CRC;
        end if;
        
	  elsif state = S_DO_WRGTEST Then
	  	state <= SSLEEP;
	  	
	  elsif state= S_DO_RDGTEST then
	  	if bit_counter_stop = '1' then
	  		state <= S_TX_CRC;
	  	end if;

      elsif state = S_DO_PULSE then
        state <= SSLEEP;
        
      elsif state = S_TX_CRC then
        if bit_counter_stop = '1' then
          state <= SSLEEP;
        end if;       
     
      elsif state = SSLEEP then
        state <= SIDLE; 
      else
        state <= SIDLE;          
      end if;
      
      
                
    end if;    
    end process;
    
	 bit_counter_preload0 <= 
			to_unsigned(7-1,8) 				      when cmd_c(3) = '0' else
			to_unsigned(GLOBAL_CONFIG_SIZE-1, 8) 	 when cmd_c = CMD_WRGCFG else
			to_unsigned(TP_CONFIG_SIZE-1, 8) 	when cmd_c = CMD_PULSE else
			to_unsigned(8-1, 8)				      when cmd_c = CMD_RDGCFG else
			to_unsigned(GLOBAL_TCONFIG_SIZE-1, 8) when cmd_c = CMD_WRGTEST else
			to_unsigned(8-1, 8)				      when cmd_c = CMD_RDGTEST else 
			to_unsigned(0, 8);
			
	bit_counter_preload1 <= 
			to_unsigned(CH_CONFIG_SIZE-1, 8) 	when cmd_r = CMD_WRCHCFG else
      		to_unsigned(CH_TCONFIG_SIZE-1, 8)	when cmd_r = CMD_WRCHTEST else
      		to_unsigned(8-1, 8);
      
    bit_counter_preload2 <= 
      to_unsigned(CH_CONFIG_SIZE-1, 8)	  when cmd_r = CMD_WRCHCFG else
      to_unsigned(CH_CONFIG_SIZE-1, 8)	  when cmd_r = CMD_RDCHCFG else
      to_unsigned(CH_TCONFIG_SIZE-1, 8) 	when cmd_r = CMD_WRCHTEST else			
      to_unsigned(CH_TCONFIG_SIZE-1, 8) 	when cmd_r = CMD_RDCHTEST else
      to_unsigned(DARK_COUNT_SIZE-1, 8)	 when cmd_r = CMD_RDDARK else
      to_unsigned(GLOBAL_CONFIG_SIZE-1, 8) 	  when cmd_r = CMD_RDGCFG else
      to_unsigned(GLOBAL_TCONFIG_SIZE-1, 8) 	  when cmd_r = CMD_RDGTEST else
      to_unsigned(0,8);

		bit_counter_preload <=
		  bit_counter_preload0 when state = SCMD3 else
			bit_counter_preload1 when state = S_GET_ADDR and bit_counter_stop = '1' else
			to_unsigned(8-1, 8)	when state = S_GET_PAYLOAD and bit_counter_stop = '1' else
			bit_counter_preload2 when state = S_ACK else
			to_unsigned(8-1, 8) when 	(state = S_DO_RDCHCFG or state = S_DO_RDCHTEST or state = S_DO_RDDARK or state = S_DO_RDGCFG or state = S_DO_RDGTEST) and bit_counter_stop = '1' else
			to_unsigned(0, 8);
			
	 process (sclk, reset) begin
	 if reset = '1' then
		bit_counter <= to_unsigned(0, 8);
--		bit_counter_stop <= '0';
	 elsif rising_edge(sclk) then
		if bit_counter /= to_unsigned(0, 8) then
			bit_counter <= bit_counter - to_unsigned(1,8);
		else
			bit_counter <= bit_counter_preload;
		end if;
		
-- 		if bit_counter = to_unsigned(1, 6) then
-- 		  bit_counter_stop <= '1';
-- 		else
-- 		  bit_counter_stop <= '0';
-- 		 end if;
		
	 end if;
	 end process;
	 
	 bit_counter_stop <='0' when bit_counter /= to_unsigned(0, 8) else 
	 					'1';
 
    sdo <=  '1' when state = S_ACK and crc_calc = crc_read_r else
            '0' when state = S_ACK and crc_calc /= crc_read_r else
            ch_cfg_data_i when state = S_DO_RDCHCFG or state = S_DO_RDCHTEST or state = S_DO_RDDARK else
            crc_calc(7) when state = S_TX_CRC else
            global_config_r(GLOBAL_CONFIG_SIZE-1) when state = S_DO_RDGCFG else
            global_tconfig_r(GLOBAL_TCONFIG_SIZE-1) when state = S_DO_RDGTEST else
            '0';
            
    sdo_oe <=	'1' when state = S_ACK else
    			'1' when state = S_DO_RDCHCFG or state = S_DO_RDCHTEST or state = S_DO_RDDARK else
    			'1' when state = S_TX_CRC else 
    			'1' when state = S_DO_RDGCFG else
    			'1' when state = S_DO_RDGTEST else
    			'0';
    
    ch_cfg_address <= addr_r;
    ch_cfg_enable <= '1' when state = S_DO_WRCHCFG else
                  '1' when state = S_DO_RDCHCFG else
                  '1' when state = S_DO_WRCHTEST else
                  '1' when state = S_DO_RDCHTEST else
                  '1' when state = S_DO_RDDARK else
                  '0';
    ch_cfg_data_o <= payload_r(CH_CONFIG_SIZE-1) when state = S_DO_WRCHCFG else
                  payload_r(CH_TCONFIG_SIZE-1) when state = S_DO_WRCHTEST else                
                '0';
    ch_cfg_cmd <= cmd_r(2 downto 0) when cmd_r(3) = '0' else 
					(others => '0');
                
    process (sclk, reset) begin
    if reset = '1' then
    	global_config <= DEFAULT_G_CONFIG;
    	global_tconfig <= DEFAULT_G_TCONFIG;
    elsif rising_edge(sclk) then
      if state = SSLEEP then
      	global_config <= global_config_r;
      	global_tconfig <= global_tconfig_r;
      end if;
    end if;
    end process;
    
    
    
    
    process (sclk, reset) begin
    if reset = '1' then
      pulse_strobe <= '0';
      pulse_number <= (others => '0');
      pulse_length <= (others => '0');
      pulse_intv <= (others => '0');
    elsif rising_edge(sclk) then
      if state = S_DO_PULSE then
        pulse_number <= payload_r(9 downto 0);
        pulse_length <= payload_r(17 downto 10);
        pulse_intv <= payload_r(25 downto 18);
        pulse_strobe <= '1';
      else
        pulse_strobe <= '0';
      end if;        
    end if;
    end process;
 
  end rtl;
