library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Instruction is
    port(
        inst        : in  STD_LOGIC_VECTOR(31 downto 0);
        Opcode      : out STD_LOGIC_VECTOR(6 downto 0);
        Read_Reg1   : out STD_LOGIC_VECTOR(4 downto 0);
        Read_Reg2   : out STD_LOGIC_VECTOR(4 downto 0);
        Write_Reg   : out STD_LOGIC_VECTOR(4 downto 0);
        ALU_inst    : out STD_LOGIC_VECTOR(3 downto 0);
        inst_Imm    : out STD_LOGIC_VECTOR(31 downto 0)
    );


end Instruction;

architecture Behavioral of Instruction is
begin 
    Opcode    <= inst(6 downto 0);
    Read_Reg1 <= inst(19 downto 15);
    Read_Reg2 <= inst(24 downto 20);
    Write_Reg <= inst(11 downto 7);
    ALU_inst  <= inst(30) & inst(14 downto 12); 
    inst_Imm  <= inst;

end Behavioral;