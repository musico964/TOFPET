library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity encoder_8b10b is
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
end encoder_8b10b;

architecture rtl of encoder_8b10b is
  
  function code_has_disparity (code : std_logic_vector) return std_logic is 
  variable d : std_logic_vector(code'length - 1 downto 0);
  variable disparity : integer;
  variable i : integer;
  begin
    d := code;
    disparity := 0;
    for i in d'length - 1 downto 0 loop
      if d(i) = '1' then
        disparity := disparity + 1;
      elsif d(i) = '0' then
        disparity := disparity - 1;
      else 
        return 'X';
      end if;      
    end loop;
	 
	 if disparity = 0 then
		return '0';
	  else
	    return '1';
	  end if;		
  end code_has_disparity;


  -- Table for 6B D.x codes with positive/neutral disparity
  -- Codes with negative disparity and K.28.x will be handled separatedly..
  function table_6b (edcba : std_logic_vector(4 downto 0)) return std_logic_vector is
  variable r : std_logic_vector(5 downto 0);
  begin
  case to_integer(unsigned(edcba)) is 
  when 00 => r := "100111";
  when 01 => r := "011101";
  when 02 => r := "101101";
  when 03 => r := "110001";    
  when 04 => r := "110101";
  when 05 => r := "101001";
  when 06 => r := "011001";
  when 07 => r := "111000";
    
  when 08 => r := "111001";
  when 09 => r := "100101";
  when 10 => r := "010101";
  when 11 => r := "110100";
  when 12 => r := "001101";
  when 13 => r := "101100";
  when 14 => r := "011100";
  when 15 => r := "010111";
    
  when 16 => r := "011011";  
  when 17 => r := "100011";
  when 18 => r := "010011";
  when 19 => r := "110010";
  when 20 => r := "001011";
  when 21 => r := "101010";
  when 22 => r := "011010";
  when 23 => r := "111010";
    
  when 24 => r := "110011";
  when 25 => r := "100110";
  when 26 => r := "010110";
  when 27 => r := "110110";
  when 28 => r := "001110";
  when 29 => r := "101110";
  when 30 => r := "011110";
  when 31 => r := "101011";
  when others => r := (others => 'X');
  end case;   
  return r; 
  end table_6b;
  
  function disparity_6b (edcba : std_logic_vector(4 downto 0)) return std_logic is
  begin
    return code_has_disparity(table_6b(edcba));
  end;

  -- Table for 4B D.x.y codes with positive/neutral disparity
  -- D.x.3, D.x.A7 and codes with negative disparity will be handled separatedly
  function table_4b (hgf : std_logic_vector(2 downto 0)) return std_logic_vector is
  variable r : std_logic_vector(3 downto 0);
  begin
    case to_integer(unsigned(hgf)) is
    when 0 => r := "1011";
    when 1 => r := "1001";
    when 2 => r := "0101";
    when 3 => r := "1100";
    when 4 => r := "1101";
    when 5 => r := "1010";
    when 6 => r := "0110";
    when 7 => r := "1110";      
    when others => r := (others => 'X');
    end case;
    return r;
  end table_4b; 
  
  function disparity_4b(hgf : std_logic_vector(2 downto 0)) return std_logic is
  begin
    return code_has_disparity(table_4b(hgf));
  end disparity_4b;
  
  function table_4bk (hgf : std_logic_vector(2 downto 0)) return std_logic_vector is
  variable r : std_logic_vector(3 downto 0);
  begin
    case to_integer(unsigned(hgf)) is
    when 0 => r := "1011";
    when 1 => r := "0110";
    when 2 => r := "1010";
    when 3 => r := "1100";
    when 4 => r := "1101";
    when 5 => r := "0101";
    when 6 => r := "1001";
    when 7 => r := "0111";      
    when others => r := (others => 'X');
    end case;
    return r;
  end table_4bk;
	
  function disparity_4bk(hgf : std_logic_vector(2 downto 0)) return std_logic is
  begin
    return code_has_disparity(table_4bk(hgf));
  end disparity_4bk;


signal rd : std_logic;

signal k_c : std_logic;
signal k : std_logic;  

signal edcba_c : std_logic_vector(4 downto 0);
signal edcba : std_logic_vector(4 downto 0);
signal abcdei : std_logic_vector(5 downto 0);
signal abcdei_r : std_logic_vector(5 downto 0);

signal code_6b : std_logic_vector(5 downto 0);
signal code_disp_6b : std_logic;
signal rd_after_6b : std_logic;


signal hgf_c : std_logic_vector(2 downto 0);
signal hgf : std_logic_vector(2 downto 0);
signal fghj : std_logic_vector(3 downto 0);
signal fghj_r : std_logic_vector(3 downto 0);
signal code_4b : std_logic_vector(3 downto 0);
signal code_disp_4b : std_logic;
signal rd_after_4b : std_logic;



begin
  
  process (clk, reset) begin
  if reset = '1' then
    rd <= '0';
  elsif rising_edge(clk) then
		if enable = '1' then
			rd <= rd_after_4b;
		end if;
  end if;
  end process;
  
  k_c <= ki;
  edcba_c <= ei & di & ci & bi & ai;
  hgf_c <= hi & gi & fi;

  process (clk, reset) begin
  if reset = '1' then
    k <= '0';
  	 edcba <= (others => '0');
	  hgf <= (others => '0');
  elsif rising_edge(clk) then
    if enable = '1' then 
      k <= k_c;
      edcba <= edcba_c;
      hgf <= hgf_c;
    end if;
  end if;
  end process;
  
  
  -- Select a positive/neutral 6b code
  -- And determine if it is positive or neutral
  process (edcba, k) begin
    if k = '1' then
      if edcba = "10111" or edcba = "11011" or edcba = "11101" or edcba = "11110" then
        code_6b <= table_6b(edcba);
        code_disp_6b <= disparity_6b(edcba);
      elsif edcba = "11100" then
        code_6b <= "001111";
        code_disp_6b <= '1';
      else
        code_6b <= (others => 'X');
        code_disp_6b <= 'X';
      end if;
    else
      code_6b <= table_6b(edcba);
      code_disp_6b <= disparity_6b(edcba);	  
    end if;                      
  end process;
  
  
  -- Select the actual 6b code
  -- And produce a running disparity for the 3b/4b
  process (rd, code_6b, code_disp_6b) begin
    if code_disp_6b = '0' then
      abcdei <= code_6b;
      rd_after_6b <= rd;
    elsif rd = '0' then
      abcdei <= code_6b;
      rd_after_6b <= '1';
    else
      abcdei <= not code_6b;
      rd_after_6b <= '0';
    end if;      
  end process;
  
  -- Select a positive/neutral 4b code
  process (rd_after_6b, k, hgf, edcba) begin
  if k = '1' then
    code_4b <= table_4bk(hgf);
	 code_disp_4b <= disparity_4bk(hgf);
  else
    if hgf = "111" then
		if (rd_after_6b = '0' and edcba = "10001") or
			(rd_after_6b = '0' and edcba = "10010") or
			(rd_after_6b = '0' and edcba = "10100") or
			(rd_after_6b = '1' and edcba = "01011") or
			(rd_after_6b = '1' and edcba = "01101") or
			(rd_after_6b = '1' and edcba = "01110") then
			code_4b <= "0111";
			code_disp_4b <= '1';
		else
			code_4b <= "1110";
			code_disp_4b <= '1';
		end if;
	 else
		code_4b <= table_4b(hgf);
		code_disp_4b <= disparity_4b(hgf);
	 end if;
  end if;
  end process;
  
  
  process (rd_after_6b, code_4b, code_disp_4b, k, hgf) begin
	if code_disp_4b = '0' then
		rd_after_4b <= rd_after_6b;
		if rd_after_6b = '1' and ((k = '0' and hgf = "011") or k = '1') then
			fghj <= not code_4b;
		else
			fghj <= code_4b;
		end if;			
	elsif rd_after_6b = '1' then
		fghj <= not code_4b;
		rd_after_4b <= '0';
	else
		fghj <= code_4b;
		rd_after_4b <= '1';
	end if;		
  end process;
  
  process (clk, reset) begin
  if reset = '1' then
    abcdei_r <= (others => '0');
    fghj_r <= (others => '0');
  elsif rising_edge(clk) then      
  	if enable = '1' then   
      abcdei_r <= abcdei;
      fghj_r <= fghj;
	 end if;
  end if;
  end process;
  
  
  ao <= abcdei_r(5);
	bo <= abcdei_r(4);
	co <= abcdei_r(3);
	do <= abcdei_r(2);
	eo <= abcdei_r(1);
	io <= abcdei_r(0);
  
	fo <= fghj_r(3);
	go <= fghj_r(2);
	ho <= fghj_r(1);
	jo <= fghj_r(0);
  
  
end rtl;
    
