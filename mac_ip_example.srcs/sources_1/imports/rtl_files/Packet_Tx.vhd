library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity Packet_TX is
    Port (
            valid_dut                  : in std_logic;
			tx_start				   : in std_logic;
			clk 						: in  STD_LOGIC;									
			reset 					: in  STD_LOGIC;										
			mac_data_out_ready	: in std_logic;								
			mac_data_out_valid	: out std_logic;							
			mac_data_out_first	: out std_logic;							
			mac_data_out_last		: out std_logic;							
			mac_data_out			: out std_logic_vector (7 downto 0);	 
			wait_cmd             : out std_logic;
			packet_header_tx     : in std_logic_vector(0  to 87); 
	--		my_mac					:in std_logic_vector(47 downto 0);
--			src_mac					:in std_logic_vector(47 downto 0);
         data_out,len         :in std_logic_vector(7 downto 0);
			rdx							:out std_logic			
			);
end Packet_TX;

architecture Behavioral of Packet_TX is

	type tx_state_type is (IDLE,SEND_ETH_HDR,SEND_L2_HDR);
	type count_mode_type is (RST, INCR, HOLD);
	type settable_cnt_type is (RST, SET, INCR, HOLD);
	signal tx_state			: tx_state_type;
	signal tx_count,datalen 			: unsigned (7 downto 0);
	signal tx_result_reg		: std_logic_vector (3 downto 0);
	signal tx_mac				: std_logic_vector (47 downto 0);
	signal mac_data_out_ready_reg	: std_logic;
	signal next_tx_state 	: tx_state_type;
	signal set_tx_state 		: std_logic;
	signal set_tx_mac			: std_logic;
	signal tx_count_val		: unsigned (7 downto 0);
	signal tx_count_mode		: settable_cnt_type;
	signal tx_data				: std_logic_vector (7 downto 0);
	signal set_last			: std_logic;
	signal tx_data_valid		: std_logic;			
	signal tx_valid_out     :std_logic;
	signal rd: std_logic:='0';	
begin
rdx<=rd;
process(tx_start)
begin
if(tx_start='1' and tx_start'event)then
if(len > x"2e")then----46
datalen<=unsigned(len);
else
datalen<=x"2e";
end if;
end if;
end process;

	tx_combinatorial : process(
		tx_start,tx_valid_out,valid_dut,packet_header_tx,len,datalen,data_out, clk,mac_data_out_ready,tx_state, tx_count, tx_mac,mac_data_out_ready_reg, 
		next_tx_state, set_tx_state,set_tx_mac, tx_count_mode,tx_data, set_last,tx_data_valid, tx_count_val
		)
	begin
		mac_data_out_first <= '0';
		case tx_state is
			when SEND_ETH_HDR=>
				mac_data_out <= tx_data;
				tx_data_valid <= mac_data_out_ready;	
				mac_data_out_last <= set_last;
				
			when SEND_L2_HDR=>
				mac_data_out <= tx_data;
				tx_data_valid <= tx_valid_out;
				mac_data_out_last <= set_last;
			when others =>
				mac_data_out <= (others => '0');
				tx_data_valid <= '0';			
				mac_data_out_last <= '0';
		end case;

		mac_data_out_valid <= tx_data_valid and mac_data_out_ready ;                      
		next_tx_state <= IDLE;
		set_tx_state <= '0';
		tx_count_mode <= HOLD;
		tx_data <= x"00";
		set_last <= '0';
		set_tx_mac <= '0';
		tx_count_val <= (others => '0');
		case tx_state is
			when IDLE =>
			   tx_valid_out<='0';
				wait_cmd<='0';
				rd<='0';
				tx_count_mode <= RST;
				if tx_start = '1' then
					if unsigned(packet_header_tx(48 to 63)) > 65000 then
						set_tx_state <= '1';
					else
						next_tx_state <= SEND_ETH_HDR;
						set_tx_state <= '1';
						wait_cmd<='1';
					end if;
				end if;
				when SEND_ETH_HDR =>
				wait_cmd<='1';
				if mac_data_out_ready = '1' then
					if tx_count = x"0d" then
						wait_cmd<=mac_data_out_ready; 
						tx_valid_out<='1';
						next_tx_state <= SEND_L2_HDR;
						tx_count_val <= x"01";									
						tx_count_mode<= SET;		
						set_tx_state <= '1';
					else
						tx_count_mode <= INCR;
					end if;
					case tx_count is
						when x"00"  =>mac_data_out_first <= mac_data_out_ready;
						tx_data                <=  x"5A";                --src_mac(47 downto 40);
						rd <= '0';       -- 
						when x"01"  => tx_data <=  x"11";                --src_mac(39 downto 32); 
						rd <= '0';
						when x"02"  => tx_data <=  x"22";                --src_mac(31 downto 24);
						rd <= '0';
						when x"03"  => tx_data <=  x"33";                --src_mac(23 downto 16);
						rd <= '0';
						when x"04"  => tx_data <=  x"44";                --src_mac(15 downto 8);
						rd <= '0';
						when x"05"  => tx_data <=  x"55";                --src_mac( 7 downto  0);
						rd <= '0';			
						when x"06"  => tx_data <=X"DA";
						rd <= '0';
						when x"07"  => tx_data <=X"11";
						rd <= '0';
						when x"08"  => tx_data <=X"22";
						rd <= '0';
						when x"09"  => tx_data <=X"33";
						rd <= '0';
						when x"0a"  => tx_data <=X"44";
						rd <= '1';
						when x"0b"  => tx_data <=X"55";	
						rd <= '1';				
						when x"0c"  => tx_data <=x"88";
						rd <= '1';
						when x"0d"  => tx_data <=x"b6";
											rd<='1';	
						when others =>
							next_tx_state <= IDLE;
							set_tx_state <= '1';
					end case;
				end if;
				
				when SEND_L2_HDR=>
			   tx_valid_out<='1';
            wait_cmd <= mac_data_out_ready;	
				--rd<='1';	
							if(unsigned(tx_count)<=unsigned(len))then
							rd<='1';	
							else
							rd<='0';	
							end if;				
				if mac_data_out_ready = '1' then
						if unsigned(tx_count) = unsigned(datalen) then
							set_last      <= '1';
							tx_data       <= data_out;--ip_tx.data.data_out;
							--rd            <= '0';
							wait_cmd		  <='0';
							tx_count_mode <= RST;
							next_tx_state <= IDLE;
							set_tx_state <= '1';
						else
							-- TX continues
							tx_count_mode <= INCR;
							tx_data <= data_out;
						end if;

				end if;
				when others=>null;
		end case;
	end process;


	tx_sequential : process (clk,reset,mac_data_out_ready_reg)
	begin
		if rising_edge(clk) then
			mac_data_out_ready_reg <= mac_data_out_ready;
		else
			mac_data_out_ready_reg <= mac_data_out_ready_reg;
		end if;
		
		if rising_edge(clk) then
			if reset = '1' then
				tx_state <= IDLE;
				tx_count <= x"00";
				tx_mac <= (others => '0');			
			else
				if set_tx_state = '1' then
					tx_state <= next_tx_state;
				else
					tx_state <= tx_state;
				end if;
				case tx_count_mode is
					when RST  =>	tx_count <= x"00";
					when SET  =>	tx_count <= tx_count_val;
					when INCR =>	tx_count <= tx_count + 1;
					when HOLD => 	tx_count <= tx_count;
				end case;
				
			end if;
		end if;
	end process;
end Behavioral;
