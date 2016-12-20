library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity arithm is 
  port(
    clk         : in std_logic;
    reset       : in std_logic;
    enable		: in std_logic;
    
    fine_counter_sub      : in std_logic_vector(7 downto 0);    
    fine_counter_saturate : in std_logic;
    
    data_in     : in std_logic_vector(60 downto 0);
    data_in_valid : in std_logic;
    
    data_out         : out std_logic_vector(39 downto 0);
    data_out_frameid : out std_logic;
    data_out_valid   : out std_logic
  );
end arithm;


architecture rtl of arithm is
  
  function gray_to_binary (x : std_logic_vector) return std_logic_vector is
  variable g : std_logic_vector(x'length-1 downto 0);
  variable b : std_logic_vector(x'length-1 downto 0);
  variable i : integer;
  begin
    g := x;
    b(g'length - 1) := g(g'length - 1);
    for i in g'length - 2 downto 0 loop
      b(i) := b(i+1) xor g(i);
    end loop;
    return b;
  end gray_to_binary;
  
  function odd_parity(x : std_logic_vector) return std_logic is
  variable d: std_logic_vector(x'length - 1 downto 0);
  variable p : std_logic;
  variable i : integer;
  begin
	 d := x;
    p := '0';
    for i in d'length - 1 downto 0 loop
      p := p xor d(i);
    end loop;
    return p;
  end odd_parity;
  
  signal data_in_r        : std_logic_vector(60 downto 0);
  signal data_in_valid_r  : std_logic;
  
  signal event_q0_chid    : std_logic_vector(6 downto 0);
  signal event_q0_tacid   : std_logic_vector(1 downto 0);
  signal event_q0_frameid : std_logic;
  signal event_q0_tcoarse : unsigned(9 downto 0);
  signal event_q0_teoc    : signed(10 downto 0);
  signal event_q0_soc     : signed(10 downto 0);
  signal event_q0_ecoarse : unsigned(9 downto 0);
  signal event_q0_eeoc    : signed(10 downto 0);
  signal event_q0_parity_ok : std_logic;
  signal event_q0_valid   : std_logic;
  
  signal event_q1_chid   : std_logic_vector(6 downto 0);
  signal event_q1_tacid  : std_logic_vector(1 downto 0);
  signal event_q1_frameid: std_logic;
  signal event_q1_tcoarse: unsigned(9 downto 0);
  signal event_q1_tfine  : signed(11 downto 0);
  signal event_q1_ecoarse: unsigned(10 downto 0);
  signal event_q1_efine  : signed(11 downto 0);
  signal event_q1_parity_ok : std_logic;
  signal event_q1_valid  : std_logic;  
  
  signal event_q1_ecoarse_saturated : unsigned(5 downto 0);
  signal event_q1_tfine_actual : signed(8 downto 0);
  signal event_q1_efine_actual : signed(8 downto 0);
  
  
  signal data_out_c         : std_logic_vector(39 downto 0);
  signal data_out_frameid_c : std_logic;
  signal data_out_valid_c   : std_logic;
  
  signal b_value : signed(11 downto 0);
begin
  
  process(clk, reset) begin
  if reset = '1' then
    data_in_r <= (others => '0');
    data_in_valid_r <= '0';
  elsif rising_edge(clk) and enable = '1' then
    if data_in_valid = '1'then
    	data_in_valid_r <= '1';
		data_in_r <= data_in;    
	else
		data_in_valid_r <= '0';
	end if;
  end if;
  end process;
  
  process (clk, reset) begin
  if reset = '1' then
    event_q0_chid <= (others => '0');
    event_q0_tacid <= (others => '0');
    event_q0_frameid <= '0';
    event_q0_tcoarse <= to_unsigned(0, 10);
    event_q0_teoc <= to_signed(0, 11);
    event_q0_soc <= to_signed(0, 11);
    event_q0_ecoarse <= to_unsigned(0, 10);
    event_q0_eeoc <= to_signed(0, 11);
    event_q0_parity_ok <= '0';
    event_q0_valid <= '0';
  elsif rising_edge(clk) and enable = '1' then
    event_q0_chid <= data_in_r(60 downto 54);
    event_q0_tacid <= data_in_r(53 downto 52);
    event_q0_frameid <= data_in_r(51);
    event_q0_tcoarse <= unsigned(gray_to_binary(data_in_r(50 downto 41)));
    event_q0_ecoarse <= unsigned(gray_to_binary(data_in_r(40 downto 31)));    
    event_q0_soc <= signed('0' & gray_to_binary(data_in_r(30 downto 21)));
    event_q0_teoc <= signed('0' & gray_to_binary(data_in_r(20 downto 11)));
    event_q0_eeoc <= signed('0' & gray_to_binary(data_in_r(10 downto 1)));
    if data_in_r(0) =  odd_parity(data_in_r(58 downto 1)) then
      event_q0_parity_ok <= '1';
    else
      event_q0_parity_ok <= '0';
    end if;
    event_q0_valid <= data_in_valid_r;
  end if;
  end process;
  
  
  b_value <= signed(b"0000" & fine_counter_sub);
 
  process (clk, reset) begin
  if reset = '1' then
    event_q1_chid <= (others => '0');
    event_q1_tacid <= (others => '0');
    event_q1_frameid <= '0';
    event_q1_tcoarse <= to_unsigned(0, 10);
    event_q1_tfine <= to_signed(0, 12);
    event_q1_ecoarse <= to_unsigned(0, 11);
    event_q1_efine <= to_signed(0, 12);
    event_q1_parity_ok <= '0';
    event_q1_valid <= '0';      
  elsif rising_edge(clk) and enable = '1' then
    event_q1_chid <= event_q0_chid;
    event_q1_tacid <= event_q0_tacid;
    event_q1_frameid <= event_q0_frameid;
    event_q1_tcoarse <= event_q0_tcoarse;
    if event_q0_teoc >= event_q0_soc then
      event_q1_tfine <= to_signed(0, 12) + event_q0_teoc - event_q0_soc - b_value;
    else
      event_q1_tfine <= to_signed(1024, 12) + event_q0_teoc - event_q0_soc - b_value;
    end if;
    
    if event_q0_ecoarse >= event_q0_tcoarse then
      event_q1_ecoarse <= to_unsigned(0, 11) + event_q0_ecoarse - event_q0_tcoarse;
    else
      event_q1_ecoarse <= to_unsigned(1024, 11) + event_q0_ecoarse - event_q0_tcoarse;
    end if;
  
    if event_q0_eeoc >= event_q0_soc then
      event_q1_efine <= to_signed(0, 12) + event_q0_eeoc - event_q0_soc - b_value;
    else
      event_q1_efine <= to_signed(1024, 12) + event_q0_eeoc - event_q0_soc - b_value;
    end if;
      
    event_q1_parity_ok <= event_q0_parity_ok;
    event_q1_valid <= event_q0_valid;      
  end if;
  end process;
  
  event_q1_ecoarse_saturated <= 
    event_q1_ecoarse(5 downto 0) when event_q1_ecoarse <= to_unsigned(63, 11) 
    else to_unsigned(63, 6);
    	 
	event_q1_tfine_actual <= to_signed(0, 9) when fine_counter_saturate = '1' and event_q1_tfine < 0 else
	                          to_signed(255, 9) when fine_counter_saturate = '1' and event_q1_tfine > 255 else
	                          event_q1_tfine(8 downto 0);
    		  
  event_q1_efine_actual <= to_signed(0, 9) when fine_counter_saturate = '1' and event_q1_efine < 0 else
                           to_signed(255, 9) when fine_counter_saturate = '1' and event_q1_efine > 255 else
                           event_q1_efine(8 downto 0);
   
		
  
  data_out_c <= 
    std_logic_vector(event_q1_tcoarse) &
    std_logic_vector(event_q1_ecoarse_saturated) &
    std_logic_vector(event_q1_tfine_actual(7 downto 0)) &
    std_logic_vector(event_q1_efine_actual(7 downto 0)) & 
    event_q1_chid(5 downto 0) &
    event_q1_tacid;

                   
  data_out_frameid_c <= event_q1_frameid;
  data_out_valid_c <= event_q1_valid;            
  
  process (clk, reset) begin
  if reset = '1' then
    data_out <= (others => '0');
    data_out_frameid <= '0';
    data_out_valid <= '0';
  elsif rising_edge(clk) and enable = '1' then
    data_out <= data_out_c;
    data_out_frameid <= data_out_frameid_c;
    data_out_valid <= data_out_valid_c;
  end if;
  end process;
  

end rtl;
