-- October 31, 2026
-- Isaias M Ramirez
-- The circuit described within this file is a generic barrel shifter 
-- It can shift left or right as specified by lr (1 - left, 0 - right)
-- the valid shift range, in decimal, for the 'amt' input is 0 to barrel_bits
-- The barrel_bits is the number of binary bits for the input/output. 
-- This implementation uses an array of memory to store each shift result
-- the results are selected out of memory with amt being treated as the address. 
-- the shifted number is wrapped around by default
-- bits can be dropped using drop_bits = '1';

library IEEE; 
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity gen_LR_barrel_shifter is
    generic(
        barrel_bits : in integer := 8;
        amt_bits    : in integer := 3 
    );
    port(
        lr          : in   STD_LOGIC;
        drop_bits   : in   STD_LOGIC;
        binary_num  : in   STD_LOGIC_VECTOR (barrel_bits - 1 downto 0);
        amt         : in   STD_LOGIC_VECTOR (   amt_bits - 1 downto 0);
        shifted_out : out  STD_LOGIC_VECTOR (barrel_bits - 1 downto 0)
    );
end gen_LR_barrel_shifter;

architecture data_flow_arch of gen_LR_barrel_shifter is
    -- declare memory type that represents memory of size (amt_bits^2 - 1)x( barrel_bits - 1 )
    type        memory_t      is array (0 to barrel_bits - 1) of std_logic_vector( barrel_bits - 1 downto 0 );
    subtype     bit_range     is natural range 0 to barrel_bits - 1;
    signal      shifted_left  : memory_t := (others=> (others=>'0'));
    signal      shifted_right : memory_t := (others=> (others=>'0'));
    constant    cZEROS         : std_logic_vector (barrel_bits -1 downto 0) := (others => '0');
    constant    cMAX_INDX     : integer := barrel_bits - 1;
begin
    shift_right : for bit_indx in bit_range generate
        shifted_right(bit_indx) <= binary_num when bit_indx = 0 else
                                   binary_num(bit_indx - 1 downto 0) 
                                    & binary_num(cMAX_INDX downto bit_indx) 
                                              when bit_indx < barrel_bits else
                                   (others=>'0');
    end generate shift_right;

    shift_left : for bit_indx in bit_range generate
        shifted_left(bit_indx) <= binary_num  when bit_indx = 0 else
                                  binary_num((cMAX_INDX - bit_indx) downto 0) 
                                  & binary_num(cMAX_INDX downto (cMAX_INDX - bit_indx)+1) 
                                            when bit_indx < barrel_bits else
                                  (others=>'0'); 
    end generate shift_left;

-- output mux using the two options 
-- lr = '0' means shift right
-- lr = '1' means shift left
-- drop_bits = '0' means rotate the number
-- drop_bits = '1' means shift without rotating (drop the bits)
    shifted_out <=  shifted_right(to_integer(unsigned(amt))) 
                        when (lr = '0' 
                        AND 
                        amt < std_logic_vector(to_unsigned(barrel_bits -1, amt_bits))
                        AND
                        drop_bits = '0') else
                    shifted_left(to_integer(unsigned(amt)))  
                        when (lr = '1' 
                        AND 
                        amt < std_logic_vector(to_unsigned(barrel_bits -1, amt_bits))
                        AND
                        drop_bits ='0')else
                    -- dealing with zero shift edge case when drop_bits = 1;
                    shifted_right(to_integer(unsigned(amt))) 
                        when (amt = cZEROS(amt_bits -1 downto 0)
                        AND
                        drop_bits = '1') else      
                    cZEROS(to_integer(unsigned(amt)) - 1 downto 0) & shifted_right(to_integer(unsigned(amt)))(cMAX_INDX - to_integer(unsigned(amt)) downto 0) 
                        when (lr = '0' 
                        AND 
                        amt <= std_logic_vector(to_unsigned(barrel_bits -1, amt_bits))
                        AND
                        drop_bits = '1') else
                    shifted_left(to_integer(unsigned(amt)))(cMAX_INDX downto to_integer(unsigned(amt))) & cZEROS(to_integer(unsigned(amt)) - 1 downto 0)  
                        when (lr = '1' 
                        AND 
                        amt <= std_logic_vector(to_unsigned(barrel_bits -1, amt_bits))
                        AND
                        drop_bits ='1')else
                    (others => '0');

end data_flow_arch;