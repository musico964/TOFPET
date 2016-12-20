library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity serializer_tb is
end serializer_tb;


architecture behavioral of serializer_tb is
  
  component serializer 
    port (
      clk       : in std_logic;
      reset     : in std_logic;
      tx_mode   : in std_logic_vector(1 downto 0);
      
      data_in   : in std_logic_vector(19 downto 0);
      data_strobe : out std_logic;
      
      tx        : out std_logic_vector(3 downto 0)
    );
  end component;

  constant T : time := 6.25 ns;
  signal clk : std_logic := '0';
  signal reset : std_logic;
  signal tx_mode : std_logic_vector(1 downto 0);
  signal data_in : std_logic_vector(19 downto 0);
  signal data_strobe : std_logic;
  signal tx : std_logic_vector(3 downto 0);
  
  
  begin
    
    dut : serializer 
    port map(
      clk => clk,
      reset => reset,
      tx_mode => tx_mode,
      data_in => data_in,
      data_strobe => data_strobe,
      tx => tx
    );
    
  
    clk <= not clk after T/2;
    
    tb : process 
    variable i : integer;
    begin
      reset <= '1';
      wait for 2*T;
      reset <= '0';
      tx_mode <= b"00";
      wait for 20*T;
      data_in <= x"11111"; wait for 20*T;
      data_in <= x"22222"; wait for 20*T;
      data_in <= x"33333"; wait for 20*T;
      data_in <= x"44444"; wait for 20*T;
      wait for 20*T;
      
            
      
      
  
      
      wait;
      
    end process;
    
  end behavioral;