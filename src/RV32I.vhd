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
        flush       : in STD_LOGIC;
        stall       : in  STD_LOGIC;
        Branch_pred_i  : in STD_LOGIC;
        PC_Imm_i       : in STD_LOGIC_VECTOR(31 downto 0);  
        PC_corrected_i : in STD_LOGIC_VECTOR(31 downto 0);   

        inst : out  STD_LOGIC_VECTOR (31 downto 0);
        PC_out : out  STD_LOGIC_VECTOR (31 downto 0);
        PC_4_out : out  STD_LOGIC_VECTOR (31 downto 0)
    );
    end component;
    signal inst_1   :  STD_LOGIC_VECTOR (31 downto 0) := (others =>'0');
    signal PC_out_1 :  STD_LOGIC_VECTOR (31 downto 0) := (others =>'0');
    signal PC_4_out_1 :  STD_LOGIC_VECTOR (31 downto 0) := (others =>'0');

    -- Hazard Unit
    component Hazard is
        port (
            
            Write_Reg_2        : in STD_LOGIC_VECTOR(4 downto 0);
            Read_Reg1_1     : in STD_LOGIC_VECTOR(4 downto 0);
            Read_Reg2_1     : in STD_LOGIC_VECTOR(4 downto 0);
            MemRead_2     : in STD_LOGIC;
            nop    : out STD_LOGIC
       
        );
    end component;
    -- Hazard
    signal nop_hazard    : STD_LOGIC := '0';        
    signal Read_Reg1_1     : STD_LOGIC_VECTOR(4 downto 0) :=(others => '0');
    signal Read_Reg2_1     : STD_LOGIC_VECTOR(4 downto 0) :=(others => '0');

    -- Branch Predictor

    component BranchPred IS
    port (
       clk         : in  STD_LOGIC;
       reset       : in  STD_LOGIC;
       taken       : in  STD_LOGIC;
       enable      : in  STD_LOGIC;
       Branch_ins  : in  STD_LOGIC;
       Branch_pred : out STD_LOGIC
    );
    END component;

    signal Branch_pred_s : STD_LOGIC:='0';

    -- II Decode Instruction
    component Decode is
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        flush       : in  STD_LOGIC;
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
        Jump       : out STD_LOGIC;
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
    end component;
    signal Jump_2       : STD_LOGIC:= '0';
    signal Jump_1       : STD_LOGIC:= '0';
    signal ALUSrc_2     : STD_LOGIC:= '0';
    signal MemtoReg_2   : STD_LOGIC:= '0';
    signal RegWrite_2   : STD_LOGIC:= '0';
    signal MemRead_2    : STD_LOGIC:= '0';
    signal MemWrite_2   : STD_LOGIC:= '0';
    signal Branch_2     : STD_LOGIC:= '0';
    signal Branch_1     : STD_LOGIC:= '0'; -- Branch Predictor
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
    -- Branch
    signal PC_Imm_1 :  STD_LOGIC_VECTOR (31 downto 0) := (others =>'0'); -- Vuelve a Decode al PC
    signal PC_Imm_2 :  STD_LOGIC_VECTOR (31 downto 0) := (others =>'0');
    signal PC_4_2 :  STD_LOGIC_VECTOR (31 downto 0) := (others =>'0');
    signal Branch_pred_2: STD_LOGIC :='0';

    signal Branch_or_Jump       : STD_LOGIC:= '0';


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
        flush       : in  STD_LOGIC;

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
        -- PC
        Branch_pred_i   : in  STD_LOGIC; 
        PC_Imm_i        : in STD_LOGIC_VECTOR (31 downto 0);
        PC_4_i          : in  STD_LOGIC_VECTOR (31 downto 0);

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
        Read_Data2_o   : out  STD_LOGIC_VECTOR(31 downto 0);
        -- PC
        Branch_pred_o   : out  STD_LOGIC; 
        PC_Imm_o        : out STD_LOGIC_VECTOR (31 downto 0);
        PC_4_o          : out  STD_LOGIC_VECTOR (31 downto 0)
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
    -- Branch
    signal PC_Imm_3 :  STD_LOGIC_VECTOR (31 downto 0) := (others =>'0');
    signal PC_4_3 :  STD_LOGIC_VECTOR (31 downto 0) := (others =>'0');
    signal Branch_pred_3: STD_LOGIC :='0';

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
        
        -- PC
        Branch_pred_i   : in  STD_LOGIC; 
        PC_Imm_i        : in STD_LOGIC_VECTOR (31 downto 0);
        PC_4_i          : in  STD_LOGIC_VECTOR (31 downto 0);

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
        Zero_and_Branch       : out STD_LOGIC;
        Flush               : out STD_LOGIC;
        PC_corrected          : out  STD_LOGIC_VECTOR (31 downto 0)

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
        signal nop :STD_LOGIC := '0';
        -- PC
        signal Zero_and_Branch_4       :  STD_LOGIC:= '0';
        signal Flush_4                 :  STD_LOGIC:= '0';
        signal PC_corrected_4          :  STD_LOGIC_VECTOR (31 downto 0) := (others => '0');


    
            -- V WriteBack
    signal Write_Data_5 : STD_LOGIC_VECTOR(31 downto 0) := ( others => '0');

