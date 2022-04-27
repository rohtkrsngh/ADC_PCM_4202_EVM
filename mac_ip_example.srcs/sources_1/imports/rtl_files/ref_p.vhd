----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:09:14 08/08/2017 
-- Design Name: 
-- Module Name:    ref_p - Behavioral 
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

entity ref_p is
port(clk,enable, reset_in: in std_logic; PRT: in std_logic_vector(31 downto 0);
       ref_clk: out std_logic);
end ref_p;

architecture Behavioral of ref_p is
signal cnt: natural:=0;
--signal s_prt : std_logic_vector(7 downto 0 ):=(others=>'0');
signal one_us: std_logic:='0';
signal cnt_us: std_logic_vector( 31 downto 0):=(others=> '0');
type TX_TYPE is (S0,S1,s2,S3);
SIGNAL P_S:TX_TYPE;
SIGNAL N_S:TX_TYPE;
signal COUNT:natural:=124;
signal enable_1: std_logic:='0';
signal enable_2: std_logic:='0';

signal s_ref_clk: std_logic:='0';
begin


  P1:PROCESS(clk, reset_in) IS
BEGIN
IF(reset_in='1') THEN
P_S<=S0;
elsIF(RISING_EDGE(clk)) THEN
P_S<=N_S;
END IF;
--end if;
END PROCESS P1;
----------------------------------------------------------#############
P2:PROCESS(P_S,N_S,COUNT,cnt_us,enable,one_us)IS
BEGIN
  CASE P_S IS 
    
    when S0  =>
	   enable_1 <='0';
	   enable_2 <='0';
          IF (enable = '1') THEN
                N_S <= S1;
          ELSE
                N_S <= S0;
          END IF;
      
    WHEN S1 =>
	   enable_1 <='1';
	   enable_2 <='0';
	   s_ref_clk<='1';
		    
--          IF(COUNT=123)THEN
--			   -- ref_clk<='1';
		       N_S<=S2;
--          ELSE 
--		       N_S<=S1;
--		    END IF;
	
	when s2=>
	    enable_1 <='0';
		 enable_2 <='1';
       s_ref_clk<='0';
		    if (enable = '0') then
		       N_S<=s0;
		    elsif cnt_us=prt-3 then
		       N_S<=S3;
		    else
		 		 N_S<=S2;
         end if;
  when s3 =>
       enable_2<='1';
		-- if one_us='1' then
       	N_S<=S1;	 
		--	else
		--	N_S<=S3;
      -- end if;
   END CASE ;
END PROCESS P2;
 ----------------------------------------------------------------
--process(clk)
--begin
--if rising_edge(clk) then
--if enable_1 = '1' then
--  if count<=123 then
--  count<=count+1;
-- else
--  count<=0;
--  end if;
--  else
--  count<=124;
-- end if;
--
-- end if;
-- end process;
--------------------------------------------------------------------
--process(clk)
--begin
--if rising_edge(clk) then
--if enable_2 = '1' then
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
 if enable_2='1' then
  -- if one_us='1'  then
      if cnt_us<PRT-2 then
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
-----------------------------------------------------------------------

-------------------------------------------------------------------  

ref_clk<=s_ref_clk;

  
end Behavioral;

