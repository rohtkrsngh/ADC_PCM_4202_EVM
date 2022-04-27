----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:17:41 06/23/2017 
-- Design Name: 
-- Module Name:    pkt - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity packet_rx is
port (data_mac : in std_logic_vector (7 downto 0);
      valid : in std_logic;
		clock : in std_logic;
		data_en  : out std_logic;
		new_pkt  : out  std_logic;
      wr_en_bram :  out std_logic;
		addr_bram_in : out std_logic_vector(6 downto 0);
		rst      : in std_logic;
		data_out : out std_logic_Vector(7 downto 0));  --343
end packet_rx;

architecture Behavioral of packet_rx is
signal data_store :  std_logic_vector (7 downto 0);
type state_type IS  (S0,S01,S02,S03,S04,S05,S1,S11,S12,S13,S14,S15,S2,S21,S3);
SIGNAL N_S , P_S : STATE_TYPE;
signal stop1 : std_logic:='0'; 
signal stop : std_logic:='0'; 
signal stop2 : std_logic:='0'; 
signal stop3 : std_logic:='0'; 

signal cnt :std_logic_vector(6 downto 0):=(others=>'0');     -- updated 29 JUly
signal enable : std_logic;
signal data_en_s : std_logic;
begin


Proc0: PROCESS(CLocK,RST) IS
BEGIN
IF(RISING_EDGE(CLocK))THEN
IF(RST='1') THEN
P_S<=S0;
ELSif(rst='0')then
P_S<=N_S;
END IF;
END IF;
END PROCESS Proc0;

proc1: process (valid, p_s,data_mac,stop)
begin
case p_s is
when s0=>
stop   <=  '0';
if(valid = '1'  ) then  --and pkt_1='0'
if(data_mac = x"DA")then
n_s <= s01;
data_en_s <='0';

else
n_s<=s0;
data_en_s <='0';

end if;
end if;

when s01=>
stop   <=  '0';
if(valid = '1') then
if(data_mac = x"11")then
n_s <= s02;
data_en_s <='0';
else
n_s<=s0;
data_en_s <='0';

end if;
end if;

when s02=>
stop   <=  '0';
if(valid = '1') then
if(data_mac = x"22")then ------------
n_s <= s03;
data_en_s <='0';
else
n_s<=s0;
data_en_s <='0';

end if;
end if;

when s03=>
stop   <=  '0';
if(valid = '1') then
if(data_mac = x"33")then--------------------
n_s <= s04;
data_en_s <='0';
else
n_s<=s0;
data_en_s <='0';
end if;
end if;

when s04=>
stop   <=  '0';
if(valid = '1') then
if(data_mac = x"44")then-----------------
n_s <= s05;
data_en_s <='0';
else
n_s<=s0;
data_en_s <='0';

end if;
end if;

when s05=>
stop   <=  '0';
if(valid = '1') then
if(data_mac = x"55")then
n_s <= s1;
data_en_s <='0';

else
n_s<=s0;
data_en_s <='0';

end if;
end if;

when s1=>
stop   <=  '0';
if(valid = '1') then
if(data_mac = x"5A")then
n_s <= s11;
data_en_s <='0';
else
n_s<=s0;
data_en_s <='0';

end if;
end if;

when s11=>
stop   <=  '0';
if(valid = '1') then
if(data_mac = x"11")then
n_s <= s12;
data_en_s <='0';

else
n_s<=s0;
data_en_s <='0';

end if;
end if;

when s12=>
stop   <=  '0';
if(valid = '1') then
if(data_mac = x"22")then
n_s <= s13;
data_en_s <='0';

else
n_s<=s0;
data_en_s <='0';

end if;
end if;

when s13=>
stop   <=  '0';
if(valid = '1') then
if(data_mac = x"33")then
n_s <= s14;
data_en_s <='0';
else
n_s<=s0;
data_en_s <='0';

end if;
end if;

when s14=>
stop   <=  '0';
if(valid = '1') then
if(data_mac = x"44")then
n_s <= s15;
data_en_s <='0';

else
n_s<=s0;
data_en_s <='0';

end if;
end if;

when s15=>
stop   <=  '0';
if(valid = '1') then
if(data_mac = x"55")then  ---
n_s <= s2;
data_en_s <='0';
else
n_s<=s0;
data_en_s <='0';

end if;
end if;

when s2=>
stop   <=  '0';
if(valid = '1') then
if(data_mac = x"88")then
n_s <= s21;
data_en_s <='0';
else
n_s<=s0;
data_en_s <='0';

end if;
end if;

when s21=>
stop   <=  '0';
if(valid = '1') then
if(data_mac = x"b6")then
n_s <= s3;
data_en_s <='0';

else
n_s<=s0;
data_en_s <='0';

end if;
end if;

when s3 =>
if (valid = '0')then
data_en_s <='0';
n_s <= s0;
stop   <=  '1';
elsif (valid ='1' )then   --and stop='0'
data_en_s <='1';
stop   <=  '0';
n_s<=s3;

end if;

when others=>
data_en_s <='0';
stop   <=  '0';
n_s <= s0;
end case;
end process proc1;

proc2 : process (clock, rst,data_en_s ,cnt)
begin
if (rising_edge (clock))then
if(rst = '1')then
cnt <= (others=>'0');
elsif (data_en_s = '1')then  --111101
cnt <= cnt + '1';
--stop<='0';
enable <= '1';
--elsif (cnt = "111110")then--data_en = '1' and 

--stop<='1';
--enable<='0';
else 
cnt    <=  (others=>'0');
--stop<='0';
enable<='0';
--data_en <= '0';                 -------------------------
end if;
end if;

end process proc2;
wr_en_bram    <=  enable;
addr_bram_in  <=  cnt;
process(clock) 
begin
if rising_edge(clock) then
  stop1<=stop;
  stop2<=stop1;
  stop3<=stop2;
  else
  stop1<=stop1;
  stop2<=stop2;
  stop3<=stop3;
  
  end if;
  end process;

data_en  <=  stop3;
new_pkt  <=  stop1;

proc10 : process(clock,data_en_s)
begin
if(rising_Edge(clock))then
if(data_en_s='1')then
data_out<=data_mac;

end if;
end if;
end process proc10;



end Behavioral;



	