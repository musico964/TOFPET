library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity pulse_tb is
end pulse_tb;

architecture behavioral of pulse_tb is
  -- Event rate
  constant event_rate : real := 40_000.0;
  constant dark_rate  : real := 1_000_000.0;
  
  -- Clock frequency
  constant T  : time := 6.25 ns;
  
  -- Pulse amplitude  
  constant event_A : real := 10.0;
  constant dark_A  : real := 1.0;  
  -- Pulse shape
  constant tPeak : real := 20.0E-9;
  constant alpha : real := 1.0;
  
 
 -- Thresholds
 constant th_T : real := 0.5;
 constant th_E : real := 2.0;
 
  -- Signals
  signal event_v  : real := 0.0;
  signal dark_v   : real := 0.0;
  signal v        : real := 0.0;
  signal clk : std_logic := '0';  
  signal disc_out_T : std_logic := '0';
  signal disc_out_E : std_logic := '0';
  
  
begin
  
  dark_generator : process 
  variable tWait  : real;
  variable i      : integer;
  variable t      : real := 0.0;
 
  variable seed1  : positive := 9843187;
  variable seed2  : positive := 1948781;
  variable u      : real;
  begin
    dark_v <= 0.0;    
    uniform(seed1, seed2, u);
    tWait := -log(u)/dark_rate;
    tWait := tWait - t;
    if tWait > 0.0 then
      wait for tWait * 1000 ms;
    else
      assert false report "Overlapping dark count" severity warning;
    end if;
    
    t := 0.0;    
    while ((t < tPeak) or (v > 0.1)) loop
      dark_v <= dark_A * ((t/tPeak)**alpha) * exp(-alpha * (t-tPeak)/tPeak);
      t := t + 10.0E-12;     
      wait for 10 ps;            
    end loop;
  end process dark_generator;
  
  
  event_generator : process 
  variable tWait  : real;
  variable i      : integer;
  variable t      : real := 0.0;
 
  variable seed1  : positive := 874382;
  variable seed2  : positive := 139743;
  variable u      : real;
  begin
    event_v <= 0.0;    
    uniform(seed1, seed2, u); -- u is uniform random [0,1]
    tWait := -log(u)/event_rate; -- Calculate time between events
    tWait := tWait - t; -- Discount time used to simulate previous pulse
    if tWait > 0.0 then
      wait for tWait * 1000 ms;
    else
      assert false report "Overlapping event" severity warning;
    end if;
    
    -- Simulate pulse until it has passed the peak and has dropped to a very small value
    t := 0.0;    
    uniform(seed1, seed2, u);
    while ((t < tPeak) or (v > 0.1)) loop
      event_v <= u*event_A * ((t/tPeak)**alpha) * exp(-alpha * (t-tPeak)/tPeak);
      t := t + 10.0E-12;     
      wait for 10 ps;            
    end loop;
  end process event_generator;
  
  clk <= not clk after T/2;
  
  v <= event_v + dark_v;
  disc_out_T <= '1' when v > th_T else '0';
  disc_out_E <= '1' when v > th_E else '0';
  
  
end behavioral;
