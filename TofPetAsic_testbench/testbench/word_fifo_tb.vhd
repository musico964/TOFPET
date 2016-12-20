library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity word_fifo_tb is 
end word_fifo_tb;

architecture behavioral of word_fifo_tb is
  
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
  
  begin
    
    clk <= not clk after T/2;
    
    dut : word_fifo 
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
      
    tb_write : process 
    variable i : unsigned(17 downto 0);
    begin
      reset <= '1';
      wait for 2*T;
      reset <= '0';
      
      i := to_unsigned(0, 18);
      while true loop
        if to_integer(unsigned(words_avail)) > 0 then
          d <= std_logic_vector(i);
          wrreq <= '1';
          i := i + 1;
        else
          d <= (others => '0');
          wrreq <= '0';
        end if;
        wait for T;          
      end loop;
      
     
    end process;
    
    tb_read : process 
    variable i : unsigned(17 downto 0);
    begin
      i := to_unsigned(0, 18);      
      wait for 3 *T ;
      while true loop
        assert q = std_logic_vector(i);
        i := i + 1;
        if empty /= '1' then
          rdreq <= '1';
        else
          rdreq <= '0';
        end if;
        wait for T;
        rdreq <= '0';
        wait for T;
      end loop;
    end process;
      
  end behavioral;
