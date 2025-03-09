library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PipeFetch is
    Port (
        clk   : in  STD_LOGIC;
        reset : in  STD_LOGIC;
        stall : in  STD_LOGIC;
        -- Entrada pipe
        inst_i  : in  STD_LOGIC_VECTOR(31 downto 0);
        PC_i    : in  STD_LOGIC_VECTOR(31 downto 0);
        PC_4_i    : in  STD_LOGIC_VECTOR(31 downto 0);
        
        -- Salida pipe
        inst_o  : out  STD_LOGIC_VECTOR(31 downto 0);
        PC_o    : out  STD_LOGIC_VECTOR(31 downto 0);
        PC_4_o    : out  STD_LOGIC_VECTOR(31 downto 0)
    );
end PipeFetch;

architecture Behavioral of PipeFetch is
    signal PC_reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0'); 
    signal PC_4_reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0'); 
    signal inst_reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if (rising_edge(clk) and stall = '0') then
            if reset = '1' then  -- Reset sincrónico
                PC_reg <= (others => '0');
                PC_4_reg <= (others => '0');
                inst_reg <= (others => '0');
            else  
                PC_reg <= PC_i;
                inst_reg <= inst_i;
            end if;
        end if;
    end process;

    PC_o <= PC_reg;
    PC_4_o <= PC_4_reg;
    inst_o <= inst_reg;

end Behavioral;
