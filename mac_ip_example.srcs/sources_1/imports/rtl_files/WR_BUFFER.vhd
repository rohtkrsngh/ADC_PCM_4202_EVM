----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/29/2014 01:05:53 PM
-- Design Name: 
-- Module Name: WR_BUFFER - WR_BUFFER_a
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
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity WR_BUFFER is
    Port (DIN_WRB           : in    std_logic_vector(7 downto 0);
          CLK1_WRB          : in    std_logic;
          DIN_RDY_WRB       : in    std_logic;
          DOUT_WRB          : out   std_logic_vector(7 downto 0);
          CLK2_WRB          : in    std_logic;
          RST_WRB           : in    std_logic;
          Full_Fifo         : out   std_logic;
          Empty_Fifo        : out   std_logic;
          Rd_Data_Count_Wrb : out   std_logic_vector(9 downto 0);
          frame_length      : in    std_logic_vector(7 downto 0);
          Prog_Full         : out   std_logic;
          Prog_Empty        : out   std_logic;
          Fifo_Rd_En        : in    std_logic;
          Rd_LL_Wrb         : in    std_logic;
          Dout_Fifo_LL      : out   std_logic_vector(7 downto 0);
          Full_LL           : out   std_logic;  
          Empty_LL          : out   std_logic;                   
          Data_Count_LL     : out   std_logic_vector(3 downto 0) ;
      valid_out_s :    out   std_logic;
          rx_pkt_cmplt      : out   std_logic		
           );

end entity WR_BUFFER;

architecture WR_BUFFER_a of WR_BUFFER is

type Wr_Buff_st is (S0_Wr_Bf,S1_Wr_Bf, S2_Wr_Bf,S3_Wr_Bf);

type Ed_st is (S0_Ed, S1_Ed,S2_Ed);
signal Ed_Cs               : Ed_St;
signal Ed_Ns               : Ed_St;
signal Valid_pulse         : std_logic;
--signal Valid_pulse1         : std_logic;
--signal Valid_pulse2         : std_logic;
--signal Valid_pulse3         : std_logic;

signal Wr_Bf_Ns                : Wr_Buff_st;        -- Next State Signal.
signal Wr_Bf_Cs                : Wr_Buff_st;        -- Current State Signal.
signal Fifo_Wr_En_s            : std_logic;
signal Cnt_Wr_Rst_s            : std_logic;
signal Cnt_Wr_En_s             : std_logic;
signal Cnt_Wr_s                : std_logic_vector(7 downto 0);
signal Cnt_Wr_s1                : std_logic_vector(7 downto 0);

signal Ld_Wr_Cnt_s             : std_logic;
signal Pkt_Buf_End_s           : std_logic;
signal Fifo_Rd_En_s            : std_logic;
 
signal DOUT_RDB_s              : std_logic_vector(7 downto 0);     
signal Full_Fifo_s             : std_logic;   
signal Empty_Fifo_s            : std_logic;   
signal Rd_Data_Count_s         : std_logic_vector(9 downto 0):= (others => '0');
signal Wr_Data_Count_s         : std_logic_vector(9 downto 0):= (others => '0');
signal Prog_Full_s             : std_logic;    
signal Prog_Empty_s            : std_logic;

signal DIN_WRB_s               :  std_logic_vector(7 downto 0);
signal RST_WRB_s               :  std_logic;
signal CLK1_WRB_s              :  std_logic;
signal DIN_RDY_WRB_s           :  std_logic; 
 
signal CLK2_WRB_s              :  std_logic;                   
                  

signal Rsp_Id_Match_s          :  std_logic;
signal Rsp_Id_Len_s            :  std_logic_vector(7 downto 0);
signal Rsp_Id_Len_Ld_s         :  std_logic_vector(7 downto 0);
signal Len_Ld_En_s             :  std_logic;

