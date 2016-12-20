library ieee, worklib;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use worklib.asic_i2c.all;

entity asic_rx is
generic (
	T 	: time := 6.25 ns;
	TX_MODE : std_logic_vector(2 downto 0) := b"000"
);
port (
	start : in std_logic;
	
	rx0	: in std_logic;
	rx1	: in std_logic;
	rx2 : in std_logic;
	rx3 : in std_logic;
	
	frame_id	: out integer;
	n_events	: out integer;
	event_st	: out std_logic;
	event		: out event_t
	
);

end asic_rx;


architecture behavioral of asic_rx is
signal TX_T : time;

signal byte_clk : std_logic := '0';

signal rx_array : std_logic_vector(0 to 3);
signal decoder_reset_array : std_logic_vector(0 to 3);

type b10_array_t is array(0 to 3) of std_logic_vector(9 downto 0);
signal b10_array : b10_array_t;

type b8_array_t is array(0 to 3) of std_logic_vector(7 downto 0);
signal b8_array : b8_array_t; 
signal k_array : std_logic_vector(0 to 3);


type frame_data_t is array (0 to 1023) of std_logic_vector(7 downto 0);
type frame_events_t is array (0 to 253) of event_t;

signal a_frame_strobe: std_logic := '0';
signal a_nevents : integer;
signal a_frame_id : integer;
signal a_frame_events : frame_events_t;

signal aux_clk : std_logic := '0';
signal event_st_i : std_logic := '0';

begin
TX_T <= T when TX_MODE(2) = '0' else 
		T/2;

byte_clk <= not byte_clk after 10*TX_T/2;

rx_array(0) <= rx0;
rx_array(1) <= rx1;
rx_array(2) <= rx2;
rx_array(3) <= rx3;

rx_generator : for n in 0 to 3 generate
process
variable i : integer;
variable rx_tmp : std_logic_vector(9 downto 0);
variable rx_ok : boolean;
begin
	wait until start = '1';

	decoder_reset_array(n) <= '1';
	rx_tmp := (others => '0');
	b10_array(n) <= (others => '0');
	while rx_tmp(9 downto 3) /= "0011111" and rx_tmp(9 downto 3) /= "1100000" loop
		rx_tmp := rx_tmp(8 downto 0) & rx_array(n);
		wait for TX_T;
	end loop;
	decoder_reset_array(n) <= '0';
	rx_ok := true;
	while true loop		
		b10_array(n) <= rx_tmp;
		for i in 0 to 9 loop
			if rx_array(n) /= '0' and rx_array(n) /= '1' then 
				rx_ok := false;
			end if;
			rx_tmp := rx_tmp(8 downto 0) & rx_array(n);
			wait for TX_T;
		end loop;
	end loop;
end process;

decoder0 : entity worklib.dec_8b10b 
    port map (
      RBYTECLK => byte_clk,
      RESET => decoder_reset_array(n),
      JI => b10_array(n)(0),
      HI => b10_array(n)(1),
      GI => b10_array(n)(2),
      FI => b10_array(n)(3),
      II => b10_array(n)(4),
      EI => b10_array(n)(5),
      DI => b10_array(n)(6),
      CI => b10_array(n)(7),
      BI => b10_array(n)(8),
      AI => b10_array(n)(9),
      
      KO => k_array(n),
      AO => b8_array(n)(0),
      BO => b8_array(n)(1),
      CO => b8_array(n)(2),
      DO => b8_array(n)(3),
      EO => b8_array(n)(4),
      FO => b8_array(n)(5),
      GO => b8_array(n)(6),
      HO => b8_array(n)(7)
    );

end generate;

frame_reception : process
variable w			: integer;
variable nevents	: integer;
variable i			: integer;
variable j			: integer;
variable frame_data			: frame_data_t;
variable nbytes			: integer;
variable nwords			: integer;
variable d40		: std_logic_vector(39 downto 0);
variable crc		: std_logic_vector(15 downto 0);

