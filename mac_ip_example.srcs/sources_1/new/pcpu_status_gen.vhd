
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

entity pcpu_status_gen is
port (   clk          :   in std_logic;
         reset        :   in std_logic;
         valid        :   in  std_logic;
		 dut_num      :   in  std_logic_vector(7 downto 0);
		 PCPU_status  :   in  std_logic;
		 valid_out    :   out std_logic;
		 tx_out       :   out std_logic_vector(7 downto 0));
end pcpu_status_gen;

architecture Behavioral of pcpu_status_gen is
signal count_data  :  std_logic_vector(7 downto 0) := (others => '0');
signal din_reg  :  std_logic_vector(7 downto 0) ;

type rx_type is (id,f_st,ff_st, s1, s2,s3,s4, f2_st,s1x, s2x,s3x,s4x);
signal prs,nxt						: rx_type;
signal en_wait_count: std_logic;
signal valid_out_sig : std_logic;
Signal wait_count  :  std_logic_vector(15 downto 0) := X"0000";

begin


process(clk,reset)
   begin
  if reset='1' then
  prs<=id;
   elsif rising_edge(	clk) then
     prs<=nxt;
	end if;
 end process ;
 
 process(prs, valid, wait_count, PCPU_status)
	begin
case prs is
  when	id => 
     en_wait_count   <=  '0';
	  din_reg	     <=  X"00";
	  valid_out_sig  <=  '0';
     if valid	=	'1'	then
		nxt	<=	ff_st;
     else
		nxt	<=	id;
	  end if;	
     		
when  ff_St	=>
     en_wait_count   <=  '1';
	  din_reg	     <=   X"00";
	  valid_out_sig  <=  '0';
	  if  wait_count < X"F000" then
	     if PCPU_status = '1' then
         nxt	      <=	f_st;
         else
         nxt	      <=	ff_st;
         end if;
	  else
	   nxt	      <=	f2_st;
	  end if;
when f_st   =>
	  valid_out_sig  <=  '1';
     din_reg        <=   X"00";
	  en_wait_count   <=  '0';

		nxt	<=	s1;

when s1	=>
	  valid_out_sig  <=  '1';
	  if  wait_count > X"000D" then
	   nxt	          <=	s2;
	   else
	    nxt	          <=	s1;
	    end if;
      din_reg   <=   X"00";
		 en_wait_count   <=  '1';
		
when s2  =>
		 en_wait_count   <=  '0';
		  valid_out_sig  <=  '1';
	      din_reg   <=  Dut_num;
		  nxt	<=	s3;
when s3  =>
 		 en_wait_count   <=  '0';
          valid_out_sig  <=  '1';
         din_reg   <=  X"11";
           nxt    <=    s4;    
when s4  =>
      		 en_wait_count   <=  '1';
            valid_out_sig  <=  '1';
              din_reg   <=  X"11";
              if  wait_count > X"0016" then
              nxt              <=    id;
              else
               nxt              <=    s4;
               end if;
               
 when f2_st   =>
         valid_out_sig  <=  '1';
        din_reg        <=  X"00";
         en_wait_count   <=  '0';
           nxt    <=    s1x;

   when s1x    =>
         valid_out_sig  <=  '1';
         if  wait_count > X"000D" then
          nxt              <=    s2x;
          else
           nxt              <=    s1x;
           end if;
         din_reg   <=  X"00";
            en_wait_count   <=  '1';
           
   when s2x  =>
            en_wait_count   <=  '0';
             valid_out_sig  <=  '1';
             din_reg   <=  Dut_num;
             nxt    <=    s3x;
   when s3x  =>
             en_wait_count   <=  '0';
             valid_out_sig  <=  '1';
            din_reg   <=  X"00";
              nxt    <=    s4x;    
   when s4x  =>
                  en_wait_count   <=  '1';
               valid_out_sig  <=  '1';
                 din_reg   <=  X"00";
                 if  wait_count > X"0016" then
                 nxt              <=    id;
                 else
                  nxt              <=    s4x;
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
valid_out  <=   valid_out_sig;
 if en_wait_count   =  '1' then
  wait_count  <=  wait_count +1;
  else
  wait_count     <=   (others => '0');
 end if;	 
 end if;
end process; 


	  
end Behavioral;


