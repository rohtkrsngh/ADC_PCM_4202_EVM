
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

library UNISIM;
use UNISIM.VComponents.all;


entity sel_clk_Mod is
port
 (  --inputs
  i_reset         :  in std_logic;
  i_clk_200       :  in std_logic;
  i_clk_125       :  in std_logic;
  self_rx_en      : in std_logic;
  rx_sclk         : out std_logic;
  o_sclk          : out std_logic
  );
  
end sel_clk_Mod;

architecture Behavioral of sel_clk_Mod is


component DCM_last
port
 (-- Clock in ports
  CLK_IN1           : in     std_logic;
  -- Clock out ports
  CLK_OUT1          : out    std_logic;
  CLK_OUT2          : out    std_logic;
  -- Status and control signals
  RESET             : in     std_logic;
  LOCKED            : out    std_logic
 );
end component;

 -- Clock out ports
 signal  clk_100T   :     std_logic;
 
 signal  Din_valid      :   std_logic_vector(7 downto 0);         


 signal  clk_div         :   std_logic_Vector(4 downto 0);   

 SIGNAL  count_clk_div   :   std_logic_vector(11 downto 0) := (others => '0');
 SIGNAL  count_clk_div2  :   std_logic_vector(11 downto 0) := (others => '0');
 SIGNAL  rx_full_count  :   std_logic_vector(11 downto 0) := (others => '0');
 SIGNAL  rx_half_count  :   std_logic_vector(11 downto 0) := (others => '0');
 signal CLK_10T         : std_logic;
begin


process(i_clk_125) 
begin
 if rising_Edge(i_clk_125) then
  if self_rx_en = '1' then
   rx_full_count <= "000011000111";
   rx_half_count <= "000001100100";
  else
   rx_full_count <= "000110001111";
   rx_half_count <= "000011001000" ;
  end if;
 end if;
 end process;    


process(clk_100T) 
begin
 if rising_Edge(clk_100T) then
 if count_clk_div < "11111001111" then  --11111001111
  count_clk_div  <= count_clk_div + '1';
  else
  count_clk_div  <= (others => '0');
  end if; 
  
 end if;
end process; 

process(clk_100T) 
begin
 if rising_Edge(clk_100T) then
   if count_clk_div  < "1111101000"  then  ---1111101000
	   o_sclk  <= '0';
	else
	   o_sclk  <= '1';
	end if;
 end if;
end process; 



process(clk_100T) 
begin
 if rising_Edge(clk_100T) then
 if count_clk_div2 < rx_full_count then  --11000111
  count_clk_div2  <= count_clk_div2 + '1';
  else
  count_clk_div2  <= (others => '0');
  end if; 
  
 end if;
end process;
--rx_sclk <= count_clk_div2(0);

process(clk_100T) 
begin
 if rising_Edge(clk_100T) then
   if count_clk_div2  < rx_half_count  then  ---1100100
	   rx_sclk  <= '0';
	else
	   rx_sclk  <= '1';
	end if;
 end if;
end process; 


DCM_100X70: DCM_last
  port map
   (-- Clock in ports
    CLK_IN1 => i_clk_200,
    -- Clock out ports
    CLK_OUT1 => clk_100T,  --20MHZ
    CLK_OUT2 => CLK_10T,
    -- Status and control signals
    RESET  => i_reset,
    LOCKED => open);



end Behavioral;

