----------------------------------------------------------------------------------
-- Designer:        JLam
-- 
-- Date:            04/12/2024 12:25:05 AM
-- Name:            mat_mul_core_strass - RTL
-- Description:     16bit piplined signed 4x4 matrix multiplcation core
--
-- Dependencies:    mat_mul_core_2x2 - RTL
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

entity mat_mul_core_strass is 
generic (
    DATA_WIDTH  : integer := 16
    -- POWER       : integer := 4 -- even int >2
);
port (
    -- input signals
    iCLK                    : in   std_logic;
    iREADY                  : in   std_logic;
    iVALID_a, iVALID_b      : in   std_logic;
    iDATA_a, iDATA_b        : in   std_logic_vector(DATA_WIDTH*4*4 - 1 downto 0);
    
    -- propagate signals
    oPVALID_a1, oPVALID_b1  : out  std_logic;
    oPVALID_a2, oPVALID_b2  : out  std_logic;
    oPVALID_a3, oPVALID_b3  : out  std_logic;
    oPVALID_a4, oPVALID_b4  : out  std_logic;
    oPVALID_a5, oPVALID_b5  : out  std_logic;
    oPVALID_a6, oPVALID_b6  : out  std_logic;
    oPVALID_a7, oPVALID_b7  : out  std_logic;
    oPDATA_a1, oPDATA_b1    : out  std_logic_vector(DATA_WIDTH*2*2 - 1 downto 0);
    oPDATA_a2, oPDATA_b2    : out  std_logic_vector(DATA_WIDTH*2*2 - 1 downto 0);
    oPDATA_a3, oPDATA_b3    : out  std_logic_vector(DATA_WIDTH*2*2 - 1 downto 0);
    oPDATA_a4, oPDATA_b4    : out  std_logic_vector(DATA_WIDTH*2*2 - 1 downto 0);
    oPDATA_a5, oPDATA_b5    : out  std_logic_vector(DATA_WIDTH*2*2 - 1 downto 0);
    oPDATA_a6, oPDATA_b6    : out  std_logic_vector(DATA_WIDTH*2*2 - 1 downto 0);
    oPDATA_a7, oPDATA_b7    : out  std_logic_vector(DATA_WIDTH*2*2 - 1 downto 0);
    iPDATA_1                : in   std_logic_vector((DATA_WIDTH*2)*2*2 - 1 downto 0);
    iPDATA_2                : in   std_logic_vector((DATA_WIDTH*2)*2*2 - 1 downto 0);
    iPDATA_3                : in   std_logic_vector((DATA_WIDTH*2)*2*2 - 1 downto 0);
    iPDATA_4                : in   std_logic_vector((DATA_WIDTH*2)*2*2 - 1 downto 0);
    iPDATA_5                : in   std_logic_vector((DATA_WIDTH*2)*2*2 - 1 downto 0);
    iPDATA_6                : in   std_logic_vector((DATA_WIDTH*2)*2*2 - 1 downto 0);
    iPDATA_7                : in   std_logic_vector((DATA_WIDTH*2)*2*2 - 1 downto 0);
    iPVALID_1               : in   std_logic;
    iPVALID_2               : in   std_logic;
    iPVALID_3               : in   std_logic;
    iPVALID_4               : in   std_logic;
    iPVALID_5               : in   std_logic;
    iPVALID_6               : in   std_logic;
    iPVALID_7               : in   std_logic;

    -- outputs
    oDATA                   : out  std_logic_vector((DATA_WIDTH*2)*4*4 - 1 downto 0);
    oVALID                  : out  std_logic;
    oREADY                  : out  std_logic;
    -- reset    
    iRST                    : in   std_logic
);
end entity mat_mul_core_strass;

