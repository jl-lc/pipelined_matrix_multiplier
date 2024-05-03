----------------------------------------------------------------------------------
-- Designer:        JLam
-- 
-- Date:            04/12/2024 12:25:05 AM
-- Name:            mat_mul_core_2x2 - RTL
-- Description:     16bit piplined signed 2x2 matrix multiplcation core
--                  Strassen algo Winograd var. 
--                  3 less additions than Strassen
--                  doesn't handle overflow
-- Specifications:  uses DSP IP for multiplication for performance
--                  500MHz clock speed
--                  synth worst negative slack:     0.070ns
--                  synth worst hold slack:         0.204ns
--                  synth worst pulse width slack:  0.175ns
--                  synth total on-ship power:      0.164W   (typical settings)
--                  synth dynamic power:            0.085W
--                  synth static power:             0.080W
--                  synth utilization:              360 LUTs, 1194 FFs, 7 DSPs
--
-- Dependencies:    /
-- Standards:       /
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- Citation:        S. Winograd. On Multiplication of 2 × 2 Matrices. Linear Algebra and Application, 4: 381-388, 1971
-- 
----------------------------------------------------------------------------------


library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;
    use IEEE.STD_LOGIC_SIGNED.ALL;

library work;

entity mat_mul_core_2x2 is 
generic (
    DATA_WIDTH  : integer := 16
);
port (
    iCLK                : in   std_logic;
    iREADY              : in   std_logic;
    iVALID_a, iVALID_b  : in   std_logic;
    iDATA_a, iDATA_b    : in   std_logic_vector(DATA_WIDTH*2*2-1 downto 0);     -- DATA_WIDTH = 4:  [A B] => std_logic_vector AAAABBBBCCCCDDDD
    oDATA               : out  std_logic_vector((DATA_WIDTH*2)*2*2-1 downto 0); --                  [C D]                     15   downto    0
    oVALID              : out  std_logic;
    oREADY              : out  std_logic;
    -- reset
    iRST                : in   std_logic
);
end entity mat_mul_core_2x2;

architecture RTL of mat_mul_core_2x2 is
    type p_data_i is array (3 downto 0) of signed(DATA_WIDTH-1 downto 0);
    type p_vec_i is array (3 downto 1) of signed(DATA_WIDTH-1 downto 0);
    type p_data_o is array (1 downto 0) of signed(DATA_WIDTH*2-1 downto 0);
    type p_res35_o is array (1 downto 0) of signed(DATA_WIDTH*2-1 downto 0);
    type p_res46_o is array (2 downto 0) of signed(DATA_WIDTH*2-1 downto 0);

    signal en, en_g : std_logic_vector(9 downto 0) := (others => '0');

    signal a1_meta : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal a2_meta : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal a3_meta : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal a4_meta : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal b1_meta : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal b2_meta : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal b3_meta : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal b4_meta : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal a1 : p_data_i;
    signal a2 : p_data_i;
    signal a3 : p_data_i;
    signal a4 : p_data_i;
    signal b1 : p_data_i;
    signal b2 : p_data_i;
    signal b3 : p_data_i;
    signal b4 : p_data_i;

    signal v1_meta : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal v2_meta : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal v3_meta : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal v4_meta : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal u1_meta : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal u2_meta : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal u3_meta : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal u4_meta : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal v1 : p_vec_i;
    signal v2 : p_vec_i;
    signal v3 : p_vec_i;
    signal v4 : p_vec_i;
    signal u1 : p_vec_i;
    signal u2 : p_vec_i;
    signal u3 : p_vec_i;
    signal u4 : p_vec_i;

    signal p1_meta : std_logic_vector(DATA_WIDTH*2-1 downto 0);
    signal p2_meta : std_logic_vector(DATA_WIDTH*2-1 downto 0);
    signal p3_meta : std_logic_vector(DATA_WIDTH*2-1 downto 0);
    signal p4_meta : std_logic_vector(DATA_WIDTH*2-1 downto 0);
    signal p5_meta : std_logic_vector(DATA_WIDTH*2-1 downto 0);
    signal p6_meta : std_logic_vector(DATA_WIDTH*2-1 downto 0);
    signal p7_meta : std_logic_vector(DATA_WIDTH*2-1 downto 0);

    signal p1 : signed(DATA_WIDTH*2-1 downto 0);
    signal p2 : signed(DATA_WIDTH*2-1 downto 0);
    signal p3 : p_res35_o;
    signal p4 : p_res46_o;
    signal p5 : p_res35_o;
    signal p6 : p_res46_o;
    signal p7 : signed(DATA_WIDTH*2-1 downto 0);

    signal o1_meta : p_data_o;
    signal o2_meta : p_data_o;
    signal o3_meta : p_data_o;
    signal o4_meta : p_data_o;

    constant idx1top : integer := DATA_WIDTH*(2*2)        - 1;
    constant idx1bot : integer := DATA_WIDTH*(2*2  * 3/4)    ;
    constant idx2top : integer := DATA_WIDTH*(2*2  * 3/4) - 1;
    constant idx2bot : integer := DATA_WIDTH*(2*2  /  2 )    ;
    constant idx3top : integer := DATA_WIDTH*(2*2  /  2 ) - 1;
    constant idx3bot : integer := DATA_WIDTH*(2*2  /  4 )    ;
    constant idx4top : integer := DATA_WIDTH*(2*2  /  4 ) - 1;
    constant idx4bot : integer := 0;
    
    constant idx1top_o : integer := (DATA_WIDTH*2)*(2*2)        - 1;
    constant idx1bot_o : integer := (DATA_WIDTH*2)*(2*2  * 3/4)    ;
    constant idx2top_o : integer := (DATA_WIDTH*2)*(2*2  * 3/4) - 1;
    constant idx2bot_o : integer := (DATA_WIDTH*2)*(2*2  /  2 )    ;
    constant idx3top_o : integer := (DATA_WIDTH*2)*(2*2  /  2 ) - 1;
    constant idx3bot_o : integer := (DATA_WIDTH*2)*(2*2  /  4 )    ;
    constant idx4top_o : integer := (DATA_WIDTH*2)*(2*2  /  4 ) - 1;
    constant idx4bot_o : integer := 0;
