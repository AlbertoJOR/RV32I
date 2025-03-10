library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Mem is
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
end Mem;
architecture Structural of Mem is

    component RAM is
        Port (
            clk      : in  STD_LOGIC;
            reset    : in  STD_LOGIC;  
            we       : in  STD_LOGIC;  
            re       : in  STD_LOGIC;  
            addr     : in  STD_LOGIC_VECTOR(31 downto 0);
            din      : in  STD_LOGIC_VECTOR(31 downto 0);
            funct3   : in  STD_LOGIC_VECTOR(2 downto 0); 
            dout     : out STD_LOGIC_VECTOR(31 downto 0) 
        );
    end component;
    signal  dout_s     : STD_LOGIC_VECTOR(31 downto 0):=(others => '0'); 
    signal Zero_and_Branch_s : STD_LOGIC:= '0';

    component BMCU is
        port (
            Zero_and_Branch:  in STD_LOGIC;
            Branch_pred: in STD_LOGIC;
            enable : in STD_LOGIC;
            PC_4  : in STD_LOGIC_VECTOR(31 downto 0);
            PC_Imm : in STD_LOGIC_VECTOR(31 downto 0);
            PC_corrected: out STD_LOGIC_VECTOR(31 downto 0);
            Flush       : out STD_LOGIC
            
        );
    end component;
    signal Result_PC_4     :  STD_LOGIC_VECTOR(31 downto 0):= (others => '0'); 

    component PipeMem is
        Port (
            clk   : in  STD_LOGIC;
            reset : in  STD_LOGIC;
    
            -- ENTRADAS
            -- ControlUnit
            MemtoReg_i   : in STD_LOGIC;
            RegWrite_i   : in STD_LOGIC;
    
            -- Instruction
            Write_Reg_i   : in  STD_LOGIC_VECTOR(4 downto 0);
    
    
            -- ALU 
            Result_i     : in STD_LOGIC_VECTOR(31 downto 0); 
    
            -- MEM
            Data_mem_i  : in STD_LOGIC_VECTOR(31 downto 0);
    
            -- SALIDAS
            -- ControlUnit
            MemtoReg_o   : out STD_LOGIC;
            RegWrite_o   : out STD_LOGIC;
    
            -- Instruction
            Write_Reg_o   : out  STD_LOGIC_VECTOR(4 downto 0);
    
            -- ALU 
            Result_o     : out STD_LOGIC_VECTOR(31 downto 0); 
            
            -- MEM
            Data_mem_o  : out STD_LOGIC_VECTOR(31 downto 0)
            
        );
    end component;



begin

    RAM_C : RAM 
        Port map (
            clk      => clk,
            reset    => reset,
            we       => MemWrite_i,
            re       => MemRead_i,  
            addr     => Result_i ,
            din      => Read_Data2_i,
            funct3   => funct_3_i ,
            dout     => dout_s 
        );
    Zero_and_Branch_s <= Zero_i and Branch_i;
    Zero_and_Branch <= Zero_and_Branch_s;
    
    BMCU_c: BMCU 
        port map(
                Zero_and_Branch    => Zero_and_Branch_s, 
                Branch_pred        => Branch_pred_i, 
                enable             => Branch_i, 
                PC_4               => PC_4_i, 
                PC_Imm             => PC_Imm_i, 
                PC_corrected       => PC_corrected, 
                Flush              =>  Flush
        );
    Result_PC_4 <= PC_4_i when Jump_i ='1' else Result_i;
    
    PipeMem_c:    PipeMem
            Port map(
                clk  => clk, 
                reset=> reset, 
                -- ControlUnit
                MemtoReg_i  => MemtoReg_i, 
                RegWrite_i  => RegWrite_i, 
        
                -- Instruction
                Write_Reg_i  => Write_Reg_i, 
        
        
                -- ALU 
                Result_i    => Result_PC_4, 
        
                -- MEM
                Data_mem_i  => dout_s , 
        
                -- SALIDAS
                -- ControlUnit
                MemtoReg_o  => MemtoReg_o,  
                RegWrite_o  => RegWrite_o, 
        
                -- Instruction
                Write_Reg_o  => Write_Reg_o, 
        
                -- ALU 
                Result_o    => Result_o, 
                
                -- MEM
                Data_mem_o  => Data_mem_o
                
            );

    
end architecture;