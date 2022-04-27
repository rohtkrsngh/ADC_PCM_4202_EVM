----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/01/2014 01:09:29 AM
-- Design Name: 
-- Module Name: UART_MAC_BRIDGE_TOP - Behavioral
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

entity UART_MAC_BRIDGE_TOP is
    Port (  RX_IN_p        : in  STD_LOGIC_vector(3 downto 0);
	         RX_monitor     : in  STD_LOGIC;
		   self_test_in   : in  STD_LOGIC;
           DOUT_UMC        : out STD_LOGIC_VECTOR (7 downto 0);
           Data_Valid_UMC  : out STD_LOGIC;
           Rd_Req_UMC      : in  std_logic; 
            format_recvr  :  in std_logic;
           LEN_UMC         : out STD_LOGIC_VECTOR (7 downto 0);
           CLK_UMC         : in  std_logic;
		   cmd_id_DUT_num_q : in std_logic_vector(3 downto 0);
		    frame_length    :  in  std_logic_vector(7 downto 0);
           clk_200         :  in std_logic;
            rx_sclk         : in std_logic;
           valid_dut       : in std_logic_vector(3 downto 0);
           valid_self_test  : in std_logic;
           RST_UMC         : in  std_logic;
			  rx_pkt_cmplt     : out   std_logic_vector(3 downto 0)
           );
end UART_MAC_BRIDGE_TOP;

architecture UART_MAC_BRIDGE_TOP_a of UART_MAC_BRIDGE_TOP is

signal   rst_clk_rx_s    :    std_logic_vector(3 downto 0); 
signal   clk_rx_s        :    std_logic_vector(3 downto 0); 
signal   rx_data_s       :    std_logic_vector(15 downto 0); 
signal   rx_data_fb      :    std_logic_vector(15 downto 0); 


signal   rx_data_f       :    std_logic_vector(15 downto 0); 
signal   rx_data_mac       :    std_logic_vector(31 downto 0); 
signal   rx_data_mac_s       :    std_logic_vector(15 downto 0); 
signal   rx_data_mac_f       :    std_logic_vector(15 downto 0); 
signal   rx_data_mac_fb1       :    std_logic_vector(15 downto 0); 

signal   rx_data_mac_fb       :    std_logic_vector(15 downto 0); 

signal   rx_data_rdy_s   :    std_logic_vector(3 downto 0):="0000";
signal   rx_data_rdy_s1   :    std_logic_vector(3 downto 0):="0000";

 signal   rx_data_rdy_f   :    std_logic_vector(3 downto 0):="0000";

signal   frm_err_s       :    std_logic_vector(3 downto 0); 
signal   DOUT_UMC_s      :    STD_LOGIC_VECTOR (7 downto 0);
signal   Data_Valid_UMC_s  :    STD_LOGIC;
signal   Data_Valid_UMC1_s :  STD_LOGIC;
signal   LEN_UMC_s       :    STD_LOGIC_VECTOR (7 downto 0);
signal   LEN_UMC1_s      :    STD_LOGIC_VECTOR (7 downto 0);
signal ch_sel_id         :    STD_LOGIC_VECTOR (7 downto 0);
type conv_16x8b is (b0,b1,b1s,b2,b3,b4,b5);
signal nxt_st,prt_st: conv_16x8b;

type conv_16x8b2 is (b02,b12,b1s2,b22,b32,b42,b52);
signal nxt_st2,prt_st2: conv_16x8b2;

type conv_16x8b3 is (b03,b13,b1s3,b23,b33,b43,b53);
signal nxt_st3,prt_st3: conv_16x8b3;

signal count_delay  : std_logic_vector(7 downto 0):=X"00";
signal count_delay2 : std_logic_vector(7 downto 0):=X"00";
signal count_delay3 : std_logic_vector(7 downto 0):=X"00";



signal enable_count  : std_logic:='0';
signal enable_count2 : std_logic:='0';
signal enable_count3 : std_logic:='0';