------- Signal for FIFO_LL -----------------
signal    Rd_LL_Wrb_s            :  std_logic;
signal    Dout_Fifo_LL_s         :  std_logic_vector(7 downto 0);
signal    Full_LL_s              :  std_logic;
signal    Empty_LL_s             :  std_logic;
signal    Data_Count_LL_s        :  std_logic_vector(3 downto 0);
signal    DIN_RDY_WRB1_s         :  std_logic;
signal sum: std_logic:='0';



-- Response Frame  Ids.

--constant Rsp_Id0_c : std_logic_vector(3 downto 0) := "0001";
constant Rsp_Id1_c : std_logic_vector(3 downto 0) := "0001";   -- Error Frame Report.
constant Rsp_Id2_c : std_logic_vector(3 downto 0) := "0010";   -- Attenuation/Response readback
constant Rsp_Id3_c : std_logic_vector(3 downto 0) := "0011";   -- Flash Read Response Frame.
constant Rsp_Id4_c : std_logic_vector(3 downto 0) := "0100";   -- Error Frame Report.
constant Rsp_Id5_c : std_logic_vector(3 downto 0) := "0101";   -- Attenuation/Response readback
constant Rsp_Id6_c : std_logic_vector(3 downto 0) := "0110"; 
constant Rsp_Id7_c : std_logic_vector(3 downto 0) := "0111";   -- Error Frame Report.
constant Rsp_Id8_c : std_logic_vector(3 downto 0) := "1000";   -- Attenuation/Response readback
constant Rsp_Id9_c : std_logic_vector(3 downto 0) := "1001"; 
constant Rsp_Id10_c : std_logic_vector(3 downto 0) := "1010";
constant Rsp_Id11_c : std_logic_vector(3 downto 0) := "1100";
component FIFO_WBB is
  PORT (
    rst             : IN    STD_LOGIC;
    wr_clk          : IN    STD_LOGIC;
    rd_clk          : IN    STD_LOGIC;
    din             : IN    STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en           : IN    STD_LOGIC;
    rd_en           : IN    STD_LOGIC;
    valid          : out std_logic;
    dout            : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
    full            : OUT   STD_LOGIC;
    empty           : OUT   STD_LOGIC;
    rd_data_count   : OUT   STD_LOGIC_VECTOR(6 DOWNTO 0);
    wr_data_count   : OUT   STD_LOGIC_VECTOR(6 DOWNTO 0);
    prog_full       : OUT   STD_LOGIC;
    prog_empty      : OUT   STD_LOGIC
  );
end component FIFO_WBB;

COMPONENT fifo_LL
  PORT (
    clk         : IN STD_LOGIC;
    srst         : IN STD_LOGIC;
    din         : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en       : IN STD_LOGIC;
    rd_en       : IN STD_LOGIC;
    dout        : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full        : OUT STD_LOGIC;
    empty       : OUT STD_LOGIC;
    data_count  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
  );
END COMPONENT;
------------------- ARCHITECTURE --------------------------
begin

DOUT_WRB                 <= DOUT_RDB_s;
 
CLK1_WRB_s               <= CLK1_WRB;
DIN_RDY_WRB_s            <= DIN_RDY_WRB;     
CLK2_WRB_s               <= CLK2_WRB;    
RST_WRB_s                <= RST_WRB;     

Fifo_Rd_En_s             <= Fifo_Rd_En;   
       
Full_Fifo                <= Full_Fifo_s;     
Empty_Fifo               <= Empty_Fifo_s;    
Rd_Data_Count_Wrb        <= Rd_Data_Count_s;
--Wr_Data_Count            <= Wr_Data_Count_s; 
Prog_Full                <= Prog_Full_s;
Prog_Empty               <= Prog_Empty_s;

Rd_LL_Wrb_s              <= RD_LL_WRB;
Dout_Fifo_LL             <= Dout_Fifo_LL_s;
Full_LL                  <= Full_LL_s;
Empty_LL                 <= Empty_LL_s;  
Data_Count_LL            <= Data_Count_LL_s;
rx_pkt_cmplt             <= sum;

