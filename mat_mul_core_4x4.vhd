----------------------------------------------------------------------------------
-- Designer:        JLam
-- 
-- Date:            04/12/2024 12:25:05 AM
-- Name:            mat_mul_core_4x4 - RTL
-- Description:     16bit piplined signed 4x4 matrix multiplcation wrapper
--                  Strassen algo Winograd var. 
--                  3 less additions than Strassen
--                  doesn't handle overflow
-- Specifications:  uses DSP IP for multiplication for performance
--                  impl max 416.667MHz clock speed
--                  impl worst negative slack:     0.001ns
--                  impl worst hold slack:         0.081ns
--                  impl worst pulse width slack:  0.575ns
--                  impl total on-ship power:      0.705W   (typical settings)
--                  impl dynamic power:            0.625W
--                  impl static power:             0.081W
--                  impl utilization:              3889 LUTs, 15348 FFs, 49 DSPs
--
-- Dependencies:    mat_mul_core_2x2 - RTL, mat_mul_core_strass - RTL
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
    use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;

entity mat_mul_core_4x4 is 
generic (
    DATA_WIDTH  : integer := 16
);
port (
    iCLK                : in   std_logic;
    iREADY              : in   std_logic;
    iVALID_a, iVALID_b  : in   std_logic;
    iDATA_a, iDATA_b    : in   std_logic_vector(DATA_WIDTH*16-1 downto 0);
    oDATA               : out  std_logic_vector((DATA_WIDTH*2)*16-1 downto 0);
    oVALID              : out  std_logic;
    oREADY              : out  std_logic;
    -- reset
    iRST                : in   std_logic
);
end entity mat_mul_core_4x4;

architecture RTL of mat_mul_core_4x4 is
    signal valid_a1 : std_logic;
    signal valid_b1 : std_logic;
    signal valid_a2 : std_logic;
    signal valid_b2 : std_logic;
    signal valid_a3 : std_logic;
    signal valid_b3 : std_logic;
    signal valid_a4 : std_logic;
    signal valid_b4 : std_logic;
    signal valid_a5 : std_logic;
    signal valid_b5 : std_logic;
    signal valid_a6 : std_logic;
    signal valid_b6 : std_logic;
    signal valid_a7 : std_logic;
    signal valid_b7 : std_logic;
    signal data_a1  : std_logic_vector(DATA_WIDTH*2*2-1 downto 0);
    signal data_b1  : std_logic_vector(DATA_WIDTH*2*2-1 downto 0);
    signal data_a2  : std_logic_vector(DATA_WIDTH*2*2-1 downto 0);
    signal data_b2  : std_logic_vector(DATA_WIDTH*2*2-1 downto 0);
    signal data_a3  : std_logic_vector(DATA_WIDTH*2*2-1 downto 0);
    signal data_b3  : std_logic_vector(DATA_WIDTH*2*2-1 downto 0);
    signal data_a4  : std_logic_vector(DATA_WIDTH*2*2-1 downto 0);
    signal data_b4  : std_logic_vector(DATA_WIDTH*2*2-1 downto 0);
    signal data_a5  : std_logic_vector(DATA_WIDTH*2*2-1 downto 0);
    signal data_b5  : std_logic_vector(DATA_WIDTH*2*2-1 downto 0);
    signal data_a6  : std_logic_vector(DATA_WIDTH*2*2-1 downto 0);
    signal data_b6  : std_logic_vector(DATA_WIDTH*2*2-1 downto 0);
    signal data_a7  : std_logic_vector(DATA_WIDTH*2*2-1 downto 0);
    signal data_b7  : std_logic_vector(DATA_WIDTH*2*2-1 downto 0);

    signal data_o1  : std_logic_vector((DATA_WIDTH*2)*2*2-1 downto 0);
    signal data_o2  : std_logic_vector((DATA_WIDTH*2)*2*2-1 downto 0);
    signal data_o3  : std_logic_vector((DATA_WIDTH*2)*2*2-1 downto 0);
    signal data_o4  : std_logic_vector((DATA_WIDTH*2)*2*2-1 downto 0);
    signal data_o5  : std_logic_vector((DATA_WIDTH*2)*2*2-1 downto 0);
    signal data_o6  : std_logic_vector((DATA_WIDTH*2)*2*2-1 downto 0);
    signal data_o7  : std_logic_vector((DATA_WIDTH*2)*2*2-1 downto 0);
    signal valid_o1 : std_logic;
    signal valid_o2 : std_logic;
    signal valid_o3 : std_logic;
    signal valid_o4 : std_logic;
    signal valid_o5 : std_logic;
    signal valid_o6 : std_logic;
    signal valid_o7 : std_logic;

    signal ready_2x2    : std_logic;
    signal ready_2x2_o1 : std_logic;
    signal ready_2x2_o2 : std_logic;
    signal ready_2x2_o3 : std_logic;
    signal ready_2x2_o4 : std_logic;
    signal ready_2x2_o5 : std_logic;
    signal ready_2x2_o6 : std_logic;
    signal ready_2x2_o7 : std_logic;
