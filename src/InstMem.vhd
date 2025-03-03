library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity InstMem is
    generic (
        ROM_SIZE : integer := 256  -- Tamaño de la ROM en bytes 
    );
    port (
        addr    : in  std_logic_vector(31 downto 0); 
        inst    : out std_logic_vector(31 downto 0)  
    );
end InstMem;

architecture Behavioral of InstMem is
    -- Memoria de instrucciones (array de bytes)
    type rom_array is array (0 to ROM_SIZE - 1) of std_logic_vector(7 downto 0);
    signal ROM : rom_array := (
        X"AB", X"BB", X"CC", X"DD",  -- Instrucción 1 = 0xAABBCCDD
        X"11", X"22", X"33", X"44",  -- Instrucción 2 = 0x11223344
        X"55", X"66", X"77", X"88",  -- Instrucción 3 = 0x55667788
        X"AB", X"CD", X"EF", X"12",  -- Instrucción 1 = 0xAABBCCDD
        others => X"00"  -- Relleno con 0s
    );

begin
    process (addr)
        variable word_addr : integer; 
    begin
        -- Convierte la dirección de bytes en índice de palabra (divide entre 4)
        word_addr := to_integer(unsigned(addr(31 downto 0)));  
        -- Concatenación de 4 bytes 
        inst <= ROM(word_addr)     &  -- Byte más significativo
                ROM(word_addr + 1) &
                ROM(word_addr + 2) &
                ROM(word_addr + 3);
    end process;

end Behavioral;
