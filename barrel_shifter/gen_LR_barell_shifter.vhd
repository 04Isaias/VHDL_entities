-- October 31, 2026
-- Isaias M Ramirez
-- The circuit described within this file is a generic barrell shifter 
-- It can shift left or right as specified by lr (1 - left, 0 - right)
-- It shifts by amount amt which is 2^n - 1 where n is amt_bits
-- The barell_bits is the number of binary bits for the input/output. 
library IEEE; 
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity gen_LR_barell_shifter is
    generic(
        barell_bits : in integer := 8;
        amt_bits    : in integer := 3 
    );
    port(
        lr          : in   STD_LOGIC;
        binary_num  : in   STD_LOGIC_VECTOR (barell_bits - 1 downto 0);
        amt         : in   STD_LOGIC_VECTOR (   amt_bits - 1 downto 0);
        shifted_out : out  STD_LOGIC_VECTOR (barell_bits - 1 downto 0)
    );
end gen_LR_barell_shifter;

architecture data_flow_arch of gen_LR_barell_shifter is
    subtype     bit_range is natural range 0 to amt_bits - 1;
    signal      shifted_left  : STD_LOGIC_VECTOR (barell_bits - 1 downto 0) := (others=>'0');
    signal      shifted_right : STD_LOGIC_VECTOR (barell_bits - 1 downto 0) := (others=>'0');
    constant    zeros         : STD_LOGIC_VECTOR (   amt_bits - 1 downto 0) := (others=>'0');
    constant    max_indx        : integer := barell_bits - 1;
begin
    shift_right : for bit_indx in bit_range generate
        shifted_right <= binary_num when amt = zeros else
                         binary_num(bit_indx-1 downto 0) 
                            & binary_num(max_indx downto bit_indx) 
                            when barell_bits = unsigned(amt) else
                         (others => '0'); 
    end generate shift_right;

    shift_left : for bit_indx in bit_range generate
        shifted_left <= binary_num when amt = zeros else
                        binary_num((max_indx - bit_indx)-1 downto 0) 
                            & binary_num(max_indx downto (max_indx - bit_indx)) 
                            when barell_bits = unsigned(amt) else
                        (others => '0'); 
    end generate shift_left;

    shifted_out <=  shifted_right when lr = '0' else
                    shifted_left  when lr = '1' else
                    (others => '0');

end data_flow_arch;