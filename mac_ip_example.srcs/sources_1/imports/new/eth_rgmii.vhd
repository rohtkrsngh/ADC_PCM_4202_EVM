

library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------------------
-- The entity declaration for the example_design level wrapper.
--------------------------------------------------------------------------------

entity eth_rgmii is
    port (
      -- asynchronous reset
      glbl_rst                      : in  std_logic;

      -- 200MHz clock input from board
      clk_in_p                      : in  std_logic;
      clk_in_n                      : in  std_logic;
      -- 125 MHz clock output from MMCM
    --  gtx_clk_bufg_out              : out std_logic;

      phy_resetn                    : out std_logic;
      clk_125, clk_100, clk_200   :  out std_logic;

      -- RGMII Interface
      ------------------
      rgmii_txd                     : out std_logic_vector(3 downto 0);
      rgmii_tx_ctl                  : out std_logic;
      rgmii_txc                     : out std_logic;
      rgmii_rxd                     : in  std_logic_vector(3 downto 0);
      rgmii_rx_ctl                  : in  std_logic;
      rgmii_rxc                     : in  std_logic;

      -- MDIO Interface
      -----------------
      mdio                          : inout std_logic;
      mdc                           : out std_logic;

   rx_axis_fifo_tvalid  :   out std_logic;
      rx_axis_fifo_tdata   : out  std_logic_vector(7 downto 0);
      rx_axis_fifo_tlast :  out std_logic;
    
     tx_axis_fifo_tvalid : in  std_logic;
      tx_axis_fifo_tready        : out std_logic;
     tx_axis_fifo_tdata    : in  std_logic_vector(7 downto 0);
     tx_axis_fifo_tlast : in  std_logic
   
    

    );
end eth_rgmii;

