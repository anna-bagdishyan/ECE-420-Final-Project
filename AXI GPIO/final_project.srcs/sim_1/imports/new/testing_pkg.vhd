-------------------------------------------------------------------------------
-- Title      : Testing Package
-- Project    :
-------------------------------------------------------------------------------
-- File       : testing_pkg.vhd
-- Author     : Phil Tracton  <ptracton@gmail.com>
-- Company    : CSUN
-- Created    : 2023-08-19
-- Last update: 2023-10-27
-- Platform   : Modelsim on Linux
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2023 CSUN
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2023-08-19  1.0      ptracton        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use std.env.finish;

package testing_pkg is
  constant COUNTER       : integer := 10;
  constant STRING_LENGTH : integer := 32;

  shared variable test_fail    : boolean;
  shared variable test_done    : boolean;
  shared variable test_name    : string(32 downto 1);
  shared variable tests_ran    : integer;
  shared variable tests_to_run : integer;

  -- environment procedures
  procedure clk_gen(signal clk : out std_logic; constant FREQ : real);

  -- simulation support
  procedure simulation_start(constant str  : in string(32 downto 1); constant tests : in natural);
  procedure simulation_done(constant value :    natural);

  --! @brief Pad a short string to n characters length with a given character
  -- https://github.com/the-moog/vhdl_modular_blocks/tree/master
  function pads(constant s : string) return string;
  procedure print(msg      : string);

  -- results checking
  procedure compare(constant str      : in string;
                    constant minimum  : in std_logic_vector(31 downto 0);
                    constant maximum  : in std_logic_vector(31 downto 0);
                    constant measured : in std_logic_vector(31 downto 0)
                    );

  procedure write_sram(
    signal clk       : in  std_logic;
    signal ena       : out std_logic;
    signal wea       : out std_logic_vector(0 downto 0);
    signal addra     : out std_logic_vector(7 downto 0);
    signal dina      : out std_logic_vector(31 downto 0);
    constant address : in  std_logic_vector(7 downto 0);
    constant data    : in  std_logic_vector(31 downto 0)
    );

  procedure read_sram(
    signal clk       : in  std_logic;
    signal ena       : out std_logic;
    signal wea       : out std_logic_vector(0 downto 0);
    signal addra     : out std_logic_vector(7 downto 0);
    signal douta     : in  std_logic_vector(31 downto 0);
    constant address : in  std_logic_vector(7 downto 0);
    signal data      : out std_logic_vector(31 downto 0)
    );


  procedure write_character(
    signal clk     : in  std_logic;
    signal tx_dv   : out std_logic;
    signal tx_byte : out std_logic_vector(7 downto 0);
    constant byte  : in  std_logic_vector(7 downto 0)
    );

  procedure read_character(
    signal rx_dv   : in  std_logic;
    signal rx_byte : in  std_logic_vector(7 downto 0);
    signal byte    : out std_logic_vector(7 downto 0)
    );
    
     procedure send_letter(
      signal clk : in std_logic;
      signal new_letter : out std_logic;
      signal letter : out character;
      constant ch : in character
  );

end testing_pkg;

