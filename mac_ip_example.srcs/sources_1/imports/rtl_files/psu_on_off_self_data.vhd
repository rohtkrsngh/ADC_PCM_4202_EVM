
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

entity psu_on_off_self_data is
port ( clk          :   in std_logic;
       reset        :   in std_logic;
       valid        :   in  std_logic;
		 pw_select    :	in	std_logic_vector(23 downto 0);
		 default_data :   in  std_logic_vector(7 downto 0);
		 tx_out       :   out std_logic_vector(7 downto 0));
end psu_on_off_self_data;

architecture Behavioral of psu_on_off_self_data is
signal count_data  :  std_logic_vector(7 downto 0) := (others => '0');
signal din_reg  :  std_logic_vector(7 downto 0) ;

type rx_type is (id,s0,s1,f_st,ff_st,fff_st);
signal prs,nxt						: rx_type;
signal en_wait_count: std_logic;
Signal wait_count  :  std_logic_vector(3 downto 0) := X"0";
begin


process(clk,reset)
           begin
			  if reset='1' then
			  prs<=id;
           elsif rising_edge(	clk) then
             prs<=nxt;
				end if;
 end process ;
 
 process(prs, valid, wait_count)
	begin
case prs is
  when	id => 
  
    en_wait_count   <=  '0';
	  din_reg	     <=  default_data;
     if valid	=	'1'	then
  	--   din_reg   <=  pw_select(15 downto 8);
		nxt	<=	s0;
     else
		nxt	<=	id;
	  end if;	
     		
when  s0	=>
     en_wait_count   <=  '1';
	  din_reg	     <=  default_data;
	  if  wait_count > X"E" then
  --   din_reg   <=  pw_select(7 downto 0);
     nxt	      <=	s1;
	  else
	  nxt	      <=	s0;
	  end if;
 when s1 =>
    en_wait_count   <=  '0';
     if valid	=	'1'	then
  	   din_reg   <=  pw_select(23 downto 16);
		nxt	<=	fff_st;
     else
      din_reg	 <=  default_data;
		nxt	<=	s1;
	  end if;	

when  fff_St	=>
    en_wait_count   <=  '0';
     din_reg   <=  pw_select(15 downto 8);
     nxt	      <=	ff_st;    		
when  ff_St	=>
     din_reg   <=  pw_select(7 downto 0);
     nxt	      <=	f_st;
	  
when f_st   =>
    en_wait_count   <=  '0';
	  if valid	=	'1'	then
  	   din_reg   <=  default_data;
		nxt	<=	f_st;
     else
      din_reg	 <=  default_data;
		nxt	<=	id;
	  end if;
end case;
end process;

process(clk)
begin
if rising_Edge(clk) then
	tx_out  <=  din_reg;
end if;
end process;	


process(clk)
begin
if rising_Edge(clk) then
 if en_wait_count   =  '1' then
  wait_count  <=  wait_count +1;
  else
  wait_count     <=   (others => '0');
 end if;	 
 end if;
end process; 
	  
end Behavioral;

