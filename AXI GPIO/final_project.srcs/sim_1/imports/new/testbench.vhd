-------------------------------------------------------------------------------
-- Title      : CSUN ECE 420 Final Project
-- Project    :
-------------------------------------------------------------------------------
-- File       : testbench.vhd<final_project.srcs>
-- Author     : Anna Bagdishyan 203475460
-- Company    : CSUN
-- Created    : 2026-04-09
-- Last update: 2026-04-25
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2024 CSUN
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author             Description
-- 2024-01-14  1.0      ABagdishyan        Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use std.env.finish;

library work;
use work.testing_pkg.all;

entity testbench is
end testbench;

architecture Behavioral of testbench is
  component top
    port (
      clk      : in  std_logic;
      reset    : in  std_logic;

      gpio_io_i : in  std_logic_vector(3 downto 0);
      gpio_io_o : out std_logic_vector(3 downto 0);
      gpio_io_t : out std_logic_vector(3 downto 0);

      locked   : out std_logic;
      clk_out  : out std_logic;

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
  end component;
   
    constant GPIO_DATA_ADDR : std_logic_vector(8 downto 0) := "000000000"; -- 0x000
    constant GPIO_TRI_ADDR  : std_logic_vector(8 downto 0) := "000000100"; -- 0x004
    
    signal clk_tb   : std_logic := '0';
    signal reset_tb : std_logic := '0';

    signal gpio_io_i_tb : std_logic_vector(3 downto 0) := (others => '0');
    signal gpio_io_o_tb : std_logic_vector(3 downto 0);
    signal gpio_io_t_tb : std_logic_vector(3 downto 0);

    signal locked_tb  : std_logic;
    signal clk_out_tb : std_logic;

    signal s_axi_awaddr_tb  : std_logic_vector(8 downto 0) := (others => '0');
    signal s_axi_awvalid_tb : std_logic := '0';
    signal s_axi_awready_tb : std_logic;

    signal s_axi_wdata_tb   : std_logic_vector(31 downto 0) := (others => '0');
    signal s_axi_wstrb_tb   : std_logic_vector(3 downto 0) := (others => '0');
    signal s_axi_wvalid_tb  : std_logic := '0';
    signal s_axi_wready_tb  : std_logic;

    signal s_axi_bresp_tb   : std_logic_vector(1 downto 0);
    signal s_axi_bvalid_tb  : std_logic;
    signal s_axi_bready_tb  : std_logic := '0';

    signal s_axi_araddr_tb  : std_logic_vector(8 downto 0) := (others => '0');
    signal s_axi_arvalid_tb : std_logic := '0';
    signal s_axi_arready_tb : std_logic;

    signal s_axi_rdata_tb   : std_logic_vector(31 downto 0);
    signal s_axi_rresp_tb   : std_logic_vector(1 downto 0);
    signal s_axi_rvalid_tb  : std_logic;
    signal s_axi_rready_tb  : std_logic := '0';

    signal test_done : boolean := false;

begin
  ------------------------------------------------------------------------------
  -- Free running clock from the board
  ------------------------------------------------------------------------------
  clk_gen(clk_tb, 125.0e6);

 ------------------------------------------------------------------------------
  -- Push button reset
  ------------------------------------------------------------------------------
  reset_process : process
  begin
    reset_tb <= '0';
    wait for 50 ns;
    reset_tb <= '1';
    wait for 100 ns;
    reset_tb <= '0';
    wait;
  end process;
  
  DUT_TOP : top
    port map (
      clk      => clk_tb,
      reset    => reset_tb,

      gpio_io_i => gpio_io_i_tb,
      gpio_io_o => gpio_io_o_tb,
      gpio_io_t => gpio_io_t_tb,

      locked   => locked_tb,
      clk_out  => clk_out_tb,

      s_axi_awaddr  => s_axi_awaddr_tb,
      s_axi_awvalid => s_axi_awvalid_tb,
      s_axi_awready => s_axi_awready_tb,

      s_axi_wdata   => s_axi_wdata_tb,
      s_axi_wstrb   => s_axi_wstrb_tb,
      s_axi_wvalid  => s_axi_wvalid_tb,
      s_axi_wready  => s_axi_wready_tb,

      s_axi_bresp   => s_axi_bresp_tb,
      s_axi_bvalid  => s_axi_bvalid_tb,
      s_axi_bready  => s_axi_bready_tb,

      s_axi_araddr  => s_axi_araddr_tb,
      s_axi_arvalid => s_axi_arvalid_tb,
      s_axi_arready => s_axi_arready_tb,

      s_axi_rdata   => s_axi_rdata_tb,
      s_axi_rresp   => s_axi_rresp_tb,
      s_axi_rvalid  => s_axi_rvalid_tb,
      s_axi_rready  => s_axi_rready_tb
    );

test_case : process is
begin
    wait until locked_tb = '1';
    wait for 20 us;

    -- Test 1 : setting GPIO to output mode
    s_axi_awaddr_tb  <= GPIO_TRI_ADDR;
    s_axi_wdata_tb   <= x"00000000";
    s_axi_wstrb_tb   <= "1111";
    s_axi_awvalid_tb <= '1';
    s_axi_wvalid_tb  <= '1';
    s_axi_bready_tb  <= '0';

    wait until rising_edge(clk_out_tb) and s_axi_awready_tb = '1' and s_axi_wready_tb  = '1';
    s_axi_awvalid_tb <= '0';
    s_axi_wvalid_tb  <= '0';
    
    -- Finish AXI write
    s_axi_bready_tb <= '1';
    wait until rising_edge(clk_out_tb) and s_axi_bvalid_tb = '1';
    s_axi_bready_tb <= '0';

    wait until rising_edge(clk_out_tb);
    wait for 1 ns;

    if gpio_io_t_tb /= "0000" then
        report "FAIL: gpio_io_t should be 0000 in output mode";
        finish;
    end if;


    -- Test 2: writing 1010
    s_axi_awaddr_tb  <= GPIO_DATA_ADDR;
    s_axi_wdata_tb   <= x"0000000A";
    s_axi_wstrb_tb   <= "1111";
    s_axi_awvalid_tb <= '1';
    s_axi_wvalid_tb  <= '1';
    s_axi_bready_tb  <= '0';

    wait until rising_edge(clk_out_tb) and s_axi_awready_tb = '1' and s_axi_wready_tb  = '1';
    s_axi_awvalid_tb <= '0';
    s_axi_wvalid_tb  <= '0';
    
    -- Finish AXI write
    s_axi_bready_tb <= '1';
    wait until rising_edge(clk_out_tb) and s_axi_bvalid_tb = '1';
    s_axi_bready_tb <= '0';

    wait until rising_edge(clk_out_tb);
    wait for 1 ns;

    if gpio_io_o_tb /= "1010" then
        report "FAIL: gpio_io_o should be 1010";
        finish;
    end if;


    -- Test 3: writing 0101
    s_axi_awaddr_tb  <= GPIO_DATA_ADDR;
    s_axi_wdata_tb   <= x"00000005";
    s_axi_wstrb_tb   <= "1111";
    s_axi_awvalid_tb <= '1';
    s_axi_wvalid_tb  <= '1';
    s_axi_bready_tb  <= '0';

    wait until rising_edge(clk_out_tb) and s_axi_awready_tb = '1' and s_axi_wready_tb  = '1';
    s_axi_awvalid_tb <= '0';
    s_axi_wvalid_tb  <= '0';
    
    -- Finish AXI write
    s_axi_bready_tb <= '1';
    wait until rising_edge(clk_out_tb) and s_axi_bvalid_tb = '1';
    s_axi_bready_tb <= '0';

    wait until rising_edge(clk_out_tb);
    wait for 1 ns;

    if gpio_io_o_tb /= "0101" then
        report "FAIL: gpio_io_o should be 0101";
        finish;
    end if;


    -- Test 4: switch to input mode
    s_axi_awaddr_tb  <= GPIO_TRI_ADDR;
    s_axi_wdata_tb   <= x"0000000F";
    s_axi_wstrb_tb   <= "1111";
    s_axi_awvalid_tb <= '1';
    s_axi_wvalid_tb  <= '1';
    s_axi_bready_tb  <= '0';

    wait until rising_edge(clk_out_tb) and s_axi_awready_tb = '1' and s_axi_wready_tb  = '1';
    s_axi_awvalid_tb <= '0';
    s_axi_wvalid_tb  <= '0';
    
    -- Finish AXI write
    s_axi_bready_tb <= '1';
    wait until rising_edge(clk_out_tb) and s_axi_bvalid_tb = '1';
    s_axi_bready_tb <= '0';

    wait until rising_edge(clk_out_tb);
    wait for 1 ns;

    if gpio_io_t_tb /= "1111" then
        report "FAIL: gpio_io_t should be 1111 in input mode";
        finish;
    end if;


    -- Test 5: reading input value 1100
    gpio_io_i_tb <= "1100";
    wait until rising_edge(clk_out_tb);
    wait until rising_edge(clk_out_tb);
    wait until rising_edge(clk_out_tb);
    wait for 1 ns;
    
    s_axi_araddr_tb  <= GPIO_DATA_ADDR;
    s_axi_arvalid_tb <= '1';
    s_axi_rready_tb  <= '0';

    wait until rising_edge(clk_out_tb) and s_axi_arready_tb = '1';
    s_axi_arvalid_tb <= '0';

    -- Finish AXI read
    s_axi_rready_tb <= '1';
    wait until rising_edge(clk_out_tb) and s_axi_rvalid_tb = '1';
    wait for 1 ns;
    
    if s_axi_rdata_tb(3 downto 0) /= "1100" then
        report "FAIL: readback should be 1100";
        finish;
    end if;

    s_axi_rready_tb <= '0';

    test_done <= true;
    wait;
end process;

  -----------------------------------------------------------------------------
  -- Check if test process is finished
  -- if so, end simulation.
  -----------------------------------------------------------------------------
  finish_proc : process (clk_tb)
  begin
    if rising_edge(clk_tb) then
      if test_done then
        simulation_done(0);
      end if;
    end if;
  end process;

 -----------------------------------------------------------------------------
  -- if the simulation fails to run in the correct amount of time, terminate
  -- it with a time out failure
  -----------------------------------------------------------------------------
  timeout_proc : process
  begin
    wait for 1 ms;
    if not test_done then
      report "FAIL: TIMEOUT";
      finish;
    end if;
  end process;

end Behavioral;