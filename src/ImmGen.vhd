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
    signal imm_i  : STD_LOGIC_VECTOR(31 downto 0);  -- Inst Inmediatas
    signal imm_s  : STD_LOGIC_VECTOR(31 downto 0);  -- Inst Store
    signal imm_b  : STD_LOGIC_VECTOR(31 downto 0);  -- Inst Branch
    signal imm12  : STD_LOGIC_VECTOR(11 downto 0);  -- Inst Branch
    signal sel    : STD_LOGIC_VECTOR(1 downto 0);

begin
    -- Extraer el selector de opcode (bits 6 y 5) los bits más significativos
    -- del opcode determinan el formato de instruccion
    sel <= instr(6 downto 5);

    -- Replicar el bit mas significativo 31

    -- I-Type (Load)
    imm_i <= (31 downto 12 => instr(31)) & instr(31 downto 20);  

    -- S-Type (Store)
    imm_s <= (31 downto 12 => instr(31)) & instr(31 downto 25) & instr(11 downto 7); 

    -- B-Type (Branch)
    imm_b <= (31 downto 12 => instr(31)) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0';

    -- Multiplexor para seleccionar el inmediato correcto
    with sel select 
        imm_out <= imm_i when "00",  -- Load (I-Type)
                   imm_s when "01",  -- Store (S-Type)
                   imm_b when "10",  -- Branch (B-Type)
                   (others => '0') when others; -- Default (0)

end Behavioral;