signal senable_2byte_f,enable_2byte_f: std_logic:='0';
signal senable_2byte_fb1,enable_2byte_fb1: std_logic:='0';
signal enable_2byte_fb2: std_logic:='0';

signal senable_2byte_s,enable_2byte_s: std_logic:='0';
signal rdy_f,rdy_s,rdy_fb: std_logic:='0';


signal ss_one,s_one: std_logic:='0';
signal v1: std_logic:='0';
signal v2: std_logic:='0';
signal sel_8: std_logic:='0';
signal s_sel_8: std_logic:='0';
signal s_sel_82: std_logic:='0';
signal sel_82: std_logic:='0';
signal data_mac : std_logic_vector(7 downto 0);
signal data_mac2 : std_logic_vector(7 downto 0);
signal data_mac3 : std_logic_vector(7 downto 0);

--signal Uart_tp1        : std_logic;
----------------------------------------------
component uart_MAC_TOP is                                                                                                          
    generic (                                                                                                                 
             BAUD_RATE   : integer :=5000000;           -- serves as clock divisor  (1041667)                                           
             CLOCK_RATE  : integer := 125000000        -- freq of clk                                                         
          );                                                                                                                  
    Port ( rst_clk_rx    : in  STD_LOGIC;              -- active high, managed synchronously                                  
           clk_rx        : in  STD_LOGIC;              -- operational clock                                                   
           rx_IN         : in  STD_LOGIC;
           rx_sclk       : in  STD_LOGIC;
         --  rx_IN_N         : in  STD_LOGIC;              -- directly from pad - not yet associated with any time domain         
      
			 clk_200        : in std_logic;     
          start_bit_num  : in  std_logic_vector(3 downto 0);	
			 word_length    : in  std_logic_vector(7 downto 0);
			 rx_data        : out STD_LOGIC_VECTOR (15 downto 0);   -- 8 bit data output valid when rx_data_rdy is asserted       
          rx_data_rdy    : out STD_LOGIC; 
          valid_dut      : in std_logic;             -- active high signal indicating rx_data is valid                      
          frm_err        : out STD_LOGIC               -- framing error - active high when STOP bit not detected              
          );                                                                                                                  
end component uart_MAC_TOP;                                                                                                        

component rx_info_schd is                                         
    Port (  DIN_WRB           : in    std_logic_vector(7 downto 0);
        CLK1_WRB          : in    std_logic;
        DIN_RDY_WRB       : in    std_logic;
           RST_WRB           : in    std_logic;
           Rd_Req            : in    std_logic;
           ch_sel_id         : in    std_logic_vector(7 downto 0);
        DOUT_WRB          : out   std_logic_vector(7 downto 0);
            DOUT_RDY_wrb     : out   STD_LOGIC;                       
         LEN_PLD_wrb      : out   STD_LOGIC_VECTOR (7 downto 0)
     );
end component rx_info_schd;      
COMPONENT meta_harden is
    Port ( clk_dst          : in  STD_LOGIC;
            rst_dst         : in  STD_LOGIC;
           signal_src       : in  STD_LOGIC;
           signal_dst       : out STD_LOGIC);
end COMPONENT meta_harden;                                        

SIGNAL 			 word_length    :   std_logic_vector(7 downto 0) := X"08";
signal rxd_clk_rx : std_logic_vector(3 downto 0);
signal rx_p, valid_dut_s : std_logic;
signal reset_update : std_logic := '0';
begin
reset_update <= rst_umc or format_recvr; 
rst_clk_rx_s  <= (0 to 3 => reset_update);
clk_rx_s      <= (0 to 3 => CLK_UMC);
--rxd_i_s       <= "1111" ;  .    
LEN_UMC1_s    <= LEN_UMC_s + 1;                  