architecture wrapper of eth_rgmii is

  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of wrapper : architecture is "yes";

  ------------------------------------------------------------------------------
  -- Component Declaration for the Tri-Mode EMAC core FIFO Block wrapper
  ------------------------------------------------------------------------------

   component mac_ip_fifo_block
   port(
      gtx_clk                    : in  std_logic;
      -- asynchronous reset
      glbl_rstn                  : in  std_logic;
      rx_axi_rstn                : in  std_logic;
      tx_axi_rstn                : in  std_logic;

      -- Reference clock for IDELAYCTRL's
      refclk                     : in  std_logic;

      -- Receiver Statistics Interface
      -----------------------------------------
      rx_mac_aclk                : out std_logic;
      rx_reset                   : out std_logic;
      rx_statistics_vector       : out std_logic_vector(27 downto 0);
      rx_statistics_valid        : out std_logic;

      -- Receiver (AXI-S) Interface
      ------------------------------------------
      rx_fifo_clock              : in  std_logic;
      rx_fifo_resetn             : in  std_logic;
      rx_axis_fifo_tready        : in  std_logic;
      rx_axis_fifo_tvalid        : out std_logic;
      
      rx_axis_fifo_tdata         : out std_logic_vector(7 downto 0);
      
      rx_axis_fifo_tlast         : out std_logic;

      -- Transmitter Statistics Interface
      --------------------------------------------
      tx_mac_aclk                : out std_logic;
      tx_reset                   : out std_logic;
      tx_ifg_delay               : in  std_logic_vector(7 downto 0);
      tx_statistics_vector       : out std_logic_vector(31 downto 0);
      tx_statistics_valid        : out std_logic;

      -- Transmitter (AXI-S) Interface
      ---------------------------------------------
      tx_fifo_clock              : in  std_logic;
      tx_fifo_resetn             : in  std_logic;
      tx_axis_fifo_tready        : out std_logic;
      tx_axis_fifo_tvalid        : in  std_logic;
      
      tx_axis_fifo_tdata         : in  std_logic_vector(7 downto 0);
      
      tx_axis_fifo_tlast         : in  std_logic;

      -- MAC Control Interface
      --------------------------
      pause_req                  : in  std_logic;
      pause_val                  : in  std_logic_vector(15 downto 0);

      -- RGMII Interface
      --------------------
      rgmii_txd                  : out std_logic_vector(3 downto 0);
      rgmii_tx_ctl               : out std_logic;
      rgmii_txc                  : out std_logic;
      rgmii_rxd                  : in  std_logic_vector(3 downto 0);
      rgmii_rx_ctl               : in  std_logic;
      rgmii_rxc                  : in  std_logic;

      -- RGMII Inband Status Registers
      ----------------------------------
      inband_link_status        : out std_logic;
      inband_clock_speed        : out std_logic_vector(1 downto 0);
      inband_duplex_status      : out std_logic;


      
      -- MDIO Interface
      -----------------
      mdio                      : inout std_logic;
      mdc                       : out std_logic;
      -- AXI-Lite Interface
      -----------------
      s_axi_aclk                : in  std_logic;
      s_axi_resetn              : in  std_logic;



      s_axi_awaddr              : in  std_logic_vector(11 downto 0);
      s_axi_awvalid             : in  std_logic;
      s_axi_awready             : out std_logic;

      s_axi_wdata               : in  std_logic_vector(31 downto 0);
      s_axi_wvalid              : in  std_logic;
      s_axi_wready              : out std_logic;

      s_axi_bresp               : out std_logic_vector(1 downto 0);
      s_axi_bvalid              : out std_logic;
      s_axi_bready              : in  std_logic;

      s_axi_araddr              : in  std_logic_vector(11 downto 0);
      s_axi_arvalid             : in  std_logic;
      s_axi_arready             : out std_logic;

      s_axi_rdata               : out std_logic_vector(31 downto 0);
      s_axi_rresp               : out std_logic_vector(1 downto 0);
      s_axi_rvalid              : out std_logic;
      s_axi_rready              : in  std_logic

   );
   end component;

  ------------------------------------------------------------------------------
  -- Component Declaration for the basic pattern generator
  ------------------------------------------------------------------------------


   

  ------------------------------------------------------------------------------
  -- Component Declaration for the AXI-Lite State machine
  ------------------------------------------------------------------------------

   component mac_ip_axi_lite_sm
   port (
      s_axi_aclk                : in  std_logic;
      s_axi_resetn              : in  std_logic;

      mac_speed                 : in  std_logic_vector(1 downto 0);
      update_speed              : in  std_logic;
      serial_command            : in  std_logic;
      serial_response           : out std_logic;
            
      phy_loopback              : in  std_logic;

      s_axi_awaddr              : out std_logic_vector(11 downto 0);
      s_axi_awvalid             : out std_logic;
      s_axi_awready             : in  std_logic;

      s_axi_wdata               : out std_logic_vector(31 downto 0);
      s_axi_wvalid              : out std_logic;
      s_axi_wready              : in  std_logic;

      s_axi_bresp               : in  std_logic_vector(1 downto 0);
      s_axi_bvalid              : in  std_logic;
      s_axi_bready              : out std_logic;

      s_axi_araddr              : out std_logic_vector(11 downto 0);
      s_axi_arvalid             : out std_logic;
      s_axi_arready             : in  std_logic;

      s_axi_rdata               : in  std_logic_vector(31 downto 0);
      s_axi_rresp               : in  std_logic_vector(1 downto 0);
      s_axi_rvalid              : in  std_logic;
      s_axi_rready              : out std_logic
   );
   end component;

  ------------------------------------------------------------------------------
  -- Component declaration for the synchroniser
  ------------------------------------------------------------------------------
  component mac_ip_sync_block
  port (
     clk                        : in  std_logic;
     data_in                    : in  std_logic;
     data_out                   : out std_logic
  );
  end component;

  ------------------------------------------------------------------------------
  -- Component declaration for the clocking logic
  ------------------------------------------------------------------------------
  component mac_ip_example_design_clocks is
   port (
   -- clocks
   clk_in_p                   : in std_logic;
   clk_in_n                   : in std_logic;

   -- asynchronous resets
   glbl_rst                   : in std_logic;
   dcm_locked                 : out std_logic;

   -- clock outputs
   gtx_clk_bufg               : out std_logic;
   
   refclk_bufg                : out std_logic;
   s_axi_aclk                 : out std_logic
   );
   end component;

  ------------------------------------------------------------------------------
  -- Component declaration for the reset logic
  ------------------------------------------------------------------------------
  component mac_ip_example_design_resets is
  port (
     -- clocks
     s_axi_aclk                 : in std_logic;
     gtx_clk                    : in std_logic;


     -- asynchronous resets
     glbl_rst                   : in std_logic;
     reset_error                : in std_logic;
     rx_reset                   : in std_logic;
     tx_reset                   : in std_logic;

     dcm_locked                 : in std_logic;

     -- synchronous reset outputs
  
     glbl_rst_intn              : out std_logic;
   
     gtx_resetn                 : out std_logic := '0';
     
     s_axi_resetn               : out std_logic := '0';
     phy_resetn                 : out std_logic;
     chk_resetn                 : out std_logic := '0'
   );
   end component;

   ------------------------------------------------------------------------------
   -- internal signals used in this top level wrapper.
   ------------------------------------------------------------------------------

   -- example design clocks
   signal gtx_clk_bufg                       : std_logic;
   
   signal refclk_bufg                        : std_logic;
   signal s_axi_aclk                         : std_logic;
   signal rx_mac_aclk                        : std_logic;
   signal tx_mac_aclk                        : std_logic;
   signal phy_resetn_int                     : std_logic;
   -- resets (and reset generation)
   signal s_axi_resetn                       : std_logic;
   signal chk_resetn                         : std_logic;
   
   signal gtx_resetn                         : std_logic;
   
   signal rx_reset                           : std_logic;
   signal tx_reset                           : std_logic;

   signal dcm_locked                         : std_logic;
   signal glbl_rst_int                       : std_logic;
   signal phy_reset_count                    : unsigned(5 downto 0) := (others => '0');
   signal glbl_rst_intn                      : std_logic;


   -- USER side RX AXI-S interface
   signal rx_fifo_clock                      : std_logic;
   signal rx_fifo_resetn                     : std_logic;
   
 
   signal rx_axis_fifo_tready                : std_logic;
   

   -- USER side TX AXI-S interface
   signal tx_fifo_resetn                     : std_logic;
   
   
  -- signal tx_axis_fifo_tready                : std_logic;
   

   -- RX Statistics serialisation signals
   signal rx_statistics_valid                : std_logic;
   signal rx_statistics_valid_reg            : std_logic;
   signal rx_statistics_vector               : std_logic_vector(27 downto 0);
   signal rx_stats                           : std_logic_vector(27 downto 0);
   signal rx_stats_shift                     : std_logic_vector(29 downto 0);
   signal rx_stats_toggle                    : std_logic := '0';
   signal rx_stats_toggle_sync               : std_logic;
   signal rx_stats_toggle_sync_reg           : std_logic := '0';

   -- TX Statistics serialisation signals
   signal tx_statistics_valid                : std_logic;
   signal tx_statistics_valid_reg            : std_logic;
   signal tx_statistics_vector               : std_logic_vector(31 downto 0);
   signal tx_stats                           : std_logic_vector(31 downto 0);
   signal tx_stats_shift                     : std_logic_vector(33 downto 0);
   signal tx_stats_toggle                    : std_logic := '0';
   signal tx_stats_toggle_sync               : std_logic;
   signal tx_stats_toggle_sync_reg           : std_logic := '0';

   -- Pause interface DESerialisation
   signal pause_shift                        : std_logic_vector(18 downto 0);
   signal pause_req                          : std_logic;
   signal pause_val                          : std_logic_vector(15 downto 0);

   -- AXI-Lite interface
   signal s_axi_awaddr                       : std_logic_vector(11 downto 0);
   signal s_axi_awvalid                      : std_logic;
   signal s_axi_awready                      : std_logic;
   signal s_axi_wdata                        : std_logic_vector(31 downto 0);
   signal s_axi_wvalid                       : std_logic;
   signal s_axi_wready                       : std_logic;
   signal s_axi_bresp                        : std_logic_vector(1 downto 0);
   signal s_axi_bvalid                       : std_logic;
   signal s_axi_bready                       : std_logic;
   signal s_axi_araddr                       : std_logic_vector(11 downto 0);
   signal s_axi_arvalid                      : std_logic;
   signal s_axi_arready                      : std_logic;
   signal s_axi_rdata                        : std_logic_vector(31 downto 0);
   signal s_axi_rresp                        : std_logic_vector(1 downto 0);
   signal s_axi_rvalid                       : std_logic;
   signal s_axi_rready                       : std_logic;

   -- signal tie offs
   signal tx_ifg_delay                       : std_logic_vector(7 downto 0) := (others => '0');    -- not used in this example

  signal inband_link_status                  : std_logic;
  signal inband_clock_speed                  : std_logic_vector(1 downto 0);
  signal inband_duplex_status                : std_logic;
  signal int_frame_error                     : std_logic;
  signal int_activity_flash                  : std_logic;
