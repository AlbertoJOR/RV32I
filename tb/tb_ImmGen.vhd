library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_ImmGen is
end tb_ImmGen;

architecture testbench of tb_ImmGen is
    -- Señales del testbench
    signal instr   : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    signal imm_out : STD_LOGIC_VECTOR (31 downto 0);
    
    -- Componente a probar (DUT - Device Under Test)
    component ImmGen
        Port (
            instr  : in  STD_LOGIC_VECTOR (31 downto 0);
            imm_out: out STD_LOGIC_VECTOR (31 downto 0)
        );
    end component;

begin
    -- Instancia del DUT
    UUT: ImmGen port map (
        instr  => instr,
        imm_out => imm_out
    );

    -- Proceso de simulación
    process
    begin
      
    end process;

end testbench;