begin
    oREADY <= iREADY;

    enable_proc : process (iCLK) is
        variable count : INTEGER := 0;
    begin
        if rising_edge (iCLK) then
            if (iRST = '1') then
                en(en'high downto en'low+1) <= (others => '0');
            elsif (iREADY = '1') then
                en(en'high downto en'low+1) <= en(en'high-1 downto en'low); 
            end if;
        end if;
    end process enable_proc;

    en(0) <= (iREADY and iVALID_a and iVALID_b) when (iRST = '0') else '0';
    en_g  <= en when (iREADY = '1') else (others => '0');

    input_proc : process (iCLK) is
    begin
        if rising_edge (iCLK) then
            if (en_g(0) = '1') then
                a1(0) <= signed(iDATA_a(idx1top downto idx1bot));
                a2(0) <= signed(iDATA_a(idx2top downto idx2bot));
                a3(0) <= signed(iDATA_a(idx3top downto idx3bot));
                a4(0) <= signed(iDATA_a(idx4top downto idx4bot));
                b1(0) <= signed(iDATA_b(idx1top downto idx1bot));
                b2(0) <= signed(iDATA_b(idx2top downto idx2bot));
                b3(0) <= signed(iDATA_b(idx3top downto idx3bot));
                b4(0) <= signed(iDATA_b(idx4top downto idx4bot));
            end if;
        end if;
    end process input_proc;

    vectors_1_proc : process (iCLK) is
    begin
        if rising_edge(iCLK) then
            if (en_g(1) = '1') then
                a1(1) <= a1(0);
                a2(1) <= a2(0);
                a3(1) <= a3(0);
                a4(1) <= a4(0);
                b1(1) <= b1(0);
                b2(1) <= b2(0);
                b3(1) <= b3(0);
                b4(1) <= b4(0);

                v1(1) <= b4(0) - b2(0);
                v2(1) <= (others => '0');
                v3(1) <= (others => '0');
                v4(1) <= b2(0) - b1(0);

                u1(1) <= a1(0) - a3(0);
                u2(1) <= a3(0) + a4(0);
                u3(1) <= (others => '0');
                u4(1) <= (others => '0');
            end if;
        end if;
    end process vectors_1_proc;

    vectors_2_proc : process (iCLK) is
    begin
        if rising_edge(iCLK) then
            if (en_g(2) = '1') then
                a1(2) <= a1(1);
                a2(2) <= a2(1);
                a3(2) <= a3(1);
                a4(2) <= a4(1);
                b1(2) <= b1(1);
                b2(2) <= b2(1);
                b3(2) <= b3(1);
                b4(2) <= b4(1);

                v1(2) <= v1(1);
                v2(2) <= v1(1) + b1(1);
                v3(2) <= v3(1);
                v4(2) <= v4(1);

                u1(2) <= u1(1);
                u2(2) <= u2(1);
                u3(2) <= u1(1) - a4(1);
                u4(2) <= u4(1);
            end if;
        end if;
    end process vectors_2_proc;

    vectors_3_proc : process (iCLK) is
    begin
        if rising_edge(iCLK) then
            if (en_g(3) = '1') then
                a1(3) <= a1(2);
                a2(3) <= a2(2);
                a3(3) <= a3(2);
                a4(3) <= a4(2);
                b1(3) <= b1(2);
                b2(3) <= b2(2);
                b3(3) <= b3(2);
                b4(3) <= b4(2);

                v1(3) <= v1(2);
                v2(3) <= v2(2);
                v3(3) <= v2(2) - b3(2);
                v4(3) <= v4(2);

                u1(3) <= u1(2);
                u2(3) <= u2(2);
                u3(3) <= u3(2);
                u4(3) <= u3(2) + a2(2);
            end if;
        end if;
    end process vectors_3_proc;

    -- v1 <= b4 - b2;
    -- v2 <= v1 + b1;
    -- v3 <= v2 - b3;
    -- v4 <= b2 - b1;

    -- u1 <= a1 - a3;
    -- u2 <= a3 + a4;
    -- u3 <= u1 - a4;
    -- u4 <= u3 + a2;

    a1_meta <= std_logic_vector(a1(3));
    a2_meta <= std_logic_vector(a2(3));
    a3_meta <= std_logic_vector(a3(3));
    a4_meta <= std_logic_vector(a4(3));
    b1_meta <= std_logic_vector(b1(3));
    b2_meta <= std_logic_vector(b2(3));
    b3_meta <= std_logic_vector(b3(3));
    b4_meta <= std_logic_vector(b4(3));

    v1_meta <= std_logic_vector(v1(3));
    v2_meta <= std_logic_vector(v2(3));
    v3_meta <= std_logic_vector(v3(3));
    v4_meta <= std_logic_vector(v4(3));

    u1_meta <= std_logic_vector(u1(3));
    u2_meta <= std_logic_vector(u2(3));
    u3_meta <= std_logic_vector(u3(3));
    u4_meta <= std_logic_vector(u4(3));        

    mult_core_1 : entity work.mult_gen_0
    port map (
        CLK => iCLK,
        A   => a1_meta, -- p1_ff2 <= a1 * b1;
        B   => b1_meta,
        P   => p1_meta
    );

    mult_core_2 : entity work.mult_gen_0
    port map (
        CLK => iCLK,
        A   => a2_meta, -- p2_ff2 <= a2 * b3;
        B   => b3_meta,
        P   => p2_meta
    );

    mult_core_3 : entity work.mult_gen_0
    port map (
        CLK => iCLK,
        A   => a4_meta, -- p3_ff2 <= a4 * v3;
        B   => v3_meta,
        P   => p3_meta
    );

    mult_core_4 : entity work.mult_gen_0
    port map (
        CLK => iCLK,
        A   => u1_meta, -- p4_ff2 <= u1 * v1;
        B   => v1_meta,
        P   => p4_meta
    );

    mult_core_5 : entity work.mult_gen_0
    port map (
        CLK => iCLK,
        A   => u2_meta, -- p5_ff2 <= u2 * v4;
        B   => v4_meta,
        P   => p5_meta
    );

    mult_core_6 : entity work.mult_gen_0
    port map (
        CLK => iCLK,
        A   => u4_meta, -- p6_ff2 <= u4 * b4;
        B   => b4_meta,
        P   => p6_meta
    );

    mult_core_7 : entity work.mult_gen_0
    port map (
        CLK => iCLK,
        A   => u3_meta, -- p7_ff2 <= u3 * v2;
        B   => v2_meta,
        P   => p7_meta
    );

    p1    <= signed(p1_meta);
    p2    <= signed(p2_meta);
    p3(0) <= signed(p3_meta);
    p4(0) <= signed(p4_meta);
    p5(0) <= signed(p5_meta);
    p6(0) <= signed(p6_meta);
    p7    <= signed(p7_meta);

    sum_1_proc : process (iCLK) is
    begin
        if rising_edge(iCLK) then
            if (en_g(7) = '1') then
                o1_meta(0) <= p1 + p2;
                o2_meta(0) <= p1 - p7;
                o3_meta(0) <= p1 - p7;
                o4_meta(0) <= p1 - p7;

                p3(1) <= p3(0);
                p4(1) <= p4(0);
                p5(1) <= p5(0);
                p6(1) <= p6(0);
            end if;
        end if;
    end process sum_1_proc;

    sum_2_proc : process (iCLK) is
    begin
        if rising_edge(iCLK) then
            if (en_g(8) = '1') then
                o1_meta(1) <= o1_meta(0);
                o2_meta(1) <= o2_meta(0) + p5(1);
                o3_meta(1) <= o3_meta(0) - p3(1);
                o4_meta(1) <= o4_meta(0) + p5(1);

                p4(2) <= p4(1);
                p6(2) <= p6(1);
            end if;
        end if;
    end process sum_2_proc;

    output_proc : process (iCLK) is
    begin
        if rising_edge(iCLK) then
            if (en_g(9) = '1') then
                oDATA(idx1top_o downto idx1bot_o) <= std_logic_vector(o1_meta(1)     );
                oDATA(idx2top_o downto idx2bot_o) <= std_logic_vector(o2_meta(1) + p6(2));
                oDATA(idx3top_o downto idx3bot_o) <= std_logic_vector(o3_meta(1) + p4(2));
                oDATA(idx4top_o downto idx4bot_o) <= std_logic_vector(o4_meta(1) + p4(2));
            end if;
            oVALID <= en(en'high);
        end if;
    end process output_proc;

    -- p1 + p2
    -- p1 - p7 + p5 + p6
    -- p1 - p7 - p3 + p4
    -- p1 - p7 + p5 + p4

end RTL;