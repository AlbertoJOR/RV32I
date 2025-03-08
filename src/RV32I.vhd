library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Fetch Stage
entity RV32I is
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC
    );
end RV32I;
architecture Structural of RV32I is
    -- I  Fetch Instruction
    component Fetch is
        Port (
            clk         : in  STD_LOGIC;
            reset       : in  STD_LOGIC;
            branch      : in  STD_LOGIC;
            -- stall       : in  STD_LOGIC;
            ImmExt      : in  STD_LOGIC_VECTOR (31 downto 0);
    
            inst : out  STD_LOGIC_VECTOR (31 downto 0);
            PC_out : out  STD_LOGIC_VECTOR (31 downto 0)
        );
    end component;
    signal inst_1   :  STD_LOGIC_VECTOR (31 downto 0) := (others =>'0');
    signal PC_out_1 :  STD_LOGIC_VECTOR (31 downto 0) := (others =>'0');

    -- II Decode Instruction
    component Decode is
        Port (
            clk         : in  STD_LOGIC;
            reset       : in  STD_LOGIC;
            inst        : in  STD_LOGIC_VECTOR (31 downto 0);
            PC_val      : in  STD_LOGIC_VECTOR (31 downto 0);
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
            Read_Reg2_o     : out STD_LOGIC_VECTOR(4 downto 0)
    
        );
    end component;
    signal Jump_2       : STD_LOGIC:= '0';
    signal ALUSrc_2     : STD_LOGIC:= '0';
    signal MemtoReg_2   : STD_LOGIC:= '0';
    signal RegWrite_2   : STD_LOGIC:= '0';
    signal MemRead_2    : STD_LOGIC:= '0';
    signal MemWrite_2   : STD_LOGIC:= '0';
    signal Branch_2     : STD_LOGIC:= '0';
    signal ALUOp_2      : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
    -- ImmGen
    signal imm_out_2    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    -- Instruction
    signal funct_3_2    : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal ALU_inst_2   : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal Write_Reg_2  : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    -- RegFile
    signal Read_Data1_2   :  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal Read_Data2_2   :  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    -- Ford
    signal Read_Reg1_2   :  STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal Read_Reg2_2   :  STD_LOGIC_VECTOR(4 downto 0) := (others => '0');


    -- Fordwarding Unit
    component Fordwarding is
        port (
            Write_Reg_3     : in STD_LOGIC_VECTOR(4 downto 0);
            Write_Reg_4     : in STD_LOGIC_VECTOR(4 downto 0);
            RegWrite_3      : in STD_LOGIC;
            RegWrite_4      : in STD_LOGIC;
            Read_Reg1_2     : in STD_LOGIC_VECTOR(4 downto 0);
            Read_Reg2_2     : in STD_LOGIC_VECTOR(4 downto 0);
            MuxSel_A        : out STD_LOGIC_VECTOR(1 downto 0);
            MuxSel_B        : out STD_LOGIC_VECTOR(1 downto 0)
        );
    end component;
    signal MuxSel_A_F   :  STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
    signal MuxSel_B_F   :  STD_LOGIC_VECTOR(1 downto 0) := (others => '0');



    -- III Execution
    component Execute is
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
            Write_Data_5_i    : in STD_LOGIC_VECTOR(31 downto 0);
    
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
    end component;
                -- ControlUnit
            signal Jump_3       : STD_LOGIC := '0';
            signal MemtoReg_3   : STD_LOGIC := '0';
            signal RegWrite_3   : STD_LOGIC := '0';
            signal MemRead_3    : STD_LOGIC := '0';
            signal MemWrite_3   : STD_LOGIC := '0';
            signal Branch_3     : STD_LOGIC := '0';
            -- Instruction
            signal funct_3_3     : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
            signal Write_Reg_3   : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
            -- ALU 
            signal Zero_3       : STD_LOGIC := '0';
            signal Result_3     : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
            -- RegFile
            signal Read_Data2_3   : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

    -- IV Memory
    component Mem is
        Port (
            clk         : in  STD_LOGIC;
            reset       : in  STD_LOGIC;
            -- Entradas
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
            
            -- RegFile
            Read_Data2_i   : in  STD_LOGIC_VECTOR(31 downto 0);
    
            --Salidas
                    -- ControlUnit
            MemtoReg_o   : out STD_LOGIC;
            RegWrite_o   : out STD_LOGIC;
    
            -- Instruction
            Write_Reg_o   : out  STD_LOGIC_VECTOR(4 downto 0);
    
            -- ALU 
            Result_o     : out STD_LOGIC_VECTOR(31 downto 0); 
            
            -- MEM
            Data_mem_o  : out STD_LOGIC_VECTOR(31 downto 0);
            -- PC
            PCSrc       : out STD_LOGIC
            -- PC valor real
    
        );
    end component;
            signal MemtoReg_4   :  STD_LOGIC := '0';
            signal RegWrite_4   :  STD_LOGIC := '0';
            -- Instruction
            signal Write_Reg_4  :   STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
            -- ALU 
            signal Result_4     :  STD_LOGIC_VECTOR(31 downto 0) := (others => '0'); 
            -- MEM
            signal Data_mem_4   :  STD_LOGIC_VECTOR(31 downto 0) := (others =>'0');
            -- PC
            signal PCSrc_4        : STD_LOGIC := '0';
            
            
            -- Program Counter
            signal ImmExt_4 : STD_LOGIC_VECTOR(31 downto 0):=(others => '0');
            signal nop :STD_LOGIC := '0';
    
            -- V WriteBack
    signal Write_Data_5 : STD_LOGIC_VECTOR(31 downto 0) := ( others => '0');

