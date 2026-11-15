-- November 11, 2026
-- Isaias M Ramirez
-- The circuit describes a mux that coverts
-- a hex input to bits that become
-- the signals that illuminate leds on a 
-- 7 segment display to represent the 
-- hex input to it's corresponding character visually
-- dp is the bit that controls the radix point on the display
library IEEE; 
use IEEE.std_logic_1164.all;

entity hex_to_7seg is
    port(
        hex     :   in  STD_LOGIC_VECTOR ( 3 downto 0);
        dp      :   in  STD_LOGIC;
        sseg    :   out STD_LOGIC_VECTOR ( 7 downto 0)
    );
end hex_to_7seg;

architecture combinatorial_arch of hex_to_7seg is 
    --constants for readability 
    constant cZERO      : STD_LOGIC_VECTOR ( 6 downto 0 ) := "1000000";
    constant cONE       : STD_LOGIC_VECTOR ( 6 downto 0 ) := "1111001";
    constant cTWO       : STD_LOGIC_VECTOR ( 6 downto 0 ) := "0100100";
    constant cTHREE     : STD_LOGIC_VECTOR ( 6 downto 0 ) := "0110000";
    constant cFOUR      : STD_LOGIC_VECTOR ( 6 downto 0 ) := "0011001";
    constant cFIVE      : STD_LOGIC_VECTOR ( 6 downto 0 ) := "0010010";
    constant cSIX       : STD_LOGIC_VECTOR ( 6 downto 0 ) := "0000010";
    constant cSEVEN     : STD_LOGIC_VECTOR ( 6 downto 0 ) := "1111000";
    constant cEIGHT     : STD_LOGIC_VECTOR ( 6 downto 0 ) := "0000000";
    constant cNINE      : STD_LOGIC_VECTOR ( 6 downto 0 ) := "0010000";
    constant cHEXA      : STD_LOGIC_VECTOR ( 6 downto 0 ) := "0001000";
    constant cHEXB      : STD_LOGIC_VECTOR ( 6 downto 0 ) := "0000011";
    constant cHEXC      : STD_LOGIC_VECTOR ( 6 downto 0 ) := "1000110";
    constant cHEXD      : STD_LOGIC_VECTOR ( 6 downto 0 ) := "0100001";
    constant cHEXE      : STD_LOGIC_VECTOR ( 6 downto 0 ) := "0000110";
    constant cHEXF      : STD_LOGIC_VECTOR ( 6 downto 0 ) := "0001110";
begin
    with hex select
        sseg (6 downto 0) <= 
            cZERO    when "0000",
            cONE     when "0001",
            cTWO     when "0010",
            cTHREE   when "0011",
            cFOUR    when "0100",
            cFIVE    when "0101",
            cSIX     when "0110",
            cSEVEN   when "0111",
            cEIGHT   when "1000",
            cNINE    when "1001",
            cHEXA    when "1010",
            cHEXB    when "1011",
            cHEXC    when "1100",
            cHEXD    when "1101",
            cHEXE    when "1110",
            cHEXF    when "1111",
            "1111111" when others; -- off
        sseg(7) <= dp;
end combinatorial_arch;