library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Instruction is
    port(
        inst : in   STD_LOGIC_VECTOR(31 downto 0);
        Read_Reg1 : out   STD_LOGIC_VECTOR(4 downto 0);
        Read_Reg2 : out   STD_LOGIC_VECTOR(4 downto 0);
        Write_Reg : out   STD_LOGIC_VECTOR(4 downto 0);
        Imm        : out STD_LOGIC_VECTOR(4 downto 0);
        Alu_Ctrl : out STD_LOGIC_VECTOR(3 downto 0)
    );

end Instruction;