signal tx_fifo_clock : std_logic;
  -- set board defaults - only updated when reprogrammed
  signal enable_address_swap                 : std_logic := '1';
            
  signal enable_phy_loopback                 : std_logic := '0';

     -------------------------------
signal      mac_speed                     :   std_logic_vector(1 downto 0) := "10";
 signal     update_speed                  :   std_logic;
 signal     config_board                  :   std_logic;
      --serial_command                : in  std_logic;  -- tied to pause_req_s
  signal    serial_response               :  std_logic;
 signal     gen_tx_data                   :   std_logic;
  signal    chk_tx_data                   : std_logic;
  signal    reset_error                   :   std_logic;
   signal   frame_error                   :  std_logic;
  signal    frame_errorn                  :  std_logic;
  signal    activity_flash                :  std_logic;
   signal   activity_flashn               :  std_logic;
  ------------------------------------------------------------------------------
  -- Begin architecture
  ------------------------------------------------------------------------------

begin

  example_clocks : mac_ip_example_design_clocks
   port map (
      -- differential clock inputs
      clk_in_p         => clk_in_p,
      clk_in_n         => clk_in_n,

      -- asynchronous control/resets
      glbl_rst         => glbl_rst,
      dcm_locked       => dcm_locked,

      -- clock outputs
      gtx_clk_bufg     => gtx_clk_bufg,
      refclk_bufg      => refclk_bufg,
      s_axi_aclk       => clk_100
   );