-- Registering input data coming from UART.

proc0_WRB : process (CLK1_WRB_s)
begin
  if rising_edge(CLK1_WRB_s) then
    if (RST_WRB_s = '1') then 
      DIN_WRB_s   <= (others =>'0');
    elsif(DIN_RDY_WRB_s = '1') then
      DIN_WRB_s   <= DIN_WRB;
    end if;
  end if;
end process proc0_WRB;
      
-- Command Id Matching logic.

Rsp_Id_Match_s <= '1' when                                                           --DIN_WRB_s(7 downto 4)    = Rsp_Id0_c  
                              DIN_RDY_WRB1_s = '1' else
                  '0';
   
--------------- Response Id Length Decoder.------------------------

Rsp_Id_Len_s  <= frame_length;
--x"02" when (DIN_WRB_s(7 downto 4)    = Rsp_Id0_c) else
--                 x"06" when (DIN_WRB_s(3 downto 0)    = Rsp_Id1_c) else
--                 x"14" when (DIN_WRB_s(3 downto 0)   = Rsp_Id2_c) else
--                 x"10" when (DIN_WRB_s(3 downto 0)    = Rsp_Id3_c) else
--                 x"10" when (DIN_WRB_s(3 downto 0)    = Rsp_Id4_c) else
--                 x"14" when (DIN_WRB_s(3 downto 0)    = Rsp_Id5_c) else --06
--                 x"06" when (DIN_WRB_s(3 downto 0)    = Rsp_Id6_c) else
--                 x"0C" when (DIN_WRB_s(3 downto 0)    = Rsp_Id7_c) else
--                 x"0C" when (DIN_WRB_s(3 downto 0)    = Rsp_Id8_c) else
--                 x"06" when (DIN_WRB_s(3 downto 0)   = Rsp_Id9_c) else 
--                 x"13" when (DIN_WRB_s(3 downto 0)   = Rsp_Id10_c) else 
--                 x"02" when (DIN_WRB_s(3 downto 0)   = Rsp_Id11_c) else                
--                 x"00";


proc1_WRB : process (CLK1_WRB_s)
begin
  if rising_edge(CLK1_WRB_s) then
    if (RST_WRB_s = '1') then
      Rsp_Id_Len_Ld_s    <= (others => '0');
    elsif (Len_Ld_En_s = '1') then
      Rsp_Id_Len_Ld_s  <= Rsp_Id_Len_s;-- Rsp_Id_Len_s;
    end if;
  end if;
end process proc1_WRB;


proc2_WRB : process(CLK1_WRB_s)      
begin                                
  if rising_edge(CLK1_WRB_s) then    
    if (RST_WRB_s = '1') then        
      DIN_RDY_WRB1_s <= '0';         
    else                             
      DIN_RDY_WRB1_s <=DIN_RDY_WRB_s;
    end if;                          
  end if;                            
end process proc2_WRB;               
                                     
p_V_p1 : process(CLK1_WRB_s)      
begin                                
  if rising_edge(CLK1_WRB_s) then    
           
      if (Valid_pulse='1') then
         if (Cnt_Wr_s  = Rsp_Id_Len_Ld_s-1 ) then
          sum <='1';		             
            end if;
      elsif Cnt_Wr_Rst_s='1' then
			sum <='0';
			else                             
      sum<=sum;
end if;
end if;
  
end process p_V_p1;

--p_V_p2 : process(CLK1_WRB_s)      
--begin                                
--  if rising_edge(CLK1_WRB_s) then    
--           
--      Valid_pulse2 <= Valid_pulse1;         
--    else                             
--      Valid_pulse2 <=Valid_pulse2;
--                              
--  end if;                            
--end process p_V_p2;
--
--p_V_p3 : process(CLK1_WRB_s)      
--begin                                
--  if rising_edge(CLK1_WRB_s) then    
--           
--      Valid_pulse3 <= Valid_pulse2;         
--    else                             
--      Valid_pulse3 <=Valid_pulse3;
--                              
--  end if;                            
--end process p_V_p3;

