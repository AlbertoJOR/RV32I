library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_RAM is
end tb_RAM;

architecture Behavioral of tb_RAM is

    -- Component Declaration of the RAM
    component RAM is
        Port (
            clk      : in  STD_LOGIC;
            reset    : in  STD_LOGIC;  -- Reset síncrono
            we       : in  STD_LOGIC;  -- Write Enable
            addr     : in  STD_LOGIC_VECTOR(31 downto 0); -- Byte address
            din      : in  STD_LOGIC_VECTOR(31 downto 0); -- Data input (for store)
            funct3   : in  STD_LOGIC_VECTOR(2 downto 0);  -- Selects lw, lh, lb, sw, sh, sb
            dout     : out STD_LOGIC_VECTOR(31 downto 0)  -- Data output (for load)
        );
    end component;

    -- Signals for RAM inputs and outputs
    signal clk      : STD_LOGIC := '0';
    signal reset    : STD_LOGIC := '0';  -- Signal de reset síncrono
    signal we       : STD_LOGIC := '0';
    signal addr     : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal din      : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal funct3   : STD_LOGIC_VECTOR(2 downto 0) := "000";  -- Set to "000" for LB by default
    signal dout     : STD_LOGIC_VECTOR(31 downto 0);

    -- Clock generation
    constant clk_period : time := 10 ns;

begin
    -- Instantiate the RAM component
    uut: RAM
        Port map (
            clk      => clk,
            reset    => reset,
            we       => we,
            addr     => addr,
            din      => din,
            funct3   => funct3,
            dout     => dout
        );

    -- Clock process (clock toggles every 5ns)
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Stimulus process
    stimulus_process: process
    begin
        -- Apply reset at the beginning
        reset <= '1';  -- Activate reset
        wait for clk_period;  -- Wait for one clock cycle with reset active
        reset <= '0';  -- Deactivate reset

        -- Test: Store Word (SW) at address 0x00, data 0x12345678
        we <= '1';
        addr <= x"00000000";  -- Address 0x00
        din <= x"12345678";   -- Data to write
        funct3 <= "010";      -- funct3 for sw
        wait for clk_period;  -- Wait for one clock cycle

        -- Test: Store Byte (SB) at address 0x04, data 0xAA
        addr <= x"00000004";  -- Address 0x04
        din <= x"000000AA";   -- Data to write (byte)
        funct3 <= "000";      -- funct3 for sb
        wait for clk_period;

        -- Test: Load Word (LW) from address 0x00
        we <= '0';            -- Disable write
        addr <= x"00000000";  -- Address 0x00
        funct3 <= "010";      -- funct3 for lw
        wait for clk_period;

        -- Test: Load Halfword (LH) from address 0x00
        addr <= x"00000000";  -- Address 0x00
        funct3 <= "001";      -- funct3 for lh
        wait for clk_period;

        -- Test: Load Byte (LB) from address 0x04
        addr <= x"00000004";  -- Address 0x04
        funct3 <= "000";      -- funct3 for lb
        wait for clk_period;

        -- Test: Store Halfword (SH) at address 0x08, data 0x1234
        we <= '1';            -- Enable write
        addr <= x"00000008";  -- Address 0x08
        din <= x"00001234";   -- Data to write (halfword)
        funct3 <= "001";      -- funct3 for sh
        wait for clk_period;

        -- Test end
        wait;
    end process;

end Behavioral;
