library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity arithm_tb is
end arithm_tb;


architecture behavioral of arithm_tb is
  
  function binary_to_gray(x: std_logic_vector) return std_logic_vector is
  begin
    return x xor ('0' & x(x'length - 1 downto 1));
  end binary_to_gray;

  function gray_to_binary (x : std_logic_vector) return std_logic_vector is
  variable g : std_logic_vector(x'length-1 downto 0);
  variable b : std_logic_vector(x'length-1 downto 0);
  variable i : integer;
  begin
    g := x;
    b(g'length - 1) := g(g'length - 1);
    for i in g'length - 2 downto 0 loop
      b(i) := b(i+1) xor g(i);
    end loop;
    return b;
  end gray_to_binary;
  
  function odd_parity(x : std_logic_vector) return std_logic is
  variable d: std_logic_vector(x'length - 1 downto 0);
  variable p : std_logic;
  variable i : integer;
  begin
    d := x;
    p := '0';
    for i in d'length - 1 downto 0 loop
      p := p xor d(i);
    end loop;
    return p;
  end odd_parity;

  component arithm is
    port (
    clk         : in std_logic;
    reset       : in std_logic;
    
    data_in     : in std_logic_vector(58 downto 0);
    data_in_valid : in std_logic;
    
    data_out         : out std_logic_vector(39 downto 0);
    data_out_frameid : out std_logic;
    data_out_valid   : out std_logic
    );
  end component; 
  
  constant T : time := 6.25 ns;

  
  signal clk        : std_logic := '0';
  signal reset      : std_logic := '1';
  signal in_chid    : integer := 0;
  signal in_frameid : std_logic := '0';
  signal in_tcoarse : integer := 0;
  signal in_teoc    : integer := 0;
  signal in_soc     : integer := 0;
  signal in_ecoarse : integer := 0;
  signal in_eeoc    : integer := 0;
  signal in_p_ok    : std_logic := '0';
  signal data_in    : std_logic_vector(58 downto 0);
  signal data_in_valid : std_logic := '0';
  
  signal out_chid     : integer := 0;
  signal out_tcoarse  : integer := 0;
  signal out_tfine    : integer := 0;
  signal out_ecoarse  : integer := 0;
  signal out_efine    : integer := 0;
  signal out_p_ok     : std_logic := '0';
  signal data_out     : std_logic_vector(39 downto 0);
  signal data_out_frameid : std_logic := '0';
  signal data_out_valid : std_logic := '0';
  
  
  signal bi       : std_logic_vector(9 downto 0);
  signal g        : std_logic_vector(9 downto 0);
  signal bo       : std_logic_vector(9 downto 0);
  
  signal parity_data : std_logic_vector(9 downto 0);
  signal parity   : std_logic;     
    
begin
  
  process 
    variable i : integer;
    variable vbi : std_logic_vector(9 downto 0);
    variable vg  : std_logic_vector(9 downto 0);
    variable vbo : std_logic_vector(9 downto 0);

  begin
    for i in 0 to 1023 loop
      vbi := std_logic_vector(to_unsigned(i, 10));
      vg  := binary_to_gray(vbi);
      vbo := gray_to_binary(vg);
      assert to_integer(unsigned(vbo)) = i report "Gray encode/decode failed";

      bi <= vbi; 
      g <= vg; 
      bo <= vbo;
      wait for T;
    end loop; 
    wait for T;   
    wait;
  end process;
  
  process 
    variable i : integer;
    variable d: std_logic_vector(9 downto 0);
    variable p : std_logic;
  begin
    for i in 0 to 1023 loop
      d := std_logic_vector(to_unsigned(i, 10));
      p := odd_parity(d);
      
      parity_data <= d;
      parity <= p;
      wait for T;
    end loop;
    
    wait for T; wait;
  end process;
  
  clk <= not clk after T/2;
  
  data_in(58 downto 1) <= 
    std_logic_vector(to_unsigned(in_chid, 7)) &
    in_frameid & 
    binary_to_gray(std_logic_vector(to_unsigned(in_tcoarse, 10))) &
    binary_to_gray(std_logic_vector(to_unsigned(in_teoc, 10))) &
    binary_to_gray(std_logic_vector(to_unsigned(in_soc, 10))) &
    binary_to_gray(std_logic_vector(to_unsigned(in_ecoarse, 10))) & 
    binary_to_gray(std_logic_vector(to_unsigned(in_eeoc, 10)));

  data_in(0) <= 
    odd_parity(data_in(58 downto 1)) when in_p_ok = '1' else
    not odd_parity(data_in(58 downto 1));
  

  out_tcoarse <= to_integer(unsigned(data_out(39 downto 30)));
  out_ecoarse <= to_integer(unsigned(data_out(29 downto 24)));
  out_tfine <= to_integer(unsigned(data_out(23 downto 16)));
  out_efine <= to_integer(unsigned(data_out(15 downto 8)));
  out_chid <= to_integer(unsigned(data_out(7 downto 1)));
  out_p_ok <= '1' when odd_parity(data_out(39 downto 1)) = data_out(0) else '0';
  
  
  dut : arithm 
  port map (
    clk => clk,
    reset => reset,
    data_in => data_in,
    data_in_valid => data_in_valid,
    
    data_out => data_out,
    data_out_frameid => data_out_frameid,
    data_out_valid => data_out_valid
  );
  
  tb : process  
  variable i,j : integer;
  begin
    reset <= '1';
    data_in_valid <= '0';
    wait for 2*T;
    reset <= '0';
    assert data_out_valid = '0';
    wait for T; 
    assert data_out_valid = '0';

    -- Pipeline test..
    for i in 0 to 10000+4 loop
      j := i - 4;
      if i <= 10000 then
        in_chid <= ( i+64 ) mod 128;
        in_tcoarse <= ( 2*i ) mod 1024;
        in_ecoarse <= ( 2*i + i/10 ) mod 1024;
        in_soc <= ( 3*i ) mod 1024;
        in_teoc <= ( 3*i + i / 4 ) mod 1024;
        in_eeoc <= ( 3*i + i/3 ) mod 1024;
        data_in_valid <= '1';
        if i mod 2 = 0 then
          in_p_ok <= '1';
        else
          in_p_ok <= '0';
        end if;
      else
        data_in_valid <= '0';
      end if;
      
      if j >= 0 then
        assert data_out_valid = '1';
        assert out_chid = ( j+64 ) mod 128;
        assert out_tcoarse = ( 2*j ) mod 1024;
        if j/10 <= 63 then
          assert out_ecoarse = j/10;
        else
          assert out_ecoarse = 63;
        end if;
        
        assert out_tfine = ( j/4 ) mod 256;
        assert out_efine = ( j/3 ) mod 256;
      else
        assert data_out_valid = '0' report "data_out_valid";
      end if;
      
      wait for T;
    end loop;
    
    
    wait for T; 
    assert false report "Simulation completed" severity failure;
  end process;


end behavioral;