package body testing_pkg is
  ------------------------------------------------------------------------------
  --
  --
  -- 
  ------------------------------------------------------------------------------
  procedure simulation_done(constant value : natural) is
  begin
    -- if we have signalled fail or have executed the wrong number
    -- of test cases we have FAILED to test
    if (test_fail = true) then
      print(LF & "Test cases failed");
      print("TEST FAILED");
    elsif (tests_ran /= tests_to_run) then
      print(LF & "Incorrect number of test cases");
      print("TEST FAILED");
    else
      print(LF & "TEST PASSED");
    end if;
    finish;
  end procedure;

  ------------------------------------------------------------------------------
  --
  --
  -- 
  ------------------------------------------------------------------------------
  procedure simulation_start(constant str : in string(32 downto 1); constant tests : in natural) is
  begin
    test_name    := str;
    test_fail    := false;
    test_done    := false;
    tests_ran    := 0;
    tests_to_run := tests;
    print(LF & "STARTING " & test_name & LF);
    print("#   | TEST                             |  MIN     | MAX      | Measure  | Status ");
    print("---------------------------------------------------------------------------------");
  end procedure;

  ------------------------------------------------------------------------------
  --
  --
  -- 
  ------------------------------------------------------------------------------
  procedure print(msg : string) is
    variable l : line;
  begin
    write(l, msg);
    writeline(output, l);
  end procedure;

  ------------------------------------------------------------------------------
  --
  --
  -- 
  ------------------------------------------------------------------------------
  procedure compare(constant str      : in string;
                    constant minimum  : in std_logic_vector(31 downto 0);
                    constant maximum  : in std_logic_vector(31 downto 0);
                    constant measured : in std_logic_vector(31 downto 0)
                    ) is
    variable pass_fail : string(3 downto 0);
  begin
    pass_fail := "PASS";

    if (measured < minimum) or (measured > maximum) then
      --assert (measured < minimum) report str severity error;
      --assert (measured > maximum) report str severity error;
      test_fail := true;
      pass_fail := "FAIL";
    end if;
    print(to_string(tests_ran) & " | " & str & " | " & to_hstring(minimum) & " | " & to_hstring(maximum) & " | " & to_hstring(measured) & " | " &pass_fail);
    tests_ran := tests_ran + 1;
  end procedure;

  ------------------------------------------------------------------------------
  --
  --
  -- 
  ------------------------------------------------------------------------------
  function pads(constant s : string) return string is
    variable temp    : string(1 to STRING_LENGTH);
    constant padchar : character := ' ';
  begin
    if STRING_LENGTH > s'length then
      temp(1 to s'length)                 := s;
      temp(s'length + 1 to STRING_LENGTH) := (others => padchar);
    else
      temp := s(1 to STRING_LENGTH);
    end if;
    return temp;
  end function;

  ------------------------------------------------------------------------------
  --
  -- https://stackoverflow.com/questions/17904514/vhdl-how-should-i-create-a-clock-in-a-testbench
  -- Procedure for clock generation
  -- 
  ------------------------------------------------------------------------------
  procedure clk_gen(signal clk : out std_logic; constant FREQ : real) is
    constant PERIOD    : time := 1 sec / FREQ;        -- Full period
    constant HIGH_TIME : time := PERIOD / 2;          -- High time
    constant LOW_TIME  : time := PERIOD - HIGH_TIME;  -- Low time; always >= HIGH_TIME
  begin
    -- Check the arguments
    assert (HIGH_TIME /= 0 fs) report "clk_plain: High time is zero; time resolution to large for frequency" severity failure;
    -- Generate a clock cycle
    loop
      clk <= '1';
      wait for HIGH_TIME;
      clk <= '0';
      wait for LOW_TIME;
    end loop;
  end procedure;

  ------------------------------------------------------------------------------
  --
  -- https://community.intel.com/t5/Programmable-Devices/conversion-of-std-logic-NOT-std-logic-vector-to-integer/td-p/106144
  -- 
  ------------------------------------------------------------------------------
  function to_integer(s : std_logic) return natural is
  begin
    if s = '1' then
      return 1;
    else
      return 0;
    end if;
  end function;

  ------------------------------------------------------------------------------
  --
  --
  -- 
  ------------------------------------------------------------------------------
  procedure write_sram(
    signal clk       : in  std_logic;
    signal ena       : out std_logic;
    signal wea       : out std_logic_vector(0 downto 0);
    signal addra     : out std_logic_vector(7 downto 0);
    signal dina      : out std_logic_vector(31 downto 0);
    constant address : in  std_logic_vector(7 downto 0);
    constant data    : in  std_logic_vector(31 downto 0))
  is
  begin

    wait until rising_edge(clk);
    ena   <= '1';
    wea   <= "1";
    addra <= address;
    dina  <= data;
    wait until rising_edge(clk);
    ena   <= '0';
    wea   <= "0";
  --addra <= (others => '0');
  --dina  <= (others => '0');
  end procedure;

  ------------------------------------------------------------------------------
  --
  --
  -- 
  ------------------------------------------------------------------------------
  procedure read_sram(
    signal clk       : in  std_logic;
    signal ena       : out std_logic;
    signal wea       : out std_logic_vector(0 downto 0);
    signal addra     : out std_logic_vector(7 downto 0);
    signal douta     : in  std_logic_vector(31 downto 0);
    constant address : in  std_logic_vector(7 downto 0);
    signal data      : out std_logic_vector(31 downto 0)
    ) is
  begin

    wait until rising_edge(clk);
    ena   <= '1';
    wea   <= "0";
    addra <= address;
    wait until rising_edge(clk);
    wait until falling_edge(clk);
    ena   <= '0';
    wea   <= "0";
    data  <= douta;

  end procedure;

  procedure write_character(
    signal clk     : in  std_logic;
    signal tx_dv   : out std_logic;
    signal tx_byte : out std_logic_vector(7 downto 0);
    constant byte  : in  std_logic_vector(7 downto 0)
    ) is
  begin
    wait until rising_edge(clk);
    tx_dv   <= '1';
    tx_byte <= byte;
    wait until rising_edge(clk);
    tx_dv   <= '0';
  end procedure;

  procedure read_character(
    signal rx_dv   : in  std_logic;
    signal rx_byte : in  std_logic_vector(7 downto 0);
    signal byte    : out std_logic_vector(7 downto 0)
    ) is
  begin
    wait until rx_dv = '1';
    byte <= rx_byte;
  end procedure;
  
  procedure send_letter(
      signal clk : in std_logic;
      signal new_letter : out std_logic;
      signal letter : out character;
      constant ch : in character
  ) is
  begin
      wait until rising_edge(clk);
      letter <= ch;
      new_letter <= '1';

      wait until rising_edge(clk);
      new_letter <= '0';
      letter <= '0';
      
  end procedure;
  
  
end testing_pkg;