library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_RegFile is
end tb_RegFile;

architecture test of tb_RegFile is
    signal clk          : STD_LOGIC := '0';
    signal reset        : STD_LOGIC := '0';
    signal Read_Reg1    : STD_LOGIC_VECTOR (4 downto 0) := "00000";
    signal Read_Reg2    : STD_LOGIC_VECTOR (4 downto 0) := "00000";
    signal Write_Reg    : STD_LOGIC_VECTOR (4 downto 0) := "00000";
    signal Write_Data   : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    signal Write_Enable : STD_LOGIC := '0';
    signal Read_Data1   : STD_LOGIC_VECTOR (31 downto 0);
    signal Read_Data2   : STD_LOGIC_VECTOR (31 downto 0);

    constant clk_period : time := 10 ns;

begin
    -- Instancia del DUT (Dispositivo Bajo Prueba)
    uut: entity work.RegFile
        port map (
            clk          => clk,
            reset        => reset,
            Read_Reg1    => Read_Reg1,
            Read_Reg2    => Read_Reg2,
            Write_Reg    => Write_Reg,
            Write_Data   => Write_Data,
            Write_Enable => Write_Enable,
            Read_Data1   => Read_Data1,
            Read_Data2   => Read_Data2
        );

    -- Generación del reloj
    process
    begin
        while now < 200 ns loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    -- Proceso de prueba
    process
    begin
        -- RESET
        reset <= '1';
        wait for clk_period;
        reset <= '0';
        wait for clk_period;

        -- ESCRITURA EN R1 Y R2 (Debe ocurrir en flanco de subida)
        Write_Enable <= '1';

        Write_Reg  <= "00001"; -- R1
        Write_Data <= X"000000AA";
        wait for clk_period;

        Write_Reg  <= "00010"; -- R2
        Write_Data <= X"000000BB";
        wait for clk_period;

        -- INTENTAR ESCRIBIR EN R0 (Debe ignorarse)
        Write_Reg  <= "00000";
        Write_Data <= X"FFFFFFFF";
        wait for clk_period;

        -- DESHABILITAR ESCRITURA
        Write_Enable <= '0';

        -- LEER R1 Y R2 EN FLANCO BAJO
        wait for clk_period / 2;
        Read_Reg1 <= "00001"; -- R1
        Read_Reg2 <= "00010"; -- R2
        wait for clk_period / 2;

        Write_Enable <= '1';
        Write_Reg  <= "00001";
        Write_Data <= X"12FF2F0F";

        -- PRUEBA DE hAZARD

        -- LEER R1 Y R2 EN FLANCO BAJO
        wait for clk_period / 2;
        Read_Reg1 <= "00001"; -- R1
        Read_Reg2 <= "00010"; -- R2
        wait for  clk_period / 2;

        Write_Reg  <= "00001";
        Write_Data <= X"12FF2F0F";
        wait for  clk_period/2;

        Write_Reg  <= "00010";
        Write_Data <= X"00000012";
        wait for  clk_period;

        Write_Reg  <= "00010";
        Write_Data <= X"00000051";
        wait for  clk_period;

        Write_Reg  <= "00010";
        Write_Data <= X"000000a2";
        wait for  clk_period;

        Write_Enable <= '0';



        -- LEER R0 (Debe devolver 0)
        wait for clk_period / 2;
        Read_Reg1 <= "00000";
        Read_Reg2 <= "00000";
        wait for clk_period / 2;

        -- FIN DE LA SIMULACION
        wait;
    end process;

end test;