begin

    -- 8bit 4x4 matrix
    mat_mul_core_strass : entity work.mat_mul_core_strass
    generic map (
        DATA_WIDTH  => DATA_WIDTH
    )
    port map (
        iCLK        => iCLK,
        iREADY      => iREADY,
        iVALID_a    => iVALID_a,
        iVALID_b    => iVALID_b,
        iDATA_a     => iDATA_a,
        iDATA_b     => iDATA_b,
        
        -- propagate signals
        oPVALID_a1  => valid_a1,
        oPVALID_b1  => valid_b1,  
        oPVALID_a2  => valid_a2,
        oPVALID_b2  => valid_b2,  
        oPVALID_a3  => valid_a3,
        oPVALID_b3  => valid_b3,  
        oPVALID_a4  => valid_a4,
        oPVALID_b4  => valid_b4,  
        oPVALID_a5  => valid_a5,
        oPVALID_b5  => valid_b5,  
        oPVALID_a6  => valid_a6,
        oPVALID_b6  => valid_b6,  
        oPVALID_a7  => valid_a7,
        oPVALID_b7  => valid_b7,  
        oPDATA_a1   => data_a1 ,
        oPDATA_b1   => data_b1 ,
        oPDATA_a2   => data_a2 ,
        oPDATA_b2   => data_b2 ,
        oPDATA_a3   => data_a3 ,
        oPDATA_b3   => data_b3 ,
        oPDATA_a4   => data_a4 ,
        oPDATA_b4   => data_b4 ,
        oPDATA_a5   => data_a5 ,
        oPDATA_b5   => data_b5 ,
        oPDATA_a6   => data_a6 ,
        oPDATA_b6   => data_b6 ,
        oPDATA_a7   => data_a7 ,
        oPDATA_b7   => data_b7 ,
        iPDATA_1    => data_o1 ,
        iPDATA_2    => data_o2 ,
        iPDATA_3    => data_o3 ,
        iPDATA_4    => data_o4 ,
        iPDATA_5    => data_o5 ,
        iPDATA_6    => data_o6 ,
        iPDATA_7    => data_o7 ,
        iPVALID_1   => valid_o1,
        iPVALID_2   => valid_o2,
        iPVALID_3   => valid_o3,
        iPVALID_4   => valid_o4,
        iPVALID_5   => valid_o5,
        iPVALID_6   => valid_o6,
        iPVALID_7   => valid_o7,

        -- outputs
        oDATA       => oDATA,
        oVALID      => oVALID,
        oREADY      => ready_2x2,
        -- reset    
        iRST        => iRST
    );

    mat_mul_core_2x2_1 : entity work.mat_mul_core_2x2
    generic map (
        DATA_WIDTH  => DATA_WIDTH
    )
    port map (
        iCLK        => iCLK,
        iREADY      => ready_2x2,
        iVALID_a    => valid_a1,
        iVALID_b    => valid_b1,
        iDATA_a     => data_a1,
        iDATA_b     => data_b1,
        oDATA       => data_o1,
        oVALID      => valid_o1,
        oREADY      => ready_2x2_o1,
        iRST        => iRST
    );

    mat_mul_core_2x2_2 : entity work.mat_mul_core_2x2
    generic map (
        DATA_WIDTH  => DATA_WIDTH
    )
    port map (
        iCLK        => iCLK,
        iREADY      => ready_2x2,
        iVALID_a    => valid_a2,
        iVALID_b    => valid_b2,
        iDATA_a     => data_a2,
        iDATA_b     => data_b2,
        oDATA       => data_o2,
        oVALID      => valid_o2,
        oREADY      => ready_2x2_o2,
        iRST        => iRST
    );

    mat_mul_core_2x2_3 : entity work.mat_mul_core_2x2
    generic map (
        DATA_WIDTH  => DATA_WIDTH
    )
    port map (
        iCLK        => iCLK,
        iREADY      => ready_2x2,
        iVALID_a    => valid_a3,
        iVALID_b    => valid_b3,
        iDATA_a     => data_a3,
        iDATA_b     => data_b3,
        oDATA       => data_o3,
        oVALID      => valid_o3,
        oREADY      => ready_2x2_o3,
        iRST        => iRST
    );

    mat_mul_core_2x2_4 : entity work.mat_mul_core_2x2
    generic map (
        DATA_WIDTH  => DATA_WIDTH
    )
    port map (
        iCLK        => iCLK,
        iREADY      => ready_2x2,
        iVALID_a    => valid_a4,
        iVALID_b    => valid_b4,
        iDATA_a     => data_a4,
        iDATA_b     => data_b4,
        oDATA       => data_o4,
        oVALID      => valid_o4,
        oREADY      => ready_2x2_o4,
        iRST        => iRST
    );

    mat_mul_core_2x2_5 : entity work.mat_mul_core_2x2
    generic map (
        DATA_WIDTH  => DATA_WIDTH
    )
    port map (
        iCLK        => iCLK,
        iREADY      => ready_2x2,
        iVALID_a    => valid_a5,
        iVALID_b    => valid_b5,
        iDATA_a     => data_a5,
        iDATA_b     => data_b5,
        oDATA       => data_o5,
        oVALID      => valid_o5,
        oREADY      => ready_2x2_o5,
        iRST        => iRST
    );

    mat_mul_core_2x2_6 : entity work.mat_mul_core_2x2
    generic map (
        DATA_WIDTH  => DATA_WIDTH
    )
    port map (
        iCLK        => iCLK,
        iREADY      => ready_2x2,
        iVALID_a    => valid_a6,
        iVALID_b    => valid_b6,
        iDATA_a     => data_a6,
        iDATA_b     => data_b6,
        oDATA       => data_o6,
        oVALID      => valid_o6,
        oREADY      => ready_2x2_o6,
        iRST        => iRST
    );

    mat_mul_core_2x2_7 : entity work.mat_mul_core_2x2
    generic map (
        DATA_WIDTH  => DATA_WIDTH
    )
    port map (
        iCLK        => iCLK,
        iREADY      => ready_2x2,
        iVALID_a    => valid_a7,
        iVALID_b    => valid_b7,
        iDATA_a     => data_a7,
        iDATA_b     => data_b7,
        oDATA       => data_o7,
        oVALID      => valid_o7,
        oREADY      => ready_2x2_o7,
        iRST        => iRST
    );
    
end RTL;