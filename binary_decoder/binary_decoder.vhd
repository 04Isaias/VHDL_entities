-- October 30, 2026
-- Isaias M Ramirez
-- The circuit described within this file is a generic binary decoder.
-- The number of bits generic is the number of binary bits to decode. 
library IEEE; 
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity binary_decoder is
    generic(
        num_bits : in integer := 4
    );
    port(
        en          : in    STD_LOGIC;
        binary_num  : in    STD_LOGIC_VECTOR (num_bits-1        downto 0);
        decoded_num : out   STD_LOGIC_VECTOR ((2**num_bits) - 1 downto 0)
    );
end binary_decoder;

architecture data_flow_arch of binary_decoder is
    subtype bit_range is natural range 0 to 2**num_bits - 1;
    signal decoded : STD_LOGIC_VECTOR ((2**num_bits) - 1 downto 0) := (others=>'0');
begin
    gen_decoder : for bit_index in bit_range generate
        decoded(bit_index) <= 
            '1' when to_integer(unsigned(binary_num)) = bit_index else '0'; 
    end generate gen_decoder;
    
    decoded_num <=  decoded when en = '1' else
                    (others=>'0');

end data_flow_arch;