------------------ WR_Buffer Manager ------------------------ 

proc3_WRB : process(CLK1_WRB_s)  
begin
  if rising_edge(CLK1_WRB_s) then 
    if (RST_WRB_s = '1') then   
      Wr_Bf_Cs  <= S0_Wr_Bf;
    else
      Wr_Bf_Cs  <= Wr_Bf_Ns ;    
    end if;
  end if;
end process proc3_WRB;

 
----------Next State Computation ----------------------------------------------

proc4_WRB : process(Wr_Bf_Cs,Rsp_Id_Match_s,Wr_Data_Count_s,DIN_RDY_WRB_s,Cnt_Wr_s,Valid_pulse,sum)
begin 
  case Wr_Bf_Cs is
    when S0_Wr_Bf =>
      if (RST_WRB_s = '1') then
        Wr_Bf_Ns  <= S0_Wr_Bf;
      elsif (Rsp_Id_Match_s = '1' ) then
        Wr_Bf_Ns      <= S1_Wr_Bf;
      else
        Wr_Bf_Ns  <= S0_Wr_Bf;
      end if;
      Fifo_Wr_En_s     <= '0';
      Pkt_Buf_End_s    <= '0';
      Len_Ld_En_s      <= '0';
      Cnt_Wr_En_s      <= '0';
      Cnt_Wr_Rst_s     <= '1';
----      sum               <='0';
    when S1_Wr_Bf =>
      Len_Ld_En_s      <= '1';
      Fifo_Wr_En_s     <= '0';
      Pkt_Buf_End_s    <= '0';
      Wr_Bf_Ns         <= S2_Wr_Bf;
      Cnt_Wr_En_s      <= '0';
      Cnt_Wr_Rst_s     <= '0';
      
    when S2_Wr_Bf =>
      Fifo_Wr_En_s     <= '1';
      Len_Ld_En_s      <= '0';
     
      Cnt_Wr_Rst_s     <= '0';
         if sum='1' then
			        Pkt_Buf_End_s    <= '1';
                 Wr_Bf_Ns      <= S0_Wr_Bf;
					  Cnt_Wr_En_s      <= '0';

					  else
					  Pkt_Buf_End_s    <= '0';
      Wr_Bf_Ns      <= S3_Wr_Bf;
       Cnt_Wr_En_s      <= '1';
		    --  Fifo_Wr_En_s     <= '1';

		  end if;

     when S3_Wr_Bf =>
       Fifo_Wr_En_s     <= '0';
       Len_Ld_En_s      <= '0'; 
       Cnt_Wr_En_s      <= '0';
       Cnt_Wr_Rst_s     <= '0';
       
--       if (Wr_Data_Count_s(7 downto 0) = Rsp_Id_Len_Ld_s) then
--         Wr_Bf_Ns      <= S0_Wr_Bf;
--         Pkt_Buf_End_s    <= '1';
--       elsif (rising_edge(DIN_RDY_WRB_s)) then 
--         Wr_Bf_Ns      <= S2_Wr_Bf;
--         Pkt_Buf_End_s    <= '0';
--       else 
--         Wr_Bf_Ns      <= S3_Wr_Bf;
--         Pkt_Buf_End_s    <= '0';
         
--       end if;
       
        
       if (Valid_pulse='1') then
         if (Cnt_Wr_s  = Rsp_Id_Len_Ld_s-1 ) then
           Wr_Bf_Ns         <= S2_Wr_Bf;     -- S0_Wr_Bf
           Pkt_Buf_End_s    <= '0';  
			 -- sum<='1';
--         Cnt_Wr_En_s      <= '0';
         else
           
           Wr_Bf_Ns      <= S2_Wr_Bf;
 
           Pkt_Buf_End_s    <= '0';
         end if;
         
       else
         Wr_Bf_Ns      <= S3_Wr_Bf;
