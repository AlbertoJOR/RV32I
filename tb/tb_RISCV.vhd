library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_RISCV is
end tb_RISCV;

architecture Behavioral of tb_RISCV is
    component RV32I is
        Port (
            clk         : in  STD_LOGIC;
            reset       : in  STD_LOGIC
        );
    end component; 
    signal clk : STD_LOGIC := '0';
    signal reset :STD_LOGIC := '0';

    constant clk_period : time := 10 ns;
begin
    DUT: RV32I
    port map(
        clk => clk,
        reset => reset
    );

    -- Clock process (clock toggles every 5ns)
    clk_process : process
    begin
        clk <= '1';
        wait for clk_period / 2;
        clk <= '0';
        wait for clk_period / 2;
    end process;
    
    -- Stimulus process
    stimulus_process: process
        begin
            -- Apply reset at the beginning
            reset <= '1';  -- Activate reset
            wait for 2* clk_period;  -- Wait for one clock cycle with reset active
            reset <= '0'; 
            wait;  -- Wait for one clock cycle with reset active
        end process;
end architecture;
