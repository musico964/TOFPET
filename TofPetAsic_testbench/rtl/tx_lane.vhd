library ieee, gctrl_lib;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tx_lane is
  port (
    clk           : in std_logic;
    reset         : in std_logic;
    enable        : in std_logic;
    training_mode : in std_logic;
    ddr_mode	  : in std_logic;
        
    byte_strobe   : in std_logic;
        
    di            : in std_logic_vector(7 downto 0);
    ki            : in std_logic;
    
    tx            : out std_logic
  );
end tx_lane;

architecture rtl of tx_lane is
  
 
  signal enc_do : std_logic_vector(9 downto 0);
  signal data_sr : std_logic_vector(9 downto 0);
  
  signal sdr_do : std_logic;
  signal ddr_do : std_logic;
  
  signal sdr_y : std_logic;
  signal ddr_y : std_logic;
  
begin
  
  encoder : entity gctrl_lib.encoder_8b10b 
    port map (
      clk => clk,
      reset => reset,
      enable => byte_strobe,
      KI => ki,
      AI => di(0),
      BI => di(1),
      CI => di(2),
      DI => di(3),
      EI => di(4),
      FI => di(5),
      GI => di(6),
      HI => di(7),
      
      JO => enc_do(0),
      HO => enc_do(1),
      GO => enc_do(2),
      FO => enc_do(3),
      IO => enc_do(4),
      EO => enc_do(5),
      DO => enc_do(6),
      CO => enc_do(7),
      BO => enc_do(8),
      AO => enc_do(9)
    );
    

process (clk, reset) begin
  if reset = '1' then
    data_sr <= (others => '0');
  elsif rising_edge(clk) then
    if enable = '1' then
      if byte_strobe = '1' then
        if training_mode = '1' then
          data_sr <= b"01_0101_0101";
        else
          data_sr <= enc_do;
        end if;        
      else 
      	if ddr_mode = '0' then
        	data_sr <= data_sr(8 downto 0) & '0';
        else
        	data_sr <= data_sr(7 downto 0) & "00";
        end if;
      end if;      
    end if;   
  end if;
  end process;
    

ddr_buffer : entity gctrl_lib.ddr_output 
	port map (
		clk => clk,
		di_l => data_sr(9),
		di_h => data_sr(8),
		do => ddr_do
	);
   
sdr_buffer : entity gctrl_lib.sdr_output 
	port map (
		clk => clk,
		di => data_sr(9),
		do => sdr_do
	);
	
--	sdr_y <= '1' when sdr_do = '1' and ddr_mode = '0' else '0';
--	ddr_y <= '1' when ddr_do = '1' and ddr_mode = '1' else '0';
	tx <= sdr_do when ddr_mode = '0' else ddr_do;

end rtl;
