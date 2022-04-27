


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity tx2 is
    Port ( CLK_125          : in  STD_LOGIC;
           clk_tx           : in  std_logic;
           DIN              : in  STD_LOGIC_VECTOR (7 downto 0);
			  rd_en_fifo       : out std_logic;
			  busy             : out std_logic;
			  valid_s          : in  std_logic;
			  len_frame_byt    : in  std_logic_vector(7 downto 0);
           RST              : in  STD_LOGIC;
           En_Tx            : IN  std_logic;
			  TX_out           : OUT STD_LOGIC);
end tx2;

architecture Behavioral of tx2 is


signal full:std_logic;
signal overflow: std_logic;
signal empty: std_logic;
signal valid: std_logic;
signal en_rd: std_logic;
signal en_wr: std_logic;
SIGNAL cnt_wr:STD_LOGIC_VECTOR(1 DOWNTO 0):="00";

 

signal busy_t: std_logic;
signal  underflow :  STD_LOGIC;
signal rd_data_count: std_logic_vector(3 downto 0);
signal wr_data_count : std_logic_vector(3 downto 0);

type TX_TYPE is (S0,S1,data_bit_St,stop_bit_St);
SIGNAL P_S:TX_TYPE;
SIGNAL N_S:TX_TYPE;

signal enable_cnt: std_logic:='0';
signal COUNT      :natural:=0;
signal length_data:natural:=0;
signal valid_s1: std_logic;
SIGNAL DIN_REG:STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL START:STD_LOGIC;
SIGNAL LAST:STD_LOGIC;
SIGNAL TX1:STD_LOGIC:='1';

signal  rd_en     :   std_logic;  


signal count_pat      :  std_logic_vector(1 downto 0)  := "00";
signal count_start    :  std_logic_vector(3 downto 0)  := X"0";
signal count_stop     :  std_logic_vector(7 downto 0)  := X"00";
signal count_data     :  std_logic_vector(7 downto 0)  := X"00";
signal start_bit_cal  :  std_logic_vector(3 downto 0)  ;
signal word_frame_len :  std_logic_vector(7 downto 0) ;
signal FIX_LEN        :  std_logic_vector(7 downto 0) ;
signal LEN_PKT_CNT    :  std_logic_vector(7 downto 0) := X"00";
signal STOP_BIT_cal   :  std_logic_vector(7 downto 0) ;
SIGNAL word_len_bits  :  std_logic_vector(7 downto 0) ;

begin

process(CLK_125) 
begin
if rising_edge(clk_125) then
FIX_LEN       <=  len_frame_byt -  '1';
STOP_BIT_cal  <=  X"98";--  4C --98
start_bit_cal <=  X"2";--
end if;
end process;

word_len_bits <= X"20";


process(clk_tx) 
begin
if rising_Edge(clk_tx) then
if count_pat = "01" then
count_start  <= count_Start + '1';
else
count_Start  <=  (others => '0' );
end if;
end if;
end process;

process(clk_tx) 
begin
if rising_Edge(clk_tx) then
if count_pat = "10" then

 count_DATA <= count_DATA + '1';
else
count_DATA  <=  (others => '0' );
end if;
end if;
end process;

process(clk_tx) 
begin
if rising_Edge(clk_tx) then
if count_pat = "11" then

 COUNT_STOP <= COUNT_STOP + '1';
else
COUNT_STOP  <=  (others => '0' );
end if;
end if;
end process;

process(clk_tx) 
begin
if rising_Edge(clk_tx) then
if count_pat = "00" then
LEN_PKT_CNT  <= (others => '0');
elsif rd_en = '1' then
LEN_PKT_CNT  <= LEN_PKT_CNT + 1;
end if;
end if;
end process;


PROCESS (clk_tx,RST) IS
BEGIN
if RST = '1'	then
tx1  <=  '1';
elsIF(RISING_EDGE (clk_tx)) THEN
 if  count_pat = "01" then
  tx1  <=  '0';
 elsif count_pat = "11" then
  tx1  <=  '1';
 elsif count_pat = "10" then
  case count_data is
   when X"01" =>  tx1   <= DIN_reg(0);
   when X"05" =>  tx1   <= DIN_reg(1);
   when X"09" =>  tx1   <= DIN_reg(2);
   when X"0D" =>  tx1   <= DIN_reg(3);
   when X"11" =>  tx1   <= DIN_reg(4);
   when X"15" =>  tx1   <= DIN_reg(5);
   when X"19" =>  tx1   <= DIN_reg(6);
   when X"1D" =>  tx1   <= DIN_reg(7);
   when X"21" =>  tx1   <= DIN_reg(0);
   when X"25" =>  tx1   <= DIN_reg(1);
   when X"29" =>  tx1   <= DIN_reg(2);
   when X"2D" =>  tx1   <= DIN_reg(3);
   when X"31" =>  tx1   <= DIN_reg(4);
   when X"35" =>  tx1   <= DIN_reg(5);
   when X"39" =>  tx1   <= DIN_reg(6);
   when X"3D" =>  tx1   <= DIN_reg(7);
   when others => tx1   <= tx1;
  end case;
  
 else
  tx1 <= '1';
 end if;
end if;
end process; 



P1:PROCESS(clk_tx, RST) IS
BEGIN
IF(RISING_EDGE(clk_tx)) THEN
IF(RST='1') THEN
P_S<=S0;
else
P_S<=N_S;
END IF;
end if;
END PROCESS P1;

P2:PROCESS(P_S,COUNT, busy_t, count_START, count_DATA, LEN_PKT_CNT, COUNT_STOP )IS
BEGIN
  CASE P_S IS 
    
     when S0  =>
	  rd_en <= '0'; 
     count_pat   <=  "00";
      IF (busy_t = '1') THEN
      N_S <= S1;
      ELSE
      N_S <= S0;
      END IF;

      
    WHEN S1 =>
	count_pat   <=  "01";
	if count_START = start_bit_cal then
	 rd_en <= '1';
    N_S <= data_bit_St;
    else
    N_S <= s1; 
	 rd_en <= '0';
    end if;
    
    when data_bit_St =>
     count_pat <= "10";
     if count_DATA = word_len_bits  then
      N_S <= stop_bit_St;
    else
    N_S <= data_bit_St; 
    end if;
	 rd_en <= '0';

	 
    when stop_bit_St =>
      count_pat  <=  "11";
		rd_en      <=  '0';
    if LEN_PKT_CNT > FIX_LEN THEN
      N_S <= s0;
     ELSIF COUNT_STOP = STOP_BIT_cal  then
      N_S   <=  s1;
    else
    N_S <= stop_bit_St; 
    end if; 
   
    END CASE ;
END PROCESS P2;


process(clk_tx) 
begin
if rising_edge(clk_tx) then
 busy_t   <=  en_tx;
end if;
end process; 

process(clk_tx) 
begin
if rising_edge(clk_tx) then
if busy_t='1' then
busy<='1';
else 
busy<='0';
end if;
end if;
end process;

rd_en_fifo  <=  rd_en;
DIN_REG <=  Din;

TX_out<=TX1;


end Behavioral;
