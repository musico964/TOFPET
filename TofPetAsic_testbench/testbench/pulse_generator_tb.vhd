library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pulse_generator_tb is
end pulse_generator_tb;

architecture behavioral of pulse_generator_tb is
  
  component pulse_generator is
    port (
      clk             : in std_logic;
      reset           : std_logic;
  
      pulse_type      : in std_logic;
      pulse_length    : in std_logic_vector(1 downto 0);
      pulse_number    : in std_logic_vector(9 downto 0);
      pulse_intv      : in std_logic_vector(7 downto 0);
      pulse_strobe    : in std_logic;
  
      test_pulse      : out std_logic;
      tdccal_pulse    : out std_logic
    );
  end component;
  
begin
end behavioral;
