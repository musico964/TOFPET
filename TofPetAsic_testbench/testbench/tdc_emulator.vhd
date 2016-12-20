library ieee, tdc_lib, worklib, gctrl_lib;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use gctrl_lib.asic_k.all;


entity tdc_emulator is
generic (
	ID				: integer := 0;
	T				: time := 6.25 ns;
	M				: real := 64.0
);
port (
	
	dot			: in std_logic;
	doe			: in std_logic;
		
	clk_i		: in std_logic;
	reset_bar_i	: in std_logic;
	
	test_pulse_i : in std_logic;
	refresh_pulse_i : in std_logic;
	
	frame_id_i	: in std_logic;	
	ctime_i		: in std_logic_vector(9 downto 0);
	
	ev_data_valid_o   : out std_logic;
	ev_data_o         : out std_logic_vector(52 downto 0);
	dark_strobe_o     : out std_logic;
	trig_err_strobe_o : out std_logic;
	config_i          : in std_logic_vector(CH_CONFIG_SIZE-1 downto 0);	
	tconfig_i         : in std_logic_vector(CH_TCONFIG_SIZE-1 downto 0)
);

end tdc_emulator;

architecture behavioral of tdc_emulator is

constant max_TDC_Q :real := 3.5;

constant comp_clock_delay : time := 400 ps;

signal clk_O			: std_logic;
signal threshold_T		: real := 0.5;
signal threshold_E		: real := 2.0;
signal disc_out_T		: std_logic := '0';
signal disc_out_E		: std_logic := '0';
signal conv_comp_clk_T	: std_logic;
signal conv_comp_clk_E 	: std_logic;
signal conv_comp_T		: std_logic := '0';
signal conv_comp_E		: std_logic := '0';
signal wtac_T			: std_logic := '0';
signal wtac_E			: std_logic := '0';
signal nrst_tac			: std_logic_vector(3 downto 0);
signal wren_tac			: std_logic_vector(3 downto 0);
signal rden_tac			: std_logic_vector(3 downto 0);
signal qtx_T			: std_logic;
signal qtx_E			: std_logic;
signal qch_T			: std_logic;
signal qch_E			: std_logic;
signal rst_tdc_T		: std_logic;
signal rst_tdc_E		: std_logic;


type tacQ_array_t is array(3 downto 0) of real;
signal tacQ_T_array : tacQ_array_t;
signal tacQ_E_array : tacQ_array_t;

signal tac_T_charge : std_logic_vector(3 downto 0);
signal tac_E_charge : std_logic_vector(3 downto 0);

signal tdcQ_T : real;
signal tdcQ_E : real;

signal tdcM_T : real := 0.0;
signal tdcM_E : real := 0.0;

signal cgatecfg			: std_logic_vector(2 downto 0);
signal latchcfg			: std_logic_vector(2 downto 0);
signal clkin_DELOUT		: std_logic;
signal delayed_DELOUT	: std_logic;
signal ngate_DELIN		: std_logic;
signal DOTL_asyn		: std_logic;
	
signal praedictio_cfg 	: std_logic_vector(3 downto 0);
signal praedictio_delay : time;
signal DOT_delayed		: std_logic;
signal DOT_actual		: std_logic;

begin


disc_out_T <= dot;
disc_out_E <= doe;


cgatecfg <= config_i(21 downto 19);	
latchcfg <= config_i(24 downto 22);			

clkin_DELOUT <= ngate_DELIN after 1.5 ns;
				
delayed_DELOUT <= 	DOTL_asyn after 100 us when cgatecfg = "000" else
					DOTL_asyn after 1.9 ns when cgatecfg = "001" else
					DOTL_asyn after 4.7 ns when cgatecfg = "010" else
					DOTL_asyn after 1.7 ns when cgatecfg = "011" else
					DOTL_asyn after 8.8 ns when cgatecfg = "100" else
					DOTL_asyn after 1.8 ns when cgatecfg = "101" else
					DOTL_asyn after 3.4 ns when cgatecfg = "110" else
					DOTL_asyn after 1.6 ns when cgatecfg = "111" else					
					'X';

				
