----------------------------------------------------------------------------------
-- Designer:        JLam
-- 
-- Date:            04/07/2024 01:43:19 PM
-- Name:            mat_mul_tb - Behavioral
-- Description:     simple tb
--
-- Dependencies:    /
-- Standards:       /
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;
    use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;

library std;
    use std.standard.all;
    use std.textio.all;

entity mat_mul_tb is
end mat_mul_tb;

architecture Behavioral of mat_mul_tb is
    signal clk, reset : std_logic;

    constant data_width     : integer := 16; -- hex

    -- mat mul core
    signal ready            : std_logic := '1';
    signal ready_out        : std_logic;
    signal valid_a, valid_b : std_logic := '0';
    signal data_a, data_b   : std_logic_vector(data_width*16-1 downto 0); 
    signal data_o           : std_logic_vector((data_width*2)*16-1 downto 0);
    signal valid_o          : std_logic := '0';

    constant clk_period  : time := 2.5 ns;
begin

    --  mat_mul_core : entity work.mat_mul_core_2x2
    --  generic map (
    --      DATA_WIDTH  => data_width
    --  )
    --  port map (
    --      iCLK        => clk,
    --      iREADY      => ready,
    --      iVALID_a    => valid_a,
    --      iVALID_b    => valid_b,
    --      iDATA_a     => data_a,
    --      iDATA_b     => data_b,
    --      oDATA       => data_o,
    --      oVALID      => valid_o,
    --      iRST        => reset
    --  );

    ready <= '1';

    mat_mul_core : entity work.mat_mul_core_4x4
    generic map (
        DATA_WIDTH  => data_width
    )
    port map (
        iCLK        => clk,
        iREADY      => ready,
        iVALID_a    => valid_a,
        iVALID_b    => valid_b,
        iDATA_a     => data_a,
        iDATA_b     => data_b,
        oDATA       => data_o,
        oVALID      => valid_o,
        oREADY      => ready_out,
        iRST        => reset
    );

    rd_clock_gen : process is
    begin
        clk <= '1';
        wait for clk_period/2;
        clk <= '0';
        wait for clk_period/2;
    end process rd_clock_gen;
    
    input : process (clk) is
        file file_in_a : text is in "input_values_a.txt";
        file file_in_b : text is in "input_values_b.txt";
        variable line_in_a, line_in_b : line;
        variable f_data_a, f_data_b : std_logic_vector(data_width*4*4-1 downto 0);
    begin
        if rising_edge(clk) then
            -- input a
            if not endfile(file_in_a) then
                readline(file_in_a, line_in_a);
                hread(line_in_a, f_data_a);
                data_a <= f_data_a;
                valid_a <= '1';
            else
                valid_a <= '0';
            end if;

            -- input b
            if not endfile(file_in_b) then
                readline(file_in_b, line_in_b);
                hread(line_in_b, f_data_b);
                data_b <= f_data_b;
                valid_b <= '1';
            else
                valid_b <= '0';
            end if;
        end if;
    end process input;

    output : process(clk) is    
        file file_out  : text is out "output_results.txt";
        variable line_out : line;
    begin        
        if rising_edge(clk) then
            if (valid_o = '1') then
                hwrite(line_out, data_o);
                writeline(file_out, line_out);
            end if;
        end if;
    end process output;

    stimulus : process (clk) is
    begin
        if rising_edge (clk) then
            reset <= '0';
        end if;
    end process stimulus;

end Behavioral;
