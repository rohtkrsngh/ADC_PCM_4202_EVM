----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:43:22 01/29/2018 
-- Design Name: 
-- Module Name:    reset_generator - Behavioral 
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

entity pcpu_gen is
port ( clk ,reset_in   : in std_logic;
       reset_enable  : in  std_logic;
         reset_out     : out std_logic);
end pcpu_gen;

architecture Behavioral of pcpu_gen is
signal count  : std_logic_vector(31 downto 0):=(others=>'0');
signal enable ,rst  : std_logic;
type state is ( s0,s1,s2,s3);
signal pre , nxt  : state ;
begin

process(clk, reset_in)
begin
if reset_in = '1'	then
pre  <= s0 ;
elsif rising_edge(clk) then
pre  <= nxt ;

end if;
end process;

process(pre , count , reset_enable)
begin
case pre is

   when  s0 =>
	            enable <= '0' ;
					rst    <= '0' ;
					if reset_enable = '1' then
					 nxt  <=  s1 ;
					else
                nxt  <=  s0;
               end if;
  when s1   =>
              enable <= '1';
				  rst <=  '1';
				  if count < X"1312D00" then   -- 10ms(f4240) 
				                             -- 200ms(1312D00)
				                             --500ms (2FAF080)
				  nxt  <=  s1 ;              --1s(5F5E100)
					else                     --5s(1DCD6500)
                nxt  <=  s2;
               end if;
  when  s2   =>
               enable <= '0' ;
					rst    <= '0' ;
             	if reset_enable = '1' then
					 nxt  <=  s2 ;
					else
                nxt  <=  s3;
               end if;	

when s3     =>
					enable <= '0' ;
					rst    <= '0' ;
					nxt    <=  s0 ;
end case;					
end process;

process(clk)
begin
if rising_edge(clk) then
if enable = '1' then
 count  <= count +1;
else
count <=(others=> '0');
end if;
end if;
end process;
 
 process(clk, reset_in)
begin
if reset_in = '1'	then
reset_out <= '0';
elsif rising_edge(clk) then
 reset_out <= rst;
 end if;
 end process;
end Behavioral;
