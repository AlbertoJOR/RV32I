library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Execute is
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;

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
        imm_out_i    : in  STD_LOGIC_VECTOR(31 downto 0);

        -- Instruction
        funct_3_i    : in  STD_LOGIC_VECTOR(2 downto 0);
        ALU_inst_i   : in  STD_LOGIC_VECTOR(3 downto 0);
        Write_Reg_i  : in  STD_LOGIC_VECTOR(4 downto 0);

        -- RegFile
        Read_Data1_i   : in  STD_LOGIC_VECTOR(31 downto 0);
        Read_Data2_i   : in  STD_LOGIC_VECTOR(31 downto 0);

        -- Fordwarding Unit
        MuxSel_A_i        : in STD_LOGIC_VECTOR(1 downto 0);
        MuxSel_B_i        : in STD_LOGIC_VECTOR(1 downto 0);
        Result_3_i        : in STD_LOGIC_VECTOR(31 downto 0);
        Write_Data_5_i        : in STD_LOGIC_VECTOR(31 downto 0);

        -- Salidas
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
        Read_Data2_o   : out  STD_LOGIC_VECTOR(31 downto 0)
    );
end Execute;
architecture Structural of Execute is
    component ALU is
        Port (
            A, B       : in  STD_LOGIC_VECTOR(31 downto 0);  -- Operandos
            ALU_Ctrl   : in  STD_LOGIC_VECTOR(4 downto 0);   -- Código de  Control
            Result     : out STD_LOGIC_VECTOR(31 downto 0); -- Salida de la ALU
            Zero       : out STD_LOGIC                      -- Señal para BEQ/BNE (1 si resultado es verdadero)
        );
    end component;
    signal B_input : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal Zero_s : STD_LOGIC:= '0';
    signal Result_s : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

    component ALUCtrl is
    port(
        ALU_inst : in STD_LOGIC_VECTOR(3 downto 0);
        ALUOp    : in STD_LOGIC_VECTOR(1 downto 0);
        ALU_CTRL : out STD_LOGIC_VECTOR(4 downto 0)
    );
    end component;
    
    signal ALU_CTRL_s : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');

    component PipeEx is
    Port (
        clk   : in  STD_LOGIC;
        reset : in  STD_LOGIC;

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
        Read_Data2_o   : out  STD_LOGIC_VECTOR(31 downto 0)
    );
    end component;
    -- Fordwarding Mux
    signal MUX_A_DATA : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal MUX_B_DATA : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

begin

    B_input <= imm_out_i when ALUSrc_i = '1' else Read_Data2_i;


    MuxA_Ford_process: process(MuxSel_A_i, Read_Data1_i, Result_3_i, Write_Data_5_i )
    begin
        case MuxSel_A_i is
            when "00" =>  
                MUX_A_DATA <= Read_Data1_i;
            when "01" =>  
                MUX_A_DATA <= Write_Data_5_i;
            when "10" =>  
                MUX_A_DATA <= Result_3_i;
            when others =>
                MUX_A_DATA <= Read_Data1_i;
        end case;
    end process;

    MuxB_Ford_process: process(MuxSel_B_i, B_input, Result_3_i, Write_Data_5_i )
    begin
        case MuxSel_B_i is
            when "00" =>  
                MUX_B_DATA <= B_input;
            when "01" =>  
                MUX_B_DATA <= Write_Data_5_i;
            when "10" =>  
                MUX_B_DATA <= Result_3_i;
            when others =>
                MUX_B_DATA <= B_input;
        end case;
    end process;
    
    ALU_C: ALU 
        port map (
            A          => MUX_A_DATA ,
            B          => B_input,
            ALU_Ctrl   => ALU_CTRL_s,
            Result     => Result_s,
            Zero       => Zero_s
        );

    ALUCtrl_c: ALUCtrl
    port map(
        ALU_inst => ALU_inst_i,
        ALUOp    => ALUOp_i,
        ALU_CTRL => ALU_CTRL_s 
    );

    PipeEx_c: PipeEx 
    Port map (
        clk   => clk, 
        reset => reset,

        -- ENTRADAS
        -- ControlUnit
        Jump_i       => Jump_i, 
        MemtoReg_i   => MemtoReg_i, 
        RegWrite_i   => RegWrite_i, 
        MemRead_i    => MemRead_i, 
        MemWrite_i   => MemWrite_i, 
        Branch_i     => Branch_i, 

        -- Instruction
        funct_3_i    => funct_3_i,
        Write_Reg_i  => Write_Reg_i,


        -- ALU 
        Zero_i       => Zero_s,
        Result_i     => Result_s,
        
        --RegFile
        Read_Data2_i  => Read_Data2_i,


        -- SALIDAS
        -- ControlUnit
        Jump_o       => Jump_o,
        MemtoReg_o   => MemtoReg_o,
        RegWrite_o   => RegWrite_o,
        MemRead_o    => MemRead_o,
        MemWrite_o   => MemWrite_o,
        Branch_o     => Branch_o,

        -- Instruction
        funct_3_o    => funct_3_o,
        Write_Reg_o  => Write_Reg_o,

        -- ALU 
        Zero_o       => Zero_o,
        Result_o     => Result_o,
        
        -- RegFile
        Read_Data2_o => Read_Data2_o
    );


    
end Structural;