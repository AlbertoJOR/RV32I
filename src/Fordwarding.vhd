library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Fordwarding is
    port (
        Write_Reg_3     : in STD_LOGIC_VECTOR(4 downto 0);
        Write_Reg_4     : in STD_LOGIC_VECTOR(4 downto 0);
        RegWrite_3      : in STD_LOGIC;
        RegWrite_4      : in STD_LOGIC;
        Read_Reg1_2     : in STD_LOGIC_VECTOR(4 downto 0);
        Read_Reg2_2     : in STD_LOGIC_VECTOR(4 downto 0);
        MuxSel_A        : out STD_LOGIC_VECTOR(1 downto 0);
        MuxSel_B        : out STD_LOGIC_VECTOR(1 downto 0)
    );
end entity;

architecture Behavioral of Fordwarding is
    signal MuxA : STD_LOGIC_VECTOR(1 downto 0) :="00";
    signal MuxB : STD_LOGIC_VECTOR(1 downto 0) :="00";

begin
    MuxSel_A <= MuxA;
    MuxSel_B <= MuxB;
    process (all)
    begin 

        if(RegWrite_3 = '1' and RegWrite_4 = '0' ) then 
            if(Write_Reg_3 = Read_Reg1_2) then 
                MuxA <= "10";
            else
                MuxA <= "00";
            end if;
            if(Write_Reg_3 = Read_Reg2_2) then
                MuxB <= "10";
            else 
                MuxB <= "00";
            end if;
        end if;

        if (RegWrite_4 = '1'and RegWrite_3 = '0' ) then --
            if((Write_Reg_4 = Read_Reg1_2) and (Write_Reg_3 /= Read_Reg1_2)) then 
                MuxA <= "01";
            else
                MuxA <="00";
            end if;
            if((Write_Reg_4 = Read_Reg2_2)and (Write_Reg_3 /= Read_Reg2_2)) then
                MuxB <= "01";
            else
                MuxB <= "00";
            end if;
        end if;
        
        if (RegWrite_4 = '1'and RegWrite_3 = '1' ) then --
            if((Write_Reg_4 = Read_Reg1_2) and (Write_Reg_3 /= Read_Reg1_2)) then 
                MuxA <= "01";
            elsif ((Write_Reg_4 /= Read_Reg1_2) and (Write_Reg_3 = Read_Reg1_2)) then
                
                MuxA <="10";
            else 
                MuxA <="00";
            end if;
            if((Write_Reg_4 = Read_Reg2_2)and (Write_Reg_3 /= Read_Reg2_2)) then
                MuxB <= "01";
            elsif ((Write_Reg_4 /= Read_Reg2_2) and (Write_Reg_3 = Read_Reg2_2)) then
                
                MuxB <="10";
            else
                MuxB <= "00";
            end if;
        end if;
        if (RegWrite_4 = '0'and RegWrite_3 = '0' ) then --
            MuxA <="00";
            MuxB <= "00";
        end if;
    end process;
    

end architecture;