library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity frame_formater_tb is
end frame_formater_tb;

architecture behavioral of frame_formater_tb is
  
  component frame_formater is
  generic (
    FIFO_AW : integer := 12
  );
  port (
    clk       : in std_logic;
    reset     : in std_logic;
    
    start     : in std_logic;
    frame_id  : in std_logic_vector(31 downto 0);
    event_number : in std_logic_vector(7 downto 0);
    event_bytes : in std_logic_vector(10 downto 0);
    event_rdreq : out std_logic;
    event_data  : in std_logic_vector(39 downto 0);    
    
    q           : out std_logic_vector(17 downto 0);
    wrreq       : out std_logic;
    words_avail : in std_logic_vector(9 downto 0)
  );
    
end component;

function crc16(crc_i : std_logic_vector(15 downto 0); data_i: std_logic_vector(15 downto 0))
  return std_logic_vector is
  variable crc_o : std_logic_vector(15 downto 0);
  begin
    crc_o(0) := data_i(0) xor data_i(4) xor data_i(11) xor crc_i(0) xor crc_i(11) xor data_i(8) xor crc_i(4) xor data_i(12) xor crc_i(8) xor crc_i(12); 
    crc_o(1) := data_i(1) xor data_i(5) xor data_i(12) xor crc_i(1) xor crc_i(12) xor data_i(9) xor crc_i(5) xor data_i(13) xor crc_i(9) xor crc_i(13); 
    crc_o(2) := data_i(2) xor data_i(6) xor data_i(13) xor crc_i(2) xor crc_i(13) xor data_i(10) xor crc_i(6) xor data_i(14) xor crc_i(10) xor crc_i(14); 
    crc_o(3) := data_i(3) xor data_i(7) xor data_i(14) xor crc_i(3) xor crc_i(14) xor data_i(11) xor crc_i(7) xor data_i(15) xor crc_i(11) xor crc_i(15); 
    crc_o(4) := data_i(4) xor data_i(8) xor data_i(15) xor crc_i(4) xor crc_i(15) xor data_i(12) xor crc_i(8) xor crc_i(12); 
    crc_o(5) := data_i(0) xor data_i(5) xor data_i(9) xor crc_i(5) xor data_i(13) xor crc_i(9) xor crc_i(13) xor data_i(4) xor data_i(11) xor crc_i(0) xor crc_i(11) xor data_i(8) xor crc_i(4) xor data_i(12) xor crc_i(8) xor crc_i(12); 
    crc_o(6) := data_i(1) xor data_i(6) xor data_i(10) xor crc_i(6) xor data_i(14) xor crc_i(10) xor crc_i(14) xor data_i(5) xor data_i(12) xor crc_i(1) xor crc_i(12) xor data_i(9) xor crc_i(5) xor data_i(13) xor crc_i(9) xor crc_i(13); 
    crc_o(7) := data_i(2) xor data_i(7) xor data_i(11) xor crc_i(7) xor data_i(15) xor crc_i(11) xor crc_i(15) xor data_i(6) xor data_i(13) xor crc_i(2) xor crc_i(13) xor data_i(10) xor crc_i(6) xor data_i(14) xor crc_i(10) xor crc_i(14); 
    crc_o(8) := data_i(3) xor data_i(8) xor data_i(12) xor crc_i(8) xor crc_i(12) xor data_i(7) xor data_i(14) xor crc_i(3) xor crc_i(14) xor data_i(11) xor crc_i(7) xor data_i(15) xor crc_i(11) xor crc_i(15); 
    crc_o(9) := data_i(4) xor data_i(9) xor data_i(13) xor crc_i(9) xor crc_i(13) xor data_i(8) xor data_i(15) xor crc_i(4) xor crc_i(15) xor data_i(12) xor crc_i(8) xor crc_i(12); 
    crc_o(10) := data_i(5) xor data_i(10) xor data_i(14) xor crc_i(10) xor crc_i(14) xor data_i(9) xor crc_i(5) xor data_i(13) xor crc_i(9) xor crc_i(13); 
    crc_o(11) := data_i(6) xor data_i(11) xor data_i(15) xor crc_i(11) xor crc_i(15) xor data_i(10) xor crc_i(6) xor data_i(14) xor crc_i(10) xor crc_i(14); 
    crc_o(12) := data_i(0) xor data_i(7) xor crc_i(7) xor data_i(15) xor crc_i(15) xor data_i(4) xor crc_i(0) xor data_i(8) xor crc_i(4) xor crc_i(8); 
    crc_o(13) := data_i(1) xor data_i(8) xor crc_i(8) xor data_i(5) xor crc_i(1) xor data_i(9) xor crc_i(5) xor crc_i(9); 
    crc_o(14) := data_i(2) xor data_i(9) xor crc_i(9) xor data_i(6) xor crc_i(2) xor data_i(10) xor crc_i(6) xor crc_i(10); 
    crc_o(15) := data_i(3) xor data_i(10) xor crc_i(10) xor data_i(7) xor crc_i(3) xor data_i(11) xor crc_i(7) xor crc_i(11); 
    return crc_o;
  end crc16;

constant T          : time := 6.25 ns;
signal clk          : std_logic := '0';
signal reset        : std_logic := '1';
signal start        : std_logic := '0';

signal frame_id     : std_logic_vector(31 downto 0) := x"0000_0000";
signal event_number : std_logic_vector(7 downto 0) := x"00";
signal event_bytes  : std_logic_vector(10 downto 0) := b"000_0000_0000";
signal event_rdreq  : std_logic := '0';
signal event_data   : std_logic_vector(39 downto 0) := x"00_0000_0000";

signal q            : std_logic_vector(17 downto 0);
signal wrreq        : std_logic;
signal words_avail  : std_logic_vector(9 downto 0) := b"00_0000_0000";


