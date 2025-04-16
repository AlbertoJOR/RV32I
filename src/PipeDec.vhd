library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PipeDec is
    Port (
        clk   : in  STD_LOGIC;
        reset : in  STD_LOGIC;
        stall : in  STD_LOGIC;

        -- ENTRADAS
        -- ControlUnit
        Jump_i       : in STD_LOGIC;
        ALUSrc_i     : in STD_LOGIC;
        MemtoReg_i   : in STD_LOGIC;
        RegWrite_i   : in STD_LOGIC;
        MemRead_i    : in STD_LOGIC;
        MemWrite_i   : in STD_LOGIC;
        Branch_i     : in STD_LOGIC;
        ALUOp_i      : in STD_LOGIC_VECTOR(1 downto 0);

        -- ImmGen
        imm_out_i   : in  STD_LOGIC_VECTOR(31 downto 0);

        -- Instruction
        funct_3_i   : in  STD_LOGIC_VECTOR(2 downto 0);
        ALU_inst_i   : in  STD_LOGIC_VECTOR(3 downto 0);
        Write_Reg_i   : in  STD_LOGIC_VECTOR(4 downto 0);

        -- RegFile
        Read_Data1_i   : in  STD_LOGIC_VECTOR(31 downto 0);
        Read_Data2_i   : in  STD_LOGIC_VECTOR(31 downto 0);
        -- Fordwarding
        Read_Reg1_i     : in STD_LOGIC_VECTOR(4 downto 0);
        Read_Reg2_i     : in STD_LOGIC_VECTOR(4 downto 0);
        -- PC 
        PC_Imm_i        : in  STD_LOGIC_VECTOR (31 downto 0);
        PC_4_i          : in  STD_LOGIC_VECTOR (31 downto 0);
        Branch_pred_i   : in STD_LOGIC; -- Predicción si toma el salto


        -- SALIDAS
        -- ControlUnit
        Jump_o       : out STD_LOGIC;
        ALUSrc_o     : out STD_LOGIC;
        MemtoReg_o   : out STD_LOGIC;
        RegWrite_o   : out STD_LOGIC;
        MemRead_o    : out STD_LOGIC;
        MemWrite_o   : out STD_LOGIC;
        Branch_o     : out STD_LOGIC;
        ALUOp_o      : out STD_LOGIC_VECTOR(1 downto 0);
        
        -- ImmGen
        imm_out_o   : out  STD_LOGIC_VECTOR(31 downto 0);

        -- Instruction
        funct_3_o   : out  STD_LOGIC_VECTOR(2 downto 0);
        ALU_inst_o   : out  STD_LOGIC_VECTOR(3 downto 0);
        Write_Reg_o   : out  STD_LOGIC_VECTOR(4 downto 0);

        -- RegFile
        Read_Data1_o   : out  STD_LOGIC_VECTOR(31 downto 0);
        Read_Data2_o   : out  STD_LOGIC_VECTOR(31 downto 0);
        -- Fordwarding
        Read_Reg1_o     : out STD_LOGIC_VECTOR(4 downto 0);
        Read_Reg2_o     : out STD_LOGIC_VECTOR(4 downto 0);
        -- PC 
        PC_Imm_o        : out  STD_LOGIC_VECTOR (31 downto 0);
        PC_4_o          : out  STD_LOGIC_VECTOR (31 downto 0);
        Branch_pred_o   : out STD_LOGIC -- Predicción si toma el salto
    );
end PipeDec;

