-- generated using copilot, does not verify drop_bits = 0 condition.
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity gen_LR_barrel_shifter_tb is
end gen_LR_barrel_shifter_tb;

architecture test of gen_LR_barrel_shifter_tb is
    constant barrel_bits : integer := 8;
    constant amt_bits    : integer := 3;

    signal lr          : std_logic := '0';
    signal drop_bits   : std_logic := '0';
    signal binary_num  : std_logic_vector(barrel_bits - 1 downto 0) := (others => '0');
    signal amt         : std_logic_vector(amt_bits - 1 downto 0) := (others => '0');
    signal shifted_out : std_logic_vector(barrel_bits - 1 downto 0);
    signal error_cnt   : unsigned(barrel_bits downto 0) := (others => '0');
begin
    dut : entity work.gen_LR_barrel_shifter
        generic map (
            barrel_bits => barrel_bits,
            amt_bits    => amt_bits
        )
        port map (
            lr          => lr,
            drop_bits   => drop_bits,
            binary_num  => binary_num,
            amt         => amt,
            shifted_out => shifted_out
        );
    drop_bits <= '1'; --drop the bits
    stimulus : process
        type input_array is array (natural range <>) of std_logic_vector(barrel_bits - 1 downto 0);
        constant test_values : input_array := ("10110110", "10000001");
        variable expected    : std_logic_vector(barrel_bits - 1 downto 0);
    begin
        for value_index in test_values'range loop
            binary_num <= test_values(value_index);

            for shift_amount in 0 to barrel_bits - 1 loop
                amt <= std_logic_vector(to_unsigned(shift_amount, amt_bits));

                lr <= '0';
                wait for 10 ns;
                expected := std_logic_vector(shift_right(unsigned(test_values(value_index)), shift_amount));
                assert shifted_out = expected
                    report "Right shift mismatch at amount=" & integer'image(shift_amount)
                    severity error;
                if(shifted_out /= expected) then 
                    report "Expected: 0b" & to_string(expected) severity note; 
                    report "Received: 0b" & to_string(shifted_out) severity note; 
                    error_cnt <= error_cnt + 1;
                end if;

                lr <= '1';
                wait for 10 ns;
                expected := std_logic_vector(shift_left(unsigned(test_values(value_index)), shift_amount));
                assert shifted_out = expected
                    report "Left shift mismatch at amount=" & integer'image(shift_amount)
                    severity error;
                if(shifted_out /= expected) then 
                    report "Expected: 0b" & to_string(expected) severity note; 
                    report "Received: 0b" & to_string(shifted_out) severity note; 
                    error_cnt <= error_cnt + 1;
                end if;
            end loop;
        end loop;

        report "Barrel shifter tests completed with " &
               integer'image(to_integer(error_cnt)) & " errors" severity note;
        wait;
    end process;
end test;
