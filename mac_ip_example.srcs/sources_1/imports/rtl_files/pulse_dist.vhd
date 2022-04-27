----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:00:17 08/14/2017 
-- Design Name: 
-- Module Name:    pulse_dist - Behavioral 
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
--use IEEE.STD_LOGIC_arith.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pulse_dist is
port(clk,enable_ref,enable_rf1,enable_rf2,enable_rf3,reset_in,
     enable_rf4,enable_rf5,enable_rf6,enable_rf7,enable_rf8,enable_trp: in std_logic; 
	  beam_ini_gap	: in std_logic_vector(7 downto 0);	
beam_hop_gap	: in std_logic_vector(7 downto 0);
	   PRT: in std_logic_vector(31 downto 0);
		 P_W_TRP: in std_logic_vector(15 downto 0);
		 start_trp: in std_logic_vector(31 downto 0); 
		 P_W_RF1: in std_logic_vector(15 downto 0);
		 start_RF1: in std_logic_vector(31 downto 0); 
		 P_W_RF2: in std_logic_vector(15 downto 0);
		 start_RF2: in std_logic_vector(31 downto 0);
		 P_W_RF3: in std_logic_vector(15 downto 0);
		 start_RF3: in std_logic_vector(31 downto 0);
		 P_W_RF4: in std_logic_vector(15 downto 0);
		 start_RF4: in std_logic_vector(31 downto 0);
		 P_W_RF5: in std_logic_vector(15 downto 0);
		 start_RF5: in std_logic_vector(31 downto 0);
		 P_W_RF6: in std_logic_vector(15 downto 0);
		 start_RF6: in std_logic_vector(31 downto 0);
		 P_W_RF7: in std_logic_vector(15 downto 0);
		 start_RF7: in std_logic_vector(31 downto 0);
		 P_W_RF8: in std_logic_vector(15 downto 0);
		 start_RF8: in std_logic_vector(31 downto 0);
		 rf_p: out std_logic_vector(7 downto 0);
		 trp_p: out std_logic
		 
		 );
end pulse_dist;

architecture Behavioral of pulse_dist is
component ref_p
port(clk,enable,reset_in: in std_logic; PRT: in std_logic_vector(31 downto 0);
       ref_clk: out std_logic);

end component;
component rf1_Pulse
port(clk,enable,ref_sig, reset_in: in std_logic; 
       P_W_TRP: in std_logic_vector(15 downto 0);
		 start_trp: in std_logic_vector(31 downto 0); 
		 rf_p: out std_logic);
end component;
component trp_pulse
port(clk,enable,ref_sig, reset_in: in std_logic;
         P_W_TRP: in std_logic_vector(15 downto 0);
			start_trp: in std_logic_vector(31 downto 0); 
			trp_p: out std_logic);
end component;
component Trig_Pulse_gen
port(clk,enable,ref_sig, reset_in: in std_logic; 
       P_W_TRP: in std_logic_vector(15 downto 0);
		 start_trp: in std_logic_vector(31 downto 0); 
		 rf_p: out std_logic);
end component;
signal enable_count: std_logic;
signal enable_count2: std_logic;

signal ref_Sig1: std_logic;
signal srf_p   :  std_logic_vector(7 downto 0); 
signal  count_value_ref_pulse  :   std_logic_vector(15 downto 0);  
type TX_TYPE is (S0,S1);
SIGNAL P_S:TX_TYPE;
SIGNAL N_S:TX_TYPE;
signal  count_value_ref_pulse2  :   std_logic_vector(7 downto 0);  
type TX_TYPE2 is (S02,S12);
SIGNAL P_S2:TX_TYPE2;
SIGNAL N_S2:TX_TYPE2;

signal  multi_result  : signed (15 downto 0);
signal  beam_ini_plus  :  std_logic_vector(7 downto 0);
signal  multi_result_std  :  std_logic_vector(15 downto 0);
begin

beam_ini_plus  <=  beam_ini_gap + '1';


multi_result  <=  ((signed(beam_ini_plus)* signed(beam_hop_gap) )+ signed(beam_ini_gap));
multi_result_std <= std_logic_vector(multi_result); 

