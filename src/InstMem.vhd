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
        -- Prueba de R y I Arith
        X"00", X"00", X"00", X"00",  -- nop 
        X"00", X"30", X"02", X"93", -- addi x5, x0, 3 -- Cargar 3 en x5
        X"00", X"50", X"03", X"13", -- addi x6, x0, 5 -- Cargar 5 en x6
        X"00", X"a0", X"00", X"93", -- addi x1, x0, 10     -- Cargar 10 en x1  
        X"01", X"40", X"81", X"13", -- addi x2, x1, 20     -- Suma   x1 mas 20 
        X"40", X"11", X"01", X"33", -- sub  x2, x2, x1     -- Resta x2 = x2 - x1 
        X"00", X"21", X"01", X"33", -- add  x2, x2, x2     -- Suma x2 = x2 + x2 
        X"00", X"20", X"e1", X"b3", -- or  x3, x1, x2     -- OR x3 = x1 or x2 
        X"00", X"31", X"72", X"33", -- and x4, x2, x3  -- AND x4 = x2 and x3
        X"00", X"52", X"43", X"b3", -- xor x7, x4, x5  -- XOR x7 = x4 xor x5
        X"00", X"63", X"94", X"33", -- sll x8, x7, x6  -- shift left x8 = x7 << x6
        X"00", X"53", X"d4", X"b3", -- srl x9, x7, x5  -- shift right x8 = x7 >> x5
        X"00", X"00", X"00", X"00",  -- nop 
        X"00", X"00", X"00", X"00",  -- nop 
        X"00", X"00", X"00", X"00",  -- nop 
        -- Puebas Load y Store
        X"06", X"40", X"00", X"93", -- addi x1, x0, 100      -- Cargar dirección base en x1 
        X"12", X"34", X"51", X"37", -- lui x2, 0x12345      -- Cargar los 20 bits superiores (0x12345000)
        X"00", X"00", X"00", X"00",  -- nop 
        X"00", X"00", X"00", X"00",  -- nop 
        X"00", X"00", X"00", X"00",  -- nop 
        X"00", X"00", X"00", X"00",  -- nop 
        X"67", X"81", X"61", X"13", -- ori x2, x2, 0x678    -- OR con los 12 bits inferiores (0x12345678)
        X"00", X"00", X"00", X"00",  -- nop 
        X"00", X"00", X"00", X"00",  -- nop 
        X"00", X"00", X"00", X"00",  -- nop 
        X"00", X"20", X"a0", X"23", -- sw  x2, 0(x1)      -- Almacenar word (4 bytes) en [x1]  
        X"00", X"20", X"93", X"23", -- sh  x2, 6(x1)      -- Almacenar halfword (2 bytes) en [x1 + 4]  
        X"00", X"20", X"84", X"23", -- sb  x2, 8(x1)      -- Almacenar byte (1 byte) en [x1 + 6] 
        X"00", X"00", X"a2", X"83", -- lw  x5, 0(x1)      -- Cargar halfword desde [x1] a x6  
        X"00", X"00", X"93", X"03", -- lh  x6, 0(x1)      -- Cargar halfword desde [x1] a x6  
        X"00", X"00", X"83", X"83", -- lb  x7, 0(x1)      -- Cargar byte desde [x1] a x7
        X"00", X"60", X"a4", X"03", -- lw  x8, 6(x1)      -- Cargar halfword desde [x1] a x6  
        X"00", X"80", X"a4", X"83", -- lw  x9, 8(x1)      -- Cargar halfword desde [x1] a x6  
        others => X"00"  -- Relleno con 0s
        -- x2 = 0x1234 5678
        -- Addr    Byte
        -- 100     78
        -- 101     56
        -- 102     34
        -- 103     12
        -- 104     00
        -- 105     00
        -- 106     78
        -- 107     56
        -- 108     78
        -- 109     00
        -- 110     00
        -- 111     00

        -- Registros
        -- x5 = 0x12345678
        -- x6 = 0x00005678
        -- x7 = 0x00000078
        -- x8 = 0x00785678
        -- x9 = 0x00000078
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
