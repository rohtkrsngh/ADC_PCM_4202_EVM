----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:49:00 10/12/2018 
-- Design Name: 
-- Module Name:    signal_status_test - Behavioral 
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

entity signal_status_test is
    Port ( clk 			: in  STD_LOGIC;
           reset 			: in  STD_LOGIC;
           en_check 		: in  STD_LOGIC;
           signal_in    : in  STD_LOGIC;
           valid_pkt    : out  STD_LOGIC;
           status_val   : out  STD_LOGIC_VECTOR (3 downto 0));
end signal_status_test;

architecture Behavioral of signal_status_test is

type rx_type is (id,f_st,ff_st,s_st,t_st,f2_st,s2_st);
signal prs,nxt						: rx_type;
signal en_cnt: std_logic;
signal cnt          : std_logic_vector(7 downto 0):=X"00";
signal status_val_s : std_logic_vector(3 downto 0):=X"0";
signal valid_pkt_s      :  std_logic;
--signal data_valid_umc_sob_Q : std_logic;
begin

 process(clk,reset)
   begin
  if reset='1' then
  prs<=id;
   elsif rising_edge(	clk) then
     prs<=nxt;
	end if;
 end process ;
 
 process(prs,en_check,signal_in,cnt)
	begin
case prs is
  when	id =>   
                 status_val_s	<=	X"0";
                 valid_pkt_s	   <=	'0';
					  	en_cnt	   <=	'0';
           if en_check='1' then
					 nxt<=ff_st;
					 else
					 nxt<=id;
                end if;
			
  
when  ff_st =>
                  status_val_s	<=	X"0";
                 valid_pkt_s	   <=	'0';
					  	en_cnt<='0';

                if signal_in='0' then
					 nxt<=f_st;
					 elsif signal_in='1' then
					 nxt<=f2_st;
					 else
					 nxt<=id;
                end if;
	
	when  f_st =>
                 status_val_s	<=	X"2";
                 valid_pkt_s	   <=	'1';
				
						en_cnt<='1';
						nxt<=s_st;
						
	when  s_st =>
                 status_val_s	   <=	X"2";
                 valid_pkt_s	   <=	'1';
						if cnt=X"35" then
							en_cnt<='0';
							nxt<=t_st;					
							else
						en_cnt<='1';
						nxt<=s_st;					

						end if;
						
	when  f2_st =>
                 status_val_s	<=	X"1";
                 valid_pkt_s	   <=	'1';
				
						en_cnt<='1';
						nxt<=s2_st;	
when  s2_st =>
                 status_val_s	   <=	X"1";
                 valid_pkt_s	   <=	'1';
						if cnt=X"21" then
							en_cnt<='0';
							nxt<=t_st;					
							else
						en_cnt<='1';
						nxt<=s2_st;					

						end if;						
						
		when  t_st =>
                  status_val_s	<=	X"0";
                 valid_pkt_s	   <=	'0';
						en_cnt<='0';
						if en_check ='0' then
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
    status_val	   <=	status_val_s;
   valid_pkt	   <=	valid_pkt_s;
end if;					  
end process;			   
end Behavioral;

