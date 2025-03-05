library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port (
        A, B       : in  STD_LOGIC_VECTOR(31 downto 0);  -- Operandos
        ALU_Ctrl   : in  STD_LOGIC_VECTOR(4 downto 0);   -- Código de operación (ALU)
        Result     : out STD_LOGIC_VECTOR(31 downto 0); -- Salida de la ALU
        Zero       : out STD_LOGIC                      -- Señal para BEQ/BNE (1 si resultado es 0)
    );
end ALU;

architecture Behavioral of ALU is
    signal alu_result : STD_LOGIC_VECTOR(31 downto 0);
    signal funct3 : STD_LOGIC_VECTOR(2 downto 0);
    signal funct7b5: STD_LOGIC;
    signal isBranch: STD_LOGIC;
begin
    funct3 <= ALU_Ctrl(2 downto 0);
    funct7b5 <= ALU_Ctrl(3); -- valor del bit numero 5 de funct7
    isBranch <= ALU_Ctrl(4);
    
    process(A, B, funct3, funct7b5, isBranch)
        variable B_mux : STD_LOGIC_VECTOR(31 downto 0);
    begin
        -- Si funct7b5 = '1' y la operación es ADD/SUB, cambia a resta (SUB)
        if funct3 = "000" and funct7b5 = '1' then
            B_mux := std_logic_vector(signed(B)); -- Tomar complemento a dos para resta (equivalente a -B)
        else
            B_mux := B;
        end if;

        case funct3 is
            -- ADD / SUB
            when "000" =>
                alu_result <= std_logic_vector(signed(A) + signed(B_mux)); -- Suma o Resta (si funct7b5 = '1')

            -- SLL (Shift Left Logical)
            when "001" =>
                alu_result <= std_logic_vector(shift_left(unsigned(A), to_integer(unsigned(B(4 downto 0)))));

            -- SLT (Set Less Than - signed)
            when "010" =>
                if signed(A) < signed(B) then
                    alu_result <= (others => '0'); alu_result(0) <= '1';
                else
                    alu_result <= (others => '0');
                end if;

            -- SLTU (Set Less Than - unsigned)
            when "011" =>
                if unsigned(A) < unsigned(B) then
                    alu_result <= (others => '0'); alu_result(0) <= '1';
                else
                    alu_result <= (others => '0');
                end if;

            -- XOR
            when "100" =>
                alu_result <= A xor B;

            -- SRL / SRA (Shift Right Logical / Arithmetic)
            when "101" =>
                if funct7b5 = '0' then  -- SRL
                    alu_result <= std_logic_vector(shift_right(unsigned(A), to_integer(unsigned(B(4 downto 0)))));
                else  -- SRA (sign-extended)
                    alu_result <= std_logic_vector(shift_right(signed(A), to_integer(unsigned(B(4 downto 0)))));
                end if;

            -- OR
            when "110" =>
                alu_result <= A or B;

            -- AND
            when "111" =>
                alu_result <= A and B;

            when others =>
                alu_result <= (others => '0');
        end case;

        -- Si es una instrucción de comparación (BEQ/BNE), establecer Zero
        if isBranch = '1' then
            if funct3 = "000" then -- BEQ
                Zero <= '1' when A = B else '0';
            elsif funct3 = "001" then -- BNE
                Zero <= '1' when A /= B else '0';
            elsif funct3 = "100" then -- BLT
                Zero <= '1' when signed(A) < signed(B) else '0';
            elsif funct3 = "101" then -- BGE
                Zero <= '1' when signed(A) >= signed(B) else '0';
            elsif funct3 = "110" then -- BLTU
                Zero <= '1' when unsigned(A) < unsigned(B) else '0';
            elsif funct3 = "111" then -- BGEU
                Zero <= '1' when unsigned(A) >= unsigned(B) else '0';
            else
                Zero <= '0';
            end if;
        else
            Zero <= '0'; -- No es comparación, Zero en bajo
        end if;
        
        -- Asignar resultado
        Result <= alu_result;
    end process;
end Behavioral;
