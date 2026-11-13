-- October 31, 2026
-- Isaias M Ramirez
-- The circuit described within this file is a generic barrel shifter 
-- It can shift left or right as specified by lr (1 - left, 0 - right)
-- the valid shift range, in decimal, for the 'amt' input is 0 to barrel_bits + 1
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
    --constants
    constant    cMAX_INDX          : integer := barrel_bits - 1;
    constant    cZEROS             : std_logic_vector (barrel_bits -1 downto 0) := (others => '0');
    -- declare memory type that represents memory of size (amt_bits^2 - 1)x( barrel_bits - 1 )
    type        memory_t           is array (0 to cMAX_INDX) of std_logic_vector( cMAX_INDX downto 0 );
    subtype     bit_range          is natural range 1 to cMAX_INDX;
    signal      shifted_left       : memory_t := (others=> (others=>'0'));
    signal      shifted_right      : memory_t := (others=> (others=>'0'));
    signal      shifted_left_drop  : memory_t := (others=> (others=>'0'));
    signal      shifted_right_drop : memory_t := (others=> (others=>'0'));
    
   
begin
    shift_right : for bit_indx in bit_range generate
        shifted_right(bit_indx) <= binary_num(bit_indx - 1 downto 0) 
                                & binary_num(cMAX_INDX downto bit_indx) 
                                          when bit_indx < barrel_bits else
                                (others=>'0');
    end generate shift_right;

    shift_left : for bit_indx in bit_range generate
        shifted_left(bit_indx) <= binary_num((cMAX_INDX - bit_indx) downto 0) 
                                & binary_num(cMAX_INDX downto (cMAX_INDX - bit_indx)+1) 
                                            when bit_indx < barrel_bits else
                                (others=>'0'); 
    end generate shift_left;

    shift_right_drop : for bit_indx in bit_range generate
        shifted_right_drop(bit_indx) <= cZeros(bit_indx - 1 downto 0) 
                                & binary_num(cMAX_INDX downto bit_indx) 
                                          when bit_indx < barrel_bits else
                                (others=>'0');
    end generate shift_right_drop;

    shift_left_drop : for bit_indx in bit_range generate
        shifted_left_drop(bit_indx) <= binary_num((cMAX_INDX - bit_indx) downto 0) 
                                & cZeros(cMAX_INDX downto (cMAX_INDX - bit_indx)+1) 
                                            when bit_indx < barrel_bits else
                                (others=>'0'); 
    end generate shift_left_drop;

-- output mux using the two options 
-- lr = '0' means shift right
-- lr = '1' means shift left
-- drop_bits = '0' means rotate the number
-- drop_bits = '1' means shift without rotating (drop the bits)
    shifted_out <=  binary_num when amt = cZeros(amt_bits - 1 downto 0)else             -- no shift
                    binary_num                                                          -- wrapped all the way around
                        when (amt = std_logic_vector(to_unsigned(cMAX_INDX+1, amt_bits))
                        AND
                        drop_bits = '0') else
                    shifted_right(to_integer(unsigned(amt))) 
                        when (lr = '0' 
                        AND 
                        amt <= std_logic_vector(to_unsigned(cMAX_INDX, amt_bits))
                        AND
                        drop_bits = '0') else
                    shifted_left(to_integer(unsigned(amt)))  
                        when (lr = '1' 
                        AND 
                        amt <= std_logic_vector(to_unsigned(cMAX_INDX, amt_bits))
                        AND
                        drop_bits ='0')else    
                    shifted_right_drop(to_integer(unsigned(amt)))
                        when (lr = '0' 
                        AND 
                        amt <= std_logic_vector(to_unsigned(cMAX_INDX, amt_bits))
                        AND
                        drop_bits = '1') else
                    shifted_left_drop(to_integer(unsigned(amt)))
                        when (lr = '1' 
                        AND 
                        amt <= std_logic_vector(to_unsigned(cMAX_INDX, amt_bits))
                        AND
                        drop_bits ='1')else
                    (others => '0');

end data_flow_arch;