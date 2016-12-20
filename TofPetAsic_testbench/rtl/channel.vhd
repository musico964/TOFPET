library ieee, gctrl_lib;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use gctrl_lib.asic_k.all;

entity channel is 
	generic (
		ADDRESS 		: integer;
		CH_DATA_SIZE	: integer;
		CH_ADDR_WIDTH 	: integer;
    	CH_CONFIG_SIZE 	: integer;
    	CH_TCONFIG_SIZE : integer;
    	DARK_COUNT_SIZE : integer
	);
	port (
		clk				: in std_logic;
		reset_clk			: in std_logic;
		veto			: in std_logic;
		sclk			: in std_logic;
		reset_sclk		: in std_logic;
		ch_cfg_enable	: in std_logic;
		ch_cfg_cmd		: in std_logic_vector(2 downto 0);
		ch_cfg_address	: in std_logic_vector(CH_ADDR_WIDTH-1 downto 0);
		ch_cfg_data_i	: in std_logic;
		ch_cfg_data_o	: out std_logic;
		config			: out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
		tconfig			: out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);		
		ev_valid_i		: in std_logic;
		ev_data_i		: in std_logic_vector(CH_DATA_SIZE-1 downto 0);
		read_enable		: in std_logic;		
		token			: in std_logic;
		ev_valid_o 		: out std_logic;
		ev_data_o		: out std_logic_vector(CH_DATA_SIZE+CH_ADDR_WIDTH downto 0);
		dark_count_strobe	: in std_logic;
		trig_err_strobe 	: in std_logic;
		count_trig_err : in std_logic;
		store_channel_counter	: in std_logic
	);
end channel;

architecture rtl of channel is
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

constant address_as_vector : std_logic_vector(CH_ADDR_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(ADDRESS, CH_ADDR_WIDTH));

signal count_strobe	: std_logic;
signal count_strobe_delayed : std_logic;

signal dark_count_current	: unsigned(DARK_COUNT_SIZE-1 downto 0);
signal dark_count_stored 	: unsigned(DARK_COUNT_SIZE-1 downto 0);


signal ev_valid_i_delayed : std_logic;
signal ev_valid_i_filtered : std_logic;
signal ev_valid_r		: std_logic;
signal ev_data_r		: std_logic_vector(CH_DATA_SIZE+CH_ADDR_WIDTH downto 0);

signal cs				: std_logic;
signal config_r			: std_logic_vector(CH_CONFIG_SIZE-1 downto 0);
signal tconfig_r		: std_logic_vector(CH_TCONFIG_SIZE-1 downto 0);
signal dark_count_r		: std_logic_vector(DARK_COUNT_SIZE-1 downto 0);

begin
-- Dark counting

count_strobe <= trig_err_strobe when count_trig_err = '1' else dark_count_strobe;

process (clk, reset_clk) begin
if reset_clk = '1' then
	count_strobe_delayed <= '0';
elsif rising_edge(clk) then
	count_strobe_delayed <= count_strobe;
end if;	
end process;

process (clk, reset_clk)
begin
if reset_clk = '1' then
	dark_count_current <= (others => '0');
	dark_count_stored <= (others => '0');
elsif rising_edge(clk) then
	if store_channel_counter = '1' then
		dark_count_stored <= dark_count_current;
		dark_count_current <= (others => '0');
	elsif count_strobe = '1' and count_strobe_delayed = '0' then
		dark_count_current <= dark_count_current + 1;
	end if;
end if;
end process;

-- Event forwarding
process (clk, reset_clk) begin
if reset_clk = '1' then
	ev_valid_i_delayed <= '0';
elsif rising_edge(clk) then
	ev_valid_i_delayed <= ev_valid_i;
end if;
end process;
ev_valid_i_filtered <= '1' when ev_valid_i = '1' and ev_valid_i_delayed = '0' else '0';
process (clk, reset_clk) 
begin
if reset_clk = '1' then
	ev_valid_r <= '0';
	ev_data_r <= (others => '0');
elsif rising_edge(clk) then
	if read_enable = '1' then
		if token = '1' then
			ev_valid_r <= '0';
		end if;
	end if;
	
	-- SYNOPSYS translate_off
	assert ev_valid_i_filtered = '0' or ev_valid_r = '0' report "Lost event due to full channel queue" severity warning;
	-- SYNOPSYS translate_on		
	if ev_valid_i_filtered = '1' and ev_valid_r = '0' then
		
		ev_valid_r <= '1';
		ev_data_r <=	address_as_vector & 
						ev_data_i &
						odd_parity(address_as_vector & ev_data_i);	
	end if;

end if;	
end process;
ev_valid_o <= ev_valid_r;
ev_data_o <= ev_data_r;



cs <= '1' when ch_cfg_enable = '1' and ch_cfg_address = address_as_vector else '0';
process (sclk, reset_sclk) begin
if reset_sclk = '1' then
	config_r <= DEFAULT_CH_CONFIG;
	tconfig_r <= DEFAULT_CH_TCONFIG;
	dark_count_r <= (others => '0');
elsif rising_edge(sclk) then
	if cs = '1' and ch_cfg_cmd = "000" then
		config_r <= config_r(CH_CONFIG_SIZE-2 downto 0) & ch_cfg_data_i;
    elsif cs = '1' and ch_cfg_cmd = "001" then
      config_r <= config_r(CH_CONFIG_SIZE-2 downto 0) & config_r(CH_CONFIG_SIZE-1);
    end if;

	if cs = '1' and ch_cfg_cmd = "010" then
		if CH_TCONFIG_SIZE < 2 then
			tconfig_r(0) <= ch_cfg_data_i;
		else
			tconfig_r <= tconfig_r(CH_TCONFIG_SIZE-2 downto 0) & ch_cfg_data_i;
		end if;
	elsif cs = '1' and ch_cfg_cmd = "011" then
		if CH_TCONFIG_SIZE < 2 then
			tconfig_r <= tconfig_r;
		else
			tconfig_r <= tconfig_r(CH_TCONFIG_SIZE-2 downto 0) & tconfig_r(CH_TCONFIG_SIZE-1);
		end if;
	end if;
    
	if cs = '1' and ch_cfg_cmd = "100" then
		dark_count_r <= dark_count_r(DARK_COUNT_SIZE-2 downto 0) & '0';
	else
		dark_count_r <= std_logic_vector(dark_count_stored);
	end if;
end if;
end process; 
ch_cfg_data_o <=config_r(CH_CONFIG_SIZE-1)	when cs = '1' and ch_cfg_cmd = "001" else
		tconfig_r(CH_TCONFIG_SIZE-1)	when cs = '1' and ch_cfg_cmd = "011" else
		dark_count_r(DARK_COUNT_SIZE-1)	when cs = '1' and ch_cfg_cmd = "100" else
		'X';

-- Disable channel when veto = '1'!!
config <= config_r(CH_CONFIG_SIZE-1 downto 1) & '0' when veto = '1' else config_r;
tconfig <= tconfig_r;

end rtl;
