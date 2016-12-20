library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity frame_buffer_tb is
end frame_buffer_tb;


architecture behavioral of frame_buffer_tb is
  
  component frame_buffer is
  port (
    clk     : in std_logic;
    reset   : in std_logic;
    
    data_in         : in std_logic_vector(39 downto 0);
    data_in_valid   : in std_logic;
    
    
    read_mode       : in std_logic;
    event_number    : out std_logic_vector(7 downto 0);
    event_bytes     : out std_logic_vector(10 downto 0);
    event_rdreq     : in std_logic;
    event_data      : out std_logic_vector(39 downto 0)
  );    
  end component;
  
  signal clk : std_logic := '0';
  signal reset : std_logic := '1';
  signal data_in_valid : std_logic := '0';
  signal data_in  : std_logic_vector(39 downto 0);
  signal read_mode  : std_logic := '0';
  signal event_number : std_logic_vector(7 downto 0);
  signal event_bytes : std_logic_vector(10 downto 0);
  signal event_rdreq  : std_logic := '0';
  signal event_data   : std_logic_vector(39 downto 0);
  
  
  constant T : time := 6.25 ns;
  
  
  begin
    
    clk <= not clk after T/2;
    
    dut : frame_buffer 
    port map (
      clk => clk,
      reset => reset,
      data_in_valid => data_in_valid,
      data_in => data_in,
      read_mode => read_mode,
      event_number => event_number,
      event_bytes => event_bytes,
      event_rdreq => event_rdreq,
      event_data => event_data
    );


    tb : process 
    variable i : integer;
    begin
      wait for 2*T;
      reset <= '0';
      
      -- Short test with continuous reading
      for i in 0 to 16 loop
        data_in <= x"AAAA" & std_logic_vector(to_unsigned(i, 8)) & x"5555";
        data_in_valid <= '1';
        wait for T;
      end loop;      
      data_in_valid <= '0';
      wait for T;
      assert to_integer(unsigned(event_number)) = 17 report "Wrong event number";
      read_mode <= '1';
      event_rdreq <= '1';
      wait for 2*T;      
      for i in 0 to 16 loop
        assert event_data = x"AAAA" & std_logic_vector(to_unsigned(i, 8)) & x"5555" report "Wrong data";
        wait for T;
      end loop;
      read_mode <= '0';
      event_rdreq <= '0';
      wait for T;
      assert to_integer(unsigned(event_number)) = 0 report "Event number not reset";
      
      wait for 10*T;
      
      -- Short test with strobed reading
      for i in 0 to 16 loop
        data_in <= x"AAAA" & std_logic_vector(to_unsigned(i, 8)) & x"5555";
        data_in_valid <= '1';
        wait for T;
      end loop;      
      data_in_valid <= '0';      
      wait for T;
      assert to_integer(unsigned(event_number)) = 17 report "Wrong event number";
      read_mode <= '1';
      event_rdreq <= '0';
      wait for 2*T;      
      for i in 0 to 16 loop
        assert event_data = x"AAAA" & std_logic_vector(to_unsigned(i, 8)) & x"5555" report "Wrong data";
        event_rdreq <= '1';
        wait for T;        
        event_rdreq <= '0';
        wait for T;
      end loop;
      read_mode <= '0';
      event_rdreq <= '0';
      wait for T;     
      assert to_integer(unsigned(event_number)) = 0 report "Event number not reset"; 
      
      wait for 10*T;

      
      -- Full buffer test with continuous reading     
      for i in 0 to 127 loop
        data_in <= x"AAAA" & std_logic_vector(to_unsigned(i, 8)) & x"5555";
        data_in_valid <= '1';
        wait for T;
      end loop;      
      data_in_valid <= '0';      
      wait for T;
      assert to_integer(unsigned(event_number)) = 128 report "Wrong event number";
      read_mode <= '1';
      event_rdreq <= '1';
      wait for 2*T;      
      for i in 0 to 127 loop
        assert event_data = x"AAAA" & std_logic_vector(to_unsigned(i, 8)) & x"5555" report "Wrong data";
        wait for T;
      end loop;
      read_mode <= '0';
      event_rdreq <= '0';
      wait for T;
      assert to_integer(unsigned(event_number)) = 0 report "Event number not reset";
      
      wait for 10*T;
      
      -- Over-full buffer test with continuous reading     
      for i in 0 to 130 loop
        data_in <= x"AAAA" & std_logic_vector(to_unsigned(i, 8)) & x"5555";
        data_in_valid <= '1';
        wait for T;
      end loop;      
      data_in_valid <= '0';      
      wait for T;
      assert to_integer(unsigned(event_number)) = 128 report "Wrong event number";
      read_mode <= '1';
      event_rdreq <= '1';
      wait for 2*T;      
      for i in 0 to 127 loop
        assert event_data = x"AAAA" & std_logic_vector(to_unsigned(i, 8)) & x"5555" report "Wrong data";
        wait for T;
      end loop;
      read_mode <= '0';
      event_rdreq <= '0';
      wait for T;
      assert to_integer(unsigned(event_number)) = 0 report "Event number not reset";


    
      wait for 10*T; 
      assert false report "Simulation completed" severity failure;    
    end process;
  end behavioral;