--praedictio_delay <= 1.0 ns + 0.287 ns * to_integer(unsigned(latchcfg(0) & cgatecfg));
praedictio_cfg <= latchcfg(0) & cgatecfg;
praedictio_delay <= 5.6 ns when praedictio_cfg = "0000" else
					4.3 ns when praedictio_cfg = "0001" else
					5.6 ns when praedictio_cfg = "0010" else
					4.3 ns when praedictio_cfg = "0011" else
					3.0 ns when praedictio_cfg = "0100" else
					3.0 ns when praedictio_cfg = "0101" else
					1.6 ns when praedictio_cfg = "0110" else
					1.6 ns when praedictio_cfg = "0111" else
					2.7 ns when praedictio_cfg = "1000" else
					2.2 ns when praedictio_cfg = "1001" else
					2.7 ns when praedictio_cfg = "1010" else
					2.2 ns when praedictio_cfg = "1011" else
					1.6 ns when praedictio_cfg = "1100" else
					1.6 ns when praedictio_cfg = "1101" else
					1.0 ns when praedictio_cfg = "1110" else
					1.0 ns;

DOT_delayed <= disc_out_T after praedictio_delay when praedictio_delay > 0 ns else '0';
DOT_actual <= DOT_delayed when config_i(49) = '1' else disc_out_T;
				
tdc : entity tdc_lib.TDC_CTRL_TOP 
port map (
	I_clk => clk_i,
	O_clk => clk_o,
	I_reset_bar => reset_bar_i,
	O_reset_bar => open,
	I_frameid => frame_id_i,
	I_coarsetime => ctime_i,
	
	-- Trigger discriminators
	I_DOT => DOT_actual,
	I_DOE => disc_out_E,
	
	-- Metstability mode configuration
	I_meta_cfg0 => config_i(50),
	I_meta_cfg1 => config_i(51),
	
		-- Test configuration
	I_gtest => config_i(11),
	I_testcfg0 => config_i(12),
	I_testcfg1 => config_i(13),
	I_test_T_EN => config_i(14),
	I_test_E_EN => config_i(15),
	I_test => test_pulse_i,
	
	-- Dead time
	I_deadtime_EN => config_i(16),
	I_deadtime => config_i(17),

	-- synchronous trigger validation when 1
	I_sync => config_i(18),
	I_praedictio => config_i(49),
	I_clkin_DELOUT => clkin_DELOUT,
	I_delayed_DELOUT =>  delayed_DELOUT,
	O_ngate_DELIN => ngate_DELIN,
	O_DOTL_asyn	=> DOTL_asyn,
	
	
	-- Conversion comparators
	I_comp_out_p_T => conv_comp_T,
	I_comp_out_p_E => conv_comp_E,
	

	-- TAC refresh
	I_refresh => refresh_pulse_i,
		
	-- Charge TAC
	O_wtac_T => wtac_T,
	O_wtacn_T => open,
	O_wtac_E => wtac_E,
	O_wtacn_E => open,
	
	-- Reset TAC pair
	O_nrst_tac3 => nrst_tac(3),
	O_nrst_tac2 => nrst_tac(2),
	O_nrst_tac1 => nrst_tac(1),
	O_nrst_tac0 => nrst_tac(0),
	
	-- WR/RD enable for TAC pair
	O_wren3 => wren_tac(3),
	O_wren2 => wren_tac(2),
	O_wren1 => wren_tac(1),
	O_wren0 => wren_tac(0),
	O_rden3 => rden_tac(3),
	O_rden2 => rden_tac(2),
	O_rden1 => rden_tac(1),
	O_rden0 => rden_tac(0),
	
	-- Transfer charge from TAC to TDC 
	O_qtx_T => qtx_T,
	O_qtx_E => qtx_E,

	-- Conversion counter enable
	O_qch_T => qch_T,
	O_qch_E => qch_E,
	
	-- "reset" charge for TDC capacitor
	O_rst_tdc_T => rst_tdc_T,
	O_rst_tdc_E => rst_tdc_E,

	O_darkcount => dark_strobe_o,
	O_trig_err => trig_err_strobe_o,
	O_ev_valid => ev_data_valid_o,
	O_ev_frameid => ev_data_o(50),
	O_ev_tcoarse => ev_data_o(49 downto 40),
	O_ev_ecoarse => ev_data_o(39 downto 30),
	O_ev_soc => ev_data_o(29 downto 20),
	O_ev_teoc => ev_data_o(19 downto 10),
	O_ev_eeoc => ev_data_o(9 downto 0),
	O_ev_idtac => ev_data_o(52 downto 51)	
	
);	

