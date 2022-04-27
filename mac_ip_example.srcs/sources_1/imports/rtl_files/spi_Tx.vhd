----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/24/2017 03:05:22 PM
-- Design Name: 
-- Module Name: uart_spi_tx2 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity spi_Tx is
generic(
            N                     : integer := 8;      -- number of bit to serialize
            CLK_DIV               : integer := 1 );
    Port ( CLK_125         : in STD_LOGIC;
           clk_40          : in std_logic;
           DIN             : in STD_LOGIC_VECTOR (7 downto 0);
	       busy             : out std_logic;
           RST             : in STD_LOGIC;
           En              : IN std_logic;
		   o_sclk            : out std_logic;
           o_ss            : out std_logic;
		   dev_en            : in std_logic;
           miso            : IN std_logic;
           TX_spi          : OUT STD_LOGIC;
           mosi_fb         : in  std_logic;
           rd_en_fifo_tx   : out std_logic;
			len_frame_byt     : in  std_logic_vector(7 downto 0);
         word_length_bits  : in  STD_LOGIC_vector(7 downto 0);

		   valid_fifo_tx   : in  std_logic;
		   sob_enable         : out std_logic;
		   spi_rx_data2    : out std_logic_vector(15 downto 0);
		   valid_spi2      : out STD_LOGIC;
		   valid_spi3      : out STD_LOGIC

);
end spi_Tx;

architecture Behavioral of spi_Tx is


component spi_ex
generic(
  N                     : integer := 8;      -- number of bit to serialize
  CLK_DIV               : integer := 1 );  -- input clock divider to generate output serial clock; o_sclk frequency = i_clk/(2*CLK_DIV)
 port (
  i_clk                 : in  std_logic;
  i_rstb                : in  std_logic;
  i_tx_start            : in  std_logic;  -- start TX on serial line
  o_tx_end              : out std_logic;  -- TX data completed; o_data_parallel available
  rd_en_fifo            : out std_logic;

  i_data_parallel       : in  std_logic_vector(N-1 downto 0);  -- data to sent
  o_data_parallel       : out std_logic_vector(15 downto 0);  -- received data
  o_data_fb             : out std_logic_vector(15 downto 0);  -- received data
  len_frame_byt         : in  std_logic_vector(7 downto 0);
  word_length_bits      : in  STD_LOGIC_vector(7 downto 0);
  
  valid_data            : out std_logic;
  sob_enable            : out std_logic;
  o_sclk                : out std_logic;
  o_ss                  : out std_logic;
  o_mosi                : out std_logic;
  i_miso                : in  std_logic;
  mosi_fb               : in  std_logic

  );
end component;


component fifo_spi
port(
rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    valid : OUT STD_LOGIC;
    rd_data_count : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
    wr_data_count : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)  );
end component;


type conv_16x8b is (b0,b1,b1s,b2,b3,b4,b5);
signal nxt_st,prt_st: conv_16x8b;

type conv_16x8b2 is (b02,b12,b1s2,b22,b32,b42,b52);
signal nxt_st2,prt_st2: conv_16x8b2;

signal count_delay: std_logic_vector(7 downto 0):=X"00";
signal count_delay2: std_logic_vector(7 downto 0):=X"00";
signal enable_count: std_logic:='0';
signal enable_count2: std_logic:='0';
signal rdy_f,rdy_s,rdy_fb: std_logic:='0';
signal data_mac : std_logic_vector(7 downto 0);
signal data_mac2 : std_logic_vector(7 downto 0);

signal dout:STD_LOGIC_VECTOR(7 DOWNTO 0);
signal full:std_logic;
signal overflow: std_logic;
signal empty: std_logic;


signal valid: std_logic;
signal en_rd: std_logic;
signal en_wr: std_logic;

signal full_spi,full_spix:std_logic;
signal overflow_spi: std_logic;
signal empty_spi,empty_spix: std_logic;
signal valid_spi,valid_spix: std_logic;
--SIGNAL valid_spi2:STD_LOGIC_VECTOR(3 DOWNTO 0):=X"0";
signal Trig45_spig:std_logic:='0';
signal en_rd_spi,en_rd_spix: std_logic;
signal en_wr_spi: std_logic;

