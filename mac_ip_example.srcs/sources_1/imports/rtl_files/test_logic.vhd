----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:53:50 03/13/2018 
-- Design Name: 
-- Module Name:    test_logic - Behavioral 
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

entity test_logic is
port (CLK_3MZH , rst , S_START_COUNT : in std_logic;
      oo  :  out std_logic);
end test_logic;

architecture Behavioral of test_logic is
signal S_DATA_COUNT  :  std_logic_Vector(5 downto 0); 
signal NUM_OF_SAMPL  :  std_logic_Vector(5 downto 0); 

begin
SERIAL_COUNT:PROCESS(CLK_3MZH,RST) 
  BEGIN
    IF(CLK_3MZH'EVENT AND CLK_3MZH = '1')THEN
	    IF(RST = '1')THEN
           S_DATA_COUNT <= "000000";
			  NUM_OF_SAMPL <= "000000";
       ELSIF(S_START_COUNT = '1')THEN
		    IF(S_DATA_COUNT = "111111")THEN
			    S_DATA_COUNT  <= "000000";
				 IF(NUM_OF_SAMPL = "101111")THEN
				   NUM_OF_SAMPL  <= "000000";
				 ELSE
				   NUM_OF_SAMPL  <= NUM_OF_SAMPL + 1;
				 END IF;			   
			 ELSE  
               S_DATA_COUNT  <= S_DATA_COUNT + 1;
          END IF;				
      ELSIF(S_START_COUNT = '0')THEN
		         S_DATA_COUNT <= "000000";
				   NUM_OF_SAMPL <= "000000";
	   END IF;
   END IF;
END PROCESS;

end Behavioral;