--         Cnt_Wr_En_s      <= '0';
         Pkt_Buf_End_s    <= '0';       
       end if;
        
         
    when others =>
      Wr_Bf_Ns         <= S0_Wr_Bf;
      Fifo_Wr_En_s     <= '0';
      Len_Ld_En_s      <= '0';
      Pkt_Buf_End_s    <= '0';
      Cnt_Wr_En_s      <= '0';
      Cnt_Wr_Rst_s     <= '0';      
      
  end case;
  
end process proc4_WRB;

------------- Write Counter -------------------------

proc5_Wr_Cnt : process(CLK1_WRB)  
begin
  if rising_edge(CLK1_WRB) then 
    if (RST_WRB_s = '1') then 
      Cnt_Wr_s  <= (others => '0');
        
    elsif (Cnt_Wr_Rst_s = '1') then
      Cnt_Wr_s  <= (others => '0');
    elsif (Cnt_Wr_En_s = '1') then
      Cnt_Wr_s      <= Cnt_Wr_s + 1;
--    else    
--      Cnt_Wr_s  <= (others => '0');      
    end if;
  end if;
end process proc5_Wr_Cnt;

---------------------Edge detection --------------------------------------
proc6_ED : process(CLK1_WRB_s)
begin
  if rising_edge(CLK1_WRB_s) then
    if (RST_WRB_s = '1') then
      Ed_Cs   <= S0_Ed;
    else
      Ed_Cs   <= Ed_Ns;
    end if;
  end if;
end process proc6_ED;

proc7_ED : process(CLK1_WRB_s)
begin
  case Ed_CS is 
    when S0_Ed =>
      if(DIN_RDY_WRB_s = '0') then
        Ed_Ns <= S0_Ed;
      elsif(DIN_RDY_WRB_s = '1') then
        Ed_Ns <= S1_Ed;
      else
        Ed_Ns <= S0_Ed;
      end if;
    Valid_pulse <= '0';
     
    
    when S1_Ed =>
      Ed_Ns <= S2_Ed;
      Valid_pulse <= '1';
    
    when S2_Ed =>           
      if(DIN_RDY_WRB_s = '0') then 
        Ed_Ns <= S0_Ed;     
      else                  
        Ed_Ns <= S2_Ed;     
      end if;               
      Valid_pulse <= '0';        
         
    when others =>
      Ed_Ns <= S0_Ed;
      Valid_pulse <= '0';
  end case;
  
end process proc7_ED;

    
    

 
 
 
---------------------- FIFO Instantiation for holding UART packets ----------------------------------                 
U0_WRB: FIFO_WBB
  PORT MAP (
    rst             => RST_WRB_s,
    wr_clk          => CLK1_WRB_s,
    rd_clk          => CLK2_WRB_s,
    din             => DIN_WRB_s,
    wr_en           => Fifo_Wr_En_s,
    rd_en           => Fifo_Rd_En_s,
    dout            => DOUT_RDB_s,
    full            => Full_Fifo_s,
    empty           => Empty_Fifo_s,
    valid               => valid_out_s,
    rd_data_count   => Rd_Data_Count_s(6 downto 0),
    wr_data_count   => Wr_Data_Count_s(6 downto 0),
    prog_full       => Prog_Full_s,
    prog_empty      => Prog_Empty_s
  );


-----------------------------FIFO Instantiation for linking packet lengths -----------------------

U1_WRB : fifo_LL
  PORT MAP (
    clk         => CLK2_WRB_s,
    srst         => RST_WRB_s,
    din         => Rsp_Id_Len_Ld_s,
    wr_en       => Pkt_Buf_End_s,
    rd_en       => Rd_LL_Wrb_s,
    dout        => Dout_Fifo_LL_s,
    full        => Full_LL_s,
    empty       => Empty_LL_s,
    data_count  => Data_Count_LL_s
  );




end WR_BUFFER_a;
