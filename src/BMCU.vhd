-- Branch Misprediction Correction Unit (BMCU)
-- Unidad Correctora de Saltos
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BMCU is
    port (
        Zero_and_Branch:  in STD_LOGIC;
        Branch_pred: in STD_LOGIC;
        enable : in STD_LOGIC;
        PC_4  : in STD_LOGIC_VECTOR(31 downto 0);
        PC_Imm : in STD_LOGIC_VECTOR(31 downto 0);
        PC_corrected: out STD_LOGIC_VECTOR(31 downto 0);
        Flush       : out STD_LOGIC
        
    );
end entity;

architecture Behavioral of BMCU is
    signal anBR: std_logic_vector(1 downto 0);


begin
    anBR <= Zero_and_Branch & Branch_pred;
    process (Zero_and_Branch, Branch_pred, enable, PC_4, PC_Imm)
    begin 
    if (enable = '1') then
        case anBR is 
            when "00" =>
                PC_corrected <= PC_4;
                Flush <= '0';
            when "01" =>
                PC_corrected <= PC_4;
                Flush <= '1';
            when "10" =>
                PC_corrected <= PC_Imm;
                Flush <= '1';
            when "11" =>
                PC_corrected <= PC_4;
                Flush <= '0';
            when others =>
                PC_corrected <= (others => '0');
                Flush <= '0';
        end case;
    else 
        Flush <='0';
        PC_corrected <= (others => '0');
    end if;
                
    end process;
end architecture;