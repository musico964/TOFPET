library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx_lane_tb is
end tx_lane_tb;


architecture behavioral of tx_lane_tb is
  
  component tx_lane is
  port (
    clk           : in std_logic;
    enable        : in std_logic;
    reset         : in std_logic;
    
    training_mode : in std_logic;
    
    data_in       : std_logic_vector(7 downto 0);
    data_type     : std_logic_vector(1 downto 0);
    
    tx            : out std_logic
  );
  end component;
    
  constant T : time := 6.25 ns;
  signal clk : std_logic := '0';
  signal reset : std_logic;
  signal enable : std_logic;
  signal training_mode : std_logic;
  signal data_in : std_logic_vector(7 downto 0);
  signal data_type : std_logic_vector(1 downto 0);
  signal tx : std_logic;
  
  begin
    
    dut : tx_lane 
    port map (
      clk => clk,
      reset => reset,
      enable => enable,
      training_mode => training_mode,
      data_in => data_in,
      data_type => data_type,
      tx => tx
    );
    
    clk <= not clk after T/2;
    
    tb : process
    begin
      reset <= '1';
      data_type <= "11";
      training_mode <= '1';
      wait for 2*T;
      reset <= '0';
      wait for 10*T;
      enable <= '1';
      wait for 100*T;
      
      training_mode <= '0';
      data_type <= "01";
      wait for 100*T;
      
      data_type <= "10";
      wait for 100*T;
      
      data_type <= "00";
      data_in <= x"AA"; wait for 10*T;
      data_in <= x"BB"; wait for 10*T;
      data_in <= x"00"; 
      data_type <= "11";
      
      
      wait;
    end process;    
    
  end behavioral;
