--
-- 64 channel global controller
-- using mutexes
-- 

library ieee, gctrl_lib;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use gctrl_lib.asic_k.all;

entity gctrl_64mx is

  port ( 
    -- clock
    clk_i				: in std_logic;    
    
    -- external sync/reset signal
    sync_rst_i			: in std_logic;

    -- external test pulse
    test_pulse_i		: in std_logic;
    
    -- data output
    clk_o				: out std_logic;
    clk_oe				: out std_logic;
    tx0_o				: out std_logic;
    tx1_o				: out std_logic;
    tx1_oe				: out std_logic;
    
    -- configuration interface
    sclk_i				: in std_logic;
    cs_i				: in std_logic;
    sdi_i				: in std_logic;
    sdo_o				: out std_logic;
    sdo_oe				: out std_logic;
    
    -- global configuration for TDC
    gconfig_o			: out std_logic_vector(GE_CONFIG_SIZE-1 downto 0);
    gtconfig_o			: out std_logic_vector(GE_TCONFIG_SIZE-1 downto 0);
    global_cal_en_o		: out std_logic;
    test_pulse_o		: out std_logic;
    
    -- Channel interface
	-- Channel 0
	ch0_clk                  : out std_logic;
	ch0_reset_bar            : out std_logic;
	ch0_frame_id             : out std_logic;
	ch0_ctime                : out std_logic_vector(9 downto 0);
	ch0_tac_refresh_pulse    : out std_logic;
	ch0_test_pulse           : out std_logic;
	ch0_ev_data_valid        : in std_logic;
	ch0_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch0_dark_strobe          : in std_logic;
	ch0_trig_err_strobe      : in std_logic;
	ch0_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch0_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch0_global_cal_en		 : out std_logic;

	-- Channel 1
	ch1_clk                  : out std_logic;
	ch1_reset_bar            : out std_logic;
	ch1_frame_id             : out std_logic;
	ch1_ctime                : out std_logic_vector(9 downto 0);
	ch1_tac_refresh_pulse    : out std_logic;
	ch1_test_pulse           : out std_logic;
	ch1_ev_data_valid        : in std_logic;
	ch1_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch1_dark_strobe          : in std_logic;
	ch1_trig_err_strobe      : in std_logic;
	ch1_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch1_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch1_global_cal_en		 : out std_logic;

	-- Channel 2
	ch2_clk                  : out std_logic;
	ch2_reset_bar            : out std_logic;
	ch2_frame_id             : out std_logic;
	ch2_ctime                : out std_logic_vector(9 downto 0);
	ch2_tac_refresh_pulse    : out std_logic;
	ch2_test_pulse           : out std_logic;
	ch2_ev_data_valid        : in std_logic;
	ch2_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch2_dark_strobe          : in std_logic;
	ch2_trig_err_strobe      : in std_logic;
	ch2_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch2_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch2_global_cal_en		 : out std_logic;

	-- Channel 3
	ch3_clk                  : out std_logic;
	ch3_reset_bar            : out std_logic;
	ch3_frame_id             : out std_logic;
	ch3_ctime                : out std_logic_vector(9 downto 0);
	ch3_tac_refresh_pulse    : out std_logic;
	ch3_test_pulse           : out std_logic;
	ch3_ev_data_valid        : in std_logic;
	ch3_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch3_dark_strobe          : in std_logic;
	ch3_trig_err_strobe      : in std_logic;
	ch3_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch3_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch3_global_cal_en		 : out std_logic;

	-- Channel 4
	ch4_clk                  : out std_logic;
	ch4_reset_bar            : out std_logic;
	ch4_frame_id             : out std_logic;
	ch4_ctime                : out std_logic_vector(9 downto 0);
	ch4_tac_refresh_pulse    : out std_logic;
	ch4_test_pulse           : out std_logic;
	ch4_ev_data_valid        : in std_logic;
	ch4_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch4_dark_strobe          : in std_logic;
	ch4_trig_err_strobe      : in std_logic;
	ch4_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch4_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch4_global_cal_en		 : out std_logic;

	-- Channel 5
	ch5_clk                  : out std_logic;
	ch5_reset_bar            : out std_logic;
	ch5_frame_id             : out std_logic;
	ch5_ctime                : out std_logic_vector(9 downto 0);
	ch5_tac_refresh_pulse    : out std_logic;
	ch5_test_pulse           : out std_logic;
	ch5_ev_data_valid        : in std_logic;
	ch5_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch5_dark_strobe          : in std_logic;
	ch5_trig_err_strobe      : in std_logic;
	ch5_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch5_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch5_global_cal_en		 : out std_logic;

	-- Channel 6
	ch6_clk                  : out std_logic;
	ch6_reset_bar            : out std_logic;
	ch6_frame_id             : out std_logic;
	ch6_ctime                : out std_logic_vector(9 downto 0);
	ch6_tac_refresh_pulse    : out std_logic;
	ch6_test_pulse           : out std_logic;
	ch6_ev_data_valid        : in std_logic;
	ch6_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch6_dark_strobe          : in std_logic;
	ch6_trig_err_strobe      : in std_logic;
	ch6_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch6_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch6_global_cal_en		 : out std_logic;

	-- Channel 7
	ch7_clk                  : out std_logic;
	ch7_reset_bar            : out std_logic;
	ch7_frame_id             : out std_logic;
	ch7_ctime                : out std_logic_vector(9 downto 0);
	ch7_tac_refresh_pulse    : out std_logic;
	ch7_test_pulse           : out std_logic;
	ch7_ev_data_valid        : in std_logic;
	ch7_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch7_dark_strobe          : in std_logic;
	ch7_trig_err_strobe      : in std_logic;
	ch7_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch7_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch7_global_cal_en		 : out std_logic;

	-- Channel 8
	ch8_clk                  : out std_logic;
	ch8_reset_bar            : out std_logic;
	ch8_frame_id             : out std_logic;
	ch8_ctime                : out std_logic_vector(9 downto 0);
	ch8_tac_refresh_pulse    : out std_logic;
	ch8_test_pulse           : out std_logic;
	ch8_ev_data_valid        : in std_logic;
	ch8_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch8_dark_strobe          : in std_logic;
	ch8_trig_err_strobe      : in std_logic;
	ch8_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch8_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch8_global_cal_en		 : out std_logic;

	-- Channel 9
	ch9_clk                  : out std_logic;
	ch9_reset_bar            : out std_logic;
	ch9_frame_id             : out std_logic;
	ch9_ctime                : out std_logic_vector(9 downto 0);
	ch9_tac_refresh_pulse    : out std_logic;
	ch9_test_pulse           : out std_logic;
	ch9_ev_data_valid        : in std_logic;
	ch9_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch9_dark_strobe          : in std_logic;
	ch9_trig_err_strobe      : in std_logic;
	ch9_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch9_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch9_global_cal_en		 : out std_logic;

	-- Channel 10
	ch10_clk                  : out std_logic;
	ch10_reset_bar            : out std_logic;
	ch10_frame_id             : out std_logic;
	ch10_ctime                : out std_logic_vector(9 downto 0);
	ch10_tac_refresh_pulse    : out std_logic;
	ch10_test_pulse           : out std_logic;
	ch10_ev_data_valid        : in std_logic;
	ch10_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch10_dark_strobe          : in std_logic;
	ch10_trig_err_strobe      : in std_logic;
	ch10_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch10_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch10_global_cal_en		 : out std_logic;

	-- Channel 11
	ch11_clk                  : out std_logic;
	ch11_reset_bar            : out std_logic;
	ch11_frame_id             : out std_logic;
	ch11_ctime                : out std_logic_vector(9 downto 0);
	ch11_tac_refresh_pulse    : out std_logic;
	ch11_test_pulse           : out std_logic;
	ch11_ev_data_valid        : in std_logic;
	ch11_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch11_dark_strobe          : in std_logic;
	ch11_trig_err_strobe      : in std_logic;
	ch11_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch11_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch11_global_cal_en		 : out std_logic;

	-- Channel 12
	ch12_clk                  : out std_logic;
	ch12_reset_bar            : out std_logic;
	ch12_frame_id             : out std_logic;
	ch12_ctime                : out std_logic_vector(9 downto 0);
	ch12_tac_refresh_pulse    : out std_logic;
	ch12_test_pulse           : out std_logic;
	ch12_ev_data_valid        : in std_logic;
	ch12_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch12_dark_strobe          : in std_logic;
	ch12_trig_err_strobe      : in std_logic;
	ch12_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch12_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch12_global_cal_en		 : out std_logic;

	-- Channel 13
	ch13_clk                  : out std_logic;
	ch13_reset_bar            : out std_logic;
	ch13_frame_id             : out std_logic;
	ch13_ctime                : out std_logic_vector(9 downto 0);
	ch13_tac_refresh_pulse    : out std_logic;
	ch13_test_pulse           : out std_logic;
	ch13_ev_data_valid        : in std_logic;
	ch13_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch13_dark_strobe          : in std_logic;
	ch13_trig_err_strobe      : in std_logic;
	ch13_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch13_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch13_global_cal_en		 : out std_logic;

	-- Channel 14
	ch14_clk                  : out std_logic;
	ch14_reset_bar            : out std_logic;
	ch14_frame_id             : out std_logic;
	ch14_ctime                : out std_logic_vector(9 downto 0);
	ch14_tac_refresh_pulse    : out std_logic;
	ch14_test_pulse           : out std_logic;
	ch14_ev_data_valid        : in std_logic;
	ch14_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch14_dark_strobe          : in std_logic;
	ch14_trig_err_strobe      : in std_logic;
	ch14_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch14_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch14_global_cal_en		 : out std_logic;

	-- Channel 15
	ch15_clk                  : out std_logic;
	ch15_reset_bar            : out std_logic;
	ch15_frame_id             : out std_logic;
	ch15_ctime                : out std_logic_vector(9 downto 0);
	ch15_tac_refresh_pulse    : out std_logic;
	ch15_test_pulse           : out std_logic;
	ch15_ev_data_valid        : in std_logic;
	ch15_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch15_dark_strobe          : in std_logic;
	ch15_trig_err_strobe      : in std_logic;
	ch15_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch15_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch15_global_cal_en		 : out std_logic;

	-- Channel 16
	ch16_clk                  : out std_logic;
	ch16_reset_bar            : out std_logic;
	ch16_frame_id             : out std_logic;
	ch16_ctime                : out std_logic_vector(9 downto 0);
	ch16_tac_refresh_pulse    : out std_logic;
	ch16_test_pulse           : out std_logic;
	ch16_ev_data_valid        : in std_logic;
	ch16_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch16_dark_strobe          : in std_logic;
	ch16_trig_err_strobe      : in std_logic;
	ch16_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch16_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch16_global_cal_en		 : out std_logic;

	-- Channel 17
	ch17_clk                  : out std_logic;
	ch17_reset_bar            : out std_logic;
	ch17_frame_id             : out std_logic;
	ch17_ctime                : out std_logic_vector(9 downto 0);
	ch17_tac_refresh_pulse    : out std_logic;
	ch17_test_pulse           : out std_logic;
	ch17_ev_data_valid        : in std_logic;
	ch17_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch17_dark_strobe          : in std_logic;
	ch17_trig_err_strobe      : in std_logic;
	ch17_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch17_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch17_global_cal_en		 : out std_logic;

	-- Channel 18
	ch18_clk                  : out std_logic;
	ch18_reset_bar            : out std_logic;
	ch18_frame_id             : out std_logic;
	ch18_ctime                : out std_logic_vector(9 downto 0);
	ch18_tac_refresh_pulse    : out std_logic;
	ch18_test_pulse           : out std_logic;
	ch18_ev_data_valid        : in std_logic;
	ch18_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch18_dark_strobe          : in std_logic;
	ch18_trig_err_strobe      : in std_logic;
	ch18_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch18_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch18_global_cal_en		 : out std_logic;

	-- Channel 19
	ch19_clk                  : out std_logic;
	ch19_reset_bar            : out std_logic;
	ch19_frame_id             : out std_logic;
	ch19_ctime                : out std_logic_vector(9 downto 0);
	ch19_tac_refresh_pulse    : out std_logic;
	ch19_test_pulse           : out std_logic;
	ch19_ev_data_valid        : in std_logic;
	ch19_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch19_dark_strobe          : in std_logic;
	ch19_trig_err_strobe      : in std_logic;
	ch19_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch19_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch19_global_cal_en		 : out std_logic;

	-- Channel 20
	ch20_clk                  : out std_logic;
	ch20_reset_bar            : out std_logic;
	ch20_frame_id             : out std_logic;
	ch20_ctime                : out std_logic_vector(9 downto 0);
	ch20_tac_refresh_pulse    : out std_logic;
	ch20_test_pulse           : out std_logic;
	ch20_ev_data_valid        : in std_logic;
	ch20_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch20_dark_strobe          : in std_logic;
	ch20_trig_err_strobe      : in std_logic;
	ch20_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch20_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch20_global_cal_en		 : out std_logic;

	-- Channel 21
	ch21_clk                  : out std_logic;
	ch21_reset_bar            : out std_logic;
	ch21_frame_id             : out std_logic;
	ch21_ctime                : out std_logic_vector(9 downto 0);
	ch21_tac_refresh_pulse    : out std_logic;
	ch21_test_pulse           : out std_logic;
	ch21_ev_data_valid        : in std_logic;
	ch21_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch21_dark_strobe          : in std_logic;
	ch21_trig_err_strobe      : in std_logic;
	ch21_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch21_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch21_global_cal_en		 : out std_logic;

	-- Channel 22
	ch22_clk                  : out std_logic;
	ch22_reset_bar            : out std_logic;
	ch22_frame_id             : out std_logic;
	ch22_ctime                : out std_logic_vector(9 downto 0);
	ch22_tac_refresh_pulse    : out std_logic;
	ch22_test_pulse           : out std_logic;
	ch22_ev_data_valid        : in std_logic;
	ch22_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch22_dark_strobe          : in std_logic;
	ch22_trig_err_strobe      : in std_logic;
	ch22_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch22_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch22_global_cal_en		 : out std_logic;

	-- Channel 23
	ch23_clk                  : out std_logic;
	ch23_reset_bar            : out std_logic;
	ch23_frame_id             : out std_logic;
	ch23_ctime                : out std_logic_vector(9 downto 0);
	ch23_tac_refresh_pulse    : out std_logic;
	ch23_test_pulse           : out std_logic;
	ch23_ev_data_valid        : in std_logic;
	ch23_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch23_dark_strobe          : in std_logic;
	ch23_trig_err_strobe      : in std_logic;
	ch23_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch23_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch23_global_cal_en		 : out std_logic;

	-- Channel 24
	ch24_clk                  : out std_logic;
	ch24_reset_bar            : out std_logic;
	ch24_frame_id             : out std_logic;
	ch24_ctime                : out std_logic_vector(9 downto 0);
	ch24_tac_refresh_pulse    : out std_logic;
	ch24_test_pulse           : out std_logic;
	ch24_ev_data_valid        : in std_logic;
	ch24_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch24_dark_strobe          : in std_logic;
	ch24_trig_err_strobe      : in std_logic;
	ch24_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch24_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch24_global_cal_en		 : out std_logic;

	-- Channel 25
	ch25_clk                  : out std_logic;
	ch25_reset_bar            : out std_logic;
	ch25_frame_id             : out std_logic;
	ch25_ctime                : out std_logic_vector(9 downto 0);
	ch25_tac_refresh_pulse    : out std_logic;
	ch25_test_pulse           : out std_logic;
	ch25_ev_data_valid        : in std_logic;
	ch25_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch25_dark_strobe          : in std_logic;
	ch25_trig_err_strobe      : in std_logic;
	ch25_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch25_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch25_global_cal_en		 : out std_logic;

	-- Channel 26
	ch26_clk                  : out std_logic;
	ch26_reset_bar            : out std_logic;
	ch26_frame_id             : out std_logic;
	ch26_ctime                : out std_logic_vector(9 downto 0);
	ch26_tac_refresh_pulse    : out std_logic;
	ch26_test_pulse           : out std_logic;
	ch26_ev_data_valid        : in std_logic;
	ch26_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch26_dark_strobe          : in std_logic;
	ch26_trig_err_strobe      : in std_logic;
	ch26_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch26_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch26_global_cal_en		 : out std_logic;

	-- Channel 27
	ch27_clk                  : out std_logic;
	ch27_reset_bar            : out std_logic;
	ch27_frame_id             : out std_logic;
	ch27_ctime                : out std_logic_vector(9 downto 0);
	ch27_tac_refresh_pulse    : out std_logic;
	ch27_test_pulse           : out std_logic;
	ch27_ev_data_valid        : in std_logic;
	ch27_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch27_dark_strobe          : in std_logic;
	ch27_trig_err_strobe      : in std_logic;
	ch27_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch27_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch27_global_cal_en		 : out std_logic;

	-- Channel 28
	ch28_clk                  : out std_logic;
	ch28_reset_bar            : out std_logic;
	ch28_frame_id             : out std_logic;
	ch28_ctime                : out std_logic_vector(9 downto 0);
	ch28_tac_refresh_pulse    : out std_logic;
	ch28_test_pulse           : out std_logic;
	ch28_ev_data_valid        : in std_logic;
	ch28_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch28_dark_strobe          : in std_logic;
	ch28_trig_err_strobe      : in std_logic;
	ch28_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch28_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch28_global_cal_en		 : out std_logic;

	-- Channel 29
	ch29_clk                  : out std_logic;
	ch29_reset_bar            : out std_logic;
	ch29_frame_id             : out std_logic;
	ch29_ctime                : out std_logic_vector(9 downto 0);
	ch29_tac_refresh_pulse    : out std_logic;
	ch29_test_pulse           : out std_logic;
	ch29_ev_data_valid        : in std_logic;
	ch29_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch29_dark_strobe          : in std_logic;
	ch29_trig_err_strobe      : in std_logic;
	ch29_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch29_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch29_global_cal_en		 : out std_logic;

	-- Channel 30
	ch30_clk                  : out std_logic;
	ch30_reset_bar            : out std_logic;
	ch30_frame_id             : out std_logic;
	ch30_ctime                : out std_logic_vector(9 downto 0);
	ch30_tac_refresh_pulse    : out std_logic;
	ch30_test_pulse           : out std_logic;
	ch30_ev_data_valid        : in std_logic;
	ch30_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch30_dark_strobe          : in std_logic;
	ch30_trig_err_strobe      : in std_logic;
	ch30_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch30_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch30_global_cal_en		 : out std_logic;

	-- Channel 31
	ch31_clk                  : out std_logic;
	ch31_reset_bar            : out std_logic;
	ch31_frame_id             : out std_logic;
	ch31_ctime                : out std_logic_vector(9 downto 0);
	ch31_tac_refresh_pulse    : out std_logic;
	ch31_test_pulse           : out std_logic;
	ch31_ev_data_valid        : in std_logic;
	ch31_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch31_dark_strobe          : in std_logic;
	ch31_trig_err_strobe      : in std_logic;
	ch31_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch31_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch31_global_cal_en		 : out std_logic;

	-- Channel 32
	ch32_clk                  : out std_logic;
	ch32_reset_bar            : out std_logic;
	ch32_frame_id             : out std_logic;
	ch32_ctime                : out std_logic_vector(9 downto 0);
	ch32_tac_refresh_pulse    : out std_logic;
	ch32_test_pulse           : out std_logic;
	ch32_ev_data_valid        : in std_logic;
	ch32_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch32_dark_strobe          : in std_logic;
	ch32_trig_err_strobe      : in std_logic;
	ch32_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch32_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch32_global_cal_en		 : out std_logic;

	-- Channel 33
	ch33_clk                  : out std_logic;
	ch33_reset_bar            : out std_logic;
	ch33_frame_id             : out std_logic;
	ch33_ctime                : out std_logic_vector(9 downto 0);
	ch33_tac_refresh_pulse    : out std_logic;
	ch33_test_pulse           : out std_logic;
	ch33_ev_data_valid        : in std_logic;
	ch33_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch33_dark_strobe          : in std_logic;
	ch33_trig_err_strobe      : in std_logic;
	ch33_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch33_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch33_global_cal_en		 : out std_logic;

	-- Channel 34
	ch34_clk                  : out std_logic;
	ch34_reset_bar            : out std_logic;
	ch34_frame_id             : out std_logic;
	ch34_ctime                : out std_logic_vector(9 downto 0);
	ch34_tac_refresh_pulse    : out std_logic;
	ch34_test_pulse           : out std_logic;
	ch34_ev_data_valid        : in std_logic;
	ch34_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch34_dark_strobe          : in std_logic;
	ch34_trig_err_strobe      : in std_logic;
	ch34_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch34_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch34_global_cal_en		 : out std_logic;

	-- Channel 35
	ch35_clk                  : out std_logic;
	ch35_reset_bar            : out std_logic;
	ch35_frame_id             : out std_logic;
	ch35_ctime                : out std_logic_vector(9 downto 0);
	ch35_tac_refresh_pulse    : out std_logic;
	ch35_test_pulse           : out std_logic;
	ch35_ev_data_valid        : in std_logic;
	ch35_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch35_dark_strobe          : in std_logic;
	ch35_trig_err_strobe      : in std_logic;
	ch35_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch35_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch35_global_cal_en		 : out std_logic;

	-- Channel 36
	ch36_clk                  : out std_logic;
	ch36_reset_bar            : out std_logic;
	ch36_frame_id             : out std_logic;
	ch36_ctime                : out std_logic_vector(9 downto 0);
	ch36_tac_refresh_pulse    : out std_logic;
	ch36_test_pulse           : out std_logic;
	ch36_ev_data_valid        : in std_logic;
	ch36_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch36_dark_strobe          : in std_logic;
	ch36_trig_err_strobe      : in std_logic;
	ch36_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch36_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch36_global_cal_en		 : out std_logic;

	-- Channel 37
	ch37_clk                  : out std_logic;
	ch37_reset_bar            : out std_logic;
	ch37_frame_id             : out std_logic;
	ch37_ctime                : out std_logic_vector(9 downto 0);
	ch37_tac_refresh_pulse    : out std_logic;
	ch37_test_pulse           : out std_logic;
	ch37_ev_data_valid        : in std_logic;
	ch37_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch37_dark_strobe          : in std_logic;
	ch37_trig_err_strobe      : in std_logic;
	ch37_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch37_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch37_global_cal_en		 : out std_logic;

	-- Channel 38
	ch38_clk                  : out std_logic;
	ch38_reset_bar            : out std_logic;
	ch38_frame_id             : out std_logic;
	ch38_ctime                : out std_logic_vector(9 downto 0);
	ch38_tac_refresh_pulse    : out std_logic;
	ch38_test_pulse           : out std_logic;
	ch38_ev_data_valid        : in std_logic;
	ch38_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch38_dark_strobe          : in std_logic;
	ch38_trig_err_strobe      : in std_logic;
	ch38_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch38_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch38_global_cal_en		 : out std_logic;

	-- Channel 39
	ch39_clk                  : out std_logic;
	ch39_reset_bar            : out std_logic;
	ch39_frame_id             : out std_logic;
	ch39_ctime                : out std_logic_vector(9 downto 0);
	ch39_tac_refresh_pulse    : out std_logic;
	ch39_test_pulse           : out std_logic;
	ch39_ev_data_valid        : in std_logic;
	ch39_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch39_dark_strobe          : in std_logic;
	ch39_trig_err_strobe      : in std_logic;
	ch39_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch39_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch39_global_cal_en		 : out std_logic;

	-- Channel 40
	ch40_clk                  : out std_logic;
	ch40_reset_bar            : out std_logic;
	ch40_frame_id             : out std_logic;
	ch40_ctime                : out std_logic_vector(9 downto 0);
	ch40_tac_refresh_pulse    : out std_logic;
	ch40_test_pulse           : out std_logic;
	ch40_ev_data_valid        : in std_logic;
	ch40_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch40_dark_strobe          : in std_logic;
	ch40_trig_err_strobe      : in std_logic;
	ch40_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch40_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch40_global_cal_en		 : out std_logic;

	-- Channel 41
	ch41_clk                  : out std_logic;
	ch41_reset_bar            : out std_logic;
	ch41_frame_id             : out std_logic;
	ch41_ctime                : out std_logic_vector(9 downto 0);
	ch41_tac_refresh_pulse    : out std_logic;
	ch41_test_pulse           : out std_logic;
	ch41_ev_data_valid        : in std_logic;
	ch41_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch41_dark_strobe          : in std_logic;
	ch41_trig_err_strobe      : in std_logic;
	ch41_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch41_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch41_global_cal_en		 : out std_logic;

	-- Channel 42
	ch42_clk                  : out std_logic;
	ch42_reset_bar            : out std_logic;
	ch42_frame_id             : out std_logic;
	ch42_ctime                : out std_logic_vector(9 downto 0);
	ch42_tac_refresh_pulse    : out std_logic;
	ch42_test_pulse           : out std_logic;
	ch42_ev_data_valid        : in std_logic;
	ch42_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch42_dark_strobe          : in std_logic;
	ch42_trig_err_strobe      : in std_logic;
	ch42_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch42_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch42_global_cal_en		 : out std_logic;

	-- Channel 43
	ch43_clk                  : out std_logic;
	ch43_reset_bar            : out std_logic;
	ch43_frame_id             : out std_logic;
	ch43_ctime                : out std_logic_vector(9 downto 0);
	ch43_tac_refresh_pulse    : out std_logic;
	ch43_test_pulse           : out std_logic;
	ch43_ev_data_valid        : in std_logic;
	ch43_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch43_dark_strobe          : in std_logic;
	ch43_trig_err_strobe      : in std_logic;
	ch43_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch43_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch43_global_cal_en		 : out std_logic;

	-- Channel 44
	ch44_clk                  : out std_logic;
	ch44_reset_bar            : out std_logic;
	ch44_frame_id             : out std_logic;
	ch44_ctime                : out std_logic_vector(9 downto 0);
	ch44_tac_refresh_pulse    : out std_logic;
	ch44_test_pulse           : out std_logic;
	ch44_ev_data_valid        : in std_logic;
	ch44_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch44_dark_strobe          : in std_logic;
	ch44_trig_err_strobe      : in std_logic;
	ch44_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch44_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch44_global_cal_en		 : out std_logic;

	-- Channel 45
	ch45_clk                  : out std_logic;
	ch45_reset_bar            : out std_logic;
	ch45_frame_id             : out std_logic;
	ch45_ctime                : out std_logic_vector(9 downto 0);
	ch45_tac_refresh_pulse    : out std_logic;
	ch45_test_pulse           : out std_logic;
	ch45_ev_data_valid        : in std_logic;
	ch45_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch45_dark_strobe          : in std_logic;
	ch45_trig_err_strobe      : in std_logic;
	ch45_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch45_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch45_global_cal_en		 : out std_logic;

	-- Channel 46
	ch46_clk                  : out std_logic;
	ch46_reset_bar            : out std_logic;
	ch46_frame_id             : out std_logic;
	ch46_ctime                : out std_logic_vector(9 downto 0);
	ch46_tac_refresh_pulse    : out std_logic;
	ch46_test_pulse           : out std_logic;
	ch46_ev_data_valid        : in std_logic;
	ch46_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch46_dark_strobe          : in std_logic;
	ch46_trig_err_strobe      : in std_logic;
	ch46_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch46_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch46_global_cal_en		 : out std_logic;

	-- Channel 47
	ch47_clk                  : out std_logic;
	ch47_reset_bar            : out std_logic;
	ch47_frame_id             : out std_logic;
	ch47_ctime                : out std_logic_vector(9 downto 0);
	ch47_tac_refresh_pulse    : out std_logic;
	ch47_test_pulse           : out std_logic;
	ch47_ev_data_valid        : in std_logic;
	ch47_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch47_dark_strobe          : in std_logic;
	ch47_trig_err_strobe      : in std_logic;
	ch47_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch47_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch47_global_cal_en		 : out std_logic;

	-- Channel 48
	ch48_clk                  : out std_logic;
	ch48_reset_bar            : out std_logic;
	ch48_frame_id             : out std_logic;
	ch48_ctime                : out std_logic_vector(9 downto 0);
	ch48_tac_refresh_pulse    : out std_logic;
	ch48_test_pulse           : out std_logic;
	ch48_ev_data_valid        : in std_logic;
	ch48_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch48_dark_strobe          : in std_logic;
	ch48_trig_err_strobe      : in std_logic;
	ch48_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch48_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch48_global_cal_en		 : out std_logic;

	-- Channel 49
	ch49_clk                  : out std_logic;
	ch49_reset_bar            : out std_logic;
	ch49_frame_id             : out std_logic;
	ch49_ctime                : out std_logic_vector(9 downto 0);
	ch49_tac_refresh_pulse    : out std_logic;
	ch49_test_pulse           : out std_logic;
	ch49_ev_data_valid        : in std_logic;
	ch49_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch49_dark_strobe          : in std_logic;
	ch49_trig_err_strobe      : in std_logic;
	ch49_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch49_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch49_global_cal_en		 : out std_logic;

	-- Channel 50
	ch50_clk                  : out std_logic;
	ch50_reset_bar            : out std_logic;
	ch50_frame_id             : out std_logic;
	ch50_ctime                : out std_logic_vector(9 downto 0);
	ch50_tac_refresh_pulse    : out std_logic;
	ch50_test_pulse           : out std_logic;
	ch50_ev_data_valid        : in std_logic;
	ch50_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch50_dark_strobe          : in std_logic;
	ch50_trig_err_strobe      : in std_logic;
	ch50_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch50_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch50_global_cal_en		 : out std_logic;

	-- Channel 51
	ch51_clk                  : out std_logic;
	ch51_reset_bar            : out std_logic;
	ch51_frame_id             : out std_logic;
	ch51_ctime                : out std_logic_vector(9 downto 0);
	ch51_tac_refresh_pulse    : out std_logic;
	ch51_test_pulse           : out std_logic;
	ch51_ev_data_valid        : in std_logic;
	ch51_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch51_dark_strobe          : in std_logic;
	ch51_trig_err_strobe      : in std_logic;
	ch51_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch51_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch51_global_cal_en		 : out std_logic;

	-- Channel 52
	ch52_clk                  : out std_logic;
	ch52_reset_bar            : out std_logic;
	ch52_frame_id             : out std_logic;
	ch52_ctime                : out std_logic_vector(9 downto 0);
	ch52_tac_refresh_pulse    : out std_logic;
	ch52_test_pulse           : out std_logic;
	ch52_ev_data_valid        : in std_logic;
	ch52_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch52_dark_strobe          : in std_logic;
	ch52_trig_err_strobe      : in std_logic;
	ch52_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch52_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch52_global_cal_en		 : out std_logic;

	-- Channel 53
	ch53_clk                  : out std_logic;
	ch53_reset_bar            : out std_logic;
	ch53_frame_id             : out std_logic;
	ch53_ctime                : out std_logic_vector(9 downto 0);
	ch53_tac_refresh_pulse    : out std_logic;
	ch53_test_pulse           : out std_logic;
	ch53_ev_data_valid        : in std_logic;
	ch53_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch53_dark_strobe          : in std_logic;
	ch53_trig_err_strobe      : in std_logic;
	ch53_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch53_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch53_global_cal_en		 : out std_logic;

	-- Channel 54
	ch54_clk                  : out std_logic;
	ch54_reset_bar            : out std_logic;
	ch54_frame_id             : out std_logic;
	ch54_ctime                : out std_logic_vector(9 downto 0);
	ch54_tac_refresh_pulse    : out std_logic;
	ch54_test_pulse           : out std_logic;
	ch54_ev_data_valid        : in std_logic;
	ch54_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch54_dark_strobe          : in std_logic;
	ch54_trig_err_strobe      : in std_logic;
	ch54_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch54_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch54_global_cal_en		 : out std_logic;

	-- Channel 55
	ch55_clk                  : out std_logic;
	ch55_reset_bar            : out std_logic;
	ch55_frame_id             : out std_logic;
	ch55_ctime                : out std_logic_vector(9 downto 0);
	ch55_tac_refresh_pulse    : out std_logic;
	ch55_test_pulse           : out std_logic;
	ch55_ev_data_valid        : in std_logic;
	ch55_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch55_dark_strobe          : in std_logic;
	ch55_trig_err_strobe      : in std_logic;
	ch55_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch55_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch55_global_cal_en		 : out std_logic;

	-- Channel 56
	ch56_clk                  : out std_logic;
	ch56_reset_bar            : out std_logic;
	ch56_frame_id             : out std_logic;
	ch56_ctime                : out std_logic_vector(9 downto 0);
	ch56_tac_refresh_pulse    : out std_logic;
	ch56_test_pulse           : out std_logic;
	ch56_ev_data_valid        : in std_logic;
	ch56_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch56_dark_strobe          : in std_logic;
	ch56_trig_err_strobe      : in std_logic;
	ch56_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch56_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch56_global_cal_en		 : out std_logic;

	-- Channel 57
	ch57_clk                  : out std_logic;
	ch57_reset_bar            : out std_logic;
	ch57_frame_id             : out std_logic;
	ch57_ctime                : out std_logic_vector(9 downto 0);
	ch57_tac_refresh_pulse    : out std_logic;
	ch57_test_pulse           : out std_logic;
	ch57_ev_data_valid        : in std_logic;
	ch57_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch57_dark_strobe          : in std_logic;
	ch57_trig_err_strobe      : in std_logic;
	ch57_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch57_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch57_global_cal_en		 : out std_logic;

	-- Channel 58
	ch58_clk                  : out std_logic;
	ch58_reset_bar            : out std_logic;
	ch58_frame_id             : out std_logic;
	ch58_ctime                : out std_logic_vector(9 downto 0);
	ch58_tac_refresh_pulse    : out std_logic;
	ch58_test_pulse           : out std_logic;
	ch58_ev_data_valid        : in std_logic;
	ch58_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch58_dark_strobe          : in std_logic;
	ch58_trig_err_strobe      : in std_logic;
	ch58_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch58_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch58_global_cal_en		 : out std_logic;

	-- Channel 59
	ch59_clk                  : out std_logic;
	ch59_reset_bar            : out std_logic;
	ch59_frame_id             : out std_logic;
	ch59_ctime                : out std_logic_vector(9 downto 0);
	ch59_tac_refresh_pulse    : out std_logic;
	ch59_test_pulse           : out std_logic;
	ch59_ev_data_valid        : in std_logic;
	ch59_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch59_dark_strobe          : in std_logic;
	ch59_trig_err_strobe      : in std_logic;
	ch59_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch59_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch59_global_cal_en		 : out std_logic;

	-- Channel 60
	ch60_clk                  : out std_logic;
	ch60_reset_bar            : out std_logic;
	ch60_frame_id             : out std_logic;
	ch60_ctime                : out std_logic_vector(9 downto 0);
	ch60_tac_refresh_pulse    : out std_logic;
	ch60_test_pulse           : out std_logic;
	ch60_ev_data_valid        : in std_logic;
	ch60_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch60_dark_strobe          : in std_logic;
	ch60_trig_err_strobe      : in std_logic;
	ch60_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch60_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch60_global_cal_en		 : out std_logic;

	-- Channel 61
	ch61_clk                  : out std_logic;
	ch61_reset_bar            : out std_logic;
	ch61_frame_id             : out std_logic;
	ch61_ctime                : out std_logic_vector(9 downto 0);
	ch61_tac_refresh_pulse    : out std_logic;
	ch61_test_pulse           : out std_logic;
	ch61_ev_data_valid        : in std_logic;
	ch61_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch61_dark_strobe          : in std_logic;
	ch61_trig_err_strobe      : in std_logic;
	ch61_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch61_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch61_global_cal_en		 : out std_logic;

	-- Channel 62
	ch62_clk                  : out std_logic;
	ch62_reset_bar            : out std_logic;
	ch62_frame_id             : out std_logic;
	ch62_ctime                : out std_logic_vector(9 downto 0);
	ch62_tac_refresh_pulse    : out std_logic;
	ch62_test_pulse           : out std_logic;
	ch62_ev_data_valid        : in std_logic;
	ch62_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch62_dark_strobe          : in std_logic;
	ch62_trig_err_strobe      : in std_logic;
	ch62_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch62_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch62_global_cal_en		 : out std_logic;

	-- Channel 63
	ch63_clk                  : out std_logic;
	ch63_reset_bar            : out std_logic;
	ch63_frame_id             : out std_logic;
	ch63_ctime                : out std_logic_vector(9 downto 0);
	ch63_tac_refresh_pulse    : out std_logic;
	ch63_test_pulse           : out std_logic;
	ch63_ev_data_valid        : in std_logic;
	ch63_ev_data              : in std_logic_vector(CH_DATA_SIZE-1 downto 0);
	ch63_dark_strobe          : in std_logic;
	ch63_trig_err_strobe      : in std_logic;
	ch63_config               : out std_logic_vector(CH_CONFIG_SIZE - 1 downto 0);
	ch63_tconfig              : out std_logic_vector(CH_TCONFIG_SIZE - 1 downto 0);
	ch63_global_cal_en		 : out std_logic
  );
  
