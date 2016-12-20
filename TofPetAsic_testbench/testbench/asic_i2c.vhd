library ieee, worklib, gctrl_lib;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use gctrl_lib.asic_k.all;

package asic_i2c is

constant T_I2C : time := 100 ns;

function crc8(crc_in : std_logic_vector(7 downto 0); data : std_logic) return std_logic_vector;
function crc8_vector(data : std_logic_vector) return std_logic_vector;
procedure send_stream(signal sdo : out std_logic; data : in std_logic_vector);

procedure read_dark(
	signal sclk : in std_logic;
    signal cs : out std_logic; 
    signal sdo : out std_logic;
    signal sdi : in std_logic;
    address : in integer;
    data : out std_logic_vector(CH_DARK_COUNT_SIZE-1 downto 0)
); 


procedure write_gcfg (
	signal sclk : in std_logic;
    signal cs : out std_logic; 
    signal sdo : out std_logic;
    signal sdi : in std_logic;
    data : in std_logic_vector(G_CONFIG_SIZE-1 downto 0)
);

procedure check_gcfg(
	signal sclk : in std_logic;
    signal cs : out std_logic; 
    signal sdo : out std_logic;
    signal sdi : in std_logic;
    data : std_logic_vector(G_CONFIG_SIZE-1 downto 0)
);

procedure write_gtcfg (
	signal sclk : in std_logic;
    signal cs : out std_logic; 
    signal sdo : out std_logic;
    signal sdi : in std_logic;
    data : in std_logic_vector(G_TCONFIG_SIZE-1 downto 0)
);

procedure check_gtcfg(
	signal sclk : in std_logic;
    signal cs : out std_logic; 
    signal sdo : out std_logic;
    signal sdi : in std_logic;
    data : std_logic_vector(G_TCONFIG_SIZE-1 downto 0)
);

procedure write_tp (
	signal sclk : in std_logic;
    signal cs : out std_logic; 
    signal sdo : out std_logic;
    signal sdi : in std_logic;
	pulse_number : integer;
	pulse_length : integer;
	pulse_interval : integer
);	

procedure write_chcfg (
	signal sclk : in std_logic;
    signal cs : out std_logic; 
    signal sdo : out std_logic;
    signal sdi : in std_logic;
    address : in integer;
    data : in std_logic_vector(CH_CONFIG_SIZE-1 downto 0)
);

procedure check_chcfg (
	signal sclk : in std_logic;
    signal cs : out std_logic; 
    signal sdo : out std_logic;
    signal sdi : in std_logic;
    address : in integer;
    data : in std_logic_vector(CH_CONFIG_SIZE-1 downto 0)
);

procedure write_chtcfg (
	signal sclk : in std_logic;
    signal cs : out std_logic; 
    signal sdo : out std_logic;
    signal sdi : in std_logic;
    address : in integer;
    data : in std_logic_vector(CH_TCONFIG_SIZE-1 downto 0)
);

procedure check_chtcfg (
	signal sclk : in std_logic;
    signal cs : out std_logic; 
    signal sdo : out std_logic;
    signal sdi : in std_logic;
    address : in integer;
    data : in std_logic_vector(CH_TCONFIG_SIZE-1 downto 0)
);

function xname (s : string) return string;
function to_std_logic_vector(s: string) return std_logic_vector;
function crc16(crc_i : std_logic_vector(15 downto 0); data_i: std_logic_vector(15 downto 0)) return std_logic_vector;
function binary_to_gray(x: std_logic_vector) return std_logic_vector;
function odd_parity(x : std_logic_vector) return std_logic;

type event_t is record
    channel : integer;
    tcoarse : integer;
    ecoarse : integer;
    tfine   : integer;
    efine   : integer;
    tac		: integer;
    matched : boolean;
    raw		: std_logic_vector(39 downto 0);
end record;

end;

