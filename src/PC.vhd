library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


entity PC is
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        Branch_pred      : in  STD_LOGIC;
        Flush      : in  STD_LOGIC;
        stall       : in  STD_LOGIC;
        ImmExt      : in  STD_LOGIC_VECTOR (31 downto 0);
        PC_corrected      : in  STD_LOGIC_VECTOR (31 downto 0);
        PC_out      : out STD_LOGIC_VECTOR (31 downto 0);
        PC_4_out      : out STD_LOGIC_VECTOR (31 downto 0)
    );
end PC;

architecture Behavioral of PC is
    signal PC_reg      : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- Registro del valor actual del PC
    signal PC_Next     : STD_LOGIC_VECTOR (31 downto 0);                    -- Valor siguiente del PC 
    signal PC_Plus4    : STD_LOGIC_VECTOR (31 downto 0);                    -- PC + 4, dirección de la siguiente instrucción en ejecución
    signal sel : std_logic_vector(1 downto 0);
begin
    -- Lógica combinacional para PC_Plus4
    PC_Plus4  <= PC_reg + 4;
    sel <= Branch_pred & Flush; -- Concatenación de señales en un vector de 2 bits

    process(sel, ImmExt, PC_corrected, PC_Plus4)
    begin
        case sel is
            when "10" =>  
                PC_Next <= ImmExt;
            when "11" =>  
                -- Prioridad a Flush
                PC_Next <= PC_corrected;
            when "01" =>  
                PC_Next <= PC_corrected;
            when others =>  
                PC_Next <= PC_Plus4;
        end case;
    end process;


    -- Proceso para actualizar el registro del PC
    process(clk, reset)
    begin
        if (rising_edge(clk) and stall = '0')then
            if reset = '1' then
                PC_reg <= (others => '0');         -- Reset síncrono: inicializa el PC a 0
            else
                PC_reg <= PC_Next;             -- Actualiza el PC con PC_Next
            end if;
        end if;
    end process;
    PC_out <= PC_reg;                           -- Asignar el valor del registro PC a la salida
    PC_4_out <= PC_Plus4;
end Behavioral;