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

entity reset_inter_sys is
port ( clk    : in std_logic;
         reset_out     : out std_logic);
end reset_inter_sys;

architecture Behavioral of reset_inter_sys is
signal count  : std_logic_vector(7 downto 0):=(others=>'0');
signal enable ,rst  : std_logic;
type state is ( s0,s1,s2);
signal pre , nxt  : state ;
begin

process(clk)
begin
if rising_edge(clk) then
pre  <= nxt ;
else
pre  <= pre ;
end if;
end process;

process(pre , count )
begin
case pre is

   when  s0 =>
	            enable <= '1' ;
					rst    <= '1' ;
					--if reset_in = '1' then
					 nxt  <=  s1 ;
--					else
--                nxt  <=  s0;
--               end if;
  when s1   =>
              enable <= '1';
				  rst <=  '1';
				  if count < X"F4" then
				  nxt  <=  s1 ;
					else
                nxt  <=  s2;
               end if;
  when  s2   =>
               enable <= '0' ;
					rst    <= '0' ;
             --	if reset_in = '1' then
					 nxt  <=  s2 ;
--					else
--                nxt  <=  s3;
--               end if;	

--when s3     =>
--					enable <= '0' ;
--					rst    <= '0' ;
--					nxt    <=  s0 ;
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
 
 process(clk)
begin
if rising_edge(clk) then
 reset_out <= rst;
 end if;
 end process;
end Behavioral;

