library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_cache is
end tb_cache;

architecture Behavioral of tb_cache is
    -- Constantes para funct3 en RISC-V
    constant F3_BYTE      : STD_LOGIC_VECTOR(2 downto 0) := "000"; -- lb/sb
    constant F3_HALF      : STD_LOGIC_VECTOR(2 downto 0) := "001"; -- lh/sh
    constant F3_WORD      : STD_LOGIC_VECTOR(2 downto 0) := "010"; -- lw/sw
    constant F3_BYTE_U    : STD_LOGIC_VECTOR(2 downto 0) := "100"; -- lbu
    constant F3_HALF_U    : STD_LOGIC_VECTOR(2 downto 0) := "101"; -- lhu

    -- Señales para el testbench
    signal clk      : STD_LOGIC := '0';
    signal reset    : STD_LOGIC := '0';
    signal addr     : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal din      : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal we       : STD_LOGIC := '0';
    signal re       : STD_LOGIC := '0';
    signal funct3   : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal dout     : STD_LOGIC_VECTOR(31 downto 0);
    signal miss     : STD_LOGIC;
    
    -- Periodo de reloj
    constant CLK_PERIOD : time := 10 ns;
    
    -- Señal para finalizar la simulación
    signal sim_done : boolean := false;
    
    -- Componente de la caché a probar
    component Cache is
        generic (
            CACHE_SIZE : integer := 64  -- número de líneas de caché (potencia de 2)
        );
        Port (
            clk      : in  STD_LOGIC;
            reset    : in  STD_LOGIC;
            addr     : in  STD_LOGIC_VECTOR(31 downto 0);
            din      : in  STD_LOGIC_VECTOR(31 downto 0);
            we       : in  STD_LOGIC;
            re       : in  STD_LOGIC;
            funct3   : in  STD_LOGIC_VECTOR(2 downto 0);
            dout     : out STD_LOGIC_VECTOR(31 downto 0);
            miss     : out STD_LOGIC
        );
    end component;
    

