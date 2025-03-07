library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ImmGen is
    Port (
        instr    : in  STD_LOGIC_VECTOR (31 downto 0);
        imm_out  : out STD_LOGIC_VECTOR (31 downto 0) 
    );
end ImmGen;

architecture Behavioral of ImmGen is
    signal imm_i  : STD_LOGIC_VECTOR(31 downto 0);  -- I-Type (Load / ALU Immediate)
    signal imm_s  : STD_LOGIC_VECTOR(31 downto 0);  -- S-Type (Store)
    signal imm_b  : STD_LOGIC_VECTOR(31 downto 0);  -- B-Type (Branch)
    signal imm_j  : STD_LOGIC_VECTOR(31 downto 0);  -- J-Type (JAL)
    signal imm_u  : STD_LOGIC_VECTOR(31 downto 0);  -- U-Type (LUI)
    signal sel    : STD_LOGIC_VECTOR(4 downto 0);  

begin
    -- Selector basado en los bits 6-2 del opcode
    sel <= instr(6 downto 2);  

    imm_i <= (31 downto 12 => instr(31)) & instr(31 downto 20);  

    imm_s <= (31 downto 12 => instr(31)) & instr(31 downto 25) & instr(11 downto 7); 

    imm_b <= (31 downto 12 => instr(31)) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0';

    imm_j <= (31 downto 20 => instr(31)) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & '0';

    imm_u <= instr(31 downto 12) & (11 downto 0 => '0');  

    with sel select 
        imm_out <= imm_i when "00000",  -- Load (0000011)
                   imm_i when "00100",  -- ALU Imm (0010011)
                   imm_i when "11001",  -- Jalr (1100111)
                   imm_s when "01000",  -- Store (0100011)
                   imm_b when "11000",  -- Branch (1100011)
                   imm_j when "11011",  -- JAL (1101111)
                   imm_u when "01101",  -- LUI (0110111)
                   (others => '0') when others;  
end Behavioral;