begin

    Fetch_c: Fetch
        Port map (
            clk         => clk,
            reset       => reset,
            branch      => PCSrc_4,
            -- stall       : in  STD_LOGIC;
            ImmExt      => ImmExt_4,
    
            inst        => inst_1, 
            PC_out      => PC_out_1
        );

    Write_Data_5 <= Data_mem_4 when MemtoReg_4 ='1' else Result_4; 

    Decode_c : Decode 
            Port map(
                clk         =>  clk ,
                reset       => reset, 
                inst        => inst_1,
                PC_val      => PC_out_1, 
                nop         => nop, 
                -- WRITEBACK
                Write_Reg_WB  => Write_Reg_4,
                RegWrite_WB   => RegWrite_4,
                Write_Data_WB => Write_Data_5,
        
                        -- ControlUnit
                Jump_o       => Jump_2,
                ALUSrc_o     => ALUSrc_2,
                MemtoReg_o   => MemtoReg_2,
                RegWrite_o   => RegWrite_2,
                MemRead_o    => MemRead_2,
                MemWrite_o   => MemWrite_2,
                Branch_o     => Branch_2,
                ALUOp_o      => ALUOp_2,
                
                -- ImmGen
                imm_out_o    => imm_out_2, 
        
                -- Instruction
                funct_3_o    => funct_3_2,
                ALU_inst_o   => ALU_inst_2,
                Write_Reg_o  => Write_Reg_2,
        
                -- RegFile
                Read_Data1_o  => Read_Data1_2,
                Read_Data2_o  => Read_Data2_2,
                Read_Reg1_o   => Read_Reg1_2, 
                Read_Reg2_o   => Read_Reg2_2
        
            );

    Fordwarding_c: Fordwarding
        port map (
            Write_Reg_3    => Write_Reg_3, 
            Write_Reg_4    => Write_Reg_4, 
            RegWrite_3     => RegWrite_3, 
            RegWrite_4     => RegWrite_4, 
            Read_Reg1_2    => Read_Reg1_2, 
            Read_Reg2_2    => Read_Reg2_2, 
            MuxSel_A       => MuxSel_A_F, 
            MuxSel_B       => MuxSel_B_f 
        );


    Execute_c : Execute
        Port map (
            clk         => clk,
            reset       => reset,
    
                    -- ControlUnit
            Jump_i       => Jump_2,
            ALUSrc_i     => ALUSrc_2,
            MemtoReg_i   => MemtoReg_2,
            RegWrite_i   => RegWrite_2,
            MemRead_i    => MemRead_2,
            MemWrite_i   => MemWrite_2,
            Branch_i     => Branch_2,
            ALUOp_i      => ALUOp_2,
            
            -- ImmGen
            imm_out_i    => imm_out_2, 
    
            -- Instruction
            funct_3_i    => funct_3_2,
            ALU_inst_i   => ALU_inst_2,
            Write_Reg_i  => Write_Reg_2,
    
            -- RegFile
            Read_Data1_i   => Read_Data1_2,
            Read_Data2_i   => Read_Data2_2,

            -- Fordwarding Unit
            MuxSel_A_i       => MuxSel_A_F , 
            MuxSel_B_i       => MuxSel_B_F, 
            Result_3_i       => Result_3, 
            Write_Data_5_i   => Write_Data_5, 
    
            -- Salidas
            -- ControlUnit
            Jump_o       => Jump_3,
            MemtoReg_o   => MemtoReg_3,
            RegWrite_o   => RegWrite_3,
            MemRead_o    => MemRead_3,
            MemWrite_o   => MemWrite_3,
            Branch_o     => Branch_3,
    
            -- Instruction
            funct_3_o    => funct_3_3,
            Write_Reg_o  => Write_Reg_3,
    
            -- ALU 
            Zero_o       => Zero_3,
            Result_o     => Result_3,
            
            -- RegFile
            Read_Data2_o   =>  Read_Data2_3
        );
    
    Mem_c:  Mem 
        Port map(
            clk         => clk,
            reset       => reset,
            -- Entradas
            -- ControlUnit
            Jump_i      => Jump_3, 
            MemtoReg_i  => MemtoReg_3 , 
            RegWrite_i  => RegWrite_3, 
            MemRead_i   => MemRead_3, 
            MemWrite_i  => MemWrite_3, 
            Branch_i    => Branch_3, 
    
            -- Instruction
            funct_3_i   => funct_3_3, 
            Write_Reg_i => Write_Reg_3,  
    
            -- ALU 
            Zero_i     => Zero_3,  
            Result_i   => Result_3,  
            
            -- RegFile
            Read_Data2_i  => Read_Data2_3, 
    
            --Salidas
                    -- ControlUnit
            MemtoReg_o  => MemtoReg_4, 
            RegWrite_o  => RegWrite_4, 
    
            -- Instruction
            Write_Reg_o  => Write_Reg_4, 
    
            -- ALU 
            Result_o     => Result_4, 
            
            -- MEM
            Data_mem_o   => Data_mem_4,
            -- PC
            PCSrc        => PCSrc_4 
            -- PC valor real
    
        );

end architecture;