library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx_block_tb is
end tx_block_tb;

architecture behavioral of tx_block_tb is
  
  component word_fifo is 
    generic (
      FIFO_AW : integer := 12
    );
    port(
      clk     : in std_logic;
      reset   : in std_logic;
      
      wrreq   : in std_logic;
      d       : in std_logic_vector(17 downto 0);
      words_avail : out std_logic_vector(FIFO_AW downto 0);
      
      rdreq   : in std_logic;
      q       : out std_logic_vector(17 downto 0);
      empty   : out std_logic
    );
    end component;
    
    component tx_block is
      port (
        clk         : in std_logic;
        reset       : in std_logic;
        
        tx_mode     : in std_logic_vector(1 downto 0);
        tx0         : out std_logic;
        tx1         : out std_logic;
        tx2         : out std_logic;
        tx3         : out std_logic;
        
        fifo_q      : in std_logic_vector(17 downto 0);
        fifo_rdreq  : out std_logic;
        fifo_empty  : in std_logic   
      );
    end component;
    
  constant FIFO_AW : integer := 12;
  constant T : time := 6.25 ns;
  signal clk  : std_logic := '0';
  signal reset : std_logic;
  signal wrreq : std_logic;
  signal d : std_logic_vector(17 downto 0);
  signal words_avail : std_logic_vector(FIFO_AW downto 0);
  signal rdreq : std_logic;
  signal q : std_logic_vector(17 downto 0);
  signal empty : std_logic; 
  
  signal tx_mode : std_logic_vector(1 downto 0);
  signal tx0      : std_logic;
  signal tx1      : std_logic;
  signal tx2      : std_logic;
  signal tx3      : std_logic;
  
begin
  
  clk <= not clk after T/2;
  
  fifo : word_fifo 
    generic map (
      FIFO_AW => 12
      )
    port map (
      clk => clk,
      reset => reset,
      wrreq => wrreq,
      d => d,
      words_avail => words_avail,
      rdreq => rdreq,
      q => q,
      empty => empty
      );
    
    dut : tx_block 
    port map (
      clk => clk,
      reset => reset,
      tx_mode => tx_mode,
      tx0 => tx0,
      tx1 => tx1,
      tx2 => tx2,
      tx3 => tx3,
      
      fifo_q => q,
      fifo_empty => empty,
      fifo_rdreq => rdreq
    );
    
    tb_write : process 
    begin
      reset <= '1';
      tx_mode <= "00";
      d <= (others => '0');
      wrreq <= '0';
      wait for 2*T;
      reset <= '0';
      wait for 40*T;
      
      wrreq <= '1';
      d <= "01" & x"F00F"; wait for T;
      d <= "00" & x"F01F"; wait for T;
      d <= "00" & x"F02F"; wait for T;
      d <= "00" & x"F03F"; wait for T;
      d <= "10" & x"F0FF"; wait for T;
      d <= "01" & x"A00A"; wait for T;
      d <= "00" & x"A01A"; wait for T;
      d <= "00" & x"A02A"; wait for T;
      d <= "10" & x"A0FA"; wait for T;
      d <= (others => '0'); 
      wrreq <= '0';
      
      wait for 1000*T;
      
      wrreq <= '1';
      d <= "01" & x"F00F"; wait for T;
      d <= "00" & x"F01F"; wait for T;
      d <= "00" & x"F02F"; wait for T;
      d <= "00" & x"F03F"; wait for T;
      d <= "10" & x"F0FF"; wait for T;
      d <= "01" & x"A00A"; wait for T;
      d <= "00" & x"A01A"; wait for T;
      d <= "00" & x"A02A"; wait for T;
      d <= "10" & x"A0FA"; wait for T;
      d <= (others => '0'); 
      wrreq <= '0';

      
      wait;
      
    end process;
      
end behavioral;