DOUT_UMC         <= DOUT_UMC_s;           
Data_Valid_UMC <= Data_Valid_UMC1_s;
LEN_UMC        <= LEN_UMC1_s;


   meta_harden_rxd_i0: meta_harden 
             port map (rst_dst=>rst_clk_rx_s(0), clk_dst=>clk_200, 
		  signal_src=>RX_IN_P(0), signal_dst=>rxd_clk_rx(0));

 meta_harden_rxd_i1: meta_harden 
             port map (rst_dst=>rst_clk_rx_s(0), clk_dst=>clk_200, 
				           signal_src=>RX_IN_P(1), signal_dst=>rxd_clk_rx(1));
 meta_harden_rxd_i2: meta_harden 
      port map (rst_dst=>rst_clk_rx_s(0), clk_dst=>clk_200, 
      signal_src=>RX_IN_P(2), signal_dst=>rxd_clk_rx(2));	
	
	
 meta_harden_rxd_i3: meta_harden 
    port map (rst_dst=>rst_clk_rx_s(0), clk_dst=>clk_200, 
    signal_src=>RX_IN_P(3), signal_dst=>rxd_clk_rx(3));	
	


process(clk_200)
begin
if rising_edge(clk_200) then
 if  cmd_id_DUT_num_q = X"1" then
 rx_p <= rxd_clk_rx(0);
 valid_dut_s <= valid_dut(0);
  ch_sel_id <= X"01";
 elsif 	cmd_id_DUT_num_q = X"2" then
  rx_p <= rxd_clk_rx(1);
   valid_dut_s <= valid_dut(1);
    ch_sel_id <= X"02";
 elsif cmd_id_DUT_num_q = X"3" then
   rx_p <= rxd_clk_rx(2);
 valid_dut_s <= valid_dut(2);
  ch_sel_id <= X"03";
 elsif cmd_id_DUT_num_q = X"4" then
    rx_p <= rxd_clk_rx(3);
 valid_dut_s <= valid_dut(3);
  ch_sel_id <= X"04";
elsif cmd_id_DUT_num_q = X"0" then
     rx_p <= '1'; 
 valid_dut_s <= '0';
 end if;
end if;
end process;				           
U1_UMC:uart_MAC_TOP                                                            
  generic map  (                                                        
           BAUD_RATE   => 5000000,           -- serves as clock divisor  
           CLOCK_RATE  => 125000000        -- freq of clk               
        )                                                               
  Port map ( rst_clk_rx     =>    rst_clk_rx_s(0),                                      
             clk_rx         =>    clk_rx_s(0),                                      
             rx_IN        => rx_p,
            -- rx_IN_N        => rx_in_n(0),  
         
				 clk_200        =>  clk_200,
				 rx_sclk        =>  rx_sclk,	
				  start_bit_num    => "0001",
				  word_length      =>  word_length,
             rx_data        =>    rx_data_f(15 downto 0),                                      
             rx_data_rdy    =>    rx_data_rdy_s1(0),
             valid_dut      =>    valid_dut_s,                                      
             frm_err        =>    frm_err_s(0)                                      
        );                                                              
			 
--U2_UMC:uart_MAC_TOP                                                            
--  generic map  (                                                        
--           BAUD_RATE   => 5000000,           -- serves as clock divisor  
--           CLOCK_RATE  => 125000000        -- freq of clk               
--        )                                                               
--  Port map ( rst_clk_rx     =>    rst_clk_rx_s(0),                                      
--             clk_rx         =>    clk_rx_s(0),                                      
--             rx_IN        => RX_monitor,
--             value_sample1  =>  "011111001111111", --"111101000010010" ,
--				 value_sample2  =>  "010100110101011",--"101000101100001",
--				 value_sample3  =>  "010100110101010", --"101000101100001",
--				 value_sample4  =>  "010100110101010", --"101000101100001",
--				 value_sample5  =>  "010100110101010", --"101000101100001",
--				 clk_200        =>  clk_200,	
--				  start_bit_num    => "0001",
--				  word_length      =>  word_length,
--             rx_data        =>    rx_data_s(15 downto 0),                                      
--             rx_data_rdy    =>    rx_data_rdy_s1(1),
--             valid_dut      =>    valid_dut(0),                                      
--             frm_err        =>    frm_err_s(1)                                      
--        );	
		  
