----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:23:24 11/07/2017 
-- Design Name: 
-- Module Name:    sob_self_gen - Behavioral 
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
use IEEE.STD_LOGIC_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity trp_self_gen is
port(clk,reset,sob_fb,valid: in std_logic; sob_self_test,data_valid_umc_sob:out std_logic);
end trp_self_gen;

architecture Behavioral of trp_self_gen is
type rx_type is (id,f_st,ff_st,s_st,t_st, f2_st);
signal prs,nxt						: rx_type;
signal en_cnt, en_cnt2: std_logic;
signal cnt: std_logic_vector(7 downto 0):=X"00";
signal cnt2: std_logic_vector( 23 downto 0):=X"000000";
signal sob_self_test_Q      :  std_logic;
signal data_valid_umc_sob_Q : std_logic;

begin

 process(clk,reset)
           begin
			  if reset='1' then
			  prs<=id;
           elsif rising_edge(	clk) then
             prs<=nxt;
				  sob_self_test  <=  sob_self_test_Q;
				 data_valid_umc_sob  <=  data_valid_umc_sob_Q;
				end if;
 end process ;
 
 process(prs,valid,sob_fb,cnt, cnt2)
	begin
case prs is
  when	id =>   
                 sob_self_test_q<='0';
                 data_valid_umc_sob_q<='0';
					  	en_cnt<='0';
						en_cnt2<='0';
           if valid='1' then
               -- if sob_fb='1' then
					 nxt<=ff_st;
					 else
					 nxt<=id;
                end if;
   
when  ff_st =>
                  sob_self_test_q<='0';
                 data_valid_umc_sob_q<='0';
					  	en_cnt<='0';
						en_cnt2<='1';
       if cnt2 < X"7A1200" then 
		 
                if sob_fb='0' then
					 en_cnt2<='0';
					 nxt<=f2_st;
					 else
					 en_cnt2<='1';
					 nxt<=ff_st;
                end if;
		else 			 
			nxt<=id;
			en_cnt2<='0';
                end if;		 
					 
					 
when  f2_st =>
                  sob_self_test_q<='0';
                 data_valid_umc_sob_q<='0';
					  	en_cnt<='0';
 if cnt2 < X"7A1200" then 
                if sob_fb='1' then
					 nxt<=f_st;
					  en_cnt2<='0';
					 else
					  en_cnt2<='1';
					 nxt<=f2_st;
                end if;	
else 			 
			nxt<=id;
			en_cnt2<='0';
                end if;					 
	
	when  f_st =>
                 sob_self_test_q <='1';
                  data_valid_umc_sob_q<='1';
				en_cnt2<='0';
						en_cnt<='1';
						nxt<=s_st;
						
	when  s_st =>
                 sob_self_test_q <='1';
                  data_valid_umc_sob_q<='0';
						if cnt=X"35" then
							en_cnt<='0';
							nxt<=t_st;					
							else
						en_cnt<='1';
						nxt<=s_st;					

						end if;
		when  t_st =>
                 sob_self_test_q <='0';
                  data_valid_umc_sob_q<='0';
						en_cnt<='0';
						en_cnt2<='0';
						if valid ='0' then
     						nxt<=id;			
                  else
                      nxt<=t_st;			
						end if;
end case;
					  
end process;

process(clk) 
begin
if rising_edge(clk) then
 if en_cnt='1' then
  cnt<=cnt+1;
  else
  cnt<=X"00";
  end if;
  end if;
 end process;

process(clk) 
begin
if rising_edge(clk) then
 if en_cnt2='1' then
  cnt2 <= cnt2+1;
  else
  cnt2<=X"000000";
  end if;
  end if;
 end process;
end Behavioral;

