library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity word_fifo is 
  generic (
  	FIFO_WIDTH : integer := 16;
    FIFO_AW : integer := 12;
    FIFO_SIZE : integer := 4096
  );
  port(
    clk     : in std_logic;
    reset   : in std_logic;
    
    wrreq   : in std_logic;
    d       : in std_logic_vector(FIFO_WIDTH-1 downto 0);
    words_avail : out std_logic_vector(FIFO_AW downto 0);
    
    rdreq   : in std_logic;
    q       : out std_logic_vector(FIFO_WIDTH-1 downto 0);
    empty   : out std_logic
  );
end word_fifo;

architecture rtl2 of word_fifo is
type mem_t is array (0 to FIFO_SIZE-1) of std_logic_vector(FIFO_WIDTH-1 downto 0);
signal mem : mem_t;

signal wr_addr : unsigned(FIFO_AW downto 0); 
signal free_words : unsigned (FIFO_AW downto 0);

signal fifo_empty : std_logic;
signal fifo_full : std_logic;
signal valid_wrreq : std_logic;
signal valid_rdreq : std_logic;

begin

fifo_empty <= '1' when wr_addr = to_unsigned(0, FIFO_AW+1) else '0';
fifo_full <= '1' when wr_addr = to_unsigned(FIFO_SIZE, FIFO_AW+1) else '0';

valid_wrreq <= '1' when wrreq = '1' and fifo_full = '0' else '0';
valid_rdreq <= '1' when rdreq = '1' and fifo_empty = '0' else '0';

process (clk, reset)
variable i : integer;
begin
if reset  = '1' then
	wr_addr <= to_unsigned(0, FIFO_AW+1);
	free_words <= to_unsigned(FIFO_SIZE, FIFO_AW+1);
elsif rising_edge(clk) then
	if valid_rdreq = '1' then
		for i in 0 to FIFO_SIZE-2 loop
			mem(i) <= mem(i+1);
		end loop;
		mem(FIFO_SIZE-1) <= (others => '0');
	end if;
	
	if valid_wrreq = '1' and valid_rdreq = '1' then
		mem(to_integer(wr_addr)-1) <= d;
	elsif valid_wrreq = '1' and valid_rdreq = '0' then
		mem(to_integer(wr_addr)) <= d;		
		wr_addr <= wr_addr + 1;
		free_words <= free_words - 1;
	elsif valid_wrreq = '0' and valid_rdreq = '1' then
		wr_addr <= wr_addr - 1;
		free_words <= free_words + 1;	
	end if;	
end if;
end process;

q <= mem(0);
words_avail <= std_logic_vector(free_words);
empty <= fifo_empty;

end;