signal expected_crc : std_logic_vector(15 downto 0);

type buffer_t is array (0 to 2047) of std_logic_vector(7 downto 0);
signal source_buffer : buffer_t;
signal sink_buffer : buffer_t;

  
begin
  clk <= not clk after T/2;
  
  dut : frame_formater 
  port map (
    clk => clk,
    reset => reset,
    start => start,
    frame_id => frame_id,
    event_number => event_number,
    event_bytes => event_bytes,
    event_rdreq => event_rdreq,
    event_data => event_data,
    q => q,
    wrreq => wrreq,
    words_avail => words_avail
  );
    
  tb_gen : process
  
  variable i : integer;
  variable n : integer;
  variable k : integer;
  variable my_event_number : std_logic_vector(7 downto 0);
  variable my_frame_id : std_logic_vector(31 downto 0);
  variable my_event    : std_logic_vector(39 downto 0);
  variable my_bytes : integer;
  variable my_words : integer;
  variable crc : std_logic_vector(15 downto 0);
  
  begin
    wait for 2*T;
    reset <= '0';
    words_avail <= std_logic_vector(to_unsigned(8, 10));
    event_number <= std_logic_vector(to_unsigned(1, 8));
    event_bytes <= std_logic_vector(to_unsigned(5, 11));
    event_data <= x"5A_5A5A_5A5A";
    frame_id <= x"9876_5432";
    wait for T;
    start <= '1';
    wait for T;
    start <= '0';
    wait for 6*T;
    assert wrreq = '0';
    
    wait for 10*T;
    words_avail <= std_logic_vector(to_unsigned(7, 10));
    event_number <= std_logic_vector(to_unsigned(1, 8));
    event_bytes <= std_logic_vector(to_unsigned(5, 11));
    event_data <= x"5A_5A5A_5A5A";
    frame_id <= x"8765_4321";
    wait for T;
    start <= '1';    
    wait for T;
    start <= '0';
    assert q = "01" & x"0087";
    wait for 4*T;
    assert wrreq = '0';
    
    
    
    
    wait for 20*T;
    words_avail <= std_logic_vector(to_unsigned(1023, 10));

    for n in 0 to 127 loop
      
        my_event_number := std_logic_vector(to_unsigned(n, 8));
        my_frame_id :=  std_logic_vector(to_unsigned(n, 16)) &
                        std_logic_vector(to_unsigned(n, 16));
        source_buffer(0) <= my_event_number;
        source_buffer(1) <= my_frame_id(31 downto 24);
        source_buffer(2) <= my_frame_id(23 downto 16);
        source_buffer(3) <= my_frame_id(15 downto  8);
        source_buffer(4) <= my_frame_id( 7 downto  0);
        for i in 0 to n - 1 loop 
          my_event := x"FA" & 
                      std_logic_vector(to_unsigned(i, 16)) & x"5AA5";
          source_buffer(5*i+5) <= my_event(39 downto 32);
          source_buffer(5*i+6) <= my_event(31 downto 24);
          source_buffer(5*i+7) <= my_event(23 downto 16);
          source_buffer(5*i+8) <= my_event(15 downto  8);
          source_buffer(5*i+9) <= my_event( 7 downto  0);                    
        end loop;
        if n mod 2 = 0 then
          source_buffer(5*n+5) <= x"00";
        end if;
        
        
        event_number <= my_event_number;
        event_bytes <= std_logic_vector(to_unsigned(5, 3) * unsigned(my_event_number));
        frame_id <= my_frame_id;
        wait for T;
        start <= '1';
        wait for T;
        start <= '0';
        for i in 0 to n - 1 loop
          event_data <= x"FA" & 
                      std_logic_vector(to_unsigned(i, 16)) & x"5AA5";
          wait until event_rdreq = '1'; wait for 0.5 * T;
        end loop;        
        wait for 10 * T;
        
        my_bytes := 5 + 5*n;
        if my_bytes mod 2 = 1 then
          my_bytes := my_bytes + 1;
        end if;
          
        for i in 0 to my_bytes - 1 loop
          assert source_buffer(i) = sink_buffer(i) report "Buffered data mismatch";
        end loop;
        
    end loop;    
    
    assert false report "Simulation finished" severity failure;
    wait;
    
  end process;
  
  tb_recv : process 
  variable my_event_number : integer;
  variable n_bytes : integer;
  variable n_words : integer;
  variable i : integer;  
  variable crc : std_logic_vector(15 downto 0);
  begin
    wait until wrreq = '1'; wait for 0.5*T;
    assert q(17 downto 16) = b"01" report "Expected start of packet";
    my_event_number := to_integer(unsigned(q(15 downto 8)));
    n_bytes := 5 + 5*my_event_number;
    if n_bytes mod 2 = 0 then
      n_words := n_bytes/2;
    else
      n_words := (n_bytes+1)/2;
    end if;
    sink_buffer(0) <= q(15 downto 8); 
    sink_buffer(1) <= q( 7 downto 0);
    crc := crc16(x"0F4A", q(15 downto 0));
    wait for T;
    for i in 1 to n_words - 1 loop    
      assert q(17 downto 16) = b"00" report "Expected middle of packet";
      sink_buffer(2*i+0) <= q(15 downto 8); 
      sink_buffer(2*i+1) <= q( 7 downto 0); 
      crc := crc16(crc, q(15 downto 0));
      wait for T;
    end loop;
    expected_crc <= crc;
    assert q(17 downto 16) = b"10" report "Expected end of packet";    
    assert q(15 downto 0) = crc report "CRC Mismatch";
    
    
    wait for 2*T;
    
  end process;

    
end behavioral;