tac_generator : for n in 0 to 3 generate
	tac_T_charge(n) <= wren_tac(n) and wtac_T;
	tac_T : process(tac_T_charge(n), nrst_tac(n))
	variable tNow : real := 0.0;
	variable tacChargeStart : real := 0.0;
	variable Q : real := 0.0;
	begin			
		tNow := real(1000 * now / T)/1000.0;	
		if rising_edge(tac_T_charge(n)) then
			tacChargeStart := tNow;			
		elsif falling_edge(tac_T_charge(n)) then
			Q := tacQ_T_array(n) + tNow - tacChargeStart;				
			if Q < 0.0 then
				tacQ_T_array(n) <= 0.0;
			elsif Q > 100.0 then
				tacQ_T_array(n) <= 100.0;
			else					
				tacQ_T_array(n) <= Q;
			end if;
		end if;
		
		if nrst_tac(n) = '0' then
			tacQ_T_array(n) <= 0.0;
		end if;	
			
		assert tacQ_T_array(n) = -101.0 or tacQ_T_array(n) >= 0.0 or tacQ_T_array(n) <= 6.0;
	end process; 
	
	tac_E_charge(n) <= wren_tac(n) and wtac_E;	
	tac_E : process(tac_E_charge(n), nrst_tac(n))
	variable tNow : real := 0.0;
	variable tacChargeStart : real := 0.0;
	variable Q : real := 0.0;
	begin
		tNow := real(1000 * now / T)/1000.0; 
		if rising_edge(tac_E_charge(n)) then
			tacChargeStart := tNow;			
		elsif falling_edge(tac_E_charge(n)) then
			Q := tacQ_E_array(n) + tNow - tacChargeStart;				
			if Q < 0.0 then
				tacQ_E_array(n) <= 0.0;
			elsif Q > 100.0 then
				tacQ_E_array(n) <= 100.0;
			else					
				tacQ_E_array(n) <= Q;
			end if;
		end if;
		
		if nrst_tac(n) = '0' then
			tacQ_E_array(n) <= 0.0;
		end if;
				
		assert tacQ_E_array(n) = -101.0 or tacQ_E_array(n) >= 0.0 or tacQ_E_array(n) <= 6.0;
	end process;	
end generate;

tdc_T : process
begin
	wait until qtx_T'event or qch_T'event or rst_tdc_T'event;
	
	-- Load charge from TAC
	if rising_edge(qtx_T) then
		case rden_tac is
			when "0001" => tdcQ_t <= tdcQ_t + tacQ_T_array(0); 
			when "0010" => tdcQ_t <= tdcQ_t + tacQ_T_array(1);
			when "0100" => tdcQ_T <= tdcQ_t + tacQ_T_array(2);
			when "1000" => tdcQ_T <= tdcQ_t + tacQ_T_array(3);
			when others => tdcQ_T <= -100.0;
		end case;
		
	-- Discarche
	elsif rising_edge(qch_T) then
		if tdcQ_T > max_TDC_Q then
			wait for M * max_TDC_Q * T;
		else		 
			wait for M * tdcQ_T * T;
		end if;
		tdcQ_T <= -101.0;
	end if;
	
	-- Reset!
	if rst_tdc_t = '1' then
		tdcQ_T <= 0.0;
	end if;
end process;


comp_T : entity worklib.latched_comparator 
	port map (u => tdcQ_T, clk => clk_o, qch => qch_T, q => conv_comp_T, q_bar => open);

tdc_E : process
begin
	wait until qtx_E'event or qch_E'event or rst_tdc_E'event;
	
	if rising_edge(qtx_E) then
		case rden_tac is
			when "0001" => tdcQ_E <= tdcQ_E + tacQ_E_array(0); 
			when "0010" => tdcQ_E <= tdcQ_E + tacQ_E_array(1);
			when "0100" => tdcQ_E <= tdcQ_E + tacQ_E_array(2);
			when "1000" => tdcQ_E <= tdcQ_E + tacQ_E_array(3);
			when others => tdcQ_E <= -100.0;
		end case;
	elsif rising_edge(qch_E) then
		if tdcQ_E > max_TDC_Q then
			wait for M * max_TDC_Q * T;
		else		 
			wait for M * tdcQ_E * T;
		end if;
		tdcQ_E <= -101.0;
	end if;
	
	if rst_tdc_E = '1' then
		tdcQ_E <= 0.0;
	end if;
end process;
	
comp_E : entity worklib.latched_comparator 
	port map (u => tdcQ_E, clk => clk_o, qch => qch_E, q => conv_comp_E, q_bar => open);


tdcM_T <= tdcQ_T when tdcQ_T > 0.0 else tdcM_T;
tdcM_E <= tdcQ_E when tdcQ_E > 0.0 else tdcM_E;

end behavioral;