s_axi_aclk <= gtx_clk_bufg;
   -- Pass the GTX clock to the Test Bench
  -- gtx_clk_bufg_out <= gtx_clk_bufg;
   

   -- generate the user side clocks for the axi fifos
   
   tx_fifo_clock <= gtx_clk_bufg;
   rx_fifo_clock <= gtx_clk_bufg;
   


  ------------------------------------------------------------------------------
  -- Generate resets required for the fifo side signals etc
  ------------------------------------------------------------------------------

   example_resets : mac_ip_example_design_resets
   port map (
      -- clocks
      s_axi_aclk       => s_axi_aclk,
      gtx_clk          => gtx_clk_bufg,

      -- asynchronous resets
      glbl_rst         => glbl_rst,
      reset_error      => '0',
      rx_reset         => rx_reset,
      tx_reset         => tx_reset,

      dcm_locked       => dcm_locked,

      -- synchronous reset outputs
  
      glbl_rst_intn    => glbl_rst_intn,
   
      
      gtx_resetn       => gtx_resetn,
      
      s_axi_resetn     => s_axi_resetn,
      phy_resetn       => phy_resetn,
      chk_resetn       => chk_resetn
   );

   -- generate the user side resets for the axi fifos
   
   tx_fifo_resetn <= gtx_resetn;
   rx_fifo_resetn <= gtx_resetn;
   

  ------------------------------------------------------------------------------
  -- Serialize the stats vectors
  -- This is a single bit approach, retimed onto gtx_clk
  -- this code is only present to prevent code being stripped..
  ------------------------------------------------------------------------------

  -- RX STATS

  -- first capture the stats on the appropriate clock
   capture_rx_stats : process (rx_mac_aclk)
   begin
      if rx_mac_aclk'event and rx_mac_aclk = '1' then
         rx_statistics_valid_reg <= rx_statistics_valid;
         if rx_statistics_valid_reg = '0' and rx_statistics_valid = '1' then
            rx_stats        <= rx_statistics_vector;
            rx_stats_toggle <= not rx_stats_toggle;
         end if;
      end if;
   end process capture_rx_stats;

   rx_stats_sync : mac_ip_sync_block
   port map (
      clk              => gtx_clk_bufg,
      data_in          => rx_stats_toggle,
      data_out         => rx_stats_toggle_sync
   );

   reg_rx_toggle : process (gtx_clk_bufg)
   begin
      if gtx_clk_bufg'event and gtx_clk_bufg = '1' then
         rx_stats_toggle_sync_reg <= rx_stats_toggle_sync;
      end if;
   end process reg_rx_toggle;

   -- when an update is rxd load shifter (plus start/stop bit)
   -- shifter always runs (no power concerns as this is an example design)
   gen_shift_rx : process (gtx_clk_bufg)
   begin
      if gtx_clk_bufg'event and gtx_clk_bufg = '1' then
         if (rx_stats_toggle_sync_reg xor rx_stats_toggle_sync) = '1' then
            rx_stats_shift <= '1' & rx_stats &  '1';
         else
            rx_stats_shift <= rx_stats_shift(28 downto 0) & '0';
         end if;
      end if;
   end process gen_shift_rx;


  -- TX STATS

  -- first capture the stats on the appropriate clock
   capture_tx_stats : process (tx_mac_aclk)
   begin
      if tx_mac_aclk'event and tx_mac_aclk = '1' then
         tx_statistics_valid_reg <= tx_statistics_valid;
         if tx_statistics_valid_reg = '0' and tx_statistics_valid = '1' then
            tx_stats        <= tx_statistics_vector;
            tx_stats_toggle <= not tx_stats_toggle;
         end if;
      end if;
   end process capture_tx_stats;

   tx_stats_sync : mac_ip_sync_block
   port map (
      clk              => gtx_clk_bufg,
      data_in          => tx_stats_toggle,
      data_out         => tx_stats_toggle_sync
   );

   reg_tx_toggle : process (gtx_clk_bufg)
   begin
      if gtx_clk_bufg'event and gtx_clk_bufg = '1' then
         tx_stats_toggle_sync_reg <= tx_stats_toggle_sync;
      end if;
   end process reg_tx_toggle;

   -- when an update is txd load shifter (plus start bit)
   -- shifter always runs (no power concerns as this is an example design)
   gen_shift_tx : process (gtx_clk_bufg)
   begin
      if gtx_clk_bufg'event and gtx_clk_bufg = '1' then
         if (tx_stats_toggle_sync_reg /= tx_stats_toggle_sync) then
            tx_stats_shift <= '1' & tx_stats & '1';
         else
            tx_stats_shift <= tx_stats_shift(32 downto 0) & '0';
         end if;
      end if;
   end process gen_shift_tx;




   grab_pause : process (gtx_clk_bufg)
   begin
      if gtx_clk_bufg'event and gtx_clk_bufg = '1' then
         if (pause_shift(18) = '0' and pause_shift(17) = '1' and pause_shift(0) = '1') then
            pause_req <= '1';
            pause_val <= pause_shift(16 downto 1);
         else
            pause_req <= '0';
            pause_val <= (others => '0');
         end if;
      end if;
   end process grab_pause;

   ------------------------------------------------------------------------------
   -- Instantiate the AXI-LITE Controller
  ----------------------------------------------------------------------------

    axi_lite_controller : mac_ip_axi_lite_sm
    port map (
       s_axi_aclk                   => s_axi_aclk,
       s_axi_resetn                 => s_axi_resetn,

       mac_speed                    => mac_speed,
       update_speed                 => update_speed,
       serial_command               => '0',
       serial_response              => serial_response,
            
       phy_loopback                 => enable_phy_loopback,

       s_axi_awaddr                 => s_axi_awaddr,
       s_axi_awvalid                => s_axi_awvalid,
       s_axi_awready                => s_axi_awready,

       s_axi_wdata                  => s_axi_wdata,
       s_axi_wvalid                 => s_axi_wvalid,
       s_axi_wready                 => s_axi_wready,

       s_axi_bresp                  => s_axi_bresp,
       s_axi_bvalid                 => s_axi_bvalid,
       s_axi_bready                 => s_axi_bready,

       s_axi_araddr                 => s_axi_araddr,
       s_axi_arvalid                => s_axi_arvalid,
       s_axi_arready                => s_axi_arready,

       s_axi_rdata                  => s_axi_rdata,
       s_axi_rresp                  => s_axi_rresp,
       s_axi_rvalid                 => s_axi_rvalid,
       s_axi_rready                 => s_axi_rready
    );

   ------------------------------------------------------------------------------
   -- Instantiate the TRIMAC core FIFO Block wrapper
   ------------------------------------------------------------------------------
   trimac_fifo_block : mac_ip_fifo_block
    port map (
       gtx_clk                      => gtx_clk_bufg,
       
       
       -- asynchronous reset
        glbl_rstn                   => glbl_rst_intn,
        rx_axi_rstn                 => '1',
        tx_axi_rstn                 => '1',

       -- Reference clock for IDELAYCTRL's
       refclk                       => refclk_bufg,

       -- Receiver Statistics Interface
       -----------------------------------------
       rx_mac_aclk                  => rx_mac_aclk,
       rx_reset                     => rx_reset,
       rx_statistics_vector         => rx_statistics_vector,
       rx_statistics_valid          => rx_statistics_valid,

       -- Receiver => AXI-S Interface
       ------------------------------------------
       rx_fifo_clock                => rx_fifo_clock,
       rx_fifo_resetn               => rx_fifo_resetn,
       rx_axis_fifo_tready          => '1',
       rx_axis_fifo_tvalid          => rx_axis_fifo_tvalid,
       rx_axis_fifo_tdata           => rx_axis_fifo_tdata,
       rx_axis_fifo_tlast           => rx_axis_fifo_tlast,
       
       -- Transmitter Statistics Interface
       --------------------------------------------
       tx_mac_aclk                  => tx_mac_aclk,
       tx_reset                     => tx_reset,
       tx_ifg_delay                 => tx_ifg_delay,
       tx_statistics_vector         => tx_statistics_vector,
       tx_statistics_valid          => tx_statistics_valid,

       -- Transmitter => AXI-S Interface
       ---------------------------------------------
       tx_fifo_clock                => tx_fifo_clock,
       tx_fifo_resetn               => tx_fifo_resetn,
       tx_axis_fifo_tready          => tx_axis_fifo_tready,
       tx_axis_fifo_tvalid          => tx_axis_fifo_tvalid,
       tx_axis_fifo_tdata           => tx_axis_fifo_tdata,
       tx_axis_fifo_tlast           => tx_axis_fifo_tlast,
       

       -- MAC Control Interface
       --------------------------
       pause_req                    => pause_req,
       pause_val                    => pause_val,

       -- RGMII Interface
       --------------------
       rgmii_txd                    => rgmii_txd,
       rgmii_tx_ctl                 => rgmii_tx_ctl,
       rgmii_txc                    => rgmii_txc,
       rgmii_rxd                    => rgmii_rxd,
       rgmii_rx_ctl                 => rgmii_rx_ctl,
       rgmii_rxc                    => rgmii_rxc,

       -- RGMII Inband Status Registers
       ----------------------------------
       inband_link_status           => inband_link_status,
       inband_clock_speed           => inband_clock_speed,
       inband_duplex_status         => inband_duplex_status,

      
      -- MDIO Interface
      -----------------
       mdio                         => mdio,
       mdc                          => mdc,

       -- AXI-Lite Interface
       -----------------
       s_axi_aclk                   => s_axi_aclk,
       s_axi_resetn                 => s_axi_resetn,

       s_axi_awaddr                 => s_axi_awaddr,
       s_axi_awvalid                => s_axi_awvalid,
       s_axi_awready                => s_axi_awready,

       s_axi_wdata                  => s_axi_wdata,
       s_axi_wvalid                 => s_axi_wvalid,
       s_axi_wready                 => s_axi_wready,

       s_axi_bresp                  => s_axi_bresp,
       s_axi_bvalid                 => s_axi_bvalid,
       s_axi_bready                 => s_axi_bready,

       s_axi_araddr                 => s_axi_araddr,
       s_axi_arvalid                => s_axi_arvalid,
       s_axi_arready                => s_axi_arready,

       s_axi_rdata                  => s_axi_rdata,
       s_axi_rresp                  => s_axi_rresp,
       s_axi_rvalid                 => s_axi_rvalid,
       s_axi_rready                 => s_axi_rready

   );

clk_125 <= gtx_clk_bufg;
clk_200 <= refclk_bufg;



end wrapper;