--U3_UMC:uart_MAC_TOP                                                            
--  generic map  (                                                        
--           BAUD_RATE   => 5000000,           -- serves as clock divisor  
--           CLOCK_RATE  => 125000000        -- freq of clk               
--        )                                                               
--  Port map ( rst_clk_rx     =>    rst_clk_rx_s(0),                                      
--             clk_rx         =>    clk_rx_s(0),                                      
--             rx_IN        => self_test_in,
--            -- rx_IN_N        => rx_in_n(0),  
--             value_sample1  =>  "011111001111111", --"111101000010010" ,
--				 value_sample2  =>  "010100110101011",--"101000101100001",
--				 value_sample3  =>  "010100110101010", --"101000101100001",
--				 value_sample4  =>  "010100110101010", --"101000101100001",
--				 value_sample5  =>  "010100110101010", --"101000101100001",
--				 clk_200        =>  clk_200,	
--				  start_bit_num    => "0001",
--				  word_length      =>  word_length,
--             rx_data        =>   rx_data_fb(15 downto 0),                                      
--             rx_data_rdy    =>    rx_data_rdy_s1(2),
--             valid_dut      =>    valid_self_test,                                      
--             frm_err        =>    frm_err_s(2)                                      
--        ); 		  

		  
       process(clk_umc)
begin
if rising_edge(clk_umc) then
      rx_data_rdy_s   <=         rx_data_rdy_s1;
		else
		rx_data_rdy_s<=rx_data_rdy_s;
		end if;
		end process;
		 
Us_UMC:rx_info_schd
  Port map(       
    DIN_wrb      =>  rx_data_mac(7 downto 0),
    CLK1_wrb     =>  CLK_UMC,
    RST_wrb      =>  RST_UMC,
    DIN_RDY_wrb  =>  rx_data_rdy_f(0),
	 ch_sel_id    =>  ch_sel_id,
    DOUT_wrb     =>  DOUT_UMC_s,
    DOUT_RDY_wrb =>  Data_Valid_UMC_s,
    LEN_PLD_wrb  =>  LEN_UMC_s,
    Rd_Req       =>  Rd_Req_UMC

	 );
  
-- process(CLK_UMC) is
--     begin
--       if rising_edge(CLK_UMC) then
--        if rdy_f = '1' then
--         ch_sel_id <= X"01";
--          elsif rdy_s = '1' then
--         ch_sel_id <= X"02";
--      elsif rdy_fb = '1' then
--         ch_sel_id <= X"AB";
--          end if;
--     end if;
--     end process; 
  
  
process(CLK_UMC) is
begin
  if rising_edge(CLK_UMC) then
   if (reset_update = '1') then
	prt_st<=b0;
	prt_st2<=b02;
	prt_st3<=b03;
	else
	prt_St<=nxt_st;
	prt_St2<=nxt_st2;
	prt_St3<=nxt_st3;
	end if;
	end if;
end process;

rx_data_mac   <=  X"00" & data_mac3 & data_mac2 & data_mac;
rx_data_rdy_f <= '0' &  rdy_fb & rdy_s & rdy_f;

process(CLK_UMC) is
begin
  if rising_edge(CLK_UMC) then
    if (rx_data_rdy_s(0)='1')  	 then
		rx_data_mac_f          <= rx_data_f; 
		else
		rx_data_mac_f          <= rx_data_mac_f;
		end if;
	end if;
end process;

--process(CLK_UMC) is
--begin
--  if rising_edge(CLK_UMC) then
--    if (rx_data_rdy_s(1)='1')  	 then
--		rx_data_mac_s          <= rx_data_s; 
--		else
--		rx_data_mac_s          <= rx_data_mac_s;
--		end if;
--	end if;
--end process;

