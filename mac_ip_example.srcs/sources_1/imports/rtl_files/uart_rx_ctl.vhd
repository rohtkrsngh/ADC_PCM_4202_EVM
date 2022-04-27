
-- 
-- -----------------------------------------------------------------------------
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;


entity uart_rx_ctl is
    Port ( clk_rx           : in  STD_LOGIC; ---clk200
           rst_clk_rx       : in  STD_LOGIC; ---reset
           baud_x16_en      : in  STD_LOGIC;
           rxd_clk_rx       : in  STD_LOGIC; --- rx_p input data
           rx_data          : out STD_LOGIC_VECTOR (15 downto 0);   
           rx_data_rdy      : out STD_LOGIC;
           valid_dut        : in  std_logic;
		   rd_clk           : in  std_logic;            --125
           start_bit_num    : in  std_logic_vector(3 downto 0); 
		    word_length     : in  std_logic_vector(7 downto 0);
		 
           frm_err          : out STD_LOGIC
          );
end uart_rx_ctl;


architecture Behavioral of uart_rx_ctl is
component fifo_data
 PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    valid : OUT STD_LOGIC;
    rd_data_count : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    wr_data_count : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
  
  );
END COMPONENT;
signal   rx_datas          :  STD_LOGIC_VECTOR (15 downto 0);   
signal wr_data_count,rd_data_count: STD_LOGIC_VECTOR (3 downto 0);
signal full,empty,rx_data_rdys,rd_en: std_logic;
type data_state is (f_st,s_st,t_st);
signal pres,nxt: data_state;
type legal_rx_states is ( IDLE, START, DATA, DATA2, DATA3, DATA4, STOP, wait_ini );
signal state                  : legal_rx_states := IDLE;
signal bit_cnt                : integer range 0 to 15 := 0;  -- 
signal over_sample_cnt_done   : std_logic := 'U';           -- 
signal bit_cnt_done           : std_logic := 'U'; 

signal cnt_v:std_logic_vector(2 downto 0):="000";
signal en_cnt:std_logic:='0';
signal   svalue_sample1 :  std_logic_vector(6 downto 0);
signal   zero_constant  :  std_logic_vector(6 downto 0) := "0000000"; 
signal   svalue_sample2 :  std_logic_vector(5 downto 0);
signal   svalue_sample3 :  std_logic_vector(5 downto 0);
signal   svalue_sample4 :  std_logic_vector(5 downto 0);
signal   svalue_sample5 :  std_logic_vector(5 downto 0);

SIGNAL  word_length_incr    : integer range 0 to 16; --range 0 to 16;
SIGNAL  word_length_int         : integer range 0 to 16; --range 0 to 16
--SIGNAL  start_bit_num       : std_logic_vector(3 downto 0) ; 

signal over_sample_cnt_track   : integer range 0 to 16000 := 0; 
--signal over_sample_cnt: integer range 0 to 20 := 0; 
signal over_sample_cnt_v1  : integer range 0 to 16000 := 0; 
signal over_sample_cnt_v2  : integer range 0 to 16000 := 0; 
signal over_sample_cnt_v3  : integer range 0 to 90 := 0; 
signal over_sample_cnt_v4  : integer range 0 to 90 := 0; 
signal over_sample_cnt_v5  : integer range 0 to 90 := 0; 
 
 
  
signal start_lrd_rx : std_logic;
signal bit_samples : std_logic_Vector(51 downto 0) := (others => '0');
signal sum_samples : std_logic_Vector(51 downto 0) := (others => '0');
signal zero_40b   :  std_logic_Vector(51 downto 0) := (others => '0');
signal bit_value : std_logic;
signal int_i : integer range 0 to 63 := 0;
signal int_bit_cnt: integer range 0 to 20 := 0;
signal        cal_val_rx : std_logic := '0';
signal new_rx_value : std_logic_vector(18 downto 0);
signal new_rx_value_r1 : std_logic_vector(15 downto 0);
signal en_wait_ini : std_logic := '0';
signal  wait_ini_count : std_logic_vector(7 downto 0) := X"00";
signal bits_rxd : std_logic_vector(7 downto 0) := X"00";
signal sample_rate_value, rd_count, sample_value_fin : integer range 0 to 63 := 0; 
signal update_sampling, en_rd_count : std_logic := '0';


type rate_st is (rs0, rs1, rs2, rs3, rs4, rs5, rs6);
signal pr_st, nx_st : rate_st; 
  attribute keep : boolean;
  attribute keep of bit_samples,sum_samples,int_i : signal is TRUE;

begin
	 
 

sample_value_fin <= 39;
 new_rx_value_r1 <= X"00" & new_rx_value(9 downto 2);
 process (clk_rx)
 begin
  if rising_edge(clk_rx) then
	if  start_lrd_rx = '1'  then 
	
	 if int_i < sample_value_fin then
	 int_i <= int_i + 1;
	 bit_samples(int_i) <= rxd_clk_rx;
	 else
	 bit_samples <= (others => '0');
	 int_i <= 0;
	 end if;
	 else
	  int_i <= 0;
	end if;
  end if;