signal busy_t: std_logic;
signal  underflow :  STD_LOGIC;
signal rd_data_count_spi,rd_data_count_spix: std_logic_vector(4 downto 0);
signal wr_data_count_spi,wr_data_count_spix : std_logic_vector(4 downto 0);
type spi_type is (spi_id,spi1,spi2);
signal pre,nex: spi_type;
type TX_TYPE is (S0,S1);

type spi_rx_TYPE is (id1,rd_st1,rd_st2);
signal pres,nxt : spi_rx_TYPE;

type spi_rx_TYPEx is (id1x,rd_st1x,rd_st2x);
signal presx,nxtx : spi_rx_TYPEx;

SIGNAL P_S:TX_TYPE;
SIGNAL N_S:TX_TYPE;
signal COUNT:natural:=0;

SIGNAL START:STD_LOGIC;
SIGNAL LAST:STD_LOGIC;
SIGNAL TX1:STD_LOGIC;
SIGNAL TX2:STD_LOGIC;

SIGNAL CLK_OUT1:STD_LOGIC;
signal COUNTER1 : std_logic_Vector(8 downto 0):=(others=>'0');
signal trp_s : std_logic_vector(3 downto 0):="0000";
signal chk_tx: std_logic:='0';
signal tx_end : std_logic:='0';
signal s_tx1_end : std_logic:='0';
signal s_tx2_end : std_logic:='0';
signal spi_in_data : std_logic_vector(7 downto 0):="00000000";

signal tx_end_f : std_logic;
signal rx_data1 : std_logic_vector(15 downto 0):= X"0000";
signal rx_data_fb2 : std_logic_vector(15 downto 0):= X"0000";
signal o_sclk1: std_logic;
signal o_sclk2: std_logic;
signal o_ss1: std_logic;
signal o_ss2: std_logic;
signal miso1: std_logic;
signal miso2: std_logic;  
signal spi_rx_data: std_logic_vector(31 downto 0):=X"00000000";
signal spi_data_valid,spi_data_validx :std_logic:='0';

signal rx_data_rdy_s :std_logic:='0';

signal din_s1: std_logic_vector(7 downto 0);

signal en_words: std_logic:='0';
signal cnt_words:std_logic_vector(11 downto 0) :=(others=>'0');
signal e_cnt_s : std_logic:='0';
signal       d_cnt_S : std_logic:='0';
signal     cnt_v  : natural :=0;
signal  	en_rd_spic ,en_rd_spixc  : std_logic;  
signal   start_tx   :  std_logic;
 -- signal     sob_s   : std_logic:='0';


begin
o_ss          <=  o_ss1;
valid_spi2    <=  valid_spi;
valid_spi3    <=  valid_spix;


P1:PROCESS(CLK_40, RST) IS
BEGIN
IF(RISING_EDGE(CLK_40)) THEN
IF(RST='1') THEN
P_S<=S0;
else
P_S<=N_S;
END IF;
end if;
END PROCESS P1;



busy  <=  busy_T;
				  
P2:PROCESS(P_S,tx_end,en,valid_fifo_tx)IS
BEGIN
  CASE P_S IS 
    
    when S0  =>
		busy_t<='0';
				
      IF (en = '1') THEN
		start_tx <= '1' ;  
      N_S <= S1;
      ELSE
		start_tx <= '0' ;
      N_S <= S0;
      END IF;
      
    WHEN S1 =>
		 busy_t<='1';
		 start_tx <= '0' ;
		 IF(tx_end='1')THEN
		 N_S<=S0;
		 ELSE 
		 N_S<=S1;
		 END IF;
    END CASE ;
END PROCESS P2;

