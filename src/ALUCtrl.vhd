library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALUCtrl is
    port(
        ALU_inst : in STD_LOGIC_VECTOR(3 downto 0);
        ALUOp    : in STD_LOGIC_VECTOR(1 downto 0);
        ALU_CTRL : out STD_LOGIC_VECTOR(4 downto 0)
    );
end entity;

architecture Behavioral of ALUCtrl is 
begin
    process(ALU_inst, ALUOp)
    begin
        case ALUOp is
            when "00" => ALU_CTRL <= "0" & ALU_inst;  -- Operaciones Artih R I.
            when "01" => ALU_CTRL <= "00000"; -- Para las instrucciones de tipo Load y Store
            when "10" => ALU_CTRL <= "1" & ALU_inst;  -- Saltos Branch 
            when others => ALU_CTRL <= (others => '0'); 
        end case;
    end process;
end architecture;
