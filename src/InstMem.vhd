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
        -- Usar el Encoder https://luplab.gitlab.io/rvcodecjs/
        X"00", X"00", X"00", X"00",  -- nop 
        X"00", X"a0", X"00", X"93",  -- addi x1, x0, 10     -- Cargar 10 en x1  
        X"01", X"40", X"01", X"13",  -- addi x2, x0, 20     -- Cargar 20 en x2  
        X"01", X"e0", X"01", X"93",  -- addi x3, x0, 30     -- Cargar 30 en x3  
        X"02", X"80", X"02", X"13",  -- addi x4, x0, 40     -- Cargar 40 en x4  
        X"03", X"20", X"02", X"93",  -- addi x5, x0, 50     -- Cargar 50 en x5  
        X"00", X"20", X"83", X"33",  -- add  x6, x1, x2     -- x6 = x1 + x2  
        X"00", X"00", X"00", X"00",  -- nop 
        X"40", X"41", X"83", X"b3",  -- sub  x7, x3, x4     -- x7 = x3 - x4  
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