spi_in_data         <=   Din;
--spi_in_data(6)    <=   Din(1);
--spi_in_data(5)    <=   Din(2);
--spi_in_data(4)    <=   Din(3);
--spi_in_data(3)    <=   Din(4);
--spi_in_data(2)    <=   Din(5);
--spi_in_data(1)    <=   Din(6);
--spi_in_data(0)    <=   Din(7);

 u1: spi_ex generic map(N    =>    8,     
                   CLK_DIV   =>      1 )
  port map(
  
  
              i_clk                =>		  CLK_40,	  
              i_rstb               =>       rst,
              i_tx_start           =>       start_tx,
              o_tx_end             =>       tx_end,
              i_data_parallel      =>       spi_in_data,
				  rd_en_fifo           =>       rd_en_fifo_tx,
              o_data_parallel      =>       rx_data1,
		        o_data_fb            =>       rx_data_fb2,
		        valid_data           =>       spi_data_valid,
				  len_frame_byt        =>       len_frame_byt,
				  	word_length_bits    =>       word_length_bits,
              o_sclk               =>       o_sclk,
              o_ss                 =>       o_ss1,
              o_mosi               =>       TX_spi,
			     sob_enable           =>       sob_enable,
		        mosi_fb              =>       mosi_fb,
              i_miso               =>       miso);              --- updated 17 July 12:41PM
  
     
	 PROCESS(CLK_40)IS
BEGIN
IF(RISING_EDGE(CLK_40))THEN
IF(busy_t='1')THEN
en_words<='1';
 elsif cnt_words =X"1F0" then
    
     en_words<='0';
	  
    else 	
   en_words<=en_words;  
	end if;
	end if;
	end process;
PROCESS(CLK_40)IS
BEGIN
IF(RISING_EDGE(CLK_40))THEN
IF(en_words='1')THEN
  cnt_words<=cnt_words+1;
  else
  cnt_words<=X"000";
  end if;
  end if;
  end process;
  


	 
	PROCESS(clk_125) IS
BEGIN
IF(RISING_EDGE(CLK_125)) THEN
   if dev_en ='1' then
      spi_data_validx<=spi_data_valid;	
		else
		spi_data_validx<='0';
		end if;
		end if;
		end process;

	
				  
	PROCESS(clk_125) IS
BEGIN
IF(RISING_EDGE(CLK_125)) THEN
IF(RST='1') THEN
pres<=id1;
presx<=id1x;
else
presx<=nxtx;
pres<=nxt;
en_rd_spic <=en_rd_spi;
en_rd_spixc<=en_rd_spix;
END IF;
end if;
END PROCESS ;


process(clk_125)
begin
case presx is
when id1x =>
           	en_rd_spix<='0';		  
				if  (rd_data_count_spix ="00000") then
                 nxtx<=id1x;
            elsif (rd_data_count_spix ="00001")	then
				
				  nxtx<=rd_St1x;
				  else
				  nxtx<=id1x;
				  end if;
--	when rd_st1 =>
--  	en_rd_spi<='1';
--	nxt<=rd_St2;
	 
	when rd_st1x => 
	en_rd_spix<='1';
	nxtx<=id1x;
	 
	 when others =>
				nxtx<=id1x;
end case;
end process;



process(clk_125)
begin
case pres is
when id1 =>
           	en_rd_spi<='0';		  
				if  (rd_data_count_spi ="00000") then
                 nxt<=id1;
            elsif (rd_data_count_spi ="00001")	then
				
				  nxt<=rd_St1;
				  else
				  nxt<=id1;
				  end if;
--	when rd_st1 =>
--  	en_rd_spi<='1';
--	nxt<=rd_St2;
	 
	when rd_st1 => 
	en_rd_spi<='1';
	nxt<=id1;
	 
	 when others =>
				nxt<=id1;
end case;
end process;				
				  

	


process(CLK_40) is
begin
  if rising_edge(CLK_40) then
   if (RST = '1') then
	prt_st<=b0;
	prt_st2<=b02;
	else
	prt_St<=nxt_st;
	prt_St2<=nxt_st2;
	end if;
	end if;
end process;

