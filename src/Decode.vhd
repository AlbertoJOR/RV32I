library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Fetch Stage
entity Decode is
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        flush       : in STD_LOGIC;
        inst        : in  STD_LOGIC_VECTOR (31 downto 0);
        PC_i        : in  STD_LOGIC_VECTOR (31 downto 0);
        PC_4_i      : in  STD_LOGIC_VECTOR (31 downto 0);
        Branch_pred_i   : in STD_LOGIC; -- Predicción si toma el salto
        nop         : in  STD_LOGIC;
        -- WRITEBACK
        Write_Reg_WB  : in STD_LOGIC_VECTOR(4 downto 0);
        RegWrite_WB   : in STD_LOGIC;
        Write_Data_WB : in STD_LOGIC_VECTOR(31 downto 0);

                -- ControlUnit
        Jump_o       : out STD_LOGIC;
        ALUSrc_o     : out STD_LOGIC;
        MemtoReg_o   : out STD_LOGIC;
        RegWrite_o   : out STD_LOGIC;
        MemRead_o    : out STD_LOGIC;
        MemWrite_o   : out STD_LOGIC;
        Branch_o     : out STD_LOGIC;
        Branch     : out STD_LOGIC;
        ALUOp_o      : out STD_LOGIC_VECTOR(1 downto 0);
        
        -- ImmGen
        imm_out_o    : out  STD_LOGIC_VECTOR(31 downto 0);

        -- Instruction
        funct_3_o    : out  STD_LOGIC_VECTOR(2 downto 0);
        ALU_inst_o   : out  STD_LOGIC_VECTOR(3 downto 0);
        Write_Reg_o  : out  STD_LOGIC_VECTOR(4 downto 0);

        -- RegFile
        Read_Data1_o   : out  STD_LOGIC_VECTOR(31 downto 0);
        Read_Data2_o   : out  STD_LOGIC_VECTOR(31 downto 0);

        -- Fordwarding
        Read_Reg1_o     : out STD_LOGIC_VECTOR(4 downto 0);
        Read_Reg2_o     : out STD_LOGIC_VECTOR(4 downto 0);

        -- Hazard
        Read_Reg1_Ho     : out STD_LOGIC_VECTOR(4 downto 0);
        Read_Reg2_Ho     : out STD_LOGIC_VECTOR(4 downto 0);
        -- PC
        PC_Imm          : out  STD_LOGIC_VECTOR (31 downto 0);
        PC_Imm_o        : out  STD_LOGIC_VECTOR (31 downto 0);
        PC_4_o          : out  STD_LOGIC_VECTOR (31 downto 0);
        Branch_pred_o   : out STD_LOGIC -- Predicción si toma el salto
    );
