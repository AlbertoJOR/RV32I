library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_cache_miss_2 is
end tb_cache_miss_2;

architecture Behavioral of tb_cache_miss_2 is
    -- Constants for RISC-V funct3
    constant F3_WORD      : STD_LOGIC_VECTOR(2 downto 0) := "010"; -- lw/sw
    constant F3_HALF      : STD_LOGIC_VECTOR(2 downto 0) := "001"; -- lh/sh
    constant F3_BYTE      : STD_LOGIC_VECTOR(2 downto 0) := "000"; -- lb/sb
    constant F3_HALF_U      : STD_LOGIC_VECTOR(2 downto 0) := "101"; -- lhu
    constant F3_BYTE_U      : STD_LOGIC_VECTOR(2 downto 0) := "100"; -- lbu

    -- Testbench signals
    signal clk      : STD_LOGIC := '0';
    signal reset    : STD_LOGIC := '0';
    signal addr     : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal din      : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal we       : STD_LOGIC := '0';
    signal re       : STD_LOGIC := '0';
    signal funct3   : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal dout     : STD_LOGIC_VECTOR(31 downto 0);
    signal miss     : STD_LOGIC;
    
    -- Clock period
    constant CLK_PERIOD : time := 10 ns;
    
    -- Simulation control signal
    signal sim_done : boolean := false;
    
    -- Cache component declaration
    component Cache is
        generic (
            CACHE_SIZE : integer := 64  -- number of cache lines (power of 2)
        );
        Port (
            clk      : in  STD_LOGIC;
            reset    : in  STD_LOGIC;
            addr     : in  STD_LOGIC_VECTOR(31 downto 0);
            din      : in  STD_LOGIC_VECTOR(31 downto 0);
            we       : in  STD_LOGIC;
            re       : in  STD_LOGIC;
            funct3   : in  STD_LOGIC_VECTOR(2 downto 0);
            dout     : out STD_LOGIC_VECTOR(31 downto 0);
            miss     : out  STD_LOGIC
        );
    end component;

begin
    -- Cache instantiation with small size (16 lines)
    UUT: Cache
        generic map (
            CACHE_SIZE => 4  -- Small cache size
        )
        port map (
            clk     => clk,
            reset   => reset,
            addr    => addr,
            din     => din,
            we      => we,
            re      => re,
            funct3  => funct3,
            dout    => dout,
            miss    => miss
        );
    
    -- Clock generation process
    clock_process: process
    begin
        while not sim_done loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;
    
    -- Stimulus process
    stimulus: process
        -- Procedure to wait n cycles
        procedure wait_cycles(n: integer) is
        begin
            for i in 1 to n loop
                wait until rising_edge(clk);
            end loop;
        end procedure;
        
        -- Procedure to write to memory
        procedure write_mem(
            address : in STD_LOGIC_VECTOR(31 downto 0);
            data    : in STD_LOGIC_VECTOR(31 downto 0);
            f3      : in STD_LOGIC_VECTOR(2 downto 0)
        ) is
        begin
            -- wait until rising_edge(clk);
            addr   <= address;
            din    <= data;
            funct3 <= f3;             -- uso del nuevo parámetro
            we     <= '1';
            re     <= '0';
            wait_cycles(1);
            -- we     <= '0';
            -- wait_cycles(1);
        end procedure;
        
        -- Procedure to read from memory
        procedure read_mem(
            address: in STD_LOGIC_VECTOR(31 downto 0);
            f3      : in STD_LOGIC_VECTOR(2 downto 0)
            ) is
        begin
            -- wait until rising_edge(clk);
            addr <= address;
            funct3 <= f3;
            re <= '1';
            we <= '0';
            wait_cycles(1);
            -- re <= '0';
            -- wait_cycles(1);
        end procedure;

        procedure down_sig is
        begin
            addr   <= (others => '0');
            din    <= (others => '0');
            funct3 <= (others => '0');             -- uso del nuevo parámetro
            we     <= '0';
            re     <= '0';
            wait_cycles(1);
        end procedure;
        
    begin
        -- Reset initial
        reset <= '1';
        wait_cycles(2);
        reset <= '0';
        wait until rising_edge(clk);
        
        report "TEST 1: Sequential Access (Fill Cache)";
        -- Write to sequential addresses to fill cache
        write_mem(x"00000100", x"18191A1B", F3_WORD);
        write_mem(x"00000104", x"28292A2B", F3_WORD);
        write_mem(x"00000108", x"38393A3B", F3_WORD);
        write_mem(x"0000010C", x"48494A4B", F3_WORD);
        
        -- Read back - these should be cache hits
        read_mem(x"00000100", F3_WORD);
        read_mem(x"00000104", F3_WORD);
        read_mem(x"00000108", F3_WORD);
        read_mem(x"0000010C", F3_WORD);

        down_sig;

        write_mem(x"00000110", x"58595A5B", F3_WORD);
        write_mem(x"00000114", x"68696A6B", F3_WORD);
        write_mem(x"00000118", x"78797A7B", F3_WORD);
        write_mem(x"0000011C", x"88898A8B", F3_WORD);

        read_mem(x"00000110", F3_WORD);
        read_mem(x"00000114", F3_WORD);

        down_sig;
        -- Cache miss
        read_mem(x"00000100", F3_WORD);
        wait_cycles(2);
        read_mem(x"00000114", F3_WORD);
        read_mem(x"00000118", F3_WORD);
        read_mem(x"00000100", F3_WORD);

        down_sig;


        
        
        -- Test complete
        wait_cycles(2);
        sim_done <= true;
        wait;
    end process;

end Behavioral;