process(prt_st,spi_data_valid,count_delay )
                 
                       
  begin
    case prt_st is
	 when b0 =>
							  enable_count   <=  '0';
	                    rdy_f           <= '0';
                     data_mac              <= X"00";
					     if (spi_data_valid='1')  	 then
						  nxt_St                 <= b1;
							else
							nxt_St                <= b0;
							
						end if;
						
		when b1 =>
                  nxt_st          <=   b1s; 
                  enable_count    <= '0';	
					   rdy_f           <= '0';
						data_mac        <= rx_data1(7 downto 0);

                    
		when b1s =>
                  nxt_st          <=   b2; 
                  enable_count    <= '0';	
					   rdy_f           <= '1';
				 		data_mac        <= rx_data1(7 downto 0);

						  
						  
     when b2 =>
               rdy_f           <= '0';
					enable_count   <='1';
					if len_frame_byt = X"08" then
					  nxt_st   <= b0;
					  data_mac <= rx_data1(7 downto 0);
					elsif count_delay = X"0A" then
					  nxt_st   <= b3;
			  	     data_mac <= rx_data1(15 downto 8);
                 else
					  data_mac   <= X"00";
					  nxt_st     <=   b2;
					 end if;
		when b3 => 	
                 nxt_st      <=b4;		
					  enable_count<='0'; 
					    rdy_f    <='1' ;
						data_mac <= rx_data1(15 downto 8);
		when b4 =>
               rdy_f     <='0' ;
					  nxt_st<=b0;
					  enable_count<='0';
					  data_mac <= rx_data1(15 downto 8);
		when others =>
               	enable_count<='0';	
					  rdy_f  <='0' ;  	  
					  nxt_st<=b0;
			end case;
end process;	



process(prt_st2,spi_data_validx,count_delay2 )
                 
                       
  begin
    case prt_st2 is
	 when b02 =>
							  enable_count2   <=  '0';
	                    rdy_s           <= '0';
                     data_mac2              <= X"00";
					     if (spi_data_validx='1')  	 then
						  nxt_St2                 <= b12;
							else
							nxt_St2                <= b02;
							
						end if;
						
		when b12 =>
                  nxt_st2          <=   b1s2; 
                  enable_count2    <= '0';	
					   rdy_s           <= '0';
						data_mac2        <= rx_data_fb2(7 downto 0);

                    
		when b1s2 =>
                  nxt_st2          <=   b22; 
                  enable_count2    <= '0';	
					   rdy_s           <= '1';
				 		data_mac2        <= rx_data_fb2(7 downto 0);

						  
						  
     when b22 =>
               rdy_s           <= '0';
					enable_count2   <='1';
					if len_frame_byt = X"08" then
					  nxt_st2   <= b02;
					  data_mac2 <= rx_data_fb2(7 downto 0);
					 elsif count_delay2 = X"0A" then
					     nxt_st2   <=b32;
						  data_mac2 <= rx_data_fb2(15 downto 8);
                 else
					  data_mac2              <= X"00";
					     nxt_st2<=b22;
					 end if;
		when b32 => 	
                 nxt_st2      <=b42;		
					  enable_count2<='0'; 
					    rdy_s    <='1' ;
						data_mac2 <= rx_data_fb2(15 downto 8);
		when b42 =>
               rdy_s     <='0' ;
					  nxt_st2<=b02;
					  enable_count2<='0';
					  data_mac2 <= rx_data_fb2(15 downto 8);
		when others =>
               	enable_count2<='0';	
					  rdy_s  <='0' ;  	  
					  nxt_st2<=b02;
			end case;
end process;

process(CLK_40) is	
begin
if rising_edge(CLK_40) then
  if enable_count='1' then
     count_delay<=count_delay+1;
     elsif enable_count='0' then
    count_delay<=X"00";
	end if;
end if;
end process;	
	
process(CLK_40) is	
begin
if rising_edge(CLK_40) then
  if enable_count2='1' then
     count_delay2<=count_delay2+1;
     elsif enable_count2='0' then
    count_delay2<=X"00";
	end if;
end if;
end process;


ss: fifo_spi
port map(
     rst => rst,
    wr_clk => clk_40,
    rd_clk => clk_125,
    din => data_mac,
    wr_en => rdy_f,
    rd_en => en_rd_spic,
    dout => spi_rx_data2(7 downto 0),
    full => full_spi,
    
    empty => empty_spi,
    valid => valid_spi,
	
    rd_data_count => rd_data_count_spi,
    wr_data_count => wr_data_count_spi   
);


sst: fifo_spi
port map(
     rst => rst,
    wr_clk => clk_40,
    rd_clk => clk_125,
    din => data_mac2,
    wr_en => rdy_s,
    rd_en => en_rd_spixc,
    dout => spi_rx_data2(15 downto 8),
    full => full_spix,
    empty => empty_spix,
    valid => valid_spix,
    rd_data_count => rd_data_count_spix,
    wr_data_count => wr_data_count_spix   
);

    


end Behavioral;