u0: ref_p port map (clk,enable_ref, reset_in,prt,ref_sig1);
u1: trp_pulse port map(clk,enable_trp,ref_sig1, reset_in,P_W_trp,start_trp,trp_p);
u2: rf1_pulse port map(clk,enable_rf1,ref_sig1, reset_in,P_W_rf1,start_rf1,srf_p(0));
u3: rf1_pulse port map(clk,enable_rf2,ref_sig1, reset_in,P_W_rf2,start_rf2,srf_p(1));
u4: rf1_pulse port map(clk,enable_rf3,ref_sig1, reset_in,P_W_rf3,start_rf3,srf_p(2));
u5: Trig_Pulse_gen port map(clk,enable_rf4,ref_sig1, reset_in,P_W_rf4,start_rf4,srf_p(3));
u6: Trig_Pulse_gen port map(clk,enable_rf5,ref_sig1, reset_in,P_W_rf5,start_rf5,srf_p(4));
u7: Trig_Pulse_gen port map(clk,enable_rf6,ref_sig1, reset_in,P_W_rf6,start_rf6,srf_p(5));
u8: Trig_Pulse_gen port map(clk,enable_rf7,ref_sig1, reset_in,P_W_rf7,start_rf7,srf_p(6));
u9: Trig_Pulse_gen port map(clk,enable_rf8,ref_sig1, reset_in,P_W_rf8,start_rf8,srf_p(7));


PROCESS(clk, reset_in) IS
BEGIN
IF(reset_in='1') THEN
P_S<=S0;
elsIF RISING_EDGE(clk) THEN
P_S<=N_S;
END IF;
--end if;
END PROCESS P1;
----------------------------------------------------------#############
P2:PROCESS(P_S, enable_ref, count_value_ref_pulse)
begin
CASE P_S IS 
    when S0  =>
	   enable_count <= '0';
	   if enable_ref = '1' then
		 N_S <= S1;
       ELSE
		 N_S <= S0;
      END IF;
	when s1 =>
	 	   enable_count <= '1';
		 if enable_ref = '0' then
		 N_S <= S0;
	    elsif (count_value_ref_pulse > beam_ini_gap ) then --multi_result_std  ) then
	    N_S <= S0;
       ELSe
		 N_S <= S1;
		end if;
    end case;
end process;

process(clk)	
begin 
   if rising_edge(clk) then
  	  if enable_count = '1' then
	   if ref_sig1 = '1' then
		  count_value_ref_pulse  <=  count_value_ref_pulse + '1';
		 end if;
     else
    	 count_value_ref_pulse  <=  X"0000";
     end if;
end if;
end process;	


PROCESS(clk, reset_in) IS
BEGIN
IF(reset_in='1') THEN
P_S2<=S02;
elsIF RISING_EDGE(clk) THEN
P_S2<=N_S2;
END IF;
--end if;
END PROCESS ;
----------------------------------------------------------#############
PROCESS(P_S2, enable_ref, count_value_ref_pulse2)
begin
CASE P_S2 IS 
    when S02  =>
	   enable_count2 <= '0';
	   if enable_ref = '1' then
		 N_S2 <= S12;
       ELSE
		 N_S2 <= S02;
      END IF;
	when s12 =>
	 	   enable_count2 <= '1';
			if enable_ref = '0' then
		 N_S2 <= S02;
	  elsif (count_value_ref_pulse2 > beam_hop_gap  ) then
	   N_S2 <= S02;
       ELSE
		 N_S2 <= S12;
		end if;
    end case;
end process;

process(clk)	
begin 
   if rising_edge(clk) then
  	  if enable_count2 = '1' then
	   if ref_sig1 = '1' then
		  count_value_ref_pulse2  <=  count_value_ref_pulse2 + '1';
		 end if;
     else
    	 count_value_ref_pulse2  <=  X"00";
     end if;
end if;
end process;	

multi_result  <=  ((signed(beam_ini_gap + '1')* signed(beam_hop_gap) )+ signed(beam_ini_gap));

  
process(clk)	
begin 
   if rising_edge(clk) then
	  rf_p(0)    <=   srf_p(0);
	  rf_p(1)    <=   srf_p(1);
	  rf_p(2)    <=   srf_p(2);
	  rf_p(5)    <=   srf_p(5);
	  rf_p(6)    <=   srf_p(6);
	  rf_p(7)    <=   srf_p(7);
	  
	 if (count_value_ref_pulse = beam_ini_gap ) then --std_logic_vector(multi_result)  ) then
	  rf_p(3)    <=  srf_p(3);
	  else
	  rf_p(3)    <=   '0';
	  end if;
	   if (count_value_ref_pulse2 = beam_hop_gap  ) then
	  rf_p(4)    <=  srf_p(4);
	  else
     rf_p(4)    <=   '0';
	  end if;
	  
	end if;
end process;	
end Behavioral;






