library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_cache_miss is
end tb_cache_miss;

architecture Behavioral of tb_cache_miss is
    -- Constants for RISC-V funct3
    constant F3_WORD      : STD_LOGIC_VECTOR(2 downto 0) := "010"; -- lw/sw

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
            CACHE_SIZE => 16  -- Small cache size
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
        procedure write_mem(address: in STD_LOGIC_VECTOR(31 downto 0);
                           data: in STD_LOGIC_VECTOR(31 downto 0)) is
        begin
            addr <= address;
            din <= data;
            funct3 <= F3_WORD;
            we <= '1';
            re <= '0';
            wait until rising_edge(clk);
            wait_cycles(1);
            we <= '0';
            wait_cycles(2);
        end procedure;
        
        -- Procedure to read from memory
        procedure read_mem(address: in STD_LOGIC_VECTOR(31 downto 0)) is
        begin
            addr <= address;
            funct3 <= F3_WORD;
            re <= '1';
            we <= '0';
            wait until rising_edge(clk);
            wait_cycles(1);
            re <= '0';
            wait_cycles(2);
        end procedure;
        
    begin
        -- Reset initial
        reset <= '1';
        wait_cycles(2);
        reset <= '0';
        wait_cycles(2);
        
        report "TEST 1: Sequential Access (Fill Cache)";
        -- Write to sequential addresses to fill cache
        for i in 0 to 15 loop
            write_mem(std_logic_vector(to_unsigned(i*4, 32)), 
                      std_logic_vector(to_unsigned(i+16#AA00#, 32)));
        end loop;
        
        -- Read back - these should be cache hits
        for i in 0 to 15 loop
            read_mem(std_logic_vector(to_unsigned(i*4, 32)));
            -- Check if the read value matches what we wrote
            wait_cycles(1);
            assert dout = std_logic_vector(to_unsigned(i+16#AA00#, 32))
                report "Test 1 read mismatch at address " & integer'image(i*4)
                severity error;
        end loop;
        
        report "TEST 2: Cache Miss Test";
        -- Write to the next 16 addresses (these should cause misses)
        for i in 16 to 31 loop
            write_mem(std_logic_vector(to_unsigned(i*4, 32)), 
                      std_logic_vector(to_unsigned(i+16#BB00#, 32)));
        end loop;
        
        -- Read back the first 16 addresses - these should now be misses
        -- because they were evicted by the second set of writes
        for i in 0 to 15 loop
            read_mem(std_logic_vector(to_unsigned(i*4, 32)));
            wait_cycles(1);
            -- Data may have been replaced, so we don't check values here
        end loop;
        
        report "TEST 3: Conflict Miss Test";
        -- For a direct-mapped cache with 16 entries, addresses that differ by 16*4=64 bytes
        -- map to the same cache line. This test causes conflict misses.
        
        -- First, write to base addresses
        for i in 0 to 15 loop
            write_mem(std_logic_vector(to_unsigned(i*4, 32)), 
                      std_logic_vector(to_unsigned(i+16#CC00#, 32)));
        end loop;
        
        -- Then write to conflicting addresses (64 bytes later)
        for i in 0 to 15 loop
            write_mem(std_logic_vector(to_unsigned(64 + i*4, 32)), 
                      std_logic_vector(to_unsigned(i+16#DD00#, 32)));
        end loop;
        
        -- Read from base addresses (should be misses since they were replaced)
        for i in 0 to 15 loop
            read_mem(std_logic_vector(to_unsigned(i*4, 32)));
            wait_cycles(1);
        end loop;
        
        -- Test complete
        report "Cache miss testing completed";
        sim_done <= true;
        wait;
    end process;

end Behavioral;