--process(CLK_UMC) is
--begin
--  if rising_edge(CLK_UMC) then
--    if (rx_data_rdy_s(2)='1')  	 then
--		rx_data_mac_fb          <= rx_data_fb; 
--		else
--		rx_data_mac_fb          <= rx_data_mac_fb;
--		end if;
--	end if;
--end process;	
-----------------------------------------------------------------------------


----------------------------------------------------------------------------

process(prt_st,rx_data_rdy_s(0),count_delay )
                 
                       
  begin
    case prt_st is
	 when b0 =>
							  enable_count   <=  '0';
	                    rdy_f           <= '0';
                     data_mac              <= X"00";
					     if (rx_data_rdy_s(0)='1')  	 then
						  nxt_St                 <= b1;
							else
							nxt_St                <= b0;
							
						end if;
						
		when b1 =>
                  nxt_st          <=   b1s; 
                  enable_count    <= '0';	
					   rdy_f           <= '0';
						data_mac        <= rx_data_mac_f(7 downto 0);

                    
		when b1s =>
                  nxt_st          <=   b2; 
                  enable_count    <= '0';	
					   rdy_f           <= '1';
				 		data_mac        <= rx_data_mac_f(7 downto 0);

						  
						  
     when b2 =>
               rdy_f           <= '0';
					enable_count   <='1';
					if word_length = X"08" then
					  nxt_st   <= b0;
					  data_mac <= rx_data_mac_f(7 downto 0);
					elsif count_delay = X"13" then
					  nxt_st   <= b3;
			  	     data_mac <= rx_data_mac_f(15 downto 8);
                 else
					  data_mac   <= X"00";
					  nxt_st     <=   b2;
					 end if;
		when b3 => 	
                 nxt_st      <=b4;		
					  enable_count<='0'; 
					    rdy_f    <='1' ;
						data_mac <= rx_data_mac_f(15 downto 8);
		when b4 =>
               rdy_f     <='0' ;
					  nxt_st<=b0;
					  enable_count<='0';
					  data_mac <= rx_data_mac_f(15 downto 8);
		when others =>
               	enable_count<='0';	
					  rdy_f  <='0' ;  	  
					  nxt_st<=b0;
			end case;
end process;	

--process(prt_st2,rx_data_rdy_s(1),count_delay2 )
                 
                       
--  begin
--    case prt_st2 is
--	 when b02 =>
--							  enable_count2   <=  '0';
--	                    rdy_s           <= '0';
--                     data_mac2              <= X"00";
--					     if (rx_data_rdy_s(1)='1')  	 then
--						  nxt_St2                 <= b12;
--							else
--							nxt_St2                <= b02;
							
--						end if;
						
--		when b12 =>
--                  nxt_st2          <=   b1s2; 
--                  enable_count2    <= '0';	
--					   rdy_s           <= '0';
--						data_mac2        <= rx_data_mac_s(7 downto 0);

                    
--		when b1s2 =>
--                  nxt_st2          <=   b22; 
--                  enable_count2    <= '0';	
--					   rdy_s           <= '1';
--				 		data_mac2        <= rx_data_mac_s(7 downto 0);

						  
						  
--     when b22 =>
--               rdy_s           <= '0';
--					enable_count2   <='1';
--					if word_length = X"08" then
--					  nxt_st2   <= b02;
--					  data_mac2 <= rx_data_mac_s(7 downto 0);
--					 elsif count_delay2 = X"13" then
--					     nxt_st2   <=b32;
--						  data_mac2 <= rx_data_mac_s(15 downto 8);
--                 else
--					  data_mac2              <= X"00";
--					     nxt_st2<=b22;
--					 end if;
--		when b32 => 	
--                 nxt_st2      <=b42;		
--					  enable_count2<='0'; 
--					    rdy_s    <='1' ;
--						data_mac2 <= rx_data_mac_s(15 downto 8);
--		when b42 =>
--               rdy_s     <='0' ;
--					  nxt_st2<=b02;
--					  enable_count2<='0';
--					  data_mac2 <= rx_data_mac_s(15 downto 8);
--		when others =>
--               	enable_count2<='0';	
--					  rdy_s  <='0' ;  	  
--					  nxt_st2<=b02;
--			end case;
--end process;