architecture Behavioral of PipeDec is

    signal Jump_reg          :  STD_LOGIC := '0';
    signal ALUSrc_reg        :  STD_LOGIC := '0';
    signal MemtoReg_reg      :  STD_LOGIC := '0';
    signal RegWrite_reg      :  STD_LOGIC := '0';
    signal MemRead_reg       :  STD_LOGIC := '0';
    signal MemWrite_reg      :  STD_LOGIC := '0';
    signal Branch_reg        :  STD_LOGIC := '0';
    signal ALUOp_reg         :   STD_LOGIC_VECTOR(1 downto 0)  := (others => '0');
    signal imm_out_reg       :   STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal funct_3_reg       :   STD_LOGIC_VECTOR(2 downto 0)  := (others => '0');
    signal ALU_inst_reg      :   STD_LOGIC_VECTOR(3 downto 0)  := (others => '0');
    signal Write_Reg_reg     :   STD_LOGIC_VECTOR(4 downto 0)  := (others => '0');
    signal Read_Data1_reg    :   STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal Read_Data2_reg    :   STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal Read_Reg1_reg       : STD_LOGIC_VECTOR(4 downto 0):=(others => '0');
    signal Read_Reg2_reg       : STD_LOGIC_VECTOR(4 downto 0):=(others => '0');
    signal PC_Imm_reg           :  STD_LOGIC_VECTOR (31 downto 0):=(others => '0');
    signal PC_4_reg             :  STD_LOGIC_VECTOR (31 downto 0):=(others => '0');
    signal Branch_pred_reg   :  STD_LOGIC;

begin
    process(clk)
    begin
        if (rising_edge(clk) and stall = '0') then
            if reset = '1' then  -- Reset sincrónico
                Jump_reg          <=  '0';
                ALUSrc_reg        <=  '0';
                MemtoReg_reg      <=  '0';
                RegWrite_reg      <=  '0';
                MemRead_reg       <=  '0';
                MemWrite_reg      <=  '0';
                Branch_reg        <=  '0';
                ALUOp_reg         <=  (others => '0');
                imm_out_reg       <=  (others => '0');
                funct_3_reg       <=  (others => '0');
                ALU_inst_reg      <=  (others => '0');
                Write_Reg_reg     <=  (others => '0');
                Read_Data1_reg    <=  (others => '0');
                Read_Data2_reg    <=  (others => '0');
                Read_Reg1_reg     <=  (others => '0'); 
                Read_Reg2_reg     <=  (others => '0'); 
                PC_Imm_reg        <=(others => '0');
                PC_4_reg          <=(others => '0');
                Branch_pred_reg   <='0';
        
            else  
                Jump_reg          <=  Jump_i ;
                ALUSrc_reg        <=  ALUSrc_i;
                MemtoReg_reg      <=  MemtoReg_i;
                RegWrite_reg      <=  RegWrite_i;
                MemRead_reg       <=  MemRead_i;
                MemWrite_reg      <=  MemWrite_i;
                Branch_reg        <=  Branch_i;
                ALUOp_reg         <=  ALUOp_i;
                imm_out_reg       <=  imm_out_i;
                funct_3_reg       <=  funct_3_i;
                ALU_inst_reg      <=  ALU_inst_i;
                Write_Reg_reg     <=  Write_Reg_i;
                Read_Data1_reg    <=  Read_Data1_i;
                Read_Data2_reg    <=  Read_Data2_i;
                Read_Reg1_reg     <=  Read_Reg1_i; 
                Read_Reg2_reg     <=  Read_Reg2_i; 
                PC_Imm_reg        <= PC_Imm_i;
                PC_4_reg          <= PC_4_i;
                Branch_pred_reg   <= Branch_pred_i;
            end if;
        end if;
    end process;
    Jump_o          <=  Jump_reg;
    ALUSrc_o        <=  ALUSrc_reg;
    MemtoReg_o      <=  MemtoReg_reg;
    RegWrite_o      <=  RegWrite_reg;
    MemRead_o       <=  MemRead_reg;
    MemWrite_o      <=  MemWrite_reg;
    Branch_o        <=  Branch_reg;
    ALUOp_o         <=  ALUOp_reg;
    imm_out_o       <=  imm_out_reg;
    funct_3_o       <=  funct_3_reg;
    ALU_inst_o      <=  ALU_inst_reg;
    Write_Reg_o     <=  Write_Reg_reg;
    Read_Data1_o    <=  Read_Data1_reg;
    Read_Data2_o    <=  Read_Data2_reg;
    Read_Reg1_o     <= Read_Reg1_reg;
    Read_Reg2_o     <= Read_Reg2_reg;
    PC_Imm_o        <= PC_Imm_reg;
    PC_4_o          <= PC_4_reg;
    Branch_pred_o   <= Branch_pred_reg;


end Behavioral;