begin
	a_frame_strobe <= '0';
	
	wait until decoder_reset_array(0) = '0';
	wait for 10.5*TX_T;
	while true loop
		for i in 0 to 1023 loop
			frame_data(i) := x"00";
		end loop;
	
		if TX_MODE(1 downto 0) = "00" then
			w := 1;
		elsif TX_MODE(1 downto 0) = "01" then
			w := 2;
		else
			w := 4;
		end if;
		
		for i in 0 to w-1 loop			
			assert k_array(i) = '1' and b8_array(i) = x"BC"
        		report "K28.5 expected" severity warning;
        end loop;
        		
		wait until b8_array(0)'event; wait for 10*TX_T;
		for i in 0 to w-1 loop
      		assert k_array(i) = '1' and b8_array(i) =  x"3C"
	       		report "K28.1 expected" severity warning;
	    end loop;
        	
        wait for 10*TX_T;
        for i in 0 to w-1 loop
        	assert k_array(i) = '0'
        		report "DXX expected" severity warning;        	
        end loop;        	
        	
       	nevents := to_integer(unsigned(b8_array(0)));
       	if nevents = 255 then
       		nevents := 0;
       	end if;
       	if nevents mod 2 = 0 then
       		nbytes := 1 + 4 + 5 * nevents + 1 + 2;
       	else
       		nbytes := 1 + 4 + 5 * nevents + 0 + 2;
       	end if;
       	
       	if w = 1 then
       		nwords := nbytes;
       	elsif w = 2 then
       		nwords := nbytes/2;
       	elsif w = 4 then
       		if nbytes mod 4 = 0 then
       			nwords := nbytes/4;
       		else
       			nwords := nbytes/4 + 1;
       		end if;
       	else
       		assert false report "Unsuported TX_MODE" severity failure;
       	end if;
       	
      	for j in 0 to nwords - 1 loop
       		for i in 0 to w-1 loop
       			frame_data(j*w + i) := b8_array(i);
       		end loop;
       		wait for 10*TX_T;
       	end loop;
		
       	
        a_nevents <= nevents;
        a_frame_id <= to_integer(unsigned(
        	frame_data(1) & frame_data(2) & frame_data(3) & frame_data(4)
        	));
        	
        for i in 0 to nevents - 1 loop
        	d40 :=	frame_data(5 + 5*i + 0) &
        			frame_data(5 + 5*i + 1) &
        			frame_data(5 + 5*i + 2) &
        			frame_data(5 + 5*i + 3) &
        			frame_data(5 + 5*i + 4);
        		
			a_frame_events(i).tac <= to_integer(unsigned(d40(1 downto 0)));
        	a_frame_events(i).channel <= to_integer(unsigned(d40(7 downto 2)));
			a_frame_events(i).efine <= to_integer(unsigned(d40(15 downto 8)));
        	a_frame_events(i).tfine <= to_integer(unsigned(d40(23 downto 16)));
        	a_frame_events(i).ecoarse <= to_integer(unsigned(d40(29 downto 24)));
        	a_frame_events(i).tcoarse <= to_integer(unsigned(d40(39 downto 30)));
        	a_frame_events(i).matched <= false;
        	a_frame_events(i).raw <= d40;				
      	
        end loop;
        a_frame_strobe <= not a_frame_strobe;
        	
	end loop;
	
end process frame_reception;

process
variable i : integer;
variable prev_frame_id : integer;
begin
	event_st_i <= '0';
	wait on a_frame_strobe;
	if a_frame_id > 0 then
		assert a_frame_id - 1 = prev_frame_id 
			report "Frame sequence violation" severity error;
	end if;
	
	
	frame_id <= a_frame_id;
	prev_frame_id := a_frame_id;
	n_events <= a_nevents;
	for i in 0 to a_nevents - 1 loop
		event <= a_frame_events(i);
		event_st_i <= '1'; 
		wait for 10 ps;		 
	end loop;

end process;


aux_clk <= not aux_clk after 5 ps;
event_st <= aux_clk when event_st_i = '1' else '0';

end behavioral;