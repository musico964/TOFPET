library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pulse_generator is
  port (
    clk             : in std_logic;
    reset           : std_logic;
    pulse_number    : in std_logic_vector(9 downto 0);
    pulse_length 	: in std_logic_vector(7 downto 0);
    pulse_intv      : in std_logic_vector(7 downto 0);
    pulse_strobe    : in std_logic;
    test_pulse      : out std_logic
  );
end pulse_generator;

architecture rtl of pulse_generator is
  
  type state_t is (
    S_IDLE, S_PRE_PULSE, S_PULSE, S_PRE_INTV, S_INTV
  );
  signal state : state_t;
  
  signal pulse_strobe_delayed : std_logic;
  signal pulse_strobe_valid : std_logic;
  signal pulse_counter : unsigned(9 downto 0);
  
  signal aux_counter : unsigned(14 downto 0);
  
begin
  
  process (clk, reset) begin
  if reset = '1' then
    pulse_strobe_delayed <= '0';
  elsif rising_edge(clk) then
    pulse_strobe_delayed <= pulse_strobe;
  end if;
  end process;
  
  pulse_strobe_valid <= '1' when pulse_strobe = '1' and pulse_strobe_delayed = '0' else '0';
  
  process(clk, reset) begin
  if reset = '1' then
    state <= S_IDLE;
         
  elsif rising_edge(clk) then   
    if pulse_strobe_valid = '1' then
        state <= S_PRE_PULSE;
     
    elsif state = S_IDLE then
      state <= S_IDLE;
      
   	elsif state = S_PRE_PULSE then
   		state <= S_PULSE;
      
    elsif state = S_PULSE then
    	if aux_counter = to_unsigned(0, 15) then
			state <= S_PRE_INTV;
		end if;
		
	elsif state = S_PRE_INTV then
		if pulse_counter = to_unsigned(0, 8) then
			state <= S_IDLE;
		else
			state <= S_INTV;
		end if; 
      
    elsif state = S_INTV then
      if aux_counter = to_unsigned(0, 8) then
      	state <= S_PRE_PULSE;
      end if;
      
    else
      state <= S_IDLE;
    end if;
  end if;
  end process;
  
	process (clk, reset) begin
	if reset = '1' then
		pulse_counter <= to_unsigned(0, 10);
	elsif rising_edge(clk) then
		if pulse_strobe_valid = '1' then 
			pulse_counter <= unsigned(pulse_number) + 1;
		elsif state = S_PRE_PULSE then
			pulse_counter <= pulse_counter - to_unsigned(1, 10);
		end if;
	end if;
  end process;

  process (clk, reset) begin
  if reset = '1' then
    aux_counter <= to_unsigned(0, 15);
  elsif rising_edge(clk) then
  	if state = S_PRE_PULSE then
  		aux_counter <= b"000_0000" & unsigned(pulse_length);
    elsif state = S_PRE_INTV then
      aux_counter <= unsigned(pulse_intv & b"000_0000") + 124;
    elsif aux_counter /= to_unsigned(0, 15) then
      aux_counter <= aux_counter - to_unsigned(1, 15);
    end if;
  end if;
  end process;
  
  test_pulse <= '1' when state = S_PULSE else '0';
end rtl;
