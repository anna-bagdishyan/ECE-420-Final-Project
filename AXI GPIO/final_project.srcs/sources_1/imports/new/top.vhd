-------------------------------------------------------------------------------
-- Title      : CSUN ECE 420 Final Project
-- Project    : 
-------------------------------------------------------------------------------
-- File       : top.vhd<final_project.srcs>
-- Author     : Anna Bagdishyan 203475460
-- Company    : CSUN
-- Created    : 2026-04-09
-- Last update: 2026-04-15
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2024 CSUN
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity top is
    port (
      clk: in std_logic;
      reset: in std_logic;
      
      gpio_io_i : in  std_logic_vector(3 downto 0);
      gpio_io_o : out std_logic_vector(3 downto 0);
      gpio_io_t : out std_logic_vector(3 downto 0);
      
      locked: out std_logic;
      clk_out: out std_logic;
      
      s_axi_awaddr  : in  std_logic_vector(8 downto 0);
      s_axi_awvalid : in  std_logic;
      s_axi_awready : out std_logic;
      
      s_axi_wdata   : in  std_logic_vector(31 downto 0);
      s_axi_wstrb   : in  std_logic_vector(3 downto 0);
      s_axi_wvalid  : in  std_logic;
      s_axi_wready  : out std_logic;

      s_axi_bresp   : out std_logic_vector(1 downto 0);
      s_axi_bvalid  : out std_logic;
      s_axi_bready  : in  std_logic;

      s_axi_araddr  : in  std_logic_vector(8 downto 0);
      s_axi_arvalid : in  std_logic;
      s_axi_arready : out std_logic;

      s_axi_rdata   : out std_logic_vector(31 downto 0);
      s_axi_rresp   : out std_logic_vector(1 downto 0);
      s_axi_rvalid  : out std_logic;
      s_axi_rready  : in  std_logic
      
    );
end top;

architecture Behavioral of top is
    component system_controller
        generic (RESET_COUNT : integer := 32);
    port(                                 
        clk_in    : in  std_logic;
        reset_in  : in  std_logic;
        
        clk_out1  : out std_logic;
        locked    : out std_logic;
        reset_out : out std_logic        
        );
    end component;
      
    component axi_gpio_0
    port (
      s_axi_aclk : IN STD_LOGIC;
      s_axi_aresetn : IN STD_LOGIC;
      s_axi_awaddr : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
      s_axi_awvalid : IN STD_LOGIC;
      s_axi_awready : OUT STD_LOGIC;
      s_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s_axi_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      s_axi_wvalid : IN STD_LOGIC;
      s_axi_wready : OUT STD_LOGIC;
      s_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      s_axi_bvalid : OUT STD_LOGIC;
      s_axi_bready : IN STD_LOGIC;
      s_axi_araddr : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
      s_axi_arvalid : IN STD_LOGIC;
      s_axi_arready : OUT STD_LOGIC;
      s_axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      s_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      s_axi_rvalid : OUT STD_LOGIC;
      s_axi_rready : IN STD_LOGIC;
      gpio_io_i : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      gpio_io_o : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      gpio_io_t : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) 
      );
    end component;
    
    signal clk1 : std_logic;
    signal reset_int : std_logic;
    
    signal s_axi_aresetn : std_logic;
    
    begin
  -----------------------------------------------------------------------------
  -- System controller: generates two clock signals (clk1, clk2)
  -----------------------------------------------------------------------------  
        system_ctrl : system_controller
        port map (
           clk_in => clk,
           reset_in => reset,
           clk_out1    => clk1,
           locked  => locked,
           reset_out  => reset_int
          );
          
    clk_out <= clk1;
    s_axi_aresetn <= not reset_int;
    
  -----------------------------------------------------------------------------
  -- AXI GPIO instance
  -----------------------------------------------------------------------------  
        axi_gpio_0_inst : axi_gpio_0
          port map (
            s_axi_aclk => clk1,
            s_axi_aresetn => s_axi_aresetn,
            s_axi_awaddr => s_axi_awaddr,
            s_axi_awvalid => s_axi_awvalid,
            s_axi_awready => s_axi_awready,
            s_axi_wdata => s_axi_wdata,
            s_axi_wstrb => s_axi_wstrb,
            s_axi_wvalid => s_axi_wvalid,
            s_axi_wready => s_axi_wready,
            s_axi_bresp => s_axi_bresp,
            s_axi_bvalid => s_axi_bvalid,
            s_axi_bready => s_axi_bready,
            s_axi_araddr => s_axi_araddr,
            s_axi_arvalid => s_axi_arvalid,
            s_axi_arready => s_axi_arready,
            s_axi_rdata => s_axi_rdata,
            s_axi_rresp => s_axi_rresp,
            s_axi_rvalid => s_axi_rvalid,
            s_axi_rready => s_axi_rready,
            gpio_io_i => gpio_io_i,
            gpio_io_o => gpio_io_o,
            gpio_io_t => gpio_io_t
          );
            
end Behavioral;