end process;  


 process (clk_rx)
 begin
  if rising_edge(clk_rx) then
  if start_lrd_rx = '1' then
	if  int_i = (sample_value_fin - 1)  then 
	  sum_samples  <=  zero_40b + bit_samples(0) 
	                + bit_samples(1)
	                + bit_samples(2)
	                + bit_samples(3)
	                + bit_samples(4)
	                + bit_samples(5)
	                + bit_samples(6)
	                + bit_samples(7)
	                + bit_samples(8)
	                + bit_samples(9)
	                + bit_samples(10)
	                + bit_samples(11)
	                + bit_samples(12)
	                + bit_samples(13)
	                + bit_samples(14)
	                + bit_samples(15)
	                + bit_samples(16)
	                + bit_samples(17)
	                + bit_samples(18)
	                + bit_samples(19)
	                + bit_samples(20)
	                + bit_samples(21)
	                + bit_samples(22)
	                + bit_samples(23)
	                + bit_samples(24)
	                + bit_samples(25)
	                + bit_samples(26)
	                + bit_samples(27)
	                + bit_samples(28)
	                + bit_samples(29)
	                + bit_samples(30)
	                + bit_samples(31)
	                + bit_samples(32)
	                + bit_samples(33)
	                + bit_samples(34)
	                + bit_samples(35)
	                + bit_samples(36)
	                + bit_samples(37)
	                + bit_samples(38)
	                + bit_samples(39)
				    + bit_samples(40)
	                + bit_samples(41)
	                + bit_samples(42)
	                + bit_samples(43)
	                + bit_samples(44)
	                + bit_samples(45)
	                + bit_samples(46)
	                + bit_samples(47)
	                + bit_samples(48)
	                + bit_samples(49)
	                + bit_samples(50)
	                + bit_samples(51);
			end if;
else
sum_samples <= (others => '0');			
 end if;
	end if;
	end process;
	
  process (clk_rx)
 begin
  if rising_edge(clk_rx) then
  if start_lrd_rx = '1' then
	if  int_i = sample_value_fin  then 
	 cal_val_rx  <=  '1';
	 int_bit_cnt <= int_bit_cnt + 1;
	  

   else
	 cal_val_rx  <=  '0';
	end if;
	else
	
	int_bit_cnt <= 0;
	cal_val_rx  <=  '0';
	end if;
	end if;
	end process;

 process (clk_rx)
 begin
  if rising_edge(clk_rx) then
  if cal_val_rx = '1' then
  bits_rxd  <= bits_rxd + '1';
  new_rx_value(int_bit_cnt) <= bit_value;
  elsif  bits_rxd = X"09" then 
  rx_data_rdys <= '1';
  bits_rxd  <= X"00";
  else
  rx_data_rdys <= '0';
  end if;
  end if;
  end process;
  process (clk_rx)
 begin
  if rising_edge(clk_rx) then
	if  sum_samples > X"0000_0000_0014"  then
	bit_value <= '1';
	else
	bit_value <= '0';
	end if;
	end if;
	end process;

		 
       --
       -- compute the next state
   genNextState: process (clk_rx)
      begin
         if rising_edge(clk_rx) then                           -- 
            if (rst_clk_rx = '1' and valid_dut = '0') then                         -- 
               state <= IDLE;  
             elsif(rst_clk_rx = '0' and valid_dut = '0') then                                -- 
            state <= IDLE; 
            elsif (rst_clk_rx = '1' and valid_dut = '1') then
            state <= IDLE; 
            else                                               -- 
              -- if (baud_x16_en = '1') then                     -
                  case state is                                -- 
                     when IDLE =>    
  					  en_wait_ini <= '0';
                        if (rxd_clk_rx = '0' and valid_dut = '1') then  
                           state <= DATA; 
                          start_lrd_rx <= '1';									
                          else    
						  state <= idle;
                        start_lrd_rx <= '0'; 
                         end if; 								
                     when data =>  
                       en_wait_ini <= '0';					 
                        if bits_rxd = X"09" then   
                                     
                              state <= wait_ini;                   
                           else                                
                              state <= data;                   
                           end if;                             
                                                       
                        start_lrd_rx <= '1'; 
                    
						when wait_ini =>  
                           en_wait_ini <= '1';
						   start_lrd_rx <= '0';
						   if rxd_clk_rx = '1' then
						   state <= idle;
						   else
						    state <= wait_ini;
							end if;
										
                     when others =>                            
                        state <= IDLE;    
                   start_lrd_rx <= '0'; 								
                  end case;                                    
              -- end if;                                       
            end if;                                            
         end if;                                               
      end process genNextState;


  ce_name : fifo_data
  PORT MAP (
    rst => rst_clk_rx,
    wr_clk => clk_rx,
    rd_clk => rd_clk,
    din => new_rx_value_r1,
    wr_en => rx_data_rdys,
    rd_en => rd_en,
    dout => rx_data,
    full => full,
    empty => empty,
	 valid=> rx_data_rdy,
	 rd_data_count=>rd_data_count,
    wr_data_count => wr_data_count
  );
  

	 process(rd_clk)
  begin
  if rising_edge(rd_clk) then
--    if cnt_v="011" then
 if rd_data_count=X"01" then
 rd_en<='1';
 else
   rd_en<='0';
	end if;
	end if;
	end process;

	 
    end Behavioral;