begin
    -- Instanciación de la caché
    UUT: Cache
        generic map (
            CACHE_SIZE => 16
        )
        port map (
            clk     => clk,
            reset   => reset,
            addr    => addr,
            din     => din,
            we      => we,
            re      => re,
            funct3  => funct3,
            dout    => dout,
            miss    => miss
        );
    
    -- Generación de reloj
    clock_process: process
    begin
        while not sim_done loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;
    
    -- Proceso de estímulo
    stimulus: process
        -- Procedimiento para esperar n ciclos
        procedure wait_cycles(n: integer) is
        begin
            for i in 1 to n loop
                wait until rising_edge(clk);
            end loop;
        end procedure;
        
        -- Procedimiento para escribir en memoria
        procedure write_mem(address: in STD_LOGIC_VECTOR(31 downto 0);
                           data: in STD_LOGIC_VECTOR(31 downto 0);
                           f3: in STD_LOGIC_VECTOR(2 downto 0)) is
        begin
            addr <= address;
            din <= data;
            funct3 <= f3;
            we <= '1';
            re <= '0';
            wait until rising_edge(clk);
            wait_cycles(1);  -- Para esperar que la caché termine su operación
            we <= '0';
            wait_cycles(2);  -- Esperar que la escritura se complete
        end procedure;
        
        -- Procedimiento para leer de memoria
        procedure read_mem(address: in STD_LOGIC_VECTOR(31 downto 0);
                          f3: in STD_LOGIC_VECTOR(2 downto 0)) is
        begin
            addr <= address;
            funct3 <= f3;
            re <= '1';
            we <= '0';
            wait until rising_edge(clk);
            wait_cycles(1);  -- Para esperar que la caché termine su operación
            re <= '0';
            wait_cycles(2);  -- Esperar que la lectura se complete
        end procedure;
        
    begin
        -- Reset inicial
        reset <= '1';
        wait_cycles(2);
        reset <= '0';
        wait_cycles(2);
        
        -- TEST 1: Escritura y lectura de palabra completa (sw/lw)
        report "TEST 1: Escritura y lectura de palabra completa (sw/lw)";
        write_mem(x"00000100", x"ABCD1234", F3_WORD);  -- sw
        read_mem(x"00000100", F3_WORD);  -- lw
        wait_cycles(1);
        assert dout = x"ABCD1234" 
            report "Test 1 falló: Se esperaba ABCD1234, se obtuvo " & to_hstring(dout)
            severity error;
        
        -- TEST 2: Escritura de byte y lectura con extensión de signo (sb/lb)
        report "TEST 2: Escritura de byte y lectura con extensión de signo (sb/lb)";
        -- Escribir byte 0x80 (valor negativo) en dirección 0x104
        write_mem(x"00000104", x"00000080", F3_BYTE);  -- sb
        -- Leer con extensión de signo
        read_mem(x"00000104", F3_BYTE);  -- lb
        wait_cycles(1);
        assert dout = x"FFFFFF80" 
            report "Test 2 falló: Se esperaba FFFFFF80 (extensión de signo), se obtuvo " & to_hstring(dout)
            severity error;
        
        -- TEST 3: Lectura de byte con extensión de ceros (lbu)
        report "TEST 3: Lectura de byte con extensión de ceros (lbu)";
        -- Usar el mismo byte escrito en el test 2
        read_mem(x"00000104", F3_BYTE_U);  -- lbu
        wait_cycles(1);
        assert dout = x"00000080" 
            report "Test 3 falló: Se esperaba 00000080 (extensión de ceros), se obtuvo " & to_hstring(dout)
            severity error;
        
        -- TEST 4: Escritura y lectura de halfword con extensión de signo (sh/lh)
        report "TEST 4: Escritura y lectura de halfword con extensión de signo (sh/lh)";
        -- Escribir halfword 0x8001 (valor negativo) en dirección 0x108
        write_mem(x"00000108", x"00008001", F3_HALF);  -- sh
        -- Leer con extensión de signo
        read_mem(x"00000108", F3_HALF);  -- lh
        wait_cycles(1);
        assert dout = x"FFFF8001" 
            report "Test 4 falló: Se esperaba FFFF8001 (extensión de signo), se obtuvo " & to_hstring(dout)
            severity error;
        
        -- TEST 5: Lectura de halfword con extensión de ceros (lhu)
        report "TEST 5: Lectura de halfword con extensión de ceros (lhu)";
        -- Usar el mismo halfword escrito en el test 4
        read_mem(x"00000108", F3_HALF_U);  -- lhu
        wait_cycles(1);
        assert dout = x"00008001" 
            report "Test 5 falló: Se esperaba 00008001 (extensión de ceros), se obtuvo " & to_hstring(dout)
            severity error;
        
        -- TEST 6: Prueba de alineación de byte (sb y lb a diferentes offsets)
        report "TEST 6: Prueba de alineación de byte (sb y lb a diferentes offsets)";
        
        -- Escribir palabra con todos los bytes diferentes
        write_mem(x"00000110", x"11223344", F3_WORD);
        
        -- Modificar solo el primer byte (byte 0)
        write_mem(x"00000110", x"000000AA", F3_BYTE);
        -- Verificar el primer byte
        read_mem(x"00000110", F3_BYTE);
        wait_cycles(1);
        assert dout = x"FFFFFFAA" 
            report "Test 6.1 falló: Se esperaba FFFFFFAA para byte 0, se obtuvo " & to_hstring(dout)
            severity error;
            
        -- Modificar solo el segundo byte (byte 1)
        write_mem(x"00000111", x"000000BB", F3_BYTE);
        -- Verificar el segundo byte
        read_mem(x"00000111", F3_BYTE);
        wait_cycles(1);
        assert dout = x"FFFFFFBB" 
            report "Test 6.2 falló: Se esperaba FFFFFFBB para byte 1, se obtuvo " & to_hstring(dout)
            severity error;
            
        -- Modificar solo el tercer byte (byte 2)
        write_mem(x"00000112", x"000000CC", F3_BYTE);
        -- Verificar el tercer byte
        read_mem(x"00000112", F3_BYTE);
        wait_cycles(1);
        assert dout = x"FFFFFFCC" 
            report "Test 6.3 falló: Se esperaba FFFFFFCC para byte 2, se obtuvo " & to_hstring(dout)
            severity error;
            
        -- Modificar solo el cuarto byte (byte 3)
        write_mem(x"00000113", x"000000DD", F3_BYTE);
        -- Verificar el cuarto byte
        read_mem(x"00000113", F3_BYTE);
        wait_cycles(1);
        assert dout = x"FFFFFFDD" 
            report "Test 6.4 falló: Se esperaba FFFFFFDD para byte 3, se obtuvo " & to_hstring(dout)
            severity error;
        
        -- Verificar que la palabra completa se ha actualizado correctamente
        read_mem(x"00000110", F3_WORD);
        wait_cycles(1);
        assert dout = x"DDCCBBAA" 
            report "Test 6.5 falló: Se esperaba DDCCBBAA para la palabra completa, se obtuvo " & to_hstring(dout)
            severity error;
        
        -- TEST 7: Prueba de alineación de halfword (sh y lh a diferentes offsets)
        report "TEST 7: Prueba de alineación de halfword (sh y lh a diferentes offsets)";
        
        -- Escribir palabra con todos los halfwords diferentes
        write_mem(x"00000120", x"55667788", F3_WORD);
        
        -- Modificar solo el primer halfword (bytes 0-1)
        write_mem(x"00000120", x"0000AAAA", F3_HALF);
        -- Verificar el primer halfword
        read_mem(x"00000120", F3_HALF);
        wait_cycles(1);
        assert dout = x"FFFFAAAA" 
            report "Test 7.1 falló: Se esperaba FFFFAAAA para halfword 0, se obtuvo " & to_hstring(dout)
            severity error;
            
        -- Modificar solo el segundo halfword (bytes 2-3)
        write_mem(x"00000122", x"0000BBBB", F3_HALF);
        -- Verificar el segundo halfword
        read_mem(x"00000122", F3_HALF);
        wait_cycles(1);
        assert dout = x"FFFFBBBB" 
            report "Test 7.2 falló: Se esperaba FFFFBBBB para halfword 1, se obtuvo " & to_hstring(dout)
            severity error;
        
        -- Verificar que la palabra completa se ha actualizado correctamente
        read_mem(x"00000120", F3_WORD);
        wait_cycles(1);
        assert dout = x"BBBBAAAA" 
            report "Test 7.3 falló: Se esperaba BBBBAAAA para la palabra completa, se obtuvo " & to_hstring(dout)
            severity error;
        
        -- TEST 8: Prueba de comportamiento de caché (miss y hit)
        report "TEST 8: Prueba de comportamiento de caché (miss y hit)";
        
        -- Primera lectura (miss de caché)
        read_mem(x"00000200", F3_WORD);
        wait_cycles(5);  -- Esperar un poco más para asegurar que se procesó el miss
        
        -- Segunda lectura a la misma dirección (hit de caché)
        read_mem(x"00000200", F3_WORD);
        wait_cycles(1);
        
        -- El resultado debería ser el mismo en ambos casos, pero el segundo debería ser más rápido
        -- (esto no se puede verificar fácilmente en este testbench)
        
        -- Terminar la simulación
        report "Finalización de pruebas";
        sim_done <= true;
        wait;
    end process;

end Behavioral;