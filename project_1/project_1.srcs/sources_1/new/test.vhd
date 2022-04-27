----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/09/2019 11:49:17 AM
-- Design Name: 
-- Module Name: test - Behavioral
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
use IEEE.STD_LOGIC_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity test is
  Port (clk_p ,clk_n : in std_logic;
         led_out : out std_logic );
end test;

architecture Behavioral of test is
signal count : std_logic_Vector(31 downto 0) := (others => '0');
signal clk : std_logic;

begin

clk_buf : IBUFDS port map
 ( O => clk,
   I => clk_p,
   IB => clk_n);


process(clk)
begin
if rising_edge(clk) then
count <= count + '1';
end if;
end process;

process(clk)
begin
if rising_edge(clk) then
if count > X"3B9ACA00" then  --77359400
led_out <= '1';
else
led_out <= '0';
end if;
end if;
end process;

end Behavioral;
