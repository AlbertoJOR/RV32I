library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_PC is
end tb_PC;

architecture test of tb_PC is
    signal clk      : std_logic := '0';
    signal reset    : std_logic := '0';
    signal branch   : std_logic := '0';
    signal ImmExt   : std_logic_vector(31 downto 0) := (others => '0');
    signal PC_out   : std_logic_vector(31 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin
    uut: entity work.PC
        port map (
            clk     => clk,
            stall   => '0',
            reset   => reset,
            branch  => branch,
            ImmExt  => ImmExt,
            PC_out  => PC_out
        );

    -- Generador de reloj
    process
    constant SIM_TIME : time := 200 ns;
    begin
        while now < SIM_TIME loop 
            clk <= '1';
            wait for CLK_PERIOD / 2;
            clk <= '0';
            wait for CLK_PERIOD / 2;
        end loop;
        wait; 
    end process;

    -- Estímulos para probar el diseño
    process
    begin
        -- 1. Reset activo (PC debe inicializarse en 0)
        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';
        wait for CLK_PERIOD;
        
        -- 2. Normal operation (PC avanza en +4)
        wait for 2*CLK_PERIOD;

        -- 3. Activa branch (PC cambia a ImmExt)
        branch <= '1';
        ImmExt <= X"00000020";  -- PC debe cambiar a 32
        wait for CLK_PERIOD;
        
        -- 4. Desactiva branch (PC debe volver a avanzar de 4 en 4)
        branch <= '0';
        wait for 2* CLK_PERIOD;

        -- 5. Vuelve a activar reset
        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';
        wait for CLK_PERIOD;

        wait; -- Termina el proceso
    end process;
end test;
