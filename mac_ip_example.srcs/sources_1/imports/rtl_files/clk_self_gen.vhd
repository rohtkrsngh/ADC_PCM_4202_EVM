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

entity clk_self_gen is
port(clk,reset,sob_fb,valid: in std_logic; sob_self_test,data_valid_umc_sob:out std_logic);
end clk_self_gen;

architecture Behavioral of clk_self_gen is
type rx_type is (id,f_st,ff_st,s_st,t_st);
signal prs,nxt						: rx_type;
signal en_cnt: std_logic;
signal cnt: std_logic_vector(7 downto 0):=X"00";
signal cnt2: std_logic_vector(7 downto 0):=X"00";
signal sob_self_test_Q      :  std_logic;
signal data_valid_umc_sob_Q : std_logic;
signal en_wait   :   std_logic;
signal wait_count  :   std_logic_vector(19 downto 0):=X"00000";
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
 
 
 process(prs,valid,sob_fb,cnt, wait_count)
	begin
case prs is
  when	id =>   
                 sob_self_test_q<='0';
                 data_valid_umc_sob_q<='0';
					  	en_cnt<='0';
						en_wait <= '0';
           if valid='1' then
                if sob_fb='0' then
					 nxt<=f_st;
					 else
					 nxt<=id;
                end if;
	else
	     						nxt<=id;			
   end if;
when  ff_st =>
                  sob_self_test_q<='0';
                 data_valid_umc_sob_q<='0';
					  	en_cnt<='0';
                 en_wait <=  '0';
                if sob_fb='1' then
					 nxt<=id;
					 else
					 nxt<=ff_st;
                end if;
	
	when  f_st =>
                 sob_self_test_q <='1';
                  data_valid_umc_sob_q<='1';
                 en_wait <=  '0';
						en_cnt<='1';
						nxt<=s_st;
						
	when  s_st =>
                 sob_self_test_q <='1';
                  data_valid_umc_sob_q<='0';
	                 en_wait <=  '0';
					
						if cnt=X"2E" then
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
						if sob_fb ='1' then
						  en_wait <=  '1';
						    if wait_count  = X"1E848" then
      						nxt<=id;			
                       else
                       nxt<=t_st;			
						     end if;
					   else
						 en_wait <=  '0';
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
if  en_wait  =  '1' then
  wait_count  <=  wait_count + '1';
 else
 wait_count  <=  (others => '0');
 end if;
end if;
end process; 
end Behavioral;

