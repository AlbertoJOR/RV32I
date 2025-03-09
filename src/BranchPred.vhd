library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY BranchPred IS
   PORT(
      clk         : in  STD_LOGIC;
      reset       : in  STD_LOGIC;
      taken       : in  STD_LOGIC;
      enable      : in  STD_LOGIC;
      Branch_ins  : in  STD_LOGIC;
      Branch_pred : out STD_LOGIC
   );
END BranchPred;

ARCHITECTURE Behavioral OF BranchPred IS
   SIGNAL state : STD_LOGIC_VECTOR(1 downto 0);  -- Registro de estado (00, 01, 10, 11)
BEGIN
    -- **Proceso de actualización del estado**
    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            state <= "10";  -- Inicializa en el estado "10" 
        ELSIF rising_edge(clk) THEN
            IF enable = '1' THEN
                CASE state IS
                    WHEN "00" =>  -- Estado s0
                        IF taken = '1' THEN
                            state <= "01";
                        END IF;
                    WHEN "01" =>  -- Estado s1
                        IF taken = '1' THEN
                            state <= "10";
                        ELSE
                            state <= "00";
                        END IF;
                    WHEN "10" =>  -- Estado s2
                        IF taken = '1' THEN
                            state <= "11";
                        ELSE
                            state <= "01";
                        END IF;
                    WHEN "11" =>  -- Estado s3
                        IF taken = '0' THEN
                            state <= "10";
                        END IF;
                    WHEN OTHERS =>
                        state <= "10";  -- Estado por defecto
                END CASE;
            END IF;
        END IF;
    END PROCESS;

    -- **Proceso de predicción de branch**
    PROCESS (Branch_ins, clk)
    BEGIN
        IF Branch_ins = '1' THEN
            CASE state IS
                WHEN "00" | "01" =>  -- Estados s0 y s1
                    Branch_pred <= '0';  -- No tomar el branch
                WHEN "10" | "11" =>  -- Estados s2 y s3
                    Branch_pred <= '1';  -- Tomar el branch
                WHEN OTHERS =>
                    Branch_pred <= '0';
            END CASE;
        ELSE
            Branch_pred <= '0';
        END IF;
    END PROCESS;

END ARCHITECTURE Behavioral;
