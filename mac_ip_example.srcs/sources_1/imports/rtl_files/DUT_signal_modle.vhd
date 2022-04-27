----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:36:39 10/12/2018 
-- Design Name: 
-- Module Name:    DUT_signal_modle - Behavioral 
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

entity DUT_signal_modle is
port ( clk  					:		in		std_logic;
		 reset					:		in		std_logic;
       clk_100             :		in		std_logic;
		 
		 en_monitor_enable	:	in	std_logic;
		 val_monitor_enable	:	in	std_logic_vector(7 downto 0);
		 
		 en_PSU_On				:	in	std_logic;
		 val_PSU_ON				:	in	std_logic_vector(7 downto 0);
		 
		 en_PSU_off				:	in	std_logic;
		 val_psu_off			:	in	std_logic_vector(7 downto 0);
		 
		 en_Self_monitor_txd	:	in	std_logic;
		 val_self_monitor_txd:	in	std_logic_vector(7 downto 0);
		 
		 monitor_enable		:	out	std_logic;
		 trm_psu_on				:	out	std_logic;
		 trm_psu_off			:	out	std_logic;
		 self_monitor_txd		:	out	std_logic);
		 
end DUT_signal_modle;

architecture Behavioral of DUT_signal_modle is

component psu_on_off_100ms is
port ( clk ,reset_in   : in std_logic;
       reset_enable  : in  std_logic;
         reset_out     : out std_logic);
end component;

SIGNAL  psu_on_sig 		:		std_logic;
SIGNAL  psu_off_sig		:		std_logic;

begin


process(clk)
begin

 if reset = '1' then
	self_monitor_txd		<=		'0';
elsif rising_Edge(clk) then	
   if  en_Self_monitor_txd	=	'1'	then
     if	val_self_monitor_txd	=	X"FF"	THEN
	     self_monitor_txd		<=		'1';
	  elsif	val_self_monitor_txd	=	X"00"	THEN
	     self_monitor_txd		<=		'0';  
	  end if;
 end if;
end if;
end process; 





process(clk, reset)
begin
 if reset = '1' then
	monitor_enable		<=		'0';
elsif rising_Edge(clk) then

 if  en_monitor_enable	=	'1'	then
     if	val_monitor_enable	=	X"FF"	THEN
	     monitor_enable		<=		'1';
	  elsif	val_monitor_enable	=	X"00"	THEN
	     monitor_enable		<=		'0';  
	  end if;
 end if;
end if;
end process; 


process(clk_100, reset)
begin
 if reset = '1' then
	trm_psu_on		<=		'0';
elsif rising_Edge(clk_100) then
   trm_psu_on		<=		psu_on_sig;  
end if;
end process;

process(clk_100, reset)
begin
if reset = '1' then
trm_psu_off		<=		'0';
elsif rising_Edge(clk_100) then
trm_psu_off		<=  psu_off_sig;
end if;
end process; 


  

U_psu_on :  psu_on_off_100ms port map( 
                                clk       	 =>  clk_100,
										  reset_in 		 =>  reset,
										  reset_enable	 =>  en_PSU_On,
										  reset_out 	 =>  psu_on_sig    );

U_psu_off :  psu_on_off_100ms port map( 
                                clk       	 =>  clk_100,
										  reset_in 		 =>  reset,
										  reset_enable	 =>  en_PSU_OFF,
										  reset_out 	 =>  psu_off_sig    );

  
end Behavioral;