--process(prt_st3,rx_data_rdy_s(2),count_delay3 )
                 
                       
--  begin
--    case prt_st3 is
--	 when b03 =>
--							  enable_count3   <=  '0';
--	                    rdy_fb           <= '0';
--                     data_mac3              <= X"00";
--					     if (rx_data_rdy_s(2)='1')  	 then
--						  nxt_St3                 <= b13;
--							else
--							nxt_St3                <= b03;
							
--						end if;
						
--		when b13 =>
--                  nxt_st3          <=   b1s3; 
--                  enable_count3    <= '0';	
--					   rdy_fb           <= '0';
--						data_mac3        <= rx_data_mac_fb(7 downto 0);

                    
--		when b1s3 =>
--                  nxt_st3          <=   b23; 
--                  enable_count3    <= '0';	
--					   rdy_fb           <= '1';
--				 		data_mac3        <= rx_data_mac_fb(7 downto 0);

						  
						  
--     when b23 =>
--               rdy_fb           <= '0';
--					enable_count3   <='1';
--					if word_length = X"08" then
--					  nxt_st3   <= b03;
--					  data_mac3 <= rx_data_mac_fb(7 downto 0);
--					 elsif count_delay3 = X"13" then
--					     nxt_st3   <=b33;
--						  data_mac3 <= rx_data_mac_fb(15 downto 8);
--                 else
--					  data_mac3              <= X"00";
--					     nxt_st3   <=   b23;
--					 end if;
--		when b33 => 	
--                 nxt_st3      <=b43;		
--					  enable_count3<='0'; 
--					    rdy_fb    <='1' ;
--						data_mac3 <= rx_data_mac_fb(15 downto 8);
--		when b43 =>
--               rdy_fb     <='0' ;
--					  nxt_st3<=b03;
--					  enable_count3<='0';
--					  data_mac3 <= rx_data_mac_fb(15 downto 8);
--		when others =>
--               	enable_count3<='0';	
--					  rdy_fb  <='0' ;  	  
--					  nxt_st3 <= b03;
--			end case;
--end process;	

---------------------
--##########################
--##########################
--##############################3





process(CLK_UMC) is	
begin
if rising_edge(CLK_UMC) then
  if enable_count='1' then
     count_delay<=count_delay+1;
     elsif enable_count='0' then
    count_delay<=X"00";
	end if;
end if;
end process;	

process(CLK_UMC) is	
begin
if rising_edge(CLK_UMC) then
  if enable_count2='1' then
     count_delay2<=count_delay2+1;
     elsif enable_count2='0' then
    count_delay2<=X"00";
	end if;
end if;
end process;

process(CLK_UMC) is	
begin
if rising_edge(CLK_UMC) then
  if enable_count3='1' then
     count_delay3<=count_delay3+1;
     elsif enable_count3='0' then
    count_delay3<=X"00";
	end if;
end if;
end process;	
proc0_UMC : process(CLK_UMC) is
variable cnt_umc_v : std_logic_vector(7 downto 0) := x"00" ;
begin
  if rising_edge(CLK_UMC) then
    if (reset_update = '1') then
      cnt_umc_v := x"00";
    elsif (Data_Valid_UMC_s = '1') then 
      
      case cnt_umc_v is
        when x"00" =>
          Data_Valid_UMC1_s <= '1';
        when x"01" =>
          Data_Valid_UMC1_s <= '1';
        when others =>               
          Data_Valid_UMC1_s <= '0';
      end case;
        
      cnt_umc_v  := cnt_umc_v + 1;  
    end if;
  end if;
end process proc0_UMC;
    
    
end architecture UART_MAC_BRIDGE_TOP_a;


