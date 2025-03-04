library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_ImmGen is
end tb_ImmGen;

architecture testbench of tb_ImmGen is
    -- Señales del testbench
    signal instr   : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    signal imm_out : STD_LOGIC_VECTOR (31 downto 0);
    
    -- Componente a probar (DUT - Device Under Test)
    component ImmGen
        Port (
            instr  : in  STD_LOGIC_VECTOR (31 downto 0);
            imm_out: out STD_LOGIC_VECTOR (31 downto 0)
        );
    end component;

begin
    -- Instancia del DUT
    UUT: ImmGen port map (
        instr  => instr,
        imm_out => imm_out
    );

    -- Proceso de simulación
    process
    begin
        -- LW x0, 4(x0)
        -- Carga el valor de memoria desde la dirección x0 + 4 en el registro x0.
        -- valor esperado: 0x00000004
        instr <= X"00402003";
        wait for 10 ns;

        -- SW x0, 4(x1)
        -- Almacena el valor de x0 en memoria en la dirección x1 + 4.
        -- valor esperado: 0x00000004
        instr <= X"00402003";
        wait for 10 ns;

        -- BEQ x1, x2, -4
        -- Salta a la dirección actual - 4 si los valores de x1 y x2 son iguales.
        -- valor esperado: 0xFFFFFFFC
        instr <= X"fe208ee3";
        wait for 10 ns;

        -- ADDI x3, x4, 10
        -- Suma el valor inmediato 10 al contenido de x4 y guarda el resultado en x3.
        -- valor esperado: 0x0000000A
        instr <= X"00a20193";
        wait for 10 ns;

        -- SW x5, 20(x6)
        -- Almacena el valor de x5 en memoria en la dirección x6 + 20.
        -- valor esperado: 	0x00000014
        instr <= X"00532a23";
        wait for 10 ns;

        -- BNE x7, x8, 16
        -- Salta a la dirección actual + 16 si los valores de x7 y x8 son diferentes.
        -- valor esperado: 0x00000010
        instr <= X"00839863";
        wait for 10 ns;

        -- ORI x9, x10, 255
        -- Realiza una operación OR entre x10 y el inmediato 255, y guarda el resultado en x9.
        -- valor esperado: 0x000000FF
        instr <= X"0ff56493";
        wait for 10 ns;

        -- ADDI x5, x6, -16
        -- Suma el valor inmediato -16 (12 bits extendido) al registro x6 y coloca el resultado en x5.
        -- valor esperado: 0xFFFFFFF0
        instr <= X"ff030293";
        wait for 10 ns;

        -- SW x7, -8(x8)
        -- Almacena el valor de x7 en la memoria en la dirección x8 + (-8) (inmediato extendido).
        -- valor esperado: 0xFFFFFFF8
        instr <= X"fe742c23";
        wait for 10 ns;

        -- BEQ x10, x11, 4
        -- Salta a la dirección 4 si los valores de x10 y x11 son iguales. Inmediato de 12 bits extendido.
        -- valor esperado: 0x00000004
        instr <= X"00b50263";
        wait for 10 ns;

        instr <= X"00000000";
        wait for 40 ns;


    end process;

end testbench;
