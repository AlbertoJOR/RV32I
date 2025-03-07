library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PipeMem is
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
end PipeMem;

architecture Behavioral of PipeMem is
    signal reg        :  STD_LOGIC_VECTOR(70 downto 0) := (others =>'0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                reg <= (others => '0');
            else
                reg <= MemtoReg_i & RegWrite_i & Write_Reg_i & Result_i & Data_mem_i;
            end if;
        end if;
    end process; 
    MemtoReg_o  <= reg(70);
    RegWrite_o  <= reg(69); 
    Write_Reg_o <= reg(68 downto 64); 
    Result_o    <= reg(63 downto 32);
    Data_mem_o   <= reg(31 downto 0);
end architecture;