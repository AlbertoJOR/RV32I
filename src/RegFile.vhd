library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegFile is
    Port (
        clk             : in  STD_LOGIC;
        reset           : in  STD_LOGIC;
        Read_Reg1       : in  STD_LOGIC_VECTOR (4 downto 0);
        Read_Reg2       : in  STD_LOGIC_VECTOR (4 downto 0);
        Write_Reg       : in  STD_LOGIC_VECTOR (4 downto 0);
        Write_Data      : in  STD_LOGIC_VECTOR (31 downto 0);
        Write_Enable    : in  STD_LOGIC;
        Read_Data1      : out STD_LOGIC_VECTOR (31 downto 0);
        Read_Data2      : out STD_LOGIC_VECTOR (31 downto 0)
    );
end RegFile;

architecture Behavioral of RegFile is
    type Reg_Array is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    signal RF : Reg_Array := (others => (others => '0'));
begin
    -- LECTURA EN FLANCO BAJO DEL RELOJ
    process(clk, reset, Read_Reg1, Read_Reg2, Write_Reg, Write_Data, Write_Enable)
    begin
        if (clk= '0') then
            if Read_Reg1 = "00000" then
                Read_Data1 <= (others => '0'); -- Registro 0 siempre es 0
            else
                Read_Data1 <= RF(to_integer(unsigned(Read_Reg1)));
            end if;

            if Read_Reg2 = "00000" then
                Read_Data2 <= (others => '0'); -- Registro 0 siempre es 0
            else
                Read_Data2 <= RF(to_integer(unsigned(Read_Reg2)));
            end if;
        end if;
    end process;

    -- ESCRITURA EN FLANCO ALTO DEL RELOJ
    process(clk, reset, Read_Reg1, Read_Reg2, Write_Reg, Write_Data, Write_Enable)
    begin
        if (clk = '1') then
            if reset = '1' then
                RF <= (others => (others => '0')); -- Reset síncrono
            elsif (Write_Enable = '1' and Write_Reg /= "00000") then
                RF(to_integer(unsigned(Write_Reg))) <= Write_Data;
            end if;
        end if;
    end process;
end Behavioral;