begin
    Branch_or_Jump <= Branch_pred_s or Jump_1;

    Fetch_c: Fetch
        Port map (
            clk         => clk,
            reset       => reset,
            Branch_pred_i =>  Branch_or_Jump ,-- BranchPredictor or Jump
            flush       =>  Flush_4,
            stall       => nop_hazard, 
            PC_Imm_i      => PC_Imm_1,
            PC_corrected_i => PC_corrected_4        ,
            inst        => inst_1, 
            PC_out      => PC_out_1,
            PC_4_out    =>  PC_4_out_1       
        );

    Write_Data_5 <= Data_mem_4 when MemtoReg_4 ='1' else Result_4; 

    Hazard_c : Hazard
        port map(
            
            Write_Reg_2  => Write_Reg_2, 
            Read_Reg1_1  => Read_Reg1_1, 
            Read_Reg2_1  => Read_Reg2_1, 
            MemRead_2    => MemRead_2, 
            nop          => nop_hazard 
       
        );
    
    BranchPred_c :BranchPred 
    port map(
       clk         => clk, 
       reset       => reset, 
       taken       => Zero_and_Branch_4, 
       enable      => Branch_3, 
       Branch_ins  => Branch_1, 
       Branch_pred => Branch_pred_s 
    );

    Decode_c : Decode 
            Port map(
                clk         =>  clk ,
                reset       => reset, 
                flush       =>  Flush_4,
                inst        => inst_1,
                PC_i        => PC_out_1, 
                PC_4_i      => PC_4_out_1, 
                Branch_pred_i => Branch_pred_s ,
                nop         => nop_hazard, 
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
                Branch     => Branch_1,
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
                -- Fordward
                Read_Reg1_o   => Read_Reg1_2, 
                Read_Reg2_o   => Read_Reg2_2,
                -- Hazard
                Read_Reg1_Ho  => Read_Reg1_1,   
                Read_Reg2_Ho  => Read_Reg2_1,
                -- PC
                PC_Imm        => PC_Imm_1,  
                PC_Imm_o      => PC_Imm_2,  
                PC_4_o        => PC_4_2,  
                Branch_pred_o => Branch_pred_2  
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
            MuxSel_B       => MuxSel_B_F 
        );


    Execute_c : Execute
        Port map (
            clk         => clk,
            reset       => reset,
            flush       =>  Flush_4,
    
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
            -- PC
            Branch_pred_i  => Branch_pred_2, 
            PC_Imm_i       => PC_Imm_2, 
            PC_4_i         => PC_4_2, 
    
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
            Read_Data2_o   =>  Read_Data2_3,
            -- PC
            Branch_pred_o  => Branch_pred_3, 
            PC_Imm_o       => PC_Imm_3, 
            PC_4_o         => PC_4_3 
 
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
            -- PC
            Branch_pred_i  => Branch_pred_3 , 
            PC_Imm_i       => PC_Imm_3, 
            PC_4_i         => PC_4_3, 
    
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
            Zero_and_Branch    =>Zero_and_Branch_4, 
            Flush              =>Flush_4, 
            PC_corrected       => PC_corrected_4
    
        );

end architecture;