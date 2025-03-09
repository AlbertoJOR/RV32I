library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Hazard is
    port (
        
        Write_Reg_2        : in STD_LOGIC_VECTOR(4 downto 0);
        Read_Reg1_1     : in STD_LOGIC_VECTOR(4 downto 0);
        Read_Reg2_1     : in STD_LOGIC_VECTOR(4 downto 0);
        MemRead_2     : in STD_LOGIC;
        nop    : out STD_LOGIC
   
    );
end entity;
architecture Behavioral of Hazard is

begin
Hazardpro : process (all)
begin 
    if (MemRead_2 = '1' and ((Read_Reg1_1 = Write_Reg_2)or (Read_Reg2_1 = Write_Reg_2))) then
        nop <= '1';
    else 
        nop <= '0';
    end if;

end process;
    

end architecture;