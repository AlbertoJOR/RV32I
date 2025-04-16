library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PipeEx is
    Port (
        clk   : in  STD_LOGIC;
        reset : in  STD_LOGIC;
        stall : in  STD_LOGIC;

        -- ENTRADAS
        -- ControlUnit
        Jump_i       : in STD_LOGIC;
        MemtoReg_i   : in STD_LOGIC;
        RegWrite_i   : in STD_LOGIC;
        MemRead_i    : in STD_LOGIC;
        MemWrite_i   : in STD_LOGIC;
        Branch_i     : in STD_LOGIC;

        -- Instruction
        funct_3_i   : in  STD_LOGIC_VECTOR(2 downto 0);
        Write_Reg_i   : in  STD_LOGIC_VECTOR(4 downto 0);


        -- ALU 
        Zero_i       : in STD_LOGIC;   
        Result_i     : in STD_LOGIC_VECTOR(31 downto 0); 
        
        --RegFile
        Read_Data2_i   : in  STD_LOGIC_VECTOR(31 downto 0);
        
        -- PC
        Branch_pred_i   : in  STD_LOGIC; 
        PC_Imm_i        : in  STD_LOGIC_VECTOR (31 downto 0);
        PC_4_i          : in  STD_LOGIC_VECTOR (31 downto 0);


        -- SALIDAS
        -- ControlUnit
        Jump_o       : out STD_LOGIC;
        MemtoReg_o   : out STD_LOGIC;
        RegWrite_o   : out STD_LOGIC;
        MemRead_o    : out STD_LOGIC;
        MemWrite_o   : out STD_LOGIC;
        Branch_o     : out STD_LOGIC;

        -- Instruction
        funct_3_o   : out  STD_LOGIC_VECTOR(2 downto 0);
        Write_Reg_o   : out  STD_LOGIC_VECTOR(4 downto 0);

        -- ALU 
        Zero_o       : out STD_LOGIC;   
        Result_o     : out STD_LOGIC_VECTOR(31 downto 0); 
        
        -- RegFile
        Read_Data2_o   : out  STD_LOGIC_VECTOR(31 downto 0);
        -- PC
        Branch_pred_o   : out  STD_LOGIC; 
        PC_Imm_o        : out  STD_LOGIC_VECTOR (31 downto 0);
        PC_4_o          : out  STD_LOGIC_VECTOR (31 downto 0)
    );
end PipeEx;

architecture Behavioral of PipeEx is

    signal reg        :  STD_LOGIC_VECTOR(78 downto 0) := (others =>'0');
    signal PC_reg        :  STD_LOGIC_VECTOR(64 downto 0) := (others =>'0');

begin
    process(clk)
    begin
        if (rising_edge(clk) and stall = '0') then
            if reset = '1' then  -- Reset sincrónico
               reg         <=  (others => '0');
               PC_reg         <=  (others => '0');
            else  
                reg    <=  Jump_i & MemtoReg_i & RegWrite_i & MemRead_i & MemWrite_i
                        & Branch_i & funct_3_i & Write_Reg_i & Zero_i & Result_i & Read_Data2_i;
                PC_reg <= Branch_pred_i & PC_Imm_i & PC_4_i;
            end if;
        end if;
    end process;
    Jump_o          <= reg(78); 
    MemtoReg_o      <= reg(77); 
    RegWrite_o      <= reg(76); 
    MemRead_o       <= reg(75); 
    MemWrite_o      <= reg(74); 
    Branch_o        <= reg(73); 
    funct_3_o       <= reg(72 downto 70); 
    Write_Reg_o     <= reg(69 downto 65); 
    Zero_o          <= reg(64); 
    Result_o        <= reg(63 downto 32); 
    Read_Data2_o    <= reg(31 downto 0); 
    Branch_pred_o   <= PC_reg(64);
    PC_Imm_o        <= PC_reg(63 downto 32);
    PC_4_o          <= PC_reg(31 downto 0);
    end Behavioral;