package body asic_i2c is

  function crc8(crc_in : std_logic_vector(7 downto 0); data : std_logic) 
    return std_logic_vector is
  variable crc_out : std_logic_vector(7 downto 0);
  begin
    crc_out(0) := data xor crc_in(7); 
    crc_out(1) := data xor crc_in(0) xor crc_in(7); 
    crc_out(2) := data xor crc_in(1) xor crc_in(7); 
    crc_out(3) := crc_in(2);
    crc_out(4) := crc_in(3); 
    crc_out(5) := crc_in(4); 
    crc_out(6) := crc_in(5); 
    crc_out(7) := crc_in(6); 
    return crc_out;  
  end crc8;

  function crc8_vector(data : std_logic_vector) return std_logic_vector is 
  variable crc_out : std_logic_vector(7 downto 0);
  variable i : integer;
  variable d : std_logic_vector(data'length - 1 downto 0);
  begin
    d := data;
    crc_out := x"8A";
    for i in d'length - 1 downto 0 loop
      crc_out := crc8(crc_out, d(i));
    end loop;
    return crc_out;
  end crc8_vector;
  
  procedure send_stream(signal sdo : out std_logic; data : in std_logic_vector) is
  variable i : integer;
  variable d : std_logic_vector(data'length - 1 downto 0);
  begin
    d := data;
    for i in d'length - 1 downto 0 loop
      sdo <= d(i); wait for T_I2C;
    end loop;
  end send_stream;

procedure read_dark(
	signal sclk : in std_logic;
    signal cs : out std_logic; 
    signal sdo : out std_logic;
    signal sdi : in std_logic;
    address : in integer;
    data : out std_logic_vector(CH_DARK_COUNT_SIZE-1 downto 0)
) is
variable cmd : std_logic_vector(3 downto 0);
variable crc : std_logic_vector(7 downto 0);
variable i : integer;
variable addr : std_logic_vector(6 downto 0);
variable d : std_logic_vector(data'length-1 downto 0);
begin
	wait until rising_edge(sclk); wait for T_I2C/2;
	cmd := "0100";
	addr :=  std_logic_vector(to_unsigned(address, 7));
	crc := crc8_vector(cmd & addr);
	cs <= '1';
	send_stream(sdo, cmd & addr & crc);
	assert sdi = '1' report "RDCDARK: Ack Failed" severity error;
   	for i in data'length-1 downto 0 loop
   		wait for T_I2C;   		
   		d(i) := sdi;
   	end loop;
   	for i in 7 downto 0 loop
   		wait for T_I2C;
   		crc(i) := sdi;
   	end loop;   	
   	cs <= '0'; sdo <= '0';
   	wait for 2*T_I2C;
   	    	
   		
	assert crc8_vector(d) = crc
		report "RDDARK: CRC8 mismatch" severity error;
		
	data := d;
end read_dark;

procedure write_gcfg (
	signal sclk : in std_logic;
	signal cs : out std_logic; 
	signal sdo : out std_logic;
	signal sdi : in std_logic;
	data : in std_logic_vector(G_CONFIG_SIZE-1 downto 0)
) is
variable cmd : std_logic_vector(3 downto 0);
variable d : std_logic_vector(data'length - 1 downto 0);
variable crc : std_logic_vector(7 downto 0);
variable i : integer;
begin
	wait until rising_edge(sclk); wait for T_I2C/2;
	cmd := "1000";
    d := data;
    crc := crc8_vector(cmd & d);
    cs <= '1';
    send_stream(sdo, cmd & d & crc);
    assert sdi = '1' report "WRGCFG: Ack Failed" severity error;
    wait for T_I2C;
    cs <= '0'; sdo <= '0';
    wait for 2*T_I2C;    
end write_gcfg;

procedure check_gcfg(
	signal sclk : in std_logic;
    signal cs : out std_logic; 
    signal sdo : out std_logic;
    signal sdi : in std_logic;
    data : std_logic_vector(G_CONFIG_SIZE-1 downto 0)
) is
variable cmd : std_logic_vector(3 downto 0);
variable crc : std_logic_vector(7 downto 0);
variable i : integer;
variable d : std_logic_vector(data'length-1 downto 0);
begin
	wait until rising_edge(sclk); wait for T_I2C/2;
	cmd := "1001";
	crc := crc8_vector(cmd);
	cs <= '1';
	send_stream(sdo, cmd & crc);
	assert sdi = '1' report "RDGCFG: Ack Failed" severity error;
   	for i in G_CONFIG_SIZE-1 downto 0 loop
   		wait for T_I2C;   		
   		d(i) := sdi;
   	end loop;
   	for i in 7 downto 0 loop
   		wait for T_I2C;
   		crc(i) := sdi;
   	end loop;   	
   	cs <= '0'; sdo <= '0';
   	wait for 2*T_I2C;
   	    	
   	assert data = d
   		report "RDGCFG: Data mismatch" severity error;
   		
	assert crc8_vector(d) = crc
		report "RDGCFG: CRC8 mismatch" severity error;
end check_gcfg;

procedure write_gtcfg (
	signal sclk : in std_logic;
	signal cs : out std_logic; 
	signal sdo : out std_logic;
	signal sdi : in std_logic;
	data : in std_logic_vector(G_TCONFIG_SIZE-1 downto 0)
) is
variable cmd : std_logic_vector(3 downto 0);
variable d : std_logic_vector(data'length - 1 downto 0);
variable crc : std_logic_vector(7 downto 0);
variable i : integer;
begin
	wait until rising_edge(sclk); wait for T_I2C/2;
	cmd := "1100";
    d := data;
    crc := crc8_vector(cmd & d);
    cs <= '1';
    send_stream(sdo, cmd & d & crc);
    assert sdi = '1' report "WRGTEST: Ack Failed" severity error;
    wait for T_I2C;
    cs <= '0'; sdo <= '0';
    wait for 2*T_I2C;    
end write_gtcfg;

procedure check_gtcfg(
	signal sclk : in std_logic;
    signal cs : out std_logic; 
    signal sdo : out std_logic;
    signal sdi : in std_logic;
    data : std_logic_vector(G_TCONFIG_SIZE-1 downto 0)
) is
variable cmd : std_logic_vector(3 downto 0);
variable crc : std_logic_vector(7 downto 0);
variable i : integer;
variable d : std_logic_vector(data'length-1 downto 0);
begin
	wait until rising_edge(sclk); wait for T_I2C/2;
	cmd := "1101";
	crc := crc8_vector(cmd);
	cs <= '1';
	send_stream(sdo, cmd & crc);
	assert sdi = '1' report "RDGTEST: Ack Failed" severity error;
   	for i in G_TCONFIG_SIZE-1 downto 0 loop
   		wait for T_I2C;   		
   		d(i) := sdi;
   	end loop;
   	for i in 7 downto 0 loop
   		wait for T_I2C;
   		crc(i) := sdi;
   	end loop;   	
   	cs <= '0'; sdo <= '0';
   	wait for 2*T_I2C;
   	    	
   	assert data = d
   		report "RDGTEST: Data mismatch" severity error;
   		
	assert crc8_vector(d) = crc
		report "RDGTEST: CRC8 mismatch" severity error;
end check_gtcfg;


procedure write_tp (
	signal sclk : in std_logic;
    signal cs : out std_logic; 
    signal sdo : out std_logic;
    signal sdi : in std_logic;
	pulse_number : integer;
	pulse_length : integer;
	pulse_interval : integer
) is
variable cmd : std_logic_vector(3 downto 0);
variable d : std_logic_vector(10 + 8 + 8 - 1 downto 0);
variable crc : std_logic_vector(7 downto 0);

begin
	wait until rising_edge(sclk); wait for T_I2C/2;
	cmd := "1010";
	d := 	std_logic_vector(to_unsigned(pulse_interval, 8)) &
			std_logic_vector(to_unsigned(pulse_length, 8)) &
			std_logic_vector(to_unsigned(pulse_number, 10));
	crc := crc8_vector(cmd & d);
    cs <= '1';
    send_stream(sdo, cmd & d & crc);
    assert sdi = '1' report "WRPULSE: Ack Failed" severity error;
    wait for T_I2C;
    cs <= '0'; sdo <= '0';
    wait for 2*T_I2C;	 
end write_tp;

procedure write_chcfg (
	signal sclk : in std_logic;
    signal cs : out std_logic; 
    signal sdo : out std_logic;
    signal sdi : in std_logic;
    address : in integer;
    data : in std_logic_vector(CH_CONFIG_SIZE-1 downto 0)
) is
variable cmd : std_logic_vector(3 downto 0);
variable d : std_logic_vector(data'length - 1 downto 0);
variable addr : std_logic_vector(6 downto 0);
variable crc : std_logic_vector(7 downto 0);
variable i : integer;
begin
	wait until rising_edge(sclk); wait for T_I2C/2;
	cmd := "0000";
    d := data;
    addr := std_logic_vector(to_unsigned(address, 7));
    crc := crc8_vector(cmd & addr & d);
    cs <= '1';
    send_stream(sdo, cmd & addr & d & crc);
    assert sdi = '1' report "WRCHCFG: Ack Failed" severity error;
    wait for T_I2C;
    wait for d'length * T_I2C;
    cs <= '0'; sdo <= '0';
    wait for 2*T_I2C;    
end write_chcfg;

procedure check_chcfg (
	signal sclk : in std_logic;
    signal cs : out std_logic; 
    signal sdo : out std_logic;
    signal sdi : in std_logic;
    address : in integer;
    data : in std_logic_vector(CH_CONFIG_SIZE-1 downto 0)
) is
variable cmd : std_logic_vector(3 downto 0);
variable crc : std_logic_vector(7 downto 0);
variable i : integer;
variable addr : std_logic_vector(6 downto 0);
variable d : std_logic_vector(data'length-1 downto 0);
begin
	wait until rising_edge(sclk); wait for T_I2C/2;
	cmd := "0001";
	addr :=  std_logic_vector(to_unsigned(address, 7));
	crc := crc8_vector(cmd & addr);
	cs <= '1';
	send_stream(sdo, cmd & addr & crc);
	assert sdi = '1' report "RDCHCFG: Ack Failed" severity error;
   	for i in CH_CONFIG_SIZE-1 downto 0 loop
   		wait for T_I2C;   		
   		d(i) := sdi;
   	end loop;
   	for i in 7 downto 0 loop
   		wait for T_I2C;
   		crc(i) := sdi;
   	end loop;   	
   	cs <= '0'; sdo <= '0';
   	wait for 2*T_I2C;
   	    	
   	assert data = d
   		report "RDCHCFG: Data mismatch" severity error;
   		
	assert crc8_vector(d) = crc
		report "RDCHCFG: CRC8 mismatch" severity error;
end check_chcfg;
  
procedure write_chtcfg (
	signal sclk : in std_logic;
    signal cs : out std_logic; 
    signal sdo : out std_logic;
    signal sdi : in std_logic;
    address : in integer;
    data : in std_logic_vector(CH_TCONFIG_SIZE-1 downto 0)
) is
variable cmd : std_logic_vector(3 downto 0);
variable d : std_logic_vector(data'length - 1 downto 0);
variable addr : std_logic_vector(6 downto 0);
variable crc : std_logic_vector(7 downto 0);
variable i : integer;
begin
	wait until rising_edge(sclk); wait for T_I2C/2;
	cmd := "0010";
    d := data;
    addr := std_logic_vector(to_unsigned(address, 7));
    crc := crc8_vector(cmd & addr & d);
    cs <= '1';
    send_stream(sdo, cmd & addr & d & crc);
    assert sdi = '1' report "WRCHTCFG: Ack Failed" severity error;
    wait for T_I2C;
    wait for d'length * T_I2C;
    cs <= '0'; sdo <= '0';
    wait for 2*T_I2C;    
end write_chtcfg;

procedure check_chtcfg (
	signal sclk : in std_logic;
    signal cs : out std_logic; 
    signal sdo : out std_logic;
    signal sdi : in std_logic;
    address : in integer;
    data : in std_logic_vector(CH_TCONFIG_SIZE-1 downto 0)
) is
variable cmd : std_logic_vector(3 downto 0);
variable crc : std_logic_vector(7 downto 0);
variable i : integer;
variable addr : std_logic_vector(6 downto 0);
variable d : std_logic_vector(data'length-1 downto 0);
begin
	wait until rising_edge(sclk); wait for T_I2C/2;
	cmd := "0011";
	addr :=  std_logic_vector(to_unsigned(address, 7));
	crc := crc8_vector(cmd & addr);
	cs <= '1';
	send_stream(sdo, cmd & addr & crc);
	assert sdi = '1' report "RDCHTCFG: Ack Failed" severity error;
   	for i in data'length-1 downto 0 loop
   		wait for T_I2C;   		
   		d(i) := sdi;
   	end loop;
   	for i in 7 downto 0 loop
   		wait for T_I2C;
   		crc(i) := sdi;
   	end loop;   	
   	cs <= '0'; sdo <= '0';
   	wait for 2*T_I2C;
   	    	
   	assert data = d
   		report "RDCHTCFG: Data mismatch" severity error;
   		
	assert crc8_vector(d) = crc
		report "RDCHTCFG: CRC8 mismatch" severity error;
end check_chtcfg;


function xname (s : string) return string is 
  variable ss : string(1 to 128);
  begin
    for i in 1 to 128 loop
      ss(i) := ' ';
    end loop;
    for i in 1 to s'length loop
      ss(i) := s(i);
    end loop;
    return ss;
  end xname; 
  
  function to_std_logic_vector(s: string) return std_logic_vector is
  variable slv: std_logic_vector(s'high-s'low downto 0);
  variable k: integer;
  begin
  k := s'high-s'low;
  for i in s'range loop
    if s(i) = '1' then 
      slv(k) := '1';
    else
      slv(k) := '0';
    end if;
  k := k - 1;
  end loop;
  return slv;
  end to_std_logic_vector;  
  
  function crc16(crc_i : std_logic_vector(15 downto 0); data_i: std_logic_vector(15 downto 0))
    return std_logic_vector is
    variable crc_o : std_logic_vector(15 downto 0);
    begin
      crc_o(0) := data_i(0) xor data_i(4) xor data_i(11) xor crc_i(0) xor crc_i(11) xor data_i(8) xor crc_i(4) xor data_i(12) xor crc_i(8) xor crc_i(12); 
      crc_o(1) := data_i(1) xor data_i(5) xor data_i(12) xor crc_i(1) xor crc_i(12) xor data_i(9) xor crc_i(5) xor data_i(13) xor crc_i(9) xor crc_i(13); 
      crc_o(2) := data_i(2) xor data_i(6) xor data_i(13) xor crc_i(2) xor crc_i(13) xor data_i(10) xor crc_i(6) xor data_i(14) xor crc_i(10) xor crc_i(14); 
      crc_o(3) := data_i(3) xor data_i(7) xor data_i(14) xor crc_i(3) xor crc_i(14) xor data_i(11) xor crc_i(7) xor data_i(15) xor crc_i(11) xor crc_i(15); 
      crc_o(4) := data_i(4) xor data_i(8) xor data_i(15) xor crc_i(4) xor crc_i(15) xor data_i(12) xor crc_i(8) xor crc_i(12); 
      crc_o(5) := data_i(0) xor data_i(5) xor data_i(9) xor crc_i(5) xor data_i(13) xor crc_i(9) xor crc_i(13) xor data_i(4) xor data_i(11) xor crc_i(0) xor crc_i(11) xor data_i(8) xor crc_i(4) xor data_i(12) xor crc_i(8) xor crc_i(12); 
      crc_o(6) := data_i(1) xor data_i(6) xor data_i(10) xor crc_i(6) xor data_i(14) xor crc_i(10) xor crc_i(14) xor data_i(5) xor data_i(12) xor crc_i(1) xor crc_i(12) xor data_i(9) xor crc_i(5) xor data_i(13) xor crc_i(9) xor crc_i(13); 
      crc_o(7) := data_i(2) xor data_i(7) xor data_i(11) xor crc_i(7) xor data_i(15) xor crc_i(11) xor crc_i(15) xor data_i(6) xor data_i(13) xor crc_i(2) xor crc_i(13) xor data_i(10) xor crc_i(6) xor data_i(14) xor crc_i(10) xor crc_i(14); 
      crc_o(8) := data_i(3) xor data_i(8) xor data_i(12) xor crc_i(8) xor crc_i(12) xor data_i(7) xor data_i(14) xor crc_i(3) xor crc_i(14) xor data_i(11) xor crc_i(7) xor data_i(15) xor crc_i(11) xor crc_i(15); 
      crc_o(9) := data_i(4) xor data_i(9) xor data_i(13) xor crc_i(9) xor crc_i(13) xor data_i(8) xor data_i(15) xor crc_i(4) xor crc_i(15) xor data_i(12) xor crc_i(8) xor crc_i(12); 
      crc_o(10) := data_i(5) xor data_i(10) xor data_i(14) xor crc_i(10) xor crc_i(14) xor data_i(9) xor crc_i(5) xor data_i(13) xor crc_i(9) xor crc_i(13); 
      crc_o(11) := data_i(6) xor data_i(11) xor data_i(15) xor crc_i(11) xor crc_i(15) xor data_i(10) xor crc_i(6) xor data_i(14) xor crc_i(10) xor crc_i(14); 
      crc_o(12) := data_i(0) xor data_i(7) xor crc_i(7) xor data_i(15) xor crc_i(15) xor data_i(4) xor crc_i(0) xor data_i(8) xor crc_i(4) xor crc_i(8); 
      crc_o(13) := data_i(1) xor data_i(8) xor crc_i(8) xor data_i(5) xor crc_i(1) xor data_i(9) xor crc_i(5) xor crc_i(9); 
      crc_o(14) := data_i(2) xor data_i(9) xor crc_i(9) xor data_i(6) xor crc_i(2) xor data_i(10) xor crc_i(6) xor crc_i(10); 
      crc_o(15) := data_i(3) xor data_i(10) xor crc_i(10) xor data_i(7) xor crc_i(3) xor data_i(11) xor crc_i(7) xor crc_i(11); 
      return crc_o;
    end crc16;  
    
    function binary_to_gray(x: std_logic_vector) return std_logic_vector is
    begin
      return x xor ('0' & x(x'high downto x'low+1));
    end binary_to_gray;    
  
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



end package body;
