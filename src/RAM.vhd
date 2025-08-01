
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RAM is
    Port (
        clk      : in  STD_LOGIC;
        reset    : in  STD_LOGIC;  
        we       : in  STD_LOGIC;  
        re       : in  STD_LOGIC;  
        addr     : in  STD_LOGIC_VECTOR(31 downto 0); -- Byte address
        din      : in  STD_LOGIC_VECTOR(31 downto 0); -- Data input (for store)
        funct3   : in  STD_LOGIC_VECTOR(2 downto 0);  -- Selects lw, lh, lb, sw, sh, sb
        dout     : out STD_LOGIC_VECTOR(31 downto 0)  -- Data output (for load)
    );
end RAM;

architecture Behavioral of RAM is
    type RAM_TYPE is array (0 to 1023) of STD_LOGIC_VECTOR(7 downto 0); -- 4 KB de RAM (1024 bytes)
    signal memory : RAM_TYPE := (others => (others => '0')); -- Inicializa en 0
    signal aligned_addr : INTEGER range 0 to 1023; -- Dirección truncada a 10 bits para el tamaño de la memoria
    signal dout_aux     :  STD_LOGIC_VECTOR(31 downto 0) := (others =>'0'); 

begin
    -- Convertir la dirección de bytes en un índice para la memoria
    aligned_addr <= to_integer(unsigned(addr(9 downto 0)));  -- Utilizamos solo los bits bajos para el índice
    
    -- Escritura de la memoria
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                -- Resetear toda la memoria
                memory <= (others => (others => '0'));  
            elsif we = '1' then  -- Escritura
                case funct3 is
                    when "010" => -- sw (Store Word)
                        memory(aligned_addr)     <= din(7 downto 0);
                        memory(aligned_addr+1)   <= din(15 downto 8);
                        memory(aligned_addr+2)   <= din(23 downto 16);
                        memory(aligned_addr+3)   <= din(31 downto 24);
                    when "001" => -- sh (Store Halfword)
                        memory(aligned_addr)     <= din(7 downto 0);
                        memory(aligned_addr+1)   <= din(15 downto 8);
                    when "000" => -- sb (Store Byte)
                        memory(aligned_addr)     <= din(7 downto 0);
                    when others => 
                        null; -- No hacer nada para otras instrucciones
                end case;
            end if;
        end if;
    end process;

    -- Lectura de la memoria con signo extendido según el tipo de instrucción
    process(aligned_addr, funct3, re)
    begin
        case funct3 is
            when "010" => -- lw (Load Word)
                dout_aux <= memory(aligned_addr+3) & memory(aligned_addr+2) & memory(aligned_addr+1) & memory(aligned_addr);
            when "001" | "101" => -- lh / lhu (Load Halfword)
                -- Extensión de signo de 16 bits
                dout_aux(15 downto 0) <= memory(aligned_addr+1) & memory(aligned_addr);  -- Lee 2 bytes
                
                if funct3 = "001" then
                    dout_aux(31 downto 16) <= (others => dout_aux(15)); -- Extiende el bit más significativo a 16 bits
                else
                    dout_aux(31 downto 16) <= (others => '0'); -- Extiende el bit más significativo a 16 bits
                end if;

            when "000" | "100" => -- lb / lbu (Load Byte)
                -- Extensión de signo de 8 bits
                dout_aux(7 downto 0) <= memory(aligned_addr);   -- Lee 1 byte
                if funct3 = "000" then
                    dout_aux(31 downto 8) <= (others => dout_aux(7));   -- Extiende el bit más significativo a 24 bits
                else
                    dout_aux(31 downto 8) <= (others => '0');   -- Extiende el bit más significativo a 24 bits
                end if;
            when others => 
                dout_aux <= (others => '0'); -- Para cualquier otro caso
        end case;
    end process;
    
dout <= dout_aux when re ='1' else (others =>'0');

end Behavioral;
