library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Test bench for encoder_8b10b
-- Uses enc_8b10 for comparisson and dec_8b10 to validate the output
-- WARNING: enc_8b10 + dec_8b10 do not worklib as expected. There's a bug every 32 symbols

-- encoder_8b10b was also validated using a similar test bench with Xilinx's encoder/decoder


entity encoder_8b10b_tb is
end encoder_8b10b_tb;

architecture behavioral of encoder_8b10b_tb is
  
  component encoder_8b10b is
  port (
    clk     : in std_logic;
    reset   : in std_logic;
    enable  : in std_logic;
    ki      : in std_logic;
    ai      : in std_logic;
    bi      : in std_logic;
    ci      : in std_logic;
    di      : in std_logic;
    ei      : in std_logic;
    fi      : in std_logic;
    gi      : in std_logic;
    hi      : in std_logic;
    
    ao      : out std_logic;
    bo      : out std_logic;
    co      : out std_logic;
    do      : out std_logic;
    eo      : out std_logic;
    io      : out std_logic;
    fo      : out std_logic;
    go      : out std_logic;
    ho      : out std_logic;
    jo      : out std_logic
  );
end component;

component dec_8b10b is	
    port(
		RESET : in std_logic ;	-- Global asynchronous reset (AH) 
		RBYTECLK : in std_logic ;	-- Master synchronous receive byte clock
		AI, BI, CI, DI, EI, II : in std_logic ;
		FI, GI, HI, JI : in std_logic ; -- Encoded input (LS..MS)		
		KO : out std_logic ;	-- Control (K) character indicator (AH)
		HO, GO, FO, EO, DO, CO, BO, AO : out std_logic 	-- Decoded out (MS..LS)
	    );
end component;

component enc_8b10b is	
    port(
		RESET : in std_logic ;		-- Global asynchronous reset (active high) 
		SBYTECLK : in std_logic ;	-- Master synchronous send byte clock
		KI : in std_logic ;			-- Control (K) input(active high)
		AI, BI, CI, DI, EI, FI, GI, HI : in std_logic ;	-- Unencoded input data
		JO, HO, GO, FO, IO, EO, DO, CO, BO, AO : out std_logic 	-- Encoded out 
	    );
end component;

signal clk : std_logic := '0';
signal sclk : std_logic := '0';
signal reset : std_logic := '1';
signal enable : std_logic := '1';

signal ki : std_logic;
signal di : std_logic_vector(7 downto 0);
signal do_v1 : std_logic_vector(9 downto 0);
signal do_V2 : std_logic_vector(9 downto 0);

signal do_disp_v1 : std_logic_vector(9 downto 0);
signal do_disp_v2 : std_logic_vector(9 downto 0);

signal byteo_v1 : std_logic_vector(7 downto 0);
signal byteo_v2 : std_logic_vector(7 downto 0);
signal ko_v1 : std_logic;
signal ko_v2 : std_logic;

signal bo_disp_v1 : std_logic_vector(7 downto 0);
signal ko_disp_v1 : std_logic;

signal bo_disp_v2 : std_logic_vector(7 downto 0);
signal ko_disp_v2 : std_logic;

type ksymbols_t is array (0 to 11) of integer;
constant ksymbols : ksymbols_t := (28, 60, 92, 124, 156, 188, 220, 252, 247, 251, 253, 254);
  
begin
  clk <= not clk after 10 ns;
  sclk <= clk;
  
  enc_v2 : encoder_8b10b 
  port map (
    clk => clk,
    reset => reset,
    enable => enable,
    
    ki => ki,
    ai => di(0),
    bi => di(1),
    ci => di(2),
    di => di(3),
    ei => di(4),
    fi => di(5),
    gi => di(6),
    hi => di(7),
    
    ao => do_v2(9),
    bo => do_v2(8),
    co => do_v2(7),
    do => do_v2(6),
    eo => do_v2(5),
    io => do_v2(4),
    
    fo => do_v2(3),
    go => do_v2(2),
    ho => do_v2(1),
    jo => do_v2(0)
  );
  
  enc_v1 : enc_8b10b 
  port map (
    sbyteclk => clk,
    reset => reset,
    ki => ki,
    ai => di(0),
    bi => di(1),
    ci => di(2),
    di => di(3),
    ei => di(4),
    fi => di(5),
    gi => di(6),
    hi => di(7),
    
    ao => do_v1(9),
    bo => do_v1(8),
    co => do_v1(7),
    do => do_v1(6),
    eo => do_v1(5),
    io => do_v1(4),
    fo => do_v1(3),
    go => do_v1(2),
    ho => do_v1(1),
    jo => do_v1(0)
  );
    
  
  tb : process
  variable i : integer;
  begin
    wait for 200 ns;
    reset <= '0';
    ki <= '1'; 
    di <= x"BC";
    wait for 100 ns;
    for i in 0 to 255 loop 
      ki <= '0';
      di <= std_logic_vector(to_unsigned(i, 8));
      wait for 100 ns;
    end loop;
	 
	  for i in 0 to 11 loop
	    ki <= '1';
	    di <= std_logic_vector(to_unsigned(ksymbols(i), 8));
	    wait for 100 ns;
    end loop;
	   
	 

    ki <= '0'; 
    di <= x"00";
    wait;
    
    
  end process;
  
  
  
  
  process(clk) begin
  if rising_edge(clk) then
    do_disp_v1 <= do_v1;
    do_disp_v2 <= do_v2;
  end if;
  end process;
  
  dec_v1 : dec_8b10b 
  port map (
    rbyteclk => clk,
    reset => reset,
    ai => do_disp_v1(9),
    bi => do_disp_v1(8),
    ci => do_disp_v1(7),
    di => do_disp_v1(6),
    ei => do_disp_v1(5),
    ii => do_disp_v1(4),
    fi => do_disp_v1(3),
    gi => do_disp_v1(2),
    hi => do_disp_v1(1),
    ji => do_disp_v1(0),
    
    ao => byteo_v1(0),
    bo => byteo_v1(1),
    co => byteo_v1(2),  
    do => byteo_v1(3),
    eo => byteo_v1(4),
    fo => byteo_v1(5),  
    go => byteo_v1(6),
    ho => byteo_v1(7),  
    ko => ko_v1
  );
    
dec_v2 : dec_8b10b 
  port map (
    rbyteclk => clk,
    reset => reset,
    ai => do_disp_v2(9),
    bi => do_disp_v2(8),
    ci => do_disp_v2(7),
    di => do_disp_v2(6),
    ei => do_disp_v2(5),
    ii => do_disp_v2(4),
    fi => do_disp_v2(3),
    gi => do_disp_v2(2),
    hi => do_disp_v2(1),
    ji => do_disp_v2(0),
    
    ao => byteo_v2(0),
    bo => byteo_v2(1),
    co => byteo_v2(2),  
    do => byteo_v2(3),
    eo => byteo_v2(4),
    fo => byteo_v2(5),  
    go => byteo_v2(6),
    ho => byteo_v2(7),  
    ko => ko_v2
  );
    
  process (clk) begin
  if rising_edge(clk) then
    bo_disp_v1 <= byteo_v1;
    ko_disp_v1 <= ko_v1;
    bo_disp_v2 <= byteo_v2;
    ko_disp_v2 <= ko_v2;
  end if;
  end process;
  
end behavioral;