architecture RTL of mat_mul_core_strass is
    type p_data_i is array (3 downto 0) of signed(DATA_WIDTH*2*2 - 1 downto 0);
    type p_vec_i  is array (3 downto 1) of signed(DATA_WIDTH*2*2 - 1 downto 0);
    type p_data_o is array (2 downto 0) of signed((DATA_WIDTH*2)*2*2 - 1 downto 0);
    type p_res35_o is array (1 downto 0) of signed((DATA_WIDTH*2)*2*2 - 1 downto 0);
    type p_res46_o is array (2 downto 0) of signed((DATA_WIDTH*2)*2*2 - 1 downto 0);

    signal en,  en_g  : std_logic_vector(4 downto 0) := (others => '0');
    signal en2, en_g2 : std_logic_vector(4 downto 0) := (others => '0');
        
    signal a1_1 : signed(DATA_WIDTH-1 downto 0);
    signal a1_2 : signed(DATA_WIDTH-1 downto 0);
    signal a1_3 : signed(DATA_WIDTH-1 downto 0);
    signal a1_4 : signed(DATA_WIDTH-1 downto 0);
    signal a2_1 : signed(DATA_WIDTH-1 downto 0);
    signal a2_2 : signed(DATA_WIDTH-1 downto 0);
    signal a2_3 : signed(DATA_WIDTH-1 downto 0);
    signal a2_4 : signed(DATA_WIDTH-1 downto 0);
    signal a3_1 : signed(DATA_WIDTH-1 downto 0);
    signal a3_2 : signed(DATA_WIDTH-1 downto 0);
    signal a3_3 : signed(DATA_WIDTH-1 downto 0);
    signal a3_4 : signed(DATA_WIDTH-1 downto 0);
    signal a4_1 : signed(DATA_WIDTH-1 downto 0);
    signal a4_2 : signed(DATA_WIDTH-1 downto 0);
    signal a4_3 : signed(DATA_WIDTH-1 downto 0);
    signal a4_4 : signed(DATA_WIDTH-1 downto 0);
    signal b1_1 : signed(DATA_WIDTH-1 downto 0);
    signal b1_2 : signed(DATA_WIDTH-1 downto 0);
    signal b1_3 : signed(DATA_WIDTH-1 downto 0);
    signal b1_4 : signed(DATA_WIDTH-1 downto 0);
    signal b2_1 : signed(DATA_WIDTH-1 downto 0);
    signal b2_2 : signed(DATA_WIDTH-1 downto 0);
    signal b2_3 : signed(DATA_WIDTH-1 downto 0);
    signal b2_4 : signed(DATA_WIDTH-1 downto 0);
    signal b3_1 : signed(DATA_WIDTH-1 downto 0);
    signal b3_2 : signed(DATA_WIDTH-1 downto 0);
    signal b3_3 : signed(DATA_WIDTH-1 downto 0);
    signal b3_4 : signed(DATA_WIDTH-1 downto 0);
    signal b4_1 : signed(DATA_WIDTH-1 downto 0);
    signal b4_2 : signed(DATA_WIDTH-1 downto 0);
    signal b4_3 : signed(DATA_WIDTH-1 downto 0);
    signal b4_4 : signed(DATA_WIDTH-1 downto 0);

    signal a1_meta : std_logic_vector(DATA_WIDTH*2*2 - 1 downto 0);
    signal a2_meta : std_logic_vector(DATA_WIDTH*2*2 - 1 downto 0);
    signal a3_meta : std_logic_vector(DATA_WIDTH*2*2 - 1 downto 0);
    signal a4_meta : std_logic_vector(DATA_WIDTH*2*2 - 1 downto 0);
    signal b1_meta : std_logic_vector(DATA_WIDTH*2*2 - 1 downto 0);
    signal b2_meta : std_logic_vector(DATA_WIDTH*2*2 - 1 downto 0);
    signal b3_meta : std_logic_vector(DATA_WIDTH*2*2 - 1 downto 0);
    signal b4_meta : std_logic_vector(DATA_WIDTH*2*2 - 1 downto 0);

    signal a1 : p_data_i;
    signal a2 : p_data_i;
    signal a3 : p_data_i;
    signal a4 : p_data_i;
    signal b1 : p_data_i;
    signal b2 : p_data_i;
    signal b3 : p_data_i;
    signal b4 : p_data_i;
    
    signal v1_meta : std_logic_vector(DATA_WIDTH*2*2 - 1 downto 0);
    signal v2_meta : std_logic_vector(DATA_WIDTH*2*2 - 1 downto 0);
    signal v3_meta : std_logic_vector(DATA_WIDTH*2*2 - 1 downto 0);
    signal v4_meta : std_logic_vector(DATA_WIDTH*2*2 - 1 downto 0);
    signal u1_meta : std_logic_vector(DATA_WIDTH*2*2 - 1 downto 0);
    signal u2_meta : std_logic_vector(DATA_WIDTH*2*2 - 1 downto 0);
    signal u3_meta : std_logic_vector(DATA_WIDTH*2*2 - 1 downto 0);
    signal u4_meta : std_logic_vector(DATA_WIDTH*2*2 - 1 downto 0);

    signal v1 : p_vec_i;
    signal v2 : p_vec_i;
    signal v3 : p_vec_i;
    signal v4 : p_vec_i;
    signal u1 : p_vec_i;
    signal u2 : p_vec_i;
    signal u3 : p_vec_i;
    signal u4 : p_vec_i;
    
    signal p1 : signed((DATA_WIDTH*2)*2*2 - 1 downto 0);
    signal p2 : signed((DATA_WIDTH*2)*2*2 - 1 downto 0);
    signal p3 : p_res35_o;
    signal p4 : p_res46_o;
    signal p5 : p_res35_o;
    signal p6 : p_res46_o;
    signal p7 : signed((DATA_WIDTH*2)*2*2 - 1 downto 0);   

    signal o1_meta : p_data_o;
    signal o2_meta : p_data_o;
    signal o3_meta : p_data_o;
    signal o4_meta : p_data_o;

    signal o1 : signed((DATA_WIDTH*2)*2*2 - 1 downto 0);
    signal o2 : signed((DATA_WIDTH*2)*2*2 - 1 downto 0);
    signal o3 : signed((DATA_WIDTH*2)*2*2 - 1 downto 0);
    signal o4 : signed((DATA_WIDTH*2)*2*2 - 1 downto 0);

    signal o1_1 : signed((DATA_WIDTH*2)-1 downto 0);
    signal o1_2 : signed((DATA_WIDTH*2)-1 downto 0);
    signal o1_3 : signed((DATA_WIDTH*2)-1 downto 0);
    signal o1_4 : signed((DATA_WIDTH*2)-1 downto 0);
    signal o2_1 : signed((DATA_WIDTH*2)-1 downto 0);
    signal o2_2 : signed((DATA_WIDTH*2)-1 downto 0);
    signal o2_3 : signed((DATA_WIDTH*2)-1 downto 0);
    signal o2_4 : signed((DATA_WIDTH*2)-1 downto 0);
    signal o3_1 : signed((DATA_WIDTH*2)-1 downto 0);
    signal o3_2 : signed((DATA_WIDTH*2)-1 downto 0);
    signal o3_3 : signed((DATA_WIDTH*2)-1 downto 0);
    signal o3_4 : signed((DATA_WIDTH*2)-1 downto 0);
    signal o4_1 : signed((DATA_WIDTH*2)-1 downto 0);
    signal o4_2 : signed((DATA_WIDTH*2)-1 downto 0);
    signal o4_3 : signed((DATA_WIDTH*2)-1 downto 0);
    signal o4_4 : signed((DATA_WIDTH*2)-1 downto 0);

    constant idx1top_dat  : integer := DATA_WIDTH*(16) - 1;
    constant idx1bot_dat  : integer := DATA_WIDTH*(15)    ;
    constant idx2top_dat  : integer := DATA_WIDTH*(15) - 1;
    constant idx2bot_dat  : integer := DATA_WIDTH*(14)    ;
    constant idx3top_dat  : integer := DATA_WIDTH*(14) - 1;
    constant idx3bot_dat  : integer := DATA_WIDTH*(13)    ;
    constant idx4top_dat  : integer := DATA_WIDTH*(13) - 1;
    constant idx4bot_dat  : integer := DATA_WIDTH*(12)    ;
    constant idx5top_dat  : integer := DATA_WIDTH*(12) - 1;
    constant idx5bot_dat  : integer := DATA_WIDTH*(11)    ;
    constant idx6top_dat  : integer := DATA_WIDTH*(11) - 1;
    constant idx6bot_dat  : integer := DATA_WIDTH*(10)    ;
    constant idx7top_dat  : integer := DATA_WIDTH*(10) - 1;
    constant idx7bot_dat  : integer := DATA_WIDTH*(9 )    ;
    constant idx8top_dat  : integer := DATA_WIDTH*(9 ) - 1;
    constant idx8bot_dat  : integer := DATA_WIDTH*(8 )    ;
    constant idx9top_dat  : integer := DATA_WIDTH*(8 ) - 1;
    constant idx9bot_dat  : integer := DATA_WIDTH*(7 )    ;
    constant idx10top_dat : integer := DATA_WIDTH*(7 ) - 1;
    constant idx10bot_dat : integer := DATA_WIDTH*(6 )    ;
    constant idx11top_dat : integer := DATA_WIDTH*(6 ) - 1;
    constant idx11bot_dat : integer := DATA_WIDTH*(5 )    ;
    constant idx12top_dat : integer := DATA_WIDTH*(5 ) - 1;
    constant idx12bot_dat : integer := DATA_WIDTH*(4 )    ;
    constant idx13top_dat : integer := DATA_WIDTH*(4 ) - 1;
    constant idx13bot_dat : integer := DATA_WIDTH*(3 )    ;
    constant idx14top_dat : integer := DATA_WIDTH*(3 ) - 1;
    constant idx14bot_dat : integer := DATA_WIDTH*(2 )    ;
    constant idx15top_dat : integer := DATA_WIDTH*(2 ) - 1;
    constant idx15bot_dat : integer := DATA_WIDTH*(1 )    ;
    constant idx16top_dat : integer := DATA_WIDTH*(1 ) - 1;
    constant idx16bot_dat : integer := 0;

    constant idx1top_4x4 : integer := DATA_WIDTH*(4*4)        - 1;
    constant idx1bot_4x4 : integer := DATA_WIDTH*(4*4  * 3/4)    ;
    constant idx2top_4x4 : integer := DATA_WIDTH*(4*4  * 3/4) - 1;
    constant idx2bot_4x4 : integer := DATA_WIDTH*(4*4  /  2 )    ;
    constant idx3top_4x4 : integer := DATA_WIDTH*(4*4  /  2 ) - 1;
    constant idx3bot_4x4 : integer := DATA_WIDTH*(4*4  /  4 )    ;
    constant idx4top_4x4 : integer := DATA_WIDTH*(4*4  /  4 ) - 1;
    constant idx4bot_4x4 : integer := 0;

    constant idx1top_2x2 : integer := DATA_WIDTH*(2*2)        - 1;
    constant idx1bot_2x2 : integer := DATA_WIDTH*(2*2  * 3/4)    ;
    constant idx2top_2x2 : integer := DATA_WIDTH*(2*2  * 3/4) - 1;
    constant idx2bot_2x2 : integer := DATA_WIDTH*(2*2  /  2 )    ;
    constant idx3top_2x2 : integer := DATA_WIDTH*(2*2  /  2 ) - 1;
    constant idx3bot_2x2 : integer := DATA_WIDTH*(2*2  /  4 )    ;
    constant idx4top_2x2 : integer := DATA_WIDTH*(2*2  /  4 ) - 1;
    constant idx4bot_2x2 : integer := 0;

    constant idx1top_2x2_o : integer := (DATA_WIDTH*2)*(2*2)        - 1;
    constant idx1bot_2x2_o : integer := (DATA_WIDTH*2)*(2*2  * 3/4)    ;
    constant idx2top_2x2_o : integer := (DATA_WIDTH*2)*(2*2  * 3/4) - 1;
    constant idx2bot_2x2_o : integer := (DATA_WIDTH*2)*(2*2  /  2 )    ;
    constant idx3top_2x2_o : integer := (DATA_WIDTH*2)*(2*2  /  2 ) - 1;
    constant idx3bot_2x2_o : integer := (DATA_WIDTH*2)*(2*2  /  4 )    ;
    constant idx4top_2x2_o : integer := (DATA_WIDTH*2)*(2*2  /  4 ) - 1;
    constant idx4bot_2x2_o : integer := 0;

    constant idx1top_4x4_o : integer := (DATA_WIDTH*2)*(4*4)        - 1;
    constant idx1bot_4x4_o : integer := (DATA_WIDTH*2)*(4*4  * 3/4)    ;
    constant idx2top_4x4_o : integer := (DATA_WIDTH*2)*(4*4  * 3/4) - 1;
    constant idx2bot_4x4_o : integer := (DATA_WIDTH*2)*(4*4  /  2 )    ;
    constant idx3top_4x4_o : integer := (DATA_WIDTH*2)*(4*4  /  2 ) - 1;
    constant idx3bot_4x4_o : integer := (DATA_WIDTH*2)*(4*4  /  4 )    ;
    constant idx4top_4x4_o : integer := (DATA_WIDTH*2)*(4*4  /  4 ) - 1;
    constant idx4bot_4x4_o : integer := 0;
