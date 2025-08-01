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
        funct_3     : out STD_LOGIC_VECTOR(2 downto 0);
        inst_Imm    : out STD_LOGIC_VECTOR(31 downto 0)
    );


end Instruction;

architecture Behavioral of Instruction is
begin 


    Opcode    <= inst(6 downto 0);
    Read_Reg1 <= "00000" when (inst(6 downto 0) = "0110111" or 
                           inst(6 downto 0) = "1101111" or 
                           inst(6 downto 0) = "0010111") 
                         else inst(19 downto 15); -- lui, jal, auipc requieren en 0 para sumar
    Read_Reg2 <= "00000" when (inst(6 downto 0) = "0110111" or 
                           inst(6 downto 0) = "1101111" or 
                           inst(6 downto 0) = "0000011" or 
                           inst(6 downto 0) = "0010011" or 
                           inst(6 downto 0) = "1100111" or 
                           inst(6 downto 0) = "0010111") 
                         else inst(24 downto 20); -- lui, jal, auipc requieren en 0 para sumar
    Write_Reg <= "00000" when (inst(6 downto 0) = "0100011" or 
                           inst(6 downto 0) = "1100011") 
                         else inst(11 downto 7); -- lui, jal, auipc requieren en 0 para sumar
    ALU_inst  <= inst(30) & inst(14 downto 12); 
    funct_3   <= inst(14 downto 12);
    inst_Imm  <= inst;



end Behavioral;