end Decode;
architecture Structural of Decode is

    component Instruction is
        port(
            inst        : in  STD_LOGIC_VECTOR(31 downto 0);
            Opcode      : out STD_LOGIC_VECTOR(6 downto 0);
            Read_Reg1   : out STD_LOGIC_VECTOR(4 downto 0);
            Read_Reg2   : out STD_LOGIC_VECTOR(4 downto 0);
            Write_Reg   : out STD_LOGIC_VECTOR(4 downto 0);
            ALU_inst    : out STD_LOGIC_VECTOR(3 downto 0);
            funct_3     : out STD_LOGIC_VECTOR(2 downto 0);
            inst_Imm    : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    signal Opcode_s      : STD_LOGIC_VECTOR(6 downto 0) := (others => '0');
    signal Read_Reg1_s   : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal Read_Reg2_s   : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal inst_Imm_s    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    
    component ControlUnit is
    Port (
        OpCode     : in  STD_LOGIC_VECTOR(6 downto 0); -- Opcode de la instrucción
        reset        : in STD_LOGIC;
        nop        : in STD_LOGIC;
        Jump       : out STD_LOGIC;
        ALUSrc     : out STD_LOGIC;
        MemtoReg   : out STD_LOGIC;
        RegWrite   : out STD_LOGIC;
        MemRead    : out STD_LOGIC;
        MemWrite   : out STD_LOGIC;
        Branch     : out STD_LOGIC;
        ALUOp      : out STD_LOGIC_VECTOR(1 downto 0)
    );
    end component;



    signal Jump_s          :  STD_LOGIC := '0';
    signal ALUSrc_s        :  STD_LOGIC := '0';
    signal MemtoReg_s      :  STD_LOGIC := '0';
    signal RegWrite_s      :  STD_LOGIC := '0';
    signal MemRead_s       :  STD_LOGIC := '0';
    signal MemWrite_s      :  STD_LOGIC := '0';
    signal Branch_s        :  STD_LOGIC := '0';
    signal ALUOp_s         :   STD_LOGIC_VECTOR(1 downto 0)  := (others => '0');
    

    component RegFile is
    Port (
        clk             : in  STD_LOGIC;
        reset           : in  STD_LOGIC;
        Read_Reg1       : in  STD_LOGIC_VECTOR (4 downto 0);
        Read_Reg2       : in  STD_LOGIC_VECTOR (4 downto 0);
        Write_Reg       : in  STD_LOGIC_VECTOR (4 downto 0);
        Write_Data      : in  STD_LOGIC_VECTOR (31 downto 0);
        Write_Enable    : in  STD_LOGIC;
        Read_Data1      : out STD_LOGIC_VECTOR (31 downto 0);
        Read_Data2      : out STD_LOGIC_VECTOR (31 downto 0)
    );
    end component;

    component ImmGen is
        Port (
            instr    : in  STD_LOGIC_VECTOR (31 downto 0);
            imm_out  : out STD_LOGIC_VECTOR (31 downto 0) 
        );
    end component;

    component Adder is
        Port (
            A     : in  STD_LOGIC_VECTOR(31 downto 0);
            B     : in  STD_LOGIC_VECTOR(31 downto 0);
            Sum   : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    signal PC_Imm_s         :   STD_LOGIC_VECTOR(31 downto 0)  := (others => '0');

    component PipeDec is
    Port (
        clk   : in  STD_LOGIC;
        reset : in  STD_LOGIC;

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
        Branch_pred_i   : in STD_LOGIC;-- Predicción si toma el salto


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
    end component;

    signal imm_out_s       :   STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal funct_3_s       :   STD_LOGIC_VECTOR(2 downto 0)  := (others => '0');
    signal ALU_inst_s      :   STD_LOGIC_VECTOR(3 downto 0)  := (others => '0');
    signal Write_Reg_s     :   STD_LOGIC_VECTOR(4 downto 0)  := (others => '0');
    signal Read_Data1_s    :   STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal Read_Data2_s    :   STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    
    signal reset_or_flush : STD_LOGIC :='0';



begin
    Instruction_c : Instruction 
        port map (
            inst        => inst  ,
            Opcode      => Opcode_s ,
            Read_Reg1   => Read_Reg1_s  ,
            Read_Reg2   => Read_Reg2_s  ,
            Write_Reg   => Write_Reg_s  ,
            ALU_inst    => ALU_inst_s  ,
            funct_3     => funct_3_s  ,
            inst_Imm    => inst_Imm_s  
        );
    ControlUnit_c : ControlUnit 
    port map (
        OpCode     => Opcode_s   ,
        reset      => reset   , 
        nop        => nop , 
        Jump       =>  Jump_s   ,
        ALUSrc     =>  ALUSrc_s  ,
        MemtoReg   =>  MemtoReg_s  ,
        RegWrite   =>  RegWrite_s  ,
        MemRead    =>  MemRead_s  ,
        MemWrite   =>  MemWrite_s  ,
        Branch     =>  Branch_s  ,
        ALUOp      =>  ALUOp_s 
    );
    Branch <= Branch_s; -- Branch predictor

    RegFile_c : RegFile 
        port map (
            clk             => clk,
            reset           => reset,
            Read_Reg1       => Read_Reg1_s,
            Read_Reg2       => Read_Reg2_s,
            Write_Reg       => Write_Reg_WB,
            Write_Data      => Write_Data_WB,
            Write_Enable    => RegWrite_WB,
            Read_Data1      => Read_Data1_s,
            Read_Data2      => Read_Data2_s 
        );
    Read_Reg2_Ho <= Read_Reg2_s;
    Read_Reg1_Ho <= Read_Reg1_s;
    
    ImmGen_c : ImmGen 
        port map (
            instr    =>inst_Imm_s, 
            imm_out  =>imm_out_s
        );
    PC_Adder : Adder 
            Port map(
                A    => PC_i, 
                B    => imm_out_s, 
                Sum  => PC_Imm_s 
            );
    PC_Imm <= PC_Imm_s; -- salida para el PC counter
    reset_or_flush <= reset or flush;
    
    PipeDec_c : PipeDec 
    port map (
        clk  => clk, 
        reset => reset_or_flush,

        -- ENTRADAS
        -- ControlUnit
        Jump_i       => Jump_s, 
        ALUSrc_i     => ALUSrc_s, 
        MemtoReg_i   => MemtoReg_s, 
        RegWrite_i   => RegWrite_s, 
        MemRead_i    => MemRead_s, 
        MemWrite_i   => MemWrite_s, 
        Branch_i     => Branch_s, 
        ALUOp_i      => ALUOp_s,

        -- ImmGen
        imm_out_i   => imm_out_S,

        -- Instruction
        funct_3_i      => funct_3_s,
        ALU_inst_i     => ALU_inst_s,
        Write_Reg_i    => Write_Reg_s,

        -- RegFile
        Read_Data1_i  => Read_Data1_s, 
        Read_Data2_i  => Read_Data2_s, 

        -- Fordwarding
        Read_Reg1_i   => Read_Reg1_s, 
        Read_Reg2_i   => Read_Reg2_s,
        -- PC
        PC_Imm_i     => PC_Imm_s ,  
        PC_4_i       => PC_4_i,  
        Branch_pred_i => Branch_pred_i, 

        -- SALIDAS
        -- ControlUnit
        Jump_o       => Jump_o,
        ALUSrc_o     => ALUSrc_o,
        MemtoReg_o   => MemtoReg_o,
        RegWrite_o   => RegWrite_o,
        MemRead_o    => MemRead_o,
        MemWrite_o   => MemWrite_o,
        Branch_o     => Branch_o,
        ALUOp_o      => ALUOp_o,
        
        -- ImmGen
        imm_out_o   => imm_out_o, 

        -- Instruction
        funct_3_o       => funct_3_o,
        ALU_inst_o      => ALU_inst_o,
        Write_Reg_o     => Write_Reg_o,

        -- RegFile
        Read_Data1_o  => Read_Data1_o, 
        Read_Data2_o  => Read_Data2_o,
                -- Fordwarding
        Read_Reg1_o   => Read_Reg1_o, 
        Read_Reg2_o   => Read_Reg2_o ,
        -- PC
        PC_Imm_o     => PC_Imm_o,  
        PC_4_o       => PC_4_o ,
        Branch_pred_o => Branch_pred_o 
    );

end Structural;