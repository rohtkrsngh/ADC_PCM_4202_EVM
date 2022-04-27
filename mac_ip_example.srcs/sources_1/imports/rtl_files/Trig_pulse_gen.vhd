----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:27:19 08/16/2017 
-- Design Name: 
-- Module Name:    RF1_Pulse - Behavioral 
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

entity Trig_Pulse_gen is
port(clk,enable,ref_sig, reset_in: in std_logic; 
       P_W_TRP: in std_logic_vector(15 downto 0);
		 start_trp: in std_logic_vector(31 downto 0); 
		 rf_p: out std_logic);

end Trig_Pulse_gen;

architecture Behavioral of Trig_Pulse_gen is

signal cnt: natural:=0;
signal one_us: std_logic:='0';
signal cnt_us: std_logic_vector( 31 downto 0):=(others=> '0');
type TX_TYPE is (S0,S1,s2,s4,s5);
SIGNAL P_S:TX_TYPE;
SIGNAL N_S:TX_TYPE;
signal enable_1: std_logic:='0';
signal enable_2: std_logic:='0';
signal rst: std_logic:='0';
signal cnt2: natural:=0;
signal one_us2: std_logic:='0';
signal cnt_us2: std_logic_vector( 15 downto 0):=(others=> '0');
signal trp_sig: std_logic:='0';

begin
rf_p<=trp_sig;
P1:PROCESS(clk, reset_in) IS
BEGIN
IF(reset_in='1') THEN
P_S<=S0;
elsIF RISING_EDGE(clk) THEN
P_S<=N_S;
END IF;

END PROCESS P1;
----------------------------------------------------------#############
P2:PROCESS(P_S,N_S,cnt_us,cnt_us2,enable,one_us,ref_sig,one_us2)IS
BEGIN
  CASE P_S IS 
    
    when S0  =>
	 	TRP_sig<= '0';

	   enable_1 <='0';
	   enable_2 <='0';
          IF (enable = '1' and ref_sig='0') THEN
                N_S <= S1;
          ELSE
                N_S <= S0;
          END IF;
      
    WHEN S1 =>
	   TRP_sig<= '0';
	   
	   enable_2 <='0';
		if (enable = '0') then
		       N_S<=s0;
		    elsif ref_sig='1' then
          enable_1 <='1';
			 N_S<=S2;
			 else
			 enable_1 <='0';

			 N_S<=S1;
			 end if;
	
	when s2=>
	    TRP_sig<= '0';
       enable_1 <='1';
		 enable_2 <='0';
		    if (enable = '0') then
		       N_S<=s0;
		    elsif cnt_us=start_trp-1 then
		       N_S<=S4;--S3;  27 oct 11:50 AM
		    else
		 		 N_S<=S2;
         end if;
--  when s3 =>
--       enable_1<='1';
--		 if one_us='1' then
--       	N_S<=S4;	 
--			else
--			N_S<=S3;
--       end if;
 
   when s4=> 
        TRP_sig<= '1';
        enable_2 <='1';
		  enable_1 <='0';
		  if (enable = '0') then
		       N_S<=s0;
		    elsif cnt_us2=P_W_TRP-2 then  -- update^2
		       N_S<=S5;
		    else
		 		 N_S<=S4;
         end if;

	when s5=>
	        TRP_sig<= '1';

	     enable_2<='1';
--		 if one_us2='1' then
       	N_S<=S1;	 
--			else
--			N_S<=S5;
--       end if;
	
END CASE ;
	
	
END PROCESS P2;
	------------------------------------------------

-- process(clk)
--begin
--if rising_edge(clk) then
--if enable_1 = '1' then
--  if cnt<=123 then
--  cnt<=cnt+1;
-- else
--  cnt<=0;
--  end if;
--  else
--  cnt<=0;
-- end if;
-- end if;
-- end process;

---------------------------------------------
-- process(clk)
--begin
--if rising_edge(clk) then
--
--  if cnt=123 then
--  one_us <='1';
--		else
--		one_us<='0';
--		end if;
--		end if;
--  end process;
-----------------------------------------------------------------  
  process(clk)
begin
if rising_edge(clk) then
 if enable_1='1' then
  -- if one_us='1'  then
      if cnt_us<start_trp-1 then
      cnt_us<=cnt_us+1;
      else
      cnt_us<=X"00000000";
      end if;
  -- end if;
  else
  cnt_us<=X"00000000";
  end if; 
 end if;
 end process;
--------------------------------- 

-- process(clk)
--begin
--if rising_edge(clk) then
--if enable_2 = '1' then
--  if cnt2<=123 then
--  cnt2<=cnt2+1;
-- else
--  cnt2<=0;
--  end if;
--  else
--  cnt2<=0;
-- end if;
-- end if;
-- end process;

---------------------------------------------

---------------------------------------------
-- process(clk)
--begin
--if rising_edge(clk) then
--
--  if cnt2=123 then
--  one_us2 <='1';
--		else
--		one_us2<='0';
--		end if;
--		end if;
--  end process;
 ---------------------------- 
 process(clk)
begin
if rising_edge(clk) then
 if enable_2='1' then
  -- if one_us2='1'  then
      if cnt_us2<P_W_trp-1 then   --update
      cnt_us2<=cnt_us2+1;
      else
      cnt_us2<=X"0000";
      end if;
  -- end if;
  else
  cnt_us2<=X"0000";
  end if; 
 end if;
 end process;
---------------------------------   
  
end Behavioral;

