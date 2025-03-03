library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_InstMem is
end tb_InstMem;

architecture test of tb_InstMem is
    signal clk      : std_logic := '0';
    signal reset    : std_logic := '0';
    signal addr     : std_logic_vector(31 downto 0) := (others => '0');
    signal inst     : std_logic_vector(31 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin
    uut: entity work.InstMem
        port map (
            addr  => addr,
            inst  => inst
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

        
        addr <= X"00000000";  -- PC debe cambiar a 32
        wait for CLK_PERIOD;
        addr <= X"00000008";  -- PC debe cambiar a 32
        wait for CLK_PERIOD;
        addr <= X"00000004";  -- PC debe cambiar a 32
        wait for CLK_PERIOD;
        addr <= X"00000000";  -- PC debe cambiar a 32
        wait for CLK_PERIOD;
        addr <= X"0000000C";  -- PC debe cambiar a 32
        wait for CLK_PERIOD;

        wait; -- Termina el proceso
    end process;
end test;