begin
    oREADY <= iREADY;

    enable_proc : process (iCLK) is
        variable count : INTEGER := 0;
    begin
        if rising_edge (iCLK) then
            if (iRST = '1') then
                en(en'high downto en'low+1) <= (others => '0');
                en2(en2'high downto en2'low+1) <= (others => '0');
            elsif (iREADY = '1') then
                en(en'high downto en'low+1) <= en(en'high-1 downto en'low); 
                en2(en2'high downto en2'low+1) <= en2(en2'high-1 downto en2'low); 
            end if;
        end if;
    end process enable_proc;

    en(0) <= (iREADY and iVALID_a and iVALID_b) when (iRST = '0') else '0';
    en_g  <= en when (iREADY = '1') else (others => '0');
    en2(0) <= iPVALID_1 and iPVALID_2 and iPVALID_3 and iPVALID_4 and iPVALID_5 and iPVALID_6 and iPVALID_7 when (iRST = '0') else '0';
    en_g2  <= en2 when (iREADY = '1') else (others => '0');

    input_proc : process (iCLK) is
    begin
        if rising_edge (iCLK) then
            if (en_g(0) = '1') then
                -- rearrange data
                a1_1 <= signed(iDATA_a(idx1top_dat  downto idx1bot_dat ));
                a1_2 <= signed(iDATA_a(idx2top_dat  downto idx2bot_dat ));
                a2_1 <= signed(iDATA_a(idx3top_dat  downto idx3bot_dat ));
                a2_2 <= signed(iDATA_a(idx4top_dat  downto idx4bot_dat ));
                a1_3 <= signed(iDATA_a(idx5top_dat  downto idx5bot_dat ));
                a1_4 <= signed(iDATA_a(idx6top_dat  downto idx6bot_dat ));
                a2_3 <= signed(iDATA_a(idx7top_dat  downto idx7bot_dat ));
                a2_4 <= signed(iDATA_a(idx8top_dat  downto idx8bot_dat ));
                a3_1 <= signed(iDATA_a(idx9top_dat  downto idx9bot_dat ));
                a3_2 <= signed(iDATA_a(idx10top_dat downto idx10bot_dat));
                a4_1 <= signed(iDATA_a(idx11top_dat downto idx11bot_dat));
                a4_2 <= signed(iDATA_a(idx12top_dat downto idx12bot_dat));
                a3_3 <= signed(iDATA_a(idx13top_dat downto idx13bot_dat));
                a3_4 <= signed(iDATA_a(idx14top_dat downto idx14bot_dat));
                a4_3 <= signed(iDATA_a(idx15top_dat downto idx15bot_dat));
                a4_4 <= signed(iDATA_a(idx16top_dat downto idx16bot_dat));
                b1_1 <= signed(iDATA_b(idx1top_dat  downto idx1bot_dat ));
                b1_2 <= signed(iDATA_b(idx2top_dat  downto idx2bot_dat ));
                b2_1 <= signed(iDATA_b(idx3top_dat  downto idx3bot_dat ));
                b2_2 <= signed(iDATA_b(idx4top_dat  downto idx4bot_dat ));
                b1_3 <= signed(iDATA_b(idx5top_dat  downto idx5bot_dat ));
                b1_4 <= signed(iDATA_b(idx6top_dat  downto idx6bot_dat ));
                b2_3 <= signed(iDATA_b(idx7top_dat  downto idx7bot_dat ));
                b2_4 <= signed(iDATA_b(idx8top_dat  downto idx8bot_dat ));
                b3_1 <= signed(iDATA_b(idx9top_dat  downto idx9bot_dat ));
                b3_2 <= signed(iDATA_b(idx10top_dat downto idx10bot_dat));
                b4_1 <= signed(iDATA_b(idx11top_dat downto idx11bot_dat));
                b4_2 <= signed(iDATA_b(idx12top_dat downto idx12bot_dat));
                b3_3 <= signed(iDATA_b(idx13top_dat downto idx13bot_dat));
                b3_4 <= signed(iDATA_b(idx14top_dat downto idx14bot_dat));
                b4_3 <= signed(iDATA_b(idx15top_dat downto idx15bot_dat));
                b4_4 <= signed(iDATA_b(idx16top_dat downto idx16bot_dat));
            end if;
        end if;
    end process input_proc;

    -- 2x2 matrices
    a1(0)(idx1top_2x2 downto idx1bot_2x2) <= a1_1;
    a1(0)(idx2top_2x2 downto idx2bot_2x2) <= a1_2;
    a1(0)(idx3top_2x2 downto idx3bot_2x2) <= a1_3;
    a1(0)(idx4top_2x2 downto idx4bot_2x2) <= a1_4;
    a2(0)(idx1top_2x2 downto idx1bot_2x2) <= a2_1;
    a2(0)(idx2top_2x2 downto idx2bot_2x2) <= a2_2;
    a2(0)(idx3top_2x2 downto idx3bot_2x2) <= a2_3;
    a2(0)(idx4top_2x2 downto idx4bot_2x2) <= a2_4;
    a3(0)(idx1top_2x2 downto idx1bot_2x2) <= a3_1;
    a3(0)(idx2top_2x2 downto idx2bot_2x2) <= a3_2;
    a3(0)(idx3top_2x2 downto idx3bot_2x2) <= a3_3;
    a3(0)(idx4top_2x2 downto idx4bot_2x2) <= a3_4;
    a4(0)(idx1top_2x2 downto idx1bot_2x2) <= a4_1;
    a4(0)(idx2top_2x2 downto idx2bot_2x2) <= a4_2;
    a4(0)(idx3top_2x2 downto idx3bot_2x2) <= a4_3;
    a4(0)(idx4top_2x2 downto idx4bot_2x2) <= a4_4;
    b1(0)(idx1top_2x2 downto idx1bot_2x2) <= b1_1;
    b1(0)(idx2top_2x2 downto idx2bot_2x2) <= b1_2;
    b1(0)(idx3top_2x2 downto idx3bot_2x2) <= b1_3;
    b1(0)(idx4top_2x2 downto idx4bot_2x2) <= b1_4;
    b2(0)(idx1top_2x2 downto idx1bot_2x2) <= b2_1;
    b2(0)(idx2top_2x2 downto idx2bot_2x2) <= b2_2;
    b2(0)(idx3top_2x2 downto idx3bot_2x2) <= b2_3;
    b2(0)(idx4top_2x2 downto idx4bot_2x2) <= b2_4;
    b3(0)(idx1top_2x2 downto idx1bot_2x2) <= b3_1;
    b3(0)(idx2top_2x2 downto idx2bot_2x2) <= b3_2;
    b3(0)(idx3top_2x2 downto idx3bot_2x2) <= b3_3;
    b3(0)(idx4top_2x2 downto idx4bot_2x2) <= b3_4;
    b4(0)(idx1top_2x2 downto idx1bot_2x2) <= b4_1;
    b4(0)(idx2top_2x2 downto idx2bot_2x2) <= b4_2;
    b4(0)(idx3top_2x2 downto idx3bot_2x2) <= b4_3;
    b4(0)(idx4top_2x2 downto idx4bot_2x2) <= b4_4;

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

                -- maybe for loop for generic
                v1(1)(idx1top_2x2 downto idx1bot_2x2) <= b4(0)(idx1top_2x2 downto idx1bot_2x2) - b2(0)(idx1top_2x2 downto idx1bot_2x2);
                v1(1)(idx2top_2x2 downto idx2bot_2x2) <= b4(0)(idx2top_2x2 downto idx2bot_2x2) - b2(0)(idx2top_2x2 downto idx2bot_2x2);
                v1(1)(idx3top_2x2 downto idx3bot_2x2) <= b4(0)(idx3top_2x2 downto idx3bot_2x2) - b2(0)(idx3top_2x2 downto idx3bot_2x2);
                v1(1)(idx4top_2x2 downto idx4bot_2x2) <= b4(0)(idx4top_2x2 downto idx4bot_2x2) - b2(0)(idx4top_2x2 downto idx4bot_2x2);
                v2(1) <= (others => '0');
                v3(1) <= (others => '0');
                v4(1)(idx1top_2x2 downto idx1bot_2x2) <= b2(0)(idx1top_2x2 downto idx1bot_2x2) - b1(0)(idx1top_2x2 downto idx1bot_2x2);
                v4(1)(idx2top_2x2 downto idx2bot_2x2) <= b2(0)(idx2top_2x2 downto idx2bot_2x2) - b1(0)(idx2top_2x2 downto idx2bot_2x2);
                v4(1)(idx3top_2x2 downto idx3bot_2x2) <= b2(0)(idx3top_2x2 downto idx3bot_2x2) - b1(0)(idx3top_2x2 downto idx3bot_2x2);
                v4(1)(idx4top_2x2 downto idx4bot_2x2) <= b2(0)(idx4top_2x2 downto idx4bot_2x2) - b1(0)(idx4top_2x2 downto idx4bot_2x2);

                u1(1)(idx1top_2x2 downto idx1bot_2x2) <= a1(0)(idx1top_2x2 downto idx1bot_2x2) - a3(0)(idx1top_2x2 downto idx1bot_2x2);
                u1(1)(idx2top_2x2 downto idx2bot_2x2) <= a1(0)(idx2top_2x2 downto idx2bot_2x2) - a3(0)(idx2top_2x2 downto idx2bot_2x2);
                u1(1)(idx3top_2x2 downto idx3bot_2x2) <= a1(0)(idx3top_2x2 downto idx3bot_2x2) - a3(0)(idx3top_2x2 downto idx3bot_2x2);
                u1(1)(idx4top_2x2 downto idx4bot_2x2) <= a1(0)(idx4top_2x2 downto idx4bot_2x2) - a3(0)(idx4top_2x2 downto idx4bot_2x2);
                u2(1)(idx1top_2x2 downto idx1bot_2x2) <= a3(0)(idx1top_2x2 downto idx1bot_2x2) + a4(0)(idx1top_2x2 downto idx1bot_2x2);
                u2(1)(idx2top_2x2 downto idx2bot_2x2) <= a3(0)(idx2top_2x2 downto idx2bot_2x2) + a4(0)(idx2top_2x2 downto idx2bot_2x2);
                u2(1)(idx3top_2x2 downto idx3bot_2x2) <= a3(0)(idx3top_2x2 downto idx3bot_2x2) + a4(0)(idx3top_2x2 downto idx3bot_2x2);
                u2(1)(idx4top_2x2 downto idx4bot_2x2) <= a3(0)(idx4top_2x2 downto idx4bot_2x2) + a4(0)(idx4top_2x2 downto idx4bot_2x2);
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
                v2(2)(idx1top_2x2 downto idx1bot_2x2) <= v1(1)(idx1top_2x2 downto idx1bot_2x2) + b1(1)(idx1top_2x2 downto idx1bot_2x2);
                v2(2)(idx2top_2x2 downto idx2bot_2x2) <= v1(1)(idx2top_2x2 downto idx2bot_2x2) + b1(1)(idx2top_2x2 downto idx2bot_2x2);
                v2(2)(idx3top_2x2 downto idx3bot_2x2) <= v1(1)(idx3top_2x2 downto idx3bot_2x2) + b1(1)(idx3top_2x2 downto idx3bot_2x2);
                v2(2)(idx4top_2x2 downto idx4bot_2x2) <= v1(1)(idx4top_2x2 downto idx4bot_2x2) + b1(1)(idx4top_2x2 downto idx4bot_2x2);
                v3(2) <= v3(1);
                v4(2) <= v4(1);

                u1(2) <= u1(1);
                u2(2) <= u2(1);
                u3(2)(idx1top_2x2 downto idx1bot_2x2) <= u1(1)(idx1top_2x2 downto idx1bot_2x2) - a4(1)(idx1top_2x2 downto idx1bot_2x2);
                u3(2)(idx2top_2x2 downto idx2bot_2x2) <= u1(1)(idx2top_2x2 downto idx2bot_2x2) - a4(1)(idx2top_2x2 downto idx2bot_2x2);
                u3(2)(idx3top_2x2 downto idx3bot_2x2) <= u1(1)(idx3top_2x2 downto idx3bot_2x2) - a4(1)(idx3top_2x2 downto idx3bot_2x2);
                u3(2)(idx4top_2x2 downto idx4bot_2x2) <= u1(1)(idx4top_2x2 downto idx4bot_2x2) - a4(1)(idx4top_2x2 downto idx4bot_2x2);
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
                v3(3)(idx1top_2x2 downto idx1bot_2x2) <= v2(2)(idx1top_2x2 downto idx1bot_2x2) - b3(2)(idx1top_2x2 downto idx1bot_2x2);
                v3(3)(idx2top_2x2 downto idx2bot_2x2) <= v2(2)(idx2top_2x2 downto idx2bot_2x2) - b3(2)(idx2top_2x2 downto idx2bot_2x2);
                v3(3)(idx3top_2x2 downto idx3bot_2x2) <= v2(2)(idx3top_2x2 downto idx3bot_2x2) - b3(2)(idx3top_2x2 downto idx3bot_2x2);
                v3(3)(idx4top_2x2 downto idx4bot_2x2) <= v2(2)(idx4top_2x2 downto idx4bot_2x2) - b3(2)(idx4top_2x2 downto idx4bot_2x2);
                v4(3) <= v4(2);

                u1(3) <= u1(2);
                u2(3) <= u2(2);
                u3(3) <= u3(2);
                u4(3)(idx1top_2x2 downto idx1bot_2x2) <= u3(2)(idx1top_2x2 downto idx1bot_2x2) + a2(2)(idx1top_2x2 downto idx1bot_2x2);
                u4(3)(idx2top_2x2 downto idx2bot_2x2) <= u3(2)(idx2top_2x2 downto idx2bot_2x2) + a2(2)(idx2top_2x2 downto idx2bot_2x2);
                u4(3)(idx3top_2x2 downto idx3bot_2x2) <= u3(2)(idx3top_2x2 downto idx3bot_2x2) + a2(2)(idx3top_2x2 downto idx3bot_2x2);
                u4(3)(idx4top_2x2 downto idx4bot_2x2) <= u3(2)(idx4top_2x2 downto idx4bot_2x2) + a2(2)(idx4top_2x2 downto idx4bot_2x2);
            end if;
        end if;
    end process vectors_3_proc;

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
    
    wstrass_proc : process (iCLK) is
    begin
        if rising_edge(iCLK) then
            if (en_g(4) = '1') then
                -- p1
                oPDATA_a1  <= a1_meta;
                oPDATA_b1  <= b1_meta;
                oPVALID_a1 <= '1';
                oPVALID_b1 <= '1';
                -- p2 
                oPDATA_a2  <= a2_meta;
                oPDATA_b2  <= b3_meta;
                oPVALID_a2 <= '1';
                oPVALID_b2 <= '1';                
                -- p3
                oPDATA_a3  <= a4_meta;
                oPDATA_b3  <= v3_meta;
                oPVALID_a3 <= '1';
                oPVALID_b3 <= '1';                
                -- p4
                oPDATA_a4  <= u1_meta;
                oPDATA_b4  <= v1_meta;
                oPVALID_a4 <= '1';
                oPVALID_b4 <= '1';
                -- p5
                oPDATA_a5  <= u2_meta;
                oPDATA_b5  <= v4_meta;
                oPVALID_a5 <= '1';
                oPVALID_b5 <= '1';
                -- p6
                oPDATA_a6  <= u4_meta;
                oPDATA_b6  <= b4_meta;
                oPVALID_a6 <= '1';
                oPVALID_b6 <= '1';
                -- p7
                oPDATA_a7  <= u3_meta;
                oPDATA_b7  <= v2_meta;
                oPVALID_a7 <= '1';
                oPVALID_b7 <= '1';
            else
                oPVALID_a1 <= '0';
                oPVALID_a2 <= '0';
                oPVALID_a3 <= '0';
                oPVALID_a4 <= '0';
                oPVALID_a5 <= '0';
                oPVALID_a6 <= '0';
                oPVALID_a7 <= '0';
                oPVALID_b1 <= '0';
                oPVALID_b2 <= '0';
                oPVALID_b3 <= '0';
                oPVALID_b4 <= '0';
                oPVALID_b5 <= '0';
                oPVALID_b6 <= '0';
                oPVALID_b7 <= '0';
            end if;
        end if;
    end process wstrass_proc;

    res_proc : process (iCLK) is
    begin
        if rising_edge(iCLK) then
            if (en_g2(0) = '1') then
                p1    <= signed(iPDATA_1);
                p2    <= signed(iPDATA_2);
                p3(0) <= signed(iPDATA_3);
                p4(0) <= signed(iPDATA_4);
                p5(0) <= signed(iPDATA_5);
                p6(0) <= signed(iPDATA_6);
                p7    <= signed(iPDATA_7);
            end if;
        end if;
    end process res_proc;

    sum_1_proc : process (iCLK) is
    begin
        if rising_edge(iCLK) then
            if (en_g2(1) = '1') then
                o1_meta(0)(idx1top_2x2_o downto idx1bot_2x2_o) <= p1(idx1top_2x2_o downto idx1bot_2x2_o) + p2(idx1top_2x2_o downto idx1bot_2x2_o);
                o1_meta(0)(idx2top_2x2_o downto idx2bot_2x2_o) <= p1(idx2top_2x2_o downto idx2bot_2x2_o) + p2(idx2top_2x2_o downto idx2bot_2x2_o);
                o1_meta(0)(idx3top_2x2_o downto idx3bot_2x2_o) <= p1(idx3top_2x2_o downto idx3bot_2x2_o) + p2(idx3top_2x2_o downto idx3bot_2x2_o);
                o1_meta(0)(idx4top_2x2_o downto idx4bot_2x2_o) <= p1(idx4top_2x2_o downto idx4bot_2x2_o) + p2(idx4top_2x2_o downto idx4bot_2x2_o);
                o2_meta(0)(idx1top_2x2_o downto idx1bot_2x2_o) <= p1(idx1top_2x2_o downto idx1bot_2x2_o) - p7(idx1top_2x2_o downto idx1bot_2x2_o);
                o2_meta(0)(idx2top_2x2_o downto idx2bot_2x2_o) <= p1(idx2top_2x2_o downto idx2bot_2x2_o) - p7(idx2top_2x2_o downto idx2bot_2x2_o);
                o2_meta(0)(idx3top_2x2_o downto idx3bot_2x2_o) <= p1(idx3top_2x2_o downto idx3bot_2x2_o) - p7(idx3top_2x2_o downto idx3bot_2x2_o);
                o2_meta(0)(idx4top_2x2_o downto idx4bot_2x2_o) <= p1(idx4top_2x2_o downto idx4bot_2x2_o) - p7(idx4top_2x2_o downto idx4bot_2x2_o);
                o3_meta(0)(idx1top_2x2_o downto idx1bot_2x2_o) <= p1(idx1top_2x2_o downto idx1bot_2x2_o) - p7(idx1top_2x2_o downto idx1bot_2x2_o);
                o3_meta(0)(idx2top_2x2_o downto idx2bot_2x2_o) <= p1(idx2top_2x2_o downto idx2bot_2x2_o) - p7(idx2top_2x2_o downto idx2bot_2x2_o);
                o3_meta(0)(idx3top_2x2_o downto idx3bot_2x2_o) <= p1(idx3top_2x2_o downto idx3bot_2x2_o) - p7(idx3top_2x2_o downto idx3bot_2x2_o);
                o3_meta(0)(idx4top_2x2_o downto idx4bot_2x2_o) <= p1(idx4top_2x2_o downto idx4bot_2x2_o) - p7(idx4top_2x2_o downto idx4bot_2x2_o);
                o4_meta(0)(idx1top_2x2_o downto idx1bot_2x2_o) <= p1(idx1top_2x2_o downto idx1bot_2x2_o) - p7(idx1top_2x2_o downto idx1bot_2x2_o);
                o4_meta(0)(idx2top_2x2_o downto idx2bot_2x2_o) <= p1(idx2top_2x2_o downto idx2bot_2x2_o) - p7(idx2top_2x2_o downto idx2bot_2x2_o);
                o4_meta(0)(idx3top_2x2_o downto idx3bot_2x2_o) <= p1(idx3top_2x2_o downto idx3bot_2x2_o) - p7(idx3top_2x2_o downto idx3bot_2x2_o);
                o4_meta(0)(idx4top_2x2_o downto idx4bot_2x2_o) <= p1(idx4top_2x2_o downto idx4bot_2x2_o) - p7(idx4top_2x2_o downto idx4bot_2x2_o);

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
            if (en_g2(2) = '1') then
                o1_meta(1) <= o1_meta(0);
                o2_meta(1)(idx1top_2x2_o downto idx1bot_2x2_o) <= o2_meta(0)(idx1top_2x2_o downto idx1bot_2x2_o) + p5(1)(idx1top_2x2_o downto idx1bot_2x2_o);
                o2_meta(1)(idx2top_2x2_o downto idx2bot_2x2_o) <= o2_meta(0)(idx2top_2x2_o downto idx2bot_2x2_o) + p5(1)(idx2top_2x2_o downto idx2bot_2x2_o);
                o2_meta(1)(idx3top_2x2_o downto idx3bot_2x2_o) <= o2_meta(0)(idx3top_2x2_o downto idx3bot_2x2_o) + p5(1)(idx3top_2x2_o downto idx3bot_2x2_o);
                o2_meta(1)(idx4top_2x2_o downto idx4bot_2x2_o) <= o2_meta(0)(idx4top_2x2_o downto idx4bot_2x2_o) + p5(1)(idx4top_2x2_o downto idx4bot_2x2_o);
                o3_meta(1)(idx1top_2x2_o downto idx1bot_2x2_o) <= o3_meta(0)(idx1top_2x2_o downto idx1bot_2x2_o) - p3(1)(idx1top_2x2_o downto idx1bot_2x2_o);
                o3_meta(1)(idx2top_2x2_o downto idx2bot_2x2_o) <= o3_meta(0)(idx2top_2x2_o downto idx2bot_2x2_o) - p3(1)(idx2top_2x2_o downto idx2bot_2x2_o);
                o3_meta(1)(idx3top_2x2_o downto idx3bot_2x2_o) <= o3_meta(0)(idx3top_2x2_o downto idx3bot_2x2_o) - p3(1)(idx3top_2x2_o downto idx3bot_2x2_o);
                o3_meta(1)(idx4top_2x2_o downto idx4bot_2x2_o) <= o3_meta(0)(idx4top_2x2_o downto idx4bot_2x2_o) - p3(1)(idx4top_2x2_o downto idx4bot_2x2_o);
                o4_meta(1)(idx1top_2x2_o downto idx1bot_2x2_o) <= o4_meta(0)(idx1top_2x2_o downto idx1bot_2x2_o) + p5(1)(idx1top_2x2_o downto idx1bot_2x2_o);
                o4_meta(1)(idx2top_2x2_o downto idx2bot_2x2_o) <= o4_meta(0)(idx2top_2x2_o downto idx2bot_2x2_o) + p5(1)(idx2top_2x2_o downto idx2bot_2x2_o);
                o4_meta(1)(idx3top_2x2_o downto idx3bot_2x2_o) <= o4_meta(0)(idx3top_2x2_o downto idx3bot_2x2_o) + p5(1)(idx3top_2x2_o downto idx3bot_2x2_o);
                o4_meta(1)(idx4top_2x2_o downto idx4bot_2x2_o) <= o4_meta(0)(idx4top_2x2_o downto idx4bot_2x2_o) + p5(1)(idx4top_2x2_o downto idx4bot_2x2_o);

                p4(2) <= p4(1);
                p6(2) <= p6(1);
            end if;
        end if;
    end process sum_2_proc;

    sum_3_proc : process (iCLK) is
    begin
        if rising_edge(iCLK) then
            if (en_g2(3) = '1') then
                o1_meta(2) <= o1_meta(1);
                o2_meta(2)(idx1top_2x2_o downto idx1bot_2x2_o) <= o2_meta(1)(idx1top_2x2_o downto idx1bot_2x2_o) + p6(2)(idx1top_2x2_o downto idx1bot_2x2_o);
                o2_meta(2)(idx2top_2x2_o downto idx2bot_2x2_o) <= o2_meta(1)(idx2top_2x2_o downto idx2bot_2x2_o) + p6(2)(idx2top_2x2_o downto idx2bot_2x2_o);
                o2_meta(2)(idx3top_2x2_o downto idx3bot_2x2_o) <= o2_meta(1)(idx3top_2x2_o downto idx3bot_2x2_o) + p6(2)(idx3top_2x2_o downto idx3bot_2x2_o);
                o2_meta(2)(idx4top_2x2_o downto idx4bot_2x2_o) <= o2_meta(1)(idx4top_2x2_o downto idx4bot_2x2_o) + p6(2)(idx4top_2x2_o downto idx4bot_2x2_o);
                o3_meta(2)(idx1top_2x2_o downto idx1bot_2x2_o) <= o3_meta(1)(idx1top_2x2_o downto idx1bot_2x2_o) + p4(2)(idx1top_2x2_o downto idx1bot_2x2_o);
                o3_meta(2)(idx2top_2x2_o downto idx2bot_2x2_o) <= o3_meta(1)(idx2top_2x2_o downto idx2bot_2x2_o) + p4(2)(idx2top_2x2_o downto idx2bot_2x2_o);
                o3_meta(2)(idx3top_2x2_o downto idx3bot_2x2_o) <= o3_meta(1)(idx3top_2x2_o downto idx3bot_2x2_o) + p4(2)(idx3top_2x2_o downto idx3bot_2x2_o);
                o3_meta(2)(idx4top_2x2_o downto idx4bot_2x2_o) <= o3_meta(1)(idx4top_2x2_o downto idx4bot_2x2_o) + p4(2)(idx4top_2x2_o downto idx4bot_2x2_o);
                o4_meta(2)(idx1top_2x2_o downto idx1bot_2x2_o) <= o4_meta(1)(idx1top_2x2_o downto idx1bot_2x2_o) + p4(2)(idx1top_2x2_o downto idx1bot_2x2_o);
                o4_meta(2)(idx2top_2x2_o downto idx2bot_2x2_o) <= o4_meta(1)(idx2top_2x2_o downto idx2bot_2x2_o) + p4(2)(idx2top_2x2_o downto idx2bot_2x2_o);
                o4_meta(2)(idx3top_2x2_o downto idx3bot_2x2_o) <= o4_meta(1)(idx3top_2x2_o downto idx3bot_2x2_o) + p4(2)(idx3top_2x2_o downto idx3bot_2x2_o);
                o4_meta(2)(idx4top_2x2_o downto idx4bot_2x2_o) <= o4_meta(1)(idx4top_2x2_o downto idx4bot_2x2_o) + p4(2)(idx4top_2x2_o downto idx4bot_2x2_o);
            end if;
        end if;
    end process sum_3_proc;

    -- rearrange
    o1_1 <= o1_meta(2)(idx1top_2x2_o downto idx1bot_2x2_o);
    o1_2 <= o1_meta(2)(idx2top_2x2_o downto idx2bot_2x2_o);
    o1_3 <= o1_meta(2)(idx3top_2x2_o downto idx3bot_2x2_o);
    o1_4 <= o1_meta(2)(idx4top_2x2_o downto idx4bot_2x2_o);
    o2_1 <= o2_meta(2)(idx1top_2x2_o downto idx1bot_2x2_o);
    o2_2 <= o2_meta(2)(idx2top_2x2_o downto idx2bot_2x2_o);
    o2_3 <= o2_meta(2)(idx3top_2x2_o downto idx3bot_2x2_o);
    o2_4 <= o2_meta(2)(idx4top_2x2_o downto idx4bot_2x2_o);
    o3_1 <= o3_meta(2)(idx1top_2x2_o downto idx1bot_2x2_o);
    o3_2 <= o3_meta(2)(idx2top_2x2_o downto idx2bot_2x2_o);
    o3_3 <= o3_meta(2)(idx3top_2x2_o downto idx3bot_2x2_o);
    o3_4 <= o3_meta(2)(idx4top_2x2_o downto idx4bot_2x2_o);
    o4_1 <= o4_meta(2)(idx1top_2x2_o downto idx1bot_2x2_o);
    o4_2 <= o4_meta(2)(idx2top_2x2_o downto idx2bot_2x2_o);
    o4_3 <= o4_meta(2)(idx3top_2x2_o downto idx3bot_2x2_o);
    o4_4 <= o4_meta(2)(idx4top_2x2_o downto idx4bot_2x2_o);

    o1(idx1top_2x2_o downto idx1bot_2x2_o) <= o1_1;
    o1(idx2top_2x2_o downto idx2bot_2x2_o) <= o1_2;
    o1(idx3top_2x2_o downto idx3bot_2x2_o) <= o2_1;
    o1(idx4top_2x2_o downto idx4bot_2x2_o) <= o2_2;
    o2(idx1top_2x2_o downto idx1bot_2x2_o) <= o1_3;
    o2(idx2top_2x2_o downto idx2bot_2x2_o) <= o1_4;
    o2(idx3top_2x2_o downto idx3bot_2x2_o) <= o2_3;
    o2(idx4top_2x2_o downto idx4bot_2x2_o) <= o2_4;
    o3(idx1top_2x2_o downto idx1bot_2x2_o) <= o3_1;
    o3(idx2top_2x2_o downto idx2bot_2x2_o) <= o3_2;
    o3(idx3top_2x2_o downto idx3bot_2x2_o) <= o4_1;
    o3(idx4top_2x2_o downto idx4bot_2x2_o) <= o4_2;
    o4(idx1top_2x2_o downto idx1bot_2x2_o) <= o3_3;
    o4(idx2top_2x2_o downto idx2bot_2x2_o) <= o3_4;
    o4(idx3top_2x2_o downto idx3bot_2x2_o) <= o4_3;
    o4(idx4top_2x2_o downto idx4bot_2x2_o) <= o4_4;

    output_proc : process (iCLK) is
    begin
        if rising_edge(iCLK) then
            if (en_g2(4) = '1') then
                oDATA(idx1top_4x4_o downto idx1bot_4x4_o) <= std_logic_vector(o1);
                oDATA(idx2top_4x4_o downto idx2bot_4x4_o) <= std_logic_vector(o2);
                oDATA(idx3top_4x4_o downto idx3bot_4x4_o) <= std_logic_vector(o3);
                oDATA(idx4top_4x4_o downto idx4bot_4x4_o) <= std_logic_vector(o4);
            end if;
            oVALID <= en2(en2'high);
        end if;
    end process output_proc;

end RTL;
