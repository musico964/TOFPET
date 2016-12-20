library ieee, worklib;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tdc_wrapper is 
generic (
);

port (
	I_clk			: std_logic;
	I_reset_bar		: std_logic;
	
	-- Trigger discriminator
	I_DOT		: in	std_logic;
	I_DOE		: in	std_logic;

	
	-- Asynchronous hit validation interface
	
	-- TACs analog interface
	I_comp_out_p_T	: in	std_logic;
	I_comp_out_p_E	: in	std_logic;
	
	
	-- TDC analog interface
	
	-- GCTRL Interface
	frame_id		: in std_logic;
	ctime			: in std_logic_vector(9 downto 0);
	ev_data_valid   : in std_logic;
    ev_data         : in std_logic_vector(50 downto 0);
    dark_strobe     : in std_logic;
    config          : out std_logic_vector(7 downto 0);
	
	
);
end tdc_wrapper;

architecture rtl of tdc_wrapper is
begin

tdc : entity work.TDC_CTRL_TOP
port map (

	I_clk => I_clk,
	I_reser_bar => I_reset_bar,
	
	I_DOT => I_DOT,			-- Trigger discriminator
	I_DOE => I_DOE,
	 
	I_sync => config(0),	-- synchronous trigger validation when 1
	
	I_comp_out_p_T => I_comp_out_p_T, 	-- Conversion comparator
	I_comp_out_p_T => I_comp_out_p_T
	
	-- Test configuration
	gtest => config(1),			
	I_test_T_EN => config(2),
	I_test_E_EN => config(3),
	I_testcfg0 => config(4), 
	I_testcfg1 => config(5),
	I_test => test_pulse			-- Test pulse
	I_refresh => refresh_pulse,
	
	I_deadtime_EN => config(6),	
	I_deadtime => config(7),
	
	-- Asynchronous validation
	I_clkin_DELOUT => 
	I_delayed_DELOUT => 
	O_ngate_DELIN =>
	O_DOTL_asyn	=>
	O_DOTL_syn =>
	O_DOEL_asyn =>
 
	
	-- Charge TAC
	O_wtac_T =>
	O_wtacn_T =>
	O_wtac_E =>
	O_wtacn_E =>
	
	-- Transfer charge from TAC to TDC
	O_qtx_T =>
	O_qtx_E =>
	
	-- Reset TAC pair
	O_nrst_tac3 =>
	O_nrst_tac2 => 
	O_nrst_tac1 =>
	O_nrst_tac0 => 
	
	-- WR/RD enable for TAC pair
	O_wren3 =>
	O_wren2 => 
	O_wren1 =>
	O_wren0 =>
	O_rden3 => 
	O_rden2 => 
	O_rden1 => 
	O_rden0 =>	
	
	-- Conversion counter enable
	O_qch_T =>
	O_qch_E =>
	
	-- "reset" charge for TDC capacitor
	O_rst_tdc_T => 
	O_rst_tdc_E => 

	O_darkcount => dark_strobe,
	O_ev_valid => ev_valid,
	O_ev_frameid => ev_data(50),
	O_ev_tcoarse => ev_data(49 downto 40)
	O_ev_ecoarse => ev_data(39 downto 30),
	O_ev_soc => ev_data(29 downto 20),
	O_ev_teoc => ev_data(19 downto 10),
	O_ev_eeoc => ev_data(9 downto 0)	
);

	

end rtl;