end gctrl_64mx;

architecture rtl of gctrl_64mx is

constant CH_ADDR_WIDTH : integer := 7;
constant N_CHANNELS : integer := 64;
constant CNT_SIZE 		: integer := 42;
constant FIFO_AW : integer := 8;
constant BUFFER_SIZE : integer := 96;

function binary_to_gray(x: std_logic_vector) return std_logic_vector is
begin
  return x xor ('0' & x(x'length - 1 downto 1));
end binary_to_gray;

signal sync				: std_logic;
signal reset			: std_logic;
signal reset_clk		: std_logic;
signal reset_sclk		: std_logic;
signal tdc_reset_bar		: std_logic;
signal veto				: std_logic;
signal time_tag		: std_logic_vector(CNT_SIZE - 1 downto 0);
signal next_time_tag		: std_logic_vector(CNT_SIZE - 1 downto 0);
signal frame_id			: std_logic;
signal ctime			: std_logic_vector(9 downto 0);

signal counter_aux	: std_logic;
signal store_channel_counter : std_logic;

signal tac_refresh_counter_en	: std_logic;
signal tac_refresh_counter_aux1 : std_logic;
signal tac_refresh_counter	: unsigned(3 downto 0);
signal tac_refresh_counter_aux2 : std_logic;
signal tac_refresh_counter_aux3 : std_logic;
signal tac_refresh_pulse		: std_logic;

signal global_config 			: std_logic_vector(G_CONFIG_SIZE - 1 downto 0);
signal tx_mode					: std_logic_vector(1 downto 0);
signal ddr_mode					: std_logic;
signal tac_refresh_intv			: std_logic_vector(3 downto 0);
signal external_test_pulse_en	: std_logic;
signal fc_saturate_en			: std_logic;
signal fc_kf					: std_logic_vector(7 downto 0);
signal count_trig_err			: std_logic;
signal count_intv				: std_logic_vector(3 downto 0);
signal veto_enable				: std_logic;
signal test_data_mode			: std_logic;

signal global_tconfig 			: std_logic_vector(G_TCONFIG_SIZE -1 downto 0);
signal global_cal_en 			: std_logic;

signal tx_speed 				: std_logic_vector(1 downto 0);

signal ch_cfg_enable			: std_logic;
signal ch_cfg_data_i			: std_logic;
signal ch_cfg_data_o			: std_logic;
signal ch_cfg_cmd				: std_logic_vector(2 downto 0);
signal ch_cfg_address			: std_logic_vector(CH_ADDR_WIDTH-1 downto 0);

signal raw_data_valid : std_logic;
signal raw_data : std_logic_vector(CH_DATA_SIZE + CH_ADDR_WIDTH downto 0);

signal full_event_mode		: std_logic;
signal alu_event_mode		: std_logic;

signal alu_data_valid		: std_logic;
signal alu_data : std_logic_vector(39 downto 0);
signal alu_data_frameid : std_logic;

signal full_data_valid : std_logic;
signal full_data : std_logic_vector(39 downto 0);
signal full_data_frameid : std_logic;

signal test_data_valid : std_logic;
signal test_data : std_logic_vector(39 downto 0);
signal test_data_frameid : std_logic;

signal processed_data_valid : std_logic;
signal processed_data : std_logic_vector(39 downto 0);
signal processed_data_frameid : std_logic;

signal fifo_d : std_logic_vector(17 downto 0);
signal fifo_wrreq : std_logic;
signal fifo_wordsavail : std_logic_vector(FIFO_AW downto 0);

signal fifo_q : std_logic_vector(17 downto 0);
signal fifo_empty : std_logic;
signal fifo_rdreq : std_logic;

signal pulse_number : std_logic_vector(9 downto 0);
signal pulse_length : std_logic_vector(7 downto 0);
signal pulse_intv : std_logic_vector(7 downto 0);
signal pulse_strobe : std_logic;
signal pulse_number_q0 : std_logic_vector(9 downto 0);
signal pulse_length_q0 : std_logic_vector(7 downto 0);
signal pulse_intv_q0 : std_logic_vector(7 downto 0);
signal pulse_strobe_q0 : std_logic;


signal internal_test_pulse : std_logic;
signal test_pulse		: std_logic;



type ch_ev_data_arr_t is array (N_CHANNELS-1 downto 0) of std_logic_vector(CH_DATA_SIZE-1 downto 0);
signal ch_ev_data_arr : ch_ev_data_arr_t;
signal ch_ev_valid_arr : std_logic_vector(N_CHANNELS-1 downto 0);
signal ch_dark_count_strobe_arr : std_logic_vector(N_CHANNELS-1 downto 0);
signal ch_trig_err_strobe_arr : std_logic_vector(N_CHANNELS-1 downto 0);

signal t2_enable : std_logic;
signal t2_ev_valid_arr: std_logic_vector(N_CHANNELS-1 downto 0);
signal t2_raw_data : std_logic_vector(CH_DATA_SIZE + CH_ADDR_WIDTH downto 0);
signal t2_raw_data_c : std_logic_vector(CH_DATA_SIZE + CH_ADDR_WIDTH downto 0);
signal t2_raw_data_valid : std_logic;
signal t2_raw_data_valid_c : std_logic;
signal t2_channel_selector : std_logic_vector(5 downto 0);
signal t2_channel_selector_decoded : std_logic_vector(11 downto 0);
signal t2_token_arr : std_logic_vector(N_CHANNELS-1 downto 0);


signal token_arr : std_logic_vector(N_CHANNELS-1 downto 0);
signal raw_ev_valid_arr : std_logic_vector(N_CHANNELS-1 downto 0);
type raw_ev_data_arr_A_t is array (N_CHANNELS-1 downto 0) of std_logic_vector(CH_DATA_SIZE + CH_ADDR_WIDTH downto 0);
signal raw_ev_data_arr_A : raw_ev_data_arr_A_t;
type raw_ev_data_arr_B_t is array (CH_DATA_SIZE + CH_ADDR_WIDTH downto 0) of std_logic_vector(N_CHANNELS-1 downto 0);
signal raw_ev_data_arr_B : raw_ev_data_arr_B_t;



signal ch_cfg_address_decoded : std_logic_vector(11 downto 0);
type ch_config_arr_t is array (0 to N_CHANNELS-1) of std_logic_vector(CH_CONFIG_SIZE-1 downto 0);
signal ch_config_arr : ch_config_arr_t;
type ch_tconfig_arr_t is array (0 to N_CHANNELS-1) of std_logic_vector(CH_TCONFIG_SIZE-1 downto 0);
signal ch_tconfig_arr : ch_tconfig_arr_t;
signal ch_cfg_data_i_arr : std_logic_vector(N_CHANNELS-1 downto 0);

begin

-- sync/reset generation
process (clk_i)
begin
if rising_edge(clk_i) then
	sync <= sync_rst_i;
    reset <= sync_rst_i and sync;
end if;    
end process;

process(clk_i, sync) begin
if sync = '1' then
	reset_clk <= '1';
elsif rising_edge(clk_i) then
	reset_clk <= '0';
end if;
end process;

process(sclk_i, reset) begin
if reset = '1' then
	reset_sclk <= '1';
elsif rising_edge(sclk_i) then
	reset_sclk <= '0';
end if;
end process;

-- CS is veto
process (clk_i, cs_i, veto_enable) begin
if cs_i = '1' and veto_enable = '1' then
	veto <= '1';
elsif rising_edge(clk_i) then
	veto <= '0';
end if;
end process;
 
tdc_reset_generator : entity gctrl_lib.tdc_reset_generator
port map (
	clk => clk_i,
	reset => reset_clk,
	veto => veto,
	ctime_parity => time_tag(0),
	reset_bar => tdc_reset_bar
);

-- 42 bit counter that serves as global timestamp
-- 32 MSB will serve as frame ID in packets
-- 10 LSB are used, gray encoded, by the TDCs
-- bit 10 is also by the TDCs to discriminate events from consecutive frames
next_time_tag <= std_logic_vector(unsigned(time_tag) + 1);
process (clk_i, reset_clk) begin
if reset_clk = '1' then
    time_tag <= (others => '0');
    frame_id <= '0';
    ctime <= (others => '0');
elsif rising_edge(clk_i) then
    time_tag <= next_time_tag;
    frame_id <= next_time_tag(10);
    ctime <= binary_to_gray(next_time_tag(9 downto 0));
end if;    
end process;

-- Data processing pipeline
-- Arithmetic module 
alu : entity gctrl_lib.arithm 
port map (
	clk => clk_i,  
	reset => reset_clk,
	enable => alu_event_mode,
	fine_counter_sub => fc_kf,	
	fine_counter_saturate => fc_saturate_en,	 
	data_in_valid => raw_data_valid,	
	data_in => raw_data,
	data_out => alu_data,  
	data_out_valid => alu_data_valid, 
	data_out_frameid => alu_data_frameid
);


-- Ful event module
full : entity gctrl_lib.full_data 
port map (
	clk => clk_i,  
	reset => reset_clk,
	enable => full_event_mode,
	data_in_valid => raw_data_valid,	
	data_in => raw_data,
	data_out => full_data,  
	data_out_valid => full_data_valid, 
	data_out_frameid => full_data_frameid

);

test : entity gctrl_lib.test_frame_generator
port map (
	clk => clk_i,
	reset => reset_clk,
	ctime => time_tag,
	data_out_valid => test_data_valid,
	data_out => test_data,
	data_out_frameid => test_data_frameid
);

processed_data <=
	test_data when test_data_mode = '1' else
	full_data when full_event_mode = '1' else 
	alu_data;
processed_data_valid <= 
	test_data_valid when test_data_mode = '1' else
	full_data_valid when full_event_mode = '1' else 
	alu_data_valid;
processed_data_frameid <= 
	test_data_frameid when test_data_mode = '1' else
	full_data_frameid when full_event_mode = '1' else 
	alu_data_frameid;


tx_speed <=	"00" when tx_mode = "00" and ddr_mode = '0' else
			"01" when tx_mode = "01" and ddr_mode = '0' else
			"01" when tx_mode = "00" and ddr_mode = '1' else
			"10"; -- when tx_mode = "01" and ddr_mode = '1';
				
-- Frame buffers and formatter
fb : entity gctrl_lib.frame_block  generic map (
  BUFFER_SIZE => BUFFER_SIZE,
  FIFO_AW => FIFO_AW
)
port map (
  clk => clk_i,
  reset => reset_clk,
  ctime => time_tag,
  
  data_in => processed_data,
  data_in_valid => processed_data_valid,
  data_in_frameid => processed_data_frameid,
  
  q => fifo_d,
  wrreq => fifo_wrreq,
  words_avail => fifo_wordsavail,
  
  tx_speed => tx_speed  
);
-- Output FIFO
fifo : entity gctrl_lib.word_fifo 
generic map (
  FIFO_WIDTH => 18,
  FIFO_AW => FIFO_AW,
  FIFO_SIZE => 2**FIFO_AW
)
port map (
  clk => clk_i,
  reset => reset_clk,
  
  d => fifo_d,
  wrreq => fifo_wrreq,
  words_avail => fifo_wordsavail,
  
  q => fifo_q,
  empty => fifo_empty,
  rdreq => fifo_rdreq  
);
-- TX module
tx : entity gctrl_lib.tx_block 
port map (
  clk => clk_i,
  reset => reset_clk,
  
  tx_mode => tx_mode,
  ddr_mode => ddr_mode,
  
  fifo_q => fifo_q,
  fifo_empty => fifo_empty,
  fifo_rdreq => fifo_rdreq,  
  
  tx0 => tx0_o,
  tx1 => tx1_o,
  tx2 => open,
  tx3 => open
  
);
clk_o <= clk_i;

-- Configuration module
cfg_ctrl : entity gctrl_lib.config_controller
generic map (	
    GLOBAL_CONFIG_SIZE => G_CONFIG_SIZE,
    GLOBAL_TCONFIG_SIZE => G_TCONFIG_SIZE,
    CH_CONFIG_SIZE => CH_CONFIG_SIZE,
    CH_TCONFIG_SIZE => CH_TCONFIG_SIZE,
    DARK_COUNT_SIZE => CH_DARK_COUNT_SIZE
)
port map (
	sclk => sclk_i,
	reset => reset_sclk,
	cs => cs_i,
	sdi => sdi_i,
	sdo => sdo_o,
	sdo_oe => sdo_oe,
	global_config => global_config,
	global_tconfig => global_tconfig,
	ch_cfg_enable => ch_cfg_enable,
	ch_cfg_data_i => ch_cfg_data_i,
	ch_cfg_data_o => ch_cfg_data_o,
	ch_cfg_cmd => ch_cfg_cmd,
	ch_cfg_address => ch_cfg_address,
	pulse_strobe => pulse_strobe,
	pulse_number => pulse_number,
	pulse_length => pulse_length,
	pulse_intv => pulse_intv
);
-- Global configuration breakout

tx_mode <= global_config(1 downto 0);
ddr_mode <= global_config(2);
external_test_pulse_en <= global_config(3);
tac_refresh_intv <= global_config(7 downto 4);
fc_saturate_en <= global_config(8);
fc_kf <= global_config(16 downto 9);
count_trig_err <= global_config(17);
count_intv <= global_config(21 downto 18);
full_event_mode <= global_config(22); alu_event_mode <= not full_event_mode;
veto_enable <= global_config(23);
test_data_mode <= global_config(24);
clk_oe <= global_config(25);
tx1_oe <= '0' when tx_mode = "00" else '1';

gconfig_o <= global_config(G_CONFIG_SIZE-1 downto G_CONFIG_SIZE-GE_CONFIG_SIZE);
 
global_cal_en <= global_tconfig(0);
gtconfig_o <= global_tconfig(G_TCONFIG_SIZE-1 downto G_TCONFIG_SIZE-GE_TCONFIG_SIZE);
global_cal_en_o <= global_cal_en;

process (clk_i, reset) begin
if reset = '1' then
	pulse_number_q0 <= (others => '0');
	pulse_length_q0 <= (others => '0');
	pulse_intv_q0 <= (others => '0');
	pulse_strobe_q0 <= '0';
elsif rising_edge(clk_i) then
	pulse_number_q0 <= pulse_number;
	pulse_length_q0 <= pulse_length;
	pulse_intv_q0 <= pulse_intv;
	pulse_strobe_q0 <= pulse_strobe;
end if;
end process;

pulse_generator0 : entity gctrl_lib.pulse_generator 
port map (
  clk => clk_i,
  reset => reset_clk,  
  pulse_number => pulse_number_q0,
  pulse_intv => pulse_intv_q0,
  pulse_length => pulse_length_q0,
  pulse_strobe => pulse_strobe_q0,  
  test_pulse => internal_test_pulse
);
-- Internal test pulse or external test pulse
test_pulse <=	'1' when internal_test_pulse = '1' else
				'1' when test_pulse_i = '1' and external_test_pulse_en = '1' else
				'0';
test_pulse_o <= test_pulse;

-- TAC refresh
tac_refresh : entity gctrl_lib.tac_refresh_generator
port map (
    clk => clk_i,
    reset => reset_clk,
    time_tag => time_tag,
    intv => tac_refresh_intv,
    strobe => tac_refresh_pulse
);

-- Channel count store
ch_count : entity gctrl_lib.channel_count_generator 
port map (
    clk => clk_i,
    reset => reset_clk,
    time_tag => time_tag,
    intv => count_intv,
    strobe => store_channel_counter
);


-- Channels
channel_generator : for i in 0 to N_CHANNELS-1 generate
	channel : entity gctrl_lib.channel
	generic map (
		ADDRESS => i, 
		CH_ADDR_WIDTH => CH_ADDR_WIDTH,
		CH_DATA_SIZE => CH_DATA_SIZE,
		CH_CONFIG_SIZE => CH_CONFIG_SIZE, 
		CH_TCONFIG_SIZE => CH_TCONFIG_SIZE, 
		DARK_COUNT_SIZE => CH_DARK_COUNT_SIZE
	)
	port map (
		clk => clk_i,
		reset_clk => reset_clk,
		veto => veto,
		sclk => sclk_i,
		reset_sclk => reset_sclk,
		ch_cfg_enable => ch_cfg_enable,
		ch_cfg_cmd => ch_cfg_cmd,
		ch_cfg_address => ch_cfg_address,
		ch_cfg_data_i => ch_cfg_data_o,
		ch_cfg_data_o => ch_cfg_data_i_arr(i),
		config => ch_config_arr(i),
		tconfig => ch_tconfig_arr(i),
		ev_valid_i => ch_ev_valid_arr(i),
		ev_data_i => ch_ev_data_arr(i),
		read_enable => t2_enable,
		token => token_arr(i),
		ev_valid_o => raw_ev_valid_arr(i),
		ev_data_o => raw_ev_data_arr_A(i),
		dark_count_strobe => ch_dark_count_strobe_arr(i),
		trig_err_strobe => ch_trig_err_strobe_arr(i),
		count_trig_err => count_trig_err,
		store_channel_counter => store_channel_counter		
);
end generate;



t2_enable <= '1' when time_tag(1 downto 0) = "11" else '0';

process (clk_i, sync) begin
if sync = '1' then
	t2_ev_valid_arr <= (others => '0');
elsif rising_edge(clk_i) and t2_enable = '1' then
	t2_ev_valid_arr <= raw_ev_valid_arr;
end if;
end process;

process (t2_ev_valid_arr) begin
	t2_channel_selector <= (others => 'X');
	for i in 0 to N_CHANNELS-1 loop
		if t2_ev_valid_arr(i) = '1' then
			t2_channel_selector <= std_logic_vector(to_unsigned(i, 6));
		end if;
	end loop;
end process;

t2_ev_mux_decoder : entity gctrl_lib.mux64_decoder port map (x => t2_channel_selector, y => t2_channel_selector_decoded);

process(t2_ev_valid_arr, t2_channel_selector) begin
	t2_token_arr <= (others => '0');
	if t2_ev_valid_arr /= x"0000_0000_0000_0000" then
		t2_token_arr(to_integer(unsigned(t2_channel_selector))) <= '1';
	end if;
end process;
token_arr <= t2_token_arr;

t2_ev_data_mux : for j in 0 to CH_DATA_SIZE + CH_ADDR_WIDTH generate
	shuffle : for i in 0 to N_CHANNELS-1 generate	
		raw_ev_data_arr_B(j)(i) <= raw_ev_data_arr_A(i)(j);
	end generate;

	mux : entity gctrl_lib.mux64 
	port map (
		a => t2_channel_selector_decoded,
		d => raw_ev_data_arr_B(j),
		q => t2_raw_data_c(j)
	);
end generate;

t2_ev_data_valid_mux : entity gctrl_lib.mux64 
	port map (
		a => t2_channel_selector_decoded,
		d => raw_ev_valid_arr,
		q => t2_raw_data_valid_c
	);

process(clk_i, sync) begin
if sync = '1' then
	t2_raw_data <= (others => '0');
	t2_raw_data_valid <= '0';
elsif rising_edge(clk_i) and t2_enable = '1' then
	if t2_ev_valid_arr /= x"0000_0000_0000_0000" then
		t2_raw_data <= t2_raw_data_c;
		t2_raw_data_valid <= t2_raw_data_valid_c;
	else
		t2_raw_data_valid <= '0';
	end if;
end if;
end process;


raw_data <= t2_raw_data;
raw_data_valid <= '1' when t2_raw_data_valid = '1' and t2_enable = '1' else '0';


-- Channel config/Dark readback MUX
cfg_mux_decoder : entity gctrl_lib.mux64_decoder port map (x => ch_cfg_address(5 downto 0), y => ch_cfg_address_decoded);
cfg_mux : entity gctrl_lib.mux64 
port map (
	a => ch_cfg_address_decoded,
	d => ch_cfg_data_i_arr,
	q => ch_cfg_data_i
);

-- I/O mapping
-- Channel 0
ch0_clk <= clk_i;
ch0_reset_bar <= tdc_reset_bar;
ch0_frame_id <= frame_id;
ch0_ctime <= ctime;
ch0_tac_refresh_pulse <= tac_refresh_pulse;
ch0_test_pulse <= test_pulse;
ch_ev_valid_arr(0) <= ch0_ev_data_valid;
ch_ev_data_arr(0) <= ch0_ev_data;
ch_dark_count_strobe_arr(0) <= ch0_dark_strobe;
ch_trig_err_strobe_arr(0) <= ch0_trig_err_strobe;
ch0_config <= ch_config_arr(0);
ch0_tconfig <= ch_tconfig_arr(0);
ch0_global_cal_en <= global_cal_en;

-- Channel 1
ch1_clk <= clk_i;
ch1_reset_bar <= tdc_reset_bar;
ch1_frame_id <= frame_id;
ch1_ctime <= ctime;
ch1_tac_refresh_pulse <= tac_refresh_pulse;
ch1_test_pulse <= test_pulse;
ch_ev_valid_arr(1) <= ch1_ev_data_valid;
ch_ev_data_arr(1) <= ch1_ev_data;
ch_dark_count_strobe_arr(1) <= ch1_dark_strobe;
ch_trig_err_strobe_arr(1) <= ch1_trig_err_strobe;
ch1_config <= ch_config_arr(1);
ch1_tconfig <= ch_tconfig_arr(1);
ch1_global_cal_en <= global_cal_en;

-- Channel 2
ch2_clk <= clk_i;
ch2_reset_bar <= tdc_reset_bar;
ch2_frame_id <= frame_id;
ch2_ctime <= ctime;
ch2_tac_refresh_pulse <= tac_refresh_pulse;
ch2_test_pulse <= test_pulse;
ch_ev_valid_arr(2) <= ch2_ev_data_valid;
ch_ev_data_arr(2) <= ch2_ev_data;
ch_dark_count_strobe_arr(2) <= ch2_dark_strobe;
ch_trig_err_strobe_arr(2) <= ch2_trig_err_strobe;
ch2_config <= ch_config_arr(2);
ch2_tconfig <= ch_tconfig_arr(2);
ch2_global_cal_en <= global_cal_en;

-- Channel 3
ch3_clk <= clk_i;
ch3_reset_bar <= tdc_reset_bar;
ch3_frame_id <= frame_id;
ch3_ctime <= ctime;
ch3_tac_refresh_pulse <= tac_refresh_pulse;
ch3_test_pulse <= test_pulse;
ch_ev_valid_arr(3) <= ch3_ev_data_valid;
ch_ev_data_arr(3) <= ch3_ev_data;
ch_dark_count_strobe_arr(3) <= ch3_dark_strobe;
ch_trig_err_strobe_arr(3) <= ch3_trig_err_strobe;
ch3_config <= ch_config_arr(3);
ch3_tconfig <= ch_tconfig_arr(3);
ch3_global_cal_en <= global_cal_en;

-- Channel 4
ch4_clk <= clk_i;
ch4_reset_bar <= tdc_reset_bar;
ch4_frame_id <= frame_id;
ch4_ctime <= ctime;
ch4_tac_refresh_pulse <= tac_refresh_pulse;
ch4_test_pulse <= test_pulse;
ch_ev_valid_arr(4) <= ch4_ev_data_valid;
ch_ev_data_arr(4) <= ch4_ev_data;
ch_dark_count_strobe_arr(4) <= ch4_dark_strobe;
ch_trig_err_strobe_arr(4) <= ch4_trig_err_strobe;
ch4_config <= ch_config_arr(4);
ch4_tconfig <= ch_tconfig_arr(4);
ch4_global_cal_en <= global_cal_en;

-- Channel 5
ch5_clk <= clk_i;
ch5_reset_bar <= tdc_reset_bar;
ch5_frame_id <= frame_id;
ch5_ctime <= ctime;
ch5_tac_refresh_pulse <= tac_refresh_pulse;
ch5_test_pulse <= test_pulse;
ch_ev_valid_arr(5) <= ch5_ev_data_valid;
ch_ev_data_arr(5) <= ch5_ev_data;
ch_dark_count_strobe_arr(5) <= ch5_dark_strobe;
ch_trig_err_strobe_arr(5) <= ch5_trig_err_strobe;
ch5_config <= ch_config_arr(5);
ch5_tconfig <= ch_tconfig_arr(5);
ch5_global_cal_en <= global_cal_en;

-- Channel 6
ch6_clk <= clk_i;
ch6_reset_bar <= tdc_reset_bar;
ch6_frame_id <= frame_id;
ch6_ctime <= ctime;
ch6_tac_refresh_pulse <= tac_refresh_pulse;
ch6_test_pulse <= test_pulse;
ch_ev_valid_arr(6) <= ch6_ev_data_valid;
ch_ev_data_arr(6) <= ch6_ev_data;
ch_dark_count_strobe_arr(6) <= ch6_dark_strobe;
ch_trig_err_strobe_arr(6) <= ch6_trig_err_strobe;
ch6_config <= ch_config_arr(6);
ch6_tconfig <= ch_tconfig_arr(6);
ch6_global_cal_en <= global_cal_en;

-- Channel 7
ch7_clk <= clk_i;
ch7_reset_bar <= tdc_reset_bar;
ch7_frame_id <= frame_id;
ch7_ctime <= ctime;
ch7_tac_refresh_pulse <= tac_refresh_pulse;
ch7_test_pulse <= test_pulse;
ch_ev_valid_arr(7) <= ch7_ev_data_valid;
ch_ev_data_arr(7) <= ch7_ev_data;
ch_dark_count_strobe_arr(7) <= ch7_dark_strobe;
ch_trig_err_strobe_arr(7) <= ch7_trig_err_strobe;
ch7_config <= ch_config_arr(7);
ch7_tconfig <= ch_tconfig_arr(7);
ch7_global_cal_en <= global_cal_en;

-- Channel 8
ch8_clk <= clk_i;
ch8_reset_bar <= tdc_reset_bar;
ch8_frame_id <= frame_id;
ch8_ctime <= ctime;
ch8_tac_refresh_pulse <= tac_refresh_pulse;
ch8_test_pulse <= test_pulse;
ch_ev_valid_arr(8) <= ch8_ev_data_valid;
ch_ev_data_arr(8) <= ch8_ev_data;
ch_dark_count_strobe_arr(8) <= ch8_dark_strobe;
ch_trig_err_strobe_arr(8) <= ch8_trig_err_strobe;
ch8_config <= ch_config_arr(8);
ch8_tconfig <= ch_tconfig_arr(8);
ch8_global_cal_en <= global_cal_en;

-- Channel 9
ch9_clk <= clk_i;
ch9_reset_bar <= tdc_reset_bar;
ch9_frame_id <= frame_id;
ch9_ctime <= ctime;
ch9_tac_refresh_pulse <= tac_refresh_pulse;
ch9_test_pulse <= test_pulse;
ch_ev_valid_arr(9) <= ch9_ev_data_valid;
ch_ev_data_arr(9) <= ch9_ev_data;
ch_dark_count_strobe_arr(9) <= ch9_dark_strobe;
ch_trig_err_strobe_arr(9) <= ch9_trig_err_strobe;
ch9_config <= ch_config_arr(9);
ch9_tconfig <= ch_tconfig_arr(9);
ch9_global_cal_en <= global_cal_en;

-- Channel 10
ch10_clk <= clk_i;
ch10_reset_bar <= tdc_reset_bar;
ch10_frame_id <= frame_id;
ch10_ctime <= ctime;
ch10_tac_refresh_pulse <= tac_refresh_pulse;
ch10_test_pulse <= test_pulse;
ch_ev_valid_arr(10) <= ch10_ev_data_valid;
ch_ev_data_arr(10) <= ch10_ev_data;
ch_dark_count_strobe_arr(10) <= ch10_dark_strobe;
ch_trig_err_strobe_arr(10) <= ch10_trig_err_strobe;
ch10_config <= ch_config_arr(10);
ch10_tconfig <= ch_tconfig_arr(10);
ch10_global_cal_en <= global_cal_en;

-- Channel 11
ch11_clk <= clk_i;
ch11_reset_bar <= tdc_reset_bar;
ch11_frame_id <= frame_id;
ch11_ctime <= ctime;
ch11_tac_refresh_pulse <= tac_refresh_pulse;
ch11_test_pulse <= test_pulse;
ch_ev_valid_arr(11) <= ch11_ev_data_valid;
ch_ev_data_arr(11) <= ch11_ev_data;
ch_dark_count_strobe_arr(11) <= ch11_dark_strobe;
ch_trig_err_strobe_arr(11) <= ch11_trig_err_strobe;
ch11_config <= ch_config_arr(11);
ch11_tconfig <= ch_tconfig_arr(11);
ch11_global_cal_en <= global_cal_en;

-- Channel 12
ch12_clk <= clk_i;
ch12_reset_bar <= tdc_reset_bar;
ch12_frame_id <= frame_id;
ch12_ctime <= ctime;
ch12_tac_refresh_pulse <= tac_refresh_pulse;
ch12_test_pulse <= test_pulse;
ch_ev_valid_arr(12) <= ch12_ev_data_valid;
ch_ev_data_arr(12) <= ch12_ev_data;
ch_dark_count_strobe_arr(12) <= ch12_dark_strobe;
ch_trig_err_strobe_arr(12) <= ch12_trig_err_strobe;
ch12_config <= ch_config_arr(12);
ch12_tconfig <= ch_tconfig_arr(12);
ch12_global_cal_en <= global_cal_en;

-- Channel 13
ch13_clk <= clk_i;
ch13_reset_bar <= tdc_reset_bar;
ch13_frame_id <= frame_id;
ch13_ctime <= ctime;
ch13_tac_refresh_pulse <= tac_refresh_pulse;
ch13_test_pulse <= test_pulse;
ch_ev_valid_arr(13) <= ch13_ev_data_valid;
ch_ev_data_arr(13) <= ch13_ev_data;
ch_dark_count_strobe_arr(13) <= ch13_dark_strobe;
ch_trig_err_strobe_arr(13) <= ch13_trig_err_strobe;
ch13_config <= ch_config_arr(13);
ch13_tconfig <= ch_tconfig_arr(13);
ch13_global_cal_en <= global_cal_en;

-- Channel 14
ch14_clk <= clk_i;
ch14_reset_bar <= tdc_reset_bar;
ch14_frame_id <= frame_id;
ch14_ctime <= ctime;
ch14_tac_refresh_pulse <= tac_refresh_pulse;
ch14_test_pulse <= test_pulse;
ch_ev_valid_arr(14) <= ch14_ev_data_valid;
ch_ev_data_arr(14) <= ch14_ev_data;
ch_dark_count_strobe_arr(14) <= ch14_dark_strobe;
ch_trig_err_strobe_arr(14) <= ch14_trig_err_strobe;
ch14_config <= ch_config_arr(14);
ch14_tconfig <= ch_tconfig_arr(14);
ch14_global_cal_en <= global_cal_en;

-- Channel 15
ch15_clk <= clk_i;
ch15_reset_bar <= tdc_reset_bar;
ch15_frame_id <= frame_id;
ch15_ctime <= ctime;
ch15_tac_refresh_pulse <= tac_refresh_pulse;
ch15_test_pulse <= test_pulse;
ch_ev_valid_arr(15) <= ch15_ev_data_valid;
ch_ev_data_arr(15) <= ch15_ev_data;
ch_dark_count_strobe_arr(15) <= ch15_dark_strobe;
ch_trig_err_strobe_arr(15) <= ch15_trig_err_strobe;
ch15_config <= ch_config_arr(15);
ch15_tconfig <= ch_tconfig_arr(15);
ch15_global_cal_en <= global_cal_en;

-- Channel 16
ch16_clk <= clk_i;
ch16_reset_bar <= tdc_reset_bar;
ch16_frame_id <= frame_id;
ch16_ctime <= ctime;
ch16_tac_refresh_pulse <= tac_refresh_pulse;
ch16_test_pulse <= test_pulse;
ch_ev_valid_arr(16) <= ch16_ev_data_valid;
ch_ev_data_arr(16) <= ch16_ev_data;
ch_dark_count_strobe_arr(16) <= ch16_dark_strobe;
ch_trig_err_strobe_arr(16) <= ch16_trig_err_strobe;
ch16_config <= ch_config_arr(16);
ch16_tconfig <= ch_tconfig_arr(16);
ch16_global_cal_en <= global_cal_en;

-- Channel 17
ch17_clk <= clk_i;
ch17_reset_bar <= tdc_reset_bar;
ch17_frame_id <= frame_id;
ch17_ctime <= ctime;
ch17_tac_refresh_pulse <= tac_refresh_pulse;
ch17_test_pulse <= test_pulse;
ch_ev_valid_arr(17) <= ch17_ev_data_valid;
ch_ev_data_arr(17) <= ch17_ev_data;
ch_dark_count_strobe_arr(17) <= ch17_dark_strobe;
ch_trig_err_strobe_arr(17) <= ch17_trig_err_strobe;
ch17_config <= ch_config_arr(17);
ch17_tconfig <= ch_tconfig_arr(17);
ch17_global_cal_en <= global_cal_en;

-- Channel 18
ch18_clk <= clk_i;
ch18_reset_bar <= tdc_reset_bar;
ch18_frame_id <= frame_id;
ch18_ctime <= ctime;
ch18_tac_refresh_pulse <= tac_refresh_pulse;
ch18_test_pulse <= test_pulse;
ch_ev_valid_arr(18) <= ch18_ev_data_valid;
ch_ev_data_arr(18) <= ch18_ev_data;
ch_dark_count_strobe_arr(18) <= ch18_dark_strobe;
ch_trig_err_strobe_arr(18) <= ch18_trig_err_strobe;
ch18_config <= ch_config_arr(18);
ch18_tconfig <= ch_tconfig_arr(18);
ch18_global_cal_en <= global_cal_en;

-- Channel 19
ch19_clk <= clk_i;
ch19_reset_bar <= tdc_reset_bar;
ch19_frame_id <= frame_id;
ch19_ctime <= ctime;
ch19_tac_refresh_pulse <= tac_refresh_pulse;
ch19_test_pulse <= test_pulse;
ch_ev_valid_arr(19) <= ch19_ev_data_valid;
ch_ev_data_arr(19) <= ch19_ev_data;
ch_dark_count_strobe_arr(19) <= ch19_dark_strobe;
ch_trig_err_strobe_arr(19) <= ch19_trig_err_strobe;
ch19_config <= ch_config_arr(19);
ch19_tconfig <= ch_tconfig_arr(19);
ch19_global_cal_en <= global_cal_en;

-- Channel 20
ch20_clk <= clk_i;
ch20_reset_bar <= tdc_reset_bar;
ch20_frame_id <= frame_id;
ch20_ctime <= ctime;
ch20_tac_refresh_pulse <= tac_refresh_pulse;
ch20_test_pulse <= test_pulse;
ch_ev_valid_arr(20) <= ch20_ev_data_valid;
ch_ev_data_arr(20) <= ch20_ev_data;
ch_dark_count_strobe_arr(20) <= ch20_dark_strobe;
ch_trig_err_strobe_arr(20) <= ch20_trig_err_strobe;
ch20_config <= ch_config_arr(20);
ch20_tconfig <= ch_tconfig_arr(20);
ch20_global_cal_en <= global_cal_en;

-- Channel 21
ch21_clk <= clk_i;
ch21_reset_bar <= tdc_reset_bar;
ch21_frame_id <= frame_id;
ch21_ctime <= ctime;
ch21_tac_refresh_pulse <= tac_refresh_pulse;
ch21_test_pulse <= test_pulse;
ch_ev_valid_arr(21) <= ch21_ev_data_valid;
ch_ev_data_arr(21) <= ch21_ev_data;
ch_dark_count_strobe_arr(21) <= ch21_dark_strobe;
ch_trig_err_strobe_arr(21) <= ch21_trig_err_strobe;
ch21_config <= ch_config_arr(21);
ch21_tconfig <= ch_tconfig_arr(21);
ch21_global_cal_en <= global_cal_en;

-- Channel 22
ch22_clk <= clk_i;
ch22_reset_bar <= tdc_reset_bar;
ch22_frame_id <= frame_id;
ch22_ctime <= ctime;
ch22_tac_refresh_pulse <= tac_refresh_pulse;
ch22_test_pulse <= test_pulse;
ch_ev_valid_arr(22) <= ch22_ev_data_valid;
ch_ev_data_arr(22) <= ch22_ev_data;
ch_dark_count_strobe_arr(22) <= ch22_dark_strobe;
ch_trig_err_strobe_arr(22) <= ch22_trig_err_strobe;
ch22_config <= ch_config_arr(22);
ch22_tconfig <= ch_tconfig_arr(22);
ch22_global_cal_en <= global_cal_en;

-- Channel 23
ch23_clk <= clk_i;
ch23_reset_bar <= tdc_reset_bar;
ch23_frame_id <= frame_id;
ch23_ctime <= ctime;
ch23_tac_refresh_pulse <= tac_refresh_pulse;
ch23_test_pulse <= test_pulse;
ch_ev_valid_arr(23) <= ch23_ev_data_valid;
ch_ev_data_arr(23) <= ch23_ev_data;
ch_dark_count_strobe_arr(23) <= ch23_dark_strobe;
ch_trig_err_strobe_arr(23) <= ch23_trig_err_strobe;
ch23_config <= ch_config_arr(23);
ch23_tconfig <= ch_tconfig_arr(23);
ch23_global_cal_en <= global_cal_en;

-- Channel 24
ch24_clk <= clk_i;
ch24_reset_bar <= tdc_reset_bar;
ch24_frame_id <= frame_id;
ch24_ctime <= ctime;
ch24_tac_refresh_pulse <= tac_refresh_pulse;
ch24_test_pulse <= test_pulse;
ch_ev_valid_arr(24) <= ch24_ev_data_valid;
ch_ev_data_arr(24) <= ch24_ev_data;
ch_dark_count_strobe_arr(24) <= ch24_dark_strobe;
ch_trig_err_strobe_arr(24) <= ch24_trig_err_strobe;
ch24_config <= ch_config_arr(24);
ch24_tconfig <= ch_tconfig_arr(24);
ch24_global_cal_en <= global_cal_en;

-- Channel 25
ch25_clk <= clk_i;
ch25_reset_bar <= tdc_reset_bar;
ch25_frame_id <= frame_id;
ch25_ctime <= ctime;
ch25_tac_refresh_pulse <= tac_refresh_pulse;
ch25_test_pulse <= test_pulse;
ch_ev_valid_arr(25) <= ch25_ev_data_valid;
ch_ev_data_arr(25) <= ch25_ev_data;
ch_dark_count_strobe_arr(25) <= ch25_dark_strobe;
ch_trig_err_strobe_arr(25) <= ch25_trig_err_strobe;
ch25_config <= ch_config_arr(25);
ch25_tconfig <= ch_tconfig_arr(25);
ch25_global_cal_en <= global_cal_en;

-- Channel 26
ch26_clk <= clk_i;
ch26_reset_bar <= tdc_reset_bar;
ch26_frame_id <= frame_id;
ch26_ctime <= ctime;
ch26_tac_refresh_pulse <= tac_refresh_pulse;
ch26_test_pulse <= test_pulse;
ch_ev_valid_arr(26) <= ch26_ev_data_valid;
ch_ev_data_arr(26) <= ch26_ev_data;
ch_dark_count_strobe_arr(26) <= ch26_dark_strobe;
ch_trig_err_strobe_arr(26) <= ch26_trig_err_strobe;
ch26_config <= ch_config_arr(26);
ch26_tconfig <= ch_tconfig_arr(26);
ch26_global_cal_en <= global_cal_en;

-- Channel 27
ch27_clk <= clk_i;
ch27_reset_bar <= tdc_reset_bar;
ch27_frame_id <= frame_id;
ch27_ctime <= ctime;
ch27_tac_refresh_pulse <= tac_refresh_pulse;
ch27_test_pulse <= test_pulse;
ch_ev_valid_arr(27) <= ch27_ev_data_valid;
ch_ev_data_arr(27) <= ch27_ev_data;
ch_dark_count_strobe_arr(27) <= ch27_dark_strobe;
ch_trig_err_strobe_arr(27) <= ch27_trig_err_strobe;
ch27_config <= ch_config_arr(27);
ch27_tconfig <= ch_tconfig_arr(27);
ch27_global_cal_en <= global_cal_en;

-- Channel 28
ch28_clk <= clk_i;
ch28_reset_bar <= tdc_reset_bar;
ch28_frame_id <= frame_id;
ch28_ctime <= ctime;
ch28_tac_refresh_pulse <= tac_refresh_pulse;
ch28_test_pulse <= test_pulse;
ch_ev_valid_arr(28) <= ch28_ev_data_valid;
ch_ev_data_arr(28) <= ch28_ev_data;
ch_dark_count_strobe_arr(28) <= ch28_dark_strobe;
ch_trig_err_strobe_arr(28) <= ch28_trig_err_strobe;
ch28_config <= ch_config_arr(28);
ch28_tconfig <= ch_tconfig_arr(28);
ch28_global_cal_en <= global_cal_en;

-- Channel 29
ch29_clk <= clk_i;
ch29_reset_bar <= tdc_reset_bar;
ch29_frame_id <= frame_id;
ch29_ctime <= ctime;
ch29_tac_refresh_pulse <= tac_refresh_pulse;
ch29_test_pulse <= test_pulse;
ch_ev_valid_arr(29) <= ch29_ev_data_valid;
ch_ev_data_arr(29) <= ch29_ev_data;
ch_dark_count_strobe_arr(29) <= ch29_dark_strobe;
ch_trig_err_strobe_arr(29) <= ch29_trig_err_strobe;
ch29_config <= ch_config_arr(29);
ch29_tconfig <= ch_tconfig_arr(29);
ch29_global_cal_en <= global_cal_en;

-- Channel 30
ch30_clk <= clk_i;
ch30_reset_bar <= tdc_reset_bar;
ch30_frame_id <= frame_id;
ch30_ctime <= ctime;
ch30_tac_refresh_pulse <= tac_refresh_pulse;
ch30_test_pulse <= test_pulse;
ch_ev_valid_arr(30) <= ch30_ev_data_valid;
ch_ev_data_arr(30) <= ch30_ev_data;
ch_dark_count_strobe_arr(30) <= ch30_dark_strobe;
ch_trig_err_strobe_arr(30) <= ch30_trig_err_strobe;
ch30_config <= ch_config_arr(30);
ch30_tconfig <= ch_tconfig_arr(30);
ch30_global_cal_en <= global_cal_en;

-- Channel 31
ch31_clk <= clk_i;
ch31_reset_bar <= tdc_reset_bar;
ch31_frame_id <= frame_id;
ch31_ctime <= ctime;
ch31_tac_refresh_pulse <= tac_refresh_pulse;
ch31_test_pulse <= test_pulse;
ch_ev_valid_arr(31) <= ch31_ev_data_valid;
ch_ev_data_arr(31) <= ch31_ev_data;
ch_dark_count_strobe_arr(31) <= ch31_dark_strobe;
ch_trig_err_strobe_arr(31) <= ch31_trig_err_strobe;
ch31_config <= ch_config_arr(31);
ch31_tconfig <= ch_tconfig_arr(31);
ch31_global_cal_en <= global_cal_en;

-- Channel 32
ch32_clk <= clk_i;
ch32_reset_bar <= tdc_reset_bar;
ch32_frame_id <= frame_id;
ch32_ctime <= ctime;
ch32_tac_refresh_pulse <= tac_refresh_pulse;
ch32_test_pulse <= test_pulse;
ch_ev_valid_arr(32) <= ch32_ev_data_valid;
ch_ev_data_arr(32) <= ch32_ev_data;
ch_dark_count_strobe_arr(32) <= ch32_dark_strobe;
ch_trig_err_strobe_arr(32) <= ch32_trig_err_strobe;
ch32_config <= ch_config_arr(32);
ch32_tconfig <= ch_tconfig_arr(32);
ch32_global_cal_en <= global_cal_en;

-- Channel 33
ch33_clk <= clk_i;
ch33_reset_bar <= tdc_reset_bar;
ch33_frame_id <= frame_id;
ch33_ctime <= ctime;
ch33_tac_refresh_pulse <= tac_refresh_pulse;
ch33_test_pulse <= test_pulse;
ch_ev_valid_arr(33) <= ch33_ev_data_valid;
ch_ev_data_arr(33) <= ch33_ev_data;
ch_dark_count_strobe_arr(33) <= ch33_dark_strobe;
ch_trig_err_strobe_arr(33) <= ch33_trig_err_strobe;
ch33_config <= ch_config_arr(33);
ch33_tconfig <= ch_tconfig_arr(33);
ch33_global_cal_en <= global_cal_en;

-- Channel 34
ch34_clk <= clk_i;
ch34_reset_bar <= tdc_reset_bar;
ch34_frame_id <= frame_id;
ch34_ctime <= ctime;
ch34_tac_refresh_pulse <= tac_refresh_pulse;
ch34_test_pulse <= test_pulse;
ch_ev_valid_arr(34) <= ch34_ev_data_valid;
ch_ev_data_arr(34) <= ch34_ev_data;
ch_dark_count_strobe_arr(34) <= ch34_dark_strobe;
ch_trig_err_strobe_arr(34) <= ch34_trig_err_strobe;
ch34_config <= ch_config_arr(34);
ch34_tconfig <= ch_tconfig_arr(34);
ch34_global_cal_en <= global_cal_en;

-- Channel 35
ch35_clk <= clk_i;
ch35_reset_bar <= tdc_reset_bar;
ch35_frame_id <= frame_id;
ch35_ctime <= ctime;
ch35_tac_refresh_pulse <= tac_refresh_pulse;
ch35_test_pulse <= test_pulse;
ch_ev_valid_arr(35) <= ch35_ev_data_valid;
ch_ev_data_arr(35) <= ch35_ev_data;
ch_dark_count_strobe_arr(35) <= ch35_dark_strobe;
ch_trig_err_strobe_arr(35) <= ch35_trig_err_strobe;
ch35_config <= ch_config_arr(35);
ch35_tconfig <= ch_tconfig_arr(35);
ch35_global_cal_en <= global_cal_en;

-- Channel 36
ch36_clk <= clk_i;
ch36_reset_bar <= tdc_reset_bar;
ch36_frame_id <= frame_id;
ch36_ctime <= ctime;
ch36_tac_refresh_pulse <= tac_refresh_pulse;
ch36_test_pulse <= test_pulse;
ch_ev_valid_arr(36) <= ch36_ev_data_valid;
ch_ev_data_arr(36) <= ch36_ev_data;
ch_dark_count_strobe_arr(36) <= ch36_dark_strobe;
ch_trig_err_strobe_arr(36) <= ch36_trig_err_strobe;
ch36_config <= ch_config_arr(36);
ch36_tconfig <= ch_tconfig_arr(36);
ch36_global_cal_en <= global_cal_en;

-- Channel 37
ch37_clk <= clk_i;
ch37_reset_bar <= tdc_reset_bar;
ch37_frame_id <= frame_id;
ch37_ctime <= ctime;
ch37_tac_refresh_pulse <= tac_refresh_pulse;
ch37_test_pulse <= test_pulse;
ch_ev_valid_arr(37) <= ch37_ev_data_valid;
ch_ev_data_arr(37) <= ch37_ev_data;
ch_dark_count_strobe_arr(37) <= ch37_dark_strobe;
ch_trig_err_strobe_arr(37) <= ch37_trig_err_strobe;
ch37_config <= ch_config_arr(37);
ch37_tconfig <= ch_tconfig_arr(37);
ch37_global_cal_en <= global_cal_en;

-- Channel 38
ch38_clk <= clk_i;
ch38_reset_bar <= tdc_reset_bar;
ch38_frame_id <= frame_id;
ch38_ctime <= ctime;
ch38_tac_refresh_pulse <= tac_refresh_pulse;
ch38_test_pulse <= test_pulse;
ch_ev_valid_arr(38) <= ch38_ev_data_valid;
ch_ev_data_arr(38) <= ch38_ev_data;
ch_dark_count_strobe_arr(38) <= ch38_dark_strobe;
ch_trig_err_strobe_arr(38) <= ch38_trig_err_strobe;
ch38_config <= ch_config_arr(38);
ch38_tconfig <= ch_tconfig_arr(38);
ch38_global_cal_en <= global_cal_en;

-- Channel 39
ch39_clk <= clk_i;
ch39_reset_bar <= tdc_reset_bar;
ch39_frame_id <= frame_id;
ch39_ctime <= ctime;
ch39_tac_refresh_pulse <= tac_refresh_pulse;
ch39_test_pulse <= test_pulse;
ch_ev_valid_arr(39) <= ch39_ev_data_valid;
ch_ev_data_arr(39) <= ch39_ev_data;
ch_dark_count_strobe_arr(39) <= ch39_dark_strobe;
ch_trig_err_strobe_arr(39) <= ch39_trig_err_strobe;
ch39_config <= ch_config_arr(39);
ch39_tconfig <= ch_tconfig_arr(39);
ch39_global_cal_en <= global_cal_en;

-- Channel 40
ch40_clk <= clk_i;
ch40_reset_bar <= tdc_reset_bar;
ch40_frame_id <= frame_id;
ch40_ctime <= ctime;
ch40_tac_refresh_pulse <= tac_refresh_pulse;
ch40_test_pulse <= test_pulse;
ch_ev_valid_arr(40) <= ch40_ev_data_valid;
ch_ev_data_arr(40) <= ch40_ev_data;
ch_dark_count_strobe_arr(40) <= ch40_dark_strobe;
ch_trig_err_strobe_arr(40) <= ch40_trig_err_strobe;
ch40_config <= ch_config_arr(40);
ch40_tconfig <= ch_tconfig_arr(40);
ch40_global_cal_en <= global_cal_en;

-- Channel 41
ch41_clk <= clk_i;
ch41_reset_bar <= tdc_reset_bar;
ch41_frame_id <= frame_id;
ch41_ctime <= ctime;
ch41_tac_refresh_pulse <= tac_refresh_pulse;
ch41_test_pulse <= test_pulse;
ch_ev_valid_arr(41) <= ch41_ev_data_valid;
ch_ev_data_arr(41) <= ch41_ev_data;
ch_dark_count_strobe_arr(41) <= ch41_dark_strobe;
ch_trig_err_strobe_arr(41) <= ch41_trig_err_strobe;
ch41_config <= ch_config_arr(41);
ch41_tconfig <= ch_tconfig_arr(41);
ch41_global_cal_en <= global_cal_en;

-- Channel 42
ch42_clk <= clk_i;
ch42_reset_bar <= tdc_reset_bar;
ch42_frame_id <= frame_id;
ch42_ctime <= ctime;
ch42_tac_refresh_pulse <= tac_refresh_pulse;
ch42_test_pulse <= test_pulse;
ch_ev_valid_arr(42) <= ch42_ev_data_valid;
ch_ev_data_arr(42) <= ch42_ev_data;
ch_dark_count_strobe_arr(42) <= ch42_dark_strobe;
ch_trig_err_strobe_arr(42) <= ch42_trig_err_strobe;
ch42_config <= ch_config_arr(42);
ch42_tconfig <= ch_tconfig_arr(42);
ch42_global_cal_en <= global_cal_en;

-- Channel 43
ch43_clk <= clk_i;
ch43_reset_bar <= tdc_reset_bar;
ch43_frame_id <= frame_id;
ch43_ctime <= ctime;
ch43_tac_refresh_pulse <= tac_refresh_pulse;
ch43_test_pulse <= test_pulse;
ch_ev_valid_arr(43) <= ch43_ev_data_valid;
ch_ev_data_arr(43) <= ch43_ev_data;
ch_dark_count_strobe_arr(43) <= ch43_dark_strobe;
ch_trig_err_strobe_arr(43) <= ch43_trig_err_strobe;
ch43_config <= ch_config_arr(43);
ch43_tconfig <= ch_tconfig_arr(43);
ch43_global_cal_en <= global_cal_en;

-- Channel 44
ch44_clk <= clk_i;
ch44_reset_bar <= tdc_reset_bar;
ch44_frame_id <= frame_id;
ch44_ctime <= ctime;
ch44_tac_refresh_pulse <= tac_refresh_pulse;
ch44_test_pulse <= test_pulse;
ch_ev_valid_arr(44) <= ch44_ev_data_valid;
ch_ev_data_arr(44) <= ch44_ev_data;
ch_dark_count_strobe_arr(44) <= ch44_dark_strobe;
ch_trig_err_strobe_arr(44) <= ch44_trig_err_strobe;
ch44_config <= ch_config_arr(44);
ch44_tconfig <= ch_tconfig_arr(44);
ch44_global_cal_en <= global_cal_en;

-- Channel 45
ch45_clk <= clk_i;
ch45_reset_bar <= tdc_reset_bar;
ch45_frame_id <= frame_id;
ch45_ctime <= ctime;
ch45_tac_refresh_pulse <= tac_refresh_pulse;
ch45_test_pulse <= test_pulse;
ch_ev_valid_arr(45) <= ch45_ev_data_valid;
ch_ev_data_arr(45) <= ch45_ev_data;
ch_dark_count_strobe_arr(45) <= ch45_dark_strobe;
ch_trig_err_strobe_arr(45) <= ch45_trig_err_strobe;
ch45_config <= ch_config_arr(45);
ch45_tconfig <= ch_tconfig_arr(45);
ch45_global_cal_en <= global_cal_en;

-- Channel 46
ch46_clk <= clk_i;
ch46_reset_bar <= tdc_reset_bar;
ch46_frame_id <= frame_id;
ch46_ctime <= ctime;
ch46_tac_refresh_pulse <= tac_refresh_pulse;
ch46_test_pulse <= test_pulse;
ch_ev_valid_arr(46) <= ch46_ev_data_valid;
ch_ev_data_arr(46) <= ch46_ev_data;
ch_dark_count_strobe_arr(46) <= ch46_dark_strobe;
ch_trig_err_strobe_arr(46) <= ch46_trig_err_strobe;
ch46_config <= ch_config_arr(46);
ch46_tconfig <= ch_tconfig_arr(46);
ch46_global_cal_en <= global_cal_en;

-- Channel 47
ch47_clk <= clk_i;
ch47_reset_bar <= tdc_reset_bar;
ch47_frame_id <= frame_id;
ch47_ctime <= ctime;
ch47_tac_refresh_pulse <= tac_refresh_pulse;
ch47_test_pulse <= test_pulse;
ch_ev_valid_arr(47) <= ch47_ev_data_valid;
ch_ev_data_arr(47) <= ch47_ev_data;
ch_dark_count_strobe_arr(47) <= ch47_dark_strobe;
ch_trig_err_strobe_arr(47) <= ch47_trig_err_strobe;
ch47_config <= ch_config_arr(47);
ch47_tconfig <= ch_tconfig_arr(47);
ch47_global_cal_en <= global_cal_en;

-- Channel 48
ch48_clk <= clk_i;
ch48_reset_bar <= tdc_reset_bar;
ch48_frame_id <= frame_id;
ch48_ctime <= ctime;
ch48_tac_refresh_pulse <= tac_refresh_pulse;
ch48_test_pulse <= test_pulse;
ch_ev_valid_arr(48) <= ch48_ev_data_valid;
ch_ev_data_arr(48) <= ch48_ev_data;
ch_dark_count_strobe_arr(48) <= ch48_dark_strobe;
ch_trig_err_strobe_arr(48) <= ch48_trig_err_strobe;
ch48_config <= ch_config_arr(48);
ch48_tconfig <= ch_tconfig_arr(48);
ch48_global_cal_en <= global_cal_en;

-- Channel 49
ch49_clk <= clk_i;
ch49_reset_bar <= tdc_reset_bar;
ch49_frame_id <= frame_id;
ch49_ctime <= ctime;
ch49_tac_refresh_pulse <= tac_refresh_pulse;
ch49_test_pulse <= test_pulse;
ch_ev_valid_arr(49) <= ch49_ev_data_valid;
ch_ev_data_arr(49) <= ch49_ev_data;
ch_dark_count_strobe_arr(49) <= ch49_dark_strobe;
ch_trig_err_strobe_arr(49) <= ch49_trig_err_strobe;
ch49_config <= ch_config_arr(49);
ch49_tconfig <= ch_tconfig_arr(49);
ch49_global_cal_en <= global_cal_en;

-- Channel 50
ch50_clk <= clk_i;
ch50_reset_bar <= tdc_reset_bar;
ch50_frame_id <= frame_id;
ch50_ctime <= ctime;
ch50_tac_refresh_pulse <= tac_refresh_pulse;
ch50_test_pulse <= test_pulse;
ch_ev_valid_arr(50) <= ch50_ev_data_valid;
ch_ev_data_arr(50) <= ch50_ev_data;
ch_dark_count_strobe_arr(50) <= ch50_dark_strobe;
ch_trig_err_strobe_arr(50) <= ch50_trig_err_strobe;
ch50_config <= ch_config_arr(50);
ch50_tconfig <= ch_tconfig_arr(50);
ch50_global_cal_en <= global_cal_en;

-- Channel 51
ch51_clk <= clk_i;
ch51_reset_bar <= tdc_reset_bar;
ch51_frame_id <= frame_id;
ch51_ctime <= ctime;
ch51_tac_refresh_pulse <= tac_refresh_pulse;
ch51_test_pulse <= test_pulse;
ch_ev_valid_arr(51) <= ch51_ev_data_valid;
ch_ev_data_arr(51) <= ch51_ev_data;
ch_dark_count_strobe_arr(51) <= ch51_dark_strobe;
ch_trig_err_strobe_arr(51) <= ch51_trig_err_strobe;
ch51_config <= ch_config_arr(51);
ch51_tconfig <= ch_tconfig_arr(51);
ch51_global_cal_en <= global_cal_en;

-- Channel 52
ch52_clk <= clk_i;
ch52_reset_bar <= tdc_reset_bar;
ch52_frame_id <= frame_id;
ch52_ctime <= ctime;
ch52_tac_refresh_pulse <= tac_refresh_pulse;
ch52_test_pulse <= test_pulse;
ch_ev_valid_arr(52) <= ch52_ev_data_valid;
ch_ev_data_arr(52) <= ch52_ev_data;
ch_dark_count_strobe_arr(52) <= ch52_dark_strobe;
ch_trig_err_strobe_arr(52) <= ch52_trig_err_strobe;
ch52_config <= ch_config_arr(52);
ch52_tconfig <= ch_tconfig_arr(52);
ch52_global_cal_en <= global_cal_en;

-- Channel 53
ch53_clk <= clk_i;
ch53_reset_bar <= tdc_reset_bar;
ch53_frame_id <= frame_id;
ch53_ctime <= ctime;
ch53_tac_refresh_pulse <= tac_refresh_pulse;
ch53_test_pulse <= test_pulse;
ch_ev_valid_arr(53) <= ch53_ev_data_valid;
ch_ev_data_arr(53) <= ch53_ev_data;
ch_dark_count_strobe_arr(53) <= ch53_dark_strobe;
ch_trig_err_strobe_arr(53) <= ch53_trig_err_strobe;
ch53_config <= ch_config_arr(53);
ch53_tconfig <= ch_tconfig_arr(53);
ch53_global_cal_en <= global_cal_en;

-- Channel 54
ch54_clk <= clk_i;
ch54_reset_bar <= tdc_reset_bar;
ch54_frame_id <= frame_id;
ch54_ctime <= ctime;
ch54_tac_refresh_pulse <= tac_refresh_pulse;
ch54_test_pulse <= test_pulse;
ch_ev_valid_arr(54) <= ch54_ev_data_valid;
ch_ev_data_arr(54) <= ch54_ev_data;
ch_dark_count_strobe_arr(54) <= ch54_dark_strobe;
ch_trig_err_strobe_arr(54) <= ch54_trig_err_strobe;
ch54_config <= ch_config_arr(54);
ch54_tconfig <= ch_tconfig_arr(54);
ch54_global_cal_en <= global_cal_en;

-- Channel 55
ch55_clk <= clk_i;
ch55_reset_bar <= tdc_reset_bar;
ch55_frame_id <= frame_id;
ch55_ctime <= ctime;
ch55_tac_refresh_pulse <= tac_refresh_pulse;
ch55_test_pulse <= test_pulse;
ch_ev_valid_arr(55) <= ch55_ev_data_valid;
ch_ev_data_arr(55) <= ch55_ev_data;
ch_dark_count_strobe_arr(55) <= ch55_dark_strobe;
ch_trig_err_strobe_arr(55) <= ch55_trig_err_strobe;
ch55_config <= ch_config_arr(55);
ch55_tconfig <= ch_tconfig_arr(55);
ch55_global_cal_en <= global_cal_en;

-- Channel 56
ch56_clk <= clk_i;
ch56_reset_bar <= tdc_reset_bar;
ch56_frame_id <= frame_id;
ch56_ctime <= ctime;
ch56_tac_refresh_pulse <= tac_refresh_pulse;
ch56_test_pulse <= test_pulse;
ch_ev_valid_arr(56) <= ch56_ev_data_valid;
ch_ev_data_arr(56) <= ch56_ev_data;
ch_dark_count_strobe_arr(56) <= ch56_dark_strobe;
ch_trig_err_strobe_arr(56) <= ch56_trig_err_strobe;
ch56_config <= ch_config_arr(56);
ch56_tconfig <= ch_tconfig_arr(56);
ch56_global_cal_en <= global_cal_en;

-- Channel 57
ch57_clk <= clk_i;
ch57_reset_bar <= tdc_reset_bar;
ch57_frame_id <= frame_id;
ch57_ctime <= ctime;
ch57_tac_refresh_pulse <= tac_refresh_pulse;
ch57_test_pulse <= test_pulse;
ch_ev_valid_arr(57) <= ch57_ev_data_valid;
ch_ev_data_arr(57) <= ch57_ev_data;
ch_dark_count_strobe_arr(57) <= ch57_dark_strobe;
ch_trig_err_strobe_arr(57) <= ch57_trig_err_strobe;
ch57_config <= ch_config_arr(57);
ch57_tconfig <= ch_tconfig_arr(57);
ch57_global_cal_en <= global_cal_en;

-- Channel 58
ch58_clk <= clk_i;
ch58_reset_bar <= tdc_reset_bar;
ch58_frame_id <= frame_id;
ch58_ctime <= ctime;
ch58_tac_refresh_pulse <= tac_refresh_pulse;
ch58_test_pulse <= test_pulse;
ch_ev_valid_arr(58) <= ch58_ev_data_valid;
ch_ev_data_arr(58) <= ch58_ev_data;
ch_dark_count_strobe_arr(58) <= ch58_dark_strobe;
ch_trig_err_strobe_arr(58) <= ch58_trig_err_strobe;
ch58_config <= ch_config_arr(58);
ch58_tconfig <= ch_tconfig_arr(58);
ch58_global_cal_en <= global_cal_en;

-- Channel 59
ch59_clk <= clk_i;
ch59_reset_bar <= tdc_reset_bar;
ch59_frame_id <= frame_id;
ch59_ctime <= ctime;
ch59_tac_refresh_pulse <= tac_refresh_pulse;
ch59_test_pulse <= test_pulse;
ch_ev_valid_arr(59) <= ch59_ev_data_valid;
ch_ev_data_arr(59) <= ch59_ev_data;
ch_dark_count_strobe_arr(59) <= ch59_dark_strobe;
ch_trig_err_strobe_arr(59) <= ch59_trig_err_strobe;
ch59_config <= ch_config_arr(59);
ch59_tconfig <= ch_tconfig_arr(59);
ch59_global_cal_en <= global_cal_en;

-- Channel 60
ch60_clk <= clk_i;
ch60_reset_bar <= tdc_reset_bar;
ch60_frame_id <= frame_id;
ch60_ctime <= ctime;
ch60_tac_refresh_pulse <= tac_refresh_pulse;
ch60_test_pulse <= test_pulse;
ch_ev_valid_arr(60) <= ch60_ev_data_valid;
ch_ev_data_arr(60) <= ch60_ev_data;
ch_dark_count_strobe_arr(60) <= ch60_dark_strobe;
ch_trig_err_strobe_arr(60) <= ch60_trig_err_strobe;
ch60_config <= ch_config_arr(60);
ch60_tconfig <= ch_tconfig_arr(60);
ch60_global_cal_en <= global_cal_en;

-- Channel 61
ch61_clk <= clk_i;
ch61_reset_bar <= tdc_reset_bar;
ch61_frame_id <= frame_id;
ch61_ctime <= ctime;
ch61_tac_refresh_pulse <= tac_refresh_pulse;
ch61_test_pulse <= test_pulse;
ch_ev_valid_arr(61) <= ch61_ev_data_valid;
ch_ev_data_arr(61) <= ch61_ev_data;
ch_dark_count_strobe_arr(61) <= ch61_dark_strobe;
ch_trig_err_strobe_arr(61) <= ch61_trig_err_strobe;
ch61_config <= ch_config_arr(61);
ch61_tconfig <= ch_tconfig_arr(61);
ch61_global_cal_en <= global_cal_en;

-- Channel 62
ch62_clk <= clk_i;
ch62_reset_bar <= tdc_reset_bar;
ch62_frame_id <= frame_id;
ch62_ctime <= ctime;
ch62_tac_refresh_pulse <= tac_refresh_pulse;
ch62_test_pulse <= test_pulse;
ch_ev_valid_arr(62) <= ch62_ev_data_valid;
ch_ev_data_arr(62) <= ch62_ev_data;
ch_dark_count_strobe_arr(62) <= ch62_dark_strobe;
ch_trig_err_strobe_arr(62) <= ch62_trig_err_strobe;
ch62_config <= ch_config_arr(62);
ch62_tconfig <= ch_tconfig_arr(62);
ch62_global_cal_en <= global_cal_en;

-- Channel 63
ch63_clk <= clk_i;
ch63_reset_bar <= tdc_reset_bar;
ch63_frame_id <= frame_id;
ch63_ctime <= ctime;
ch63_tac_refresh_pulse <= tac_refresh_pulse;
ch63_test_pulse <= test_pulse;
ch_ev_valid_arr(63) <= ch63_ev_data_valid;
ch_ev_data_arr(63) <= ch63_ev_data;
ch_dark_count_strobe_arr(63) <= ch63_dark_strobe;
ch_trig_err_strobe_arr(63) <= ch63_trig_err_strobe;
ch63_config <= ch_config_arr(63);
ch63_tconfig <= ch_tconfig_arr(63);
ch63_global_cal_en <= global_cal_en;

end rtl;
