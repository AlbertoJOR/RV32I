library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ControlUnit is
    Port (
        OpCode     : in  STD_LOGIC_VECTOR(6 downto 0); -- Opcode de la instrucción
        reset        : in STD_LOGIC;
        nop        : in STD_LOGIC;
        Jump     : out STD_LOGIC;
        ALUSrc     : out STD_LOGIC;
        MemtoReg   : out STD_LOGIC;
        RegWrite   : out STD_LOGIC;
        MemRead    : out STD_LOGIC;
        MemWrite   : out STD_LOGIC;
        Branch     : out STD_LOGIC;
        ALUOp      : out STD_LOGIC_VECTOR(1 downto 0)
    );
end ControlUnit;

architecture Behavioral of ControlUnit is
begin
    process(OpCode, reset, nop)
    begin
        if (reset = '1' or nop = '1') then 
                Jump   <= '0';
                ALUSrc   <= '0';
                MemtoReg <= '0';
                RegWrite <= '0';
                MemRead  <= '0';
                MemWrite <= '0';
                Branch   <= '0';
                ALUOp    <= "00";
    else
        case OpCode is
            -- lb, lh, lw, lbu, lhu, 
            -- opcode(3)
            when "0000011" => 
                Jump     <= '0';
                ALUSrc   <= '1';
                MemtoReg <= '1';
                RegWrite <= '1';
                MemRead  <= '1';
                MemWrite <= '0';
                Branch   <= '0';
                ALUOp    <= "01";

            -- addi, slli, slti, altiu, xori, srli, srai, ori, andi, 
            -- opcode(19)
            when "0010011" => 
                Jump     <= '0';
                ALUSrc   <= '1';
                MemtoReg <= '0';
                RegWrite <= '1';
                MemRead  <= '0';
                MemWrite <= '0';
                Branch   <= '0';
                ALUOp    <= "00";

            -- auipc, 
            -- opcode(23)
            when "0010111" => 
                Jump     <= '0';
                ALUSrc   <= '0';
                MemtoReg <= '0';
                RegWrite <= '0';
                MemRead  <= '0';
                MemWrite <= '0';
                Branch   <= '0';
                ALUOp    <= "00";

            -- S Inst
            -- sb, sh, sw 
            -- opcode(35)
            when "0100011" => 
                Jump     <= '0';
                ALUSrc   <= '1';
                MemtoReg <= '0';
                RegWrite <= '0';
                MemRead  <= '0';
                MemWrite <= '1';
                Branch   <= '0';
                ALUOp    <= "01";

            -- R Inst
            -- opcode(51)
            when "0110011" => 
                Jump     <= '0';
                ALUSrc   <= '0';
                MemtoReg <= '0';
                RegWrite <= '1';
                MemRead  <= '0';
                MemWrite <= '0';
                Branch   <= '0';
                ALUOp    <= "00";

            -- lui
            -- opcode(55)
            when "0110111" => 
                Jump     <= '0';
                ALUSrc   <= '0';
                MemtoReg <= '0';
                RegWrite <= '0';
                MemRead  <= '0';
                MemWrite <= '0';
                Branch   <= '0';
                ALUOp    <= "00";

            -- B inst
            -- beq, bne, blt, bge, bltu, bgeu
            -- opcode(99)
            when "1100011" => 
                Jump     <= '0';
                ALUSrc   <= '0';
                MemtoReg <= '0';
                RegWrite <= '0';
                MemRead  <= '0';
                MemWrite <= '0';
                Branch   <= '1';
                ALUOp    <= "10";

            -- jalr 
            -- opcode(103)
            when "1100111" => 
                Jump     <= '1';
                ALUSrc   <= '0';
                MemtoReg <= '0';
                RegWrite <= '1';
                MemRead  <= '0';
                MemWrite <= '0';
                Branch   <= '0';
                ALUOp    <= "00";

            -- jal 
            -- opcode(101)
            when "1101111" => 
                Jump     <= '1';
                ALUSrc   <= '0';
                MemtoReg <= '0';
                RegWrite <= '1';
                MemRead  <= '0';
                MemWrite <= '0';
                Branch   <= '0';
                ALUOp    <= "00";

            
            when others =>
                Jump   <= '0';
                ALUSrc   <= '0';
                MemtoReg <= '0';
                RegWrite <= '0';
                MemRead  <= '0';
                MemWrite <= '0';
                Branch   <= '0';
                ALUOp    <= "00";
        end case;
    end if;
    end process;
end Behavioral;
