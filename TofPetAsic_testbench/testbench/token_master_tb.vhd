library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity token_master_tb is
end token_master_tb;


architecture behavioral of token_master_tb is
  
  component token_master is 
    port (
      clk         : in std_logic;
      reset       : in std_logic;      
      
      token_out   : out std_logic;
      token_in    : in std_logic;
            
      data_in_avail   : in std_logic;
      data_in_valid   : inout std_logic;
      data_in         : inout std_logic_vector(58 downto 0);
      
      data_out_valid  : out std_logic;
      data_out        : out std_logic_vector(58 downto 0);
      
      token_lost_count : out std_logic_vector(9 downto 0)
    );
  end component;
  
  constant T : time := 6.25 ns;
  
  
  signal clk      : std_logic := '0';  
  signal reset    : std_logic;
  signal token_out  : std_logic;
  signal token_in   : std_logic;
  signal data_in_avail  : std_logic;
  signal data_in_valid  : std_logic;
  signal data_in        : std_logic_vector(58 downto 0);
  signal data_out_valid : std_logic;
  signal data_out       : std_logic_vector(58 downto 0);
  signal token_lost_count : std_logic_vector(9 downto 0);

begin
    
  DUT : token_master 
  port map (
    clk => clk,
    reset => reset,
    token_out => token_out,
    token_in => token_in,
    data_in_avail => data_in_avail,
    data_in_valid => data_in_valid,
    data_in => data_in,
    data_out_valid => data_out_valid,
    data_out => data_out,
    token_lost_count => token_lost_count
  );
  
  clk <= not clk after T/2;
  
  tb: process begin
    token_in <= '0';
    data_in_valid <= 'Z';
    data_in <= (others => 'Z');
    reset <= '1'; 
    wait for 2*T;
    reset <= '0';
    
    wait for 4*T;
    assert data_in_valid = '0';
    data_in_avail <= '1';    
    wait for T;
    assert data_in_valid = '0';
    assert token_out = '1'; 
    data_in_avail <= '0';
    wait for T;  
    assert data_in_valid = 'Z';
    data_in <= (others => '0');    
    data_in_valid <= '0';
    wait for T;   
    
    data_in_avail <= '1';
    wait for T;
    assert token_out = '0';
    data_in_avail <= '0';
    wait for T;
    
    
    data_in <= "101" & x"55_5555_5555_5555";
    data_in_valid <= '1';
    wait for T;
    assert data_out_valid = '1';
    assert data_out = "101" & x"55_5555_5555_5555";
    data_in <= (others => '0');    
    data_in_valid <= '0';
    wait for 10*T;
    
    
    data_in <= (others => '0');    
    data_in_valid <= '0';
    wait for T;   
    data_in <= "010" & x"AA_AAAA_AAAA_AAAA";
    data_in_valid <= '1';
    wait for T;
    assert data_out_valid = '1';
    assert data_out = "010" & x"AA_AAAA_AAAA_AAAA";
    
    
    data_in <= "101" & x"55_5555_5555_5555";
    data_in_valid <= '1';
    wait for T;
    assert data_out_valid = '1';
    assert data_out = "101" & x"55_5555_5555_5555";
    
    
    data_in <= (others => '0');    
    data_in_valid <= '0';
    wait for 10*T;
    

    token_in <= '1';
    wait for T;
    token_in <= '0';
    data_in_valid <= 'Z';    
    data_in <= (others => 'Z');
    wait for T;
    assert token_lost_count = b"00_0000_0000";
    
    assert data_in_valid = '0';
    data_in_avail <= '1';    
    wait for T;
    assert data_in_valid = '0';
    assert token_out = '1'; 
    data_in_avail <= '0';
    wait for T;  
    assert data_in_valid = 'Z';
    data_in <= (others => '0');    
    data_in_valid <= '0';
    wait for 520*T;   
    assert token_lost_count = b"00_0000_0001";

    assert data_in_valid = '0';
    data_in_avail <= '1';    
    wait for T;
    assert data_in_valid = '0';
    assert token_out = '1'; 
    data_in_avail <= '0';
    wait for T;  

  
    wait for T; wait;
  end process;
  
  
end behavioral;


