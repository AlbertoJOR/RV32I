library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Mem is
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        -- Entradas
        -- ControlUnit
        Jump_i       : out STD_LOGIC;
        MemtoReg_i   : out STD_LOGIC;
        RegWrite_i   : out STD_LOGIC;
        MemRead_i    : out STD_LOGIC;
        MemWrite_i   : out STD_LOGIC;
        Branch_i     : out STD_LOGIC;

        -- Instruction
        funct_3_i   : out  STD_LOGIC_VECTOR(2 downto 0);
        Write_Reg_i   : out  STD_LOGIC_VECTOR(4 downto 0);

        -- ALU 
        Zero_i       : out STD_LOGIC;   
        Result_i     : out STD_LOGIC_VECTOR(31 downto 0); 
        
        -- RegFile
        Read_Data2_i   : out  STD_LOGIC_VECTOR(31 downto 0);

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
    signal PCSrc_s : STD_LOGIC:= '0';

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
                Result_i    => Result_i, 
        
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
    PCSrc_s <= Zero_i and Branch_i;
    PCSrc <= PCSrc_s;

    
end architecture;