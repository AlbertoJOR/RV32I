library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Fetch Stage
entity Fetch is
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        branch      : in  STD_LOGIC;
        stall       : in  STD_LOGIC;
        ImmExt      : in  STD_LOGIC_VECTOR (31 downto 0);

        inst : out  STD_LOGIC_VECTOR (31 downto 0);
        PC_out : out  STD_LOGIC_VECTOR (31 downto 0)
    );
end Fetch;

architecture Structural of Fetch is

    component PC is
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        branch      : in  STD_LOGIC;
        stall       : in  STD_LOGIC;
        -- stall       : in  STD_LOGIC;
        ImmExt      : in  STD_LOGIC_VECTOR (31 downto 0);
        PC_out      : out STD_LOGIC_VECTOR (31 downto 0)
    );
    end component;
    signal PC_out_s : STD_LOGIC_VECTOR(31 downto 0) := (others => '0'); 

    component InstMem is
        generic (
            ROM_SIZE : integer := 256  -- Tamaño de la ROM en bytes (valor por defecto)
        );
        port (
            addr : in  std_logic_vector(31 downto 0);
            inst : out std_logic_vector(31 downto 0)
        );
    end component;

    signal inst_s : STD_LOGIC_VECTOR(31 downto 0) := (others => '0'); 
    

    component PipeFetch is
        Port (
            clk   : in  STD_LOGIC;
            reset : in  STD_LOGIC;
            stall       : in  STD_LOGIC;
            -- Entrada pipe
            inst_i  : in  STD_LOGIC_VECTOR(31 downto 0);
            PC_i    : in  STD_LOGIC_VECTOR(31 downto 0);
            
            -- Salida pipe
            inst_o  : out  STD_LOGIC_VECTOR(31 downto 0);
            PC_o    : out  STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

begin
    PC_c : PC
        port map(
            clk => clk ,
            reset => reset,
            stall => stall,
            branch => branch,
            ImmExt => ImmExt,
            PC_out => PC_out_s
        );

    InstMem_c :InstMem
        generic map (
            ROM_SIZE => 256 
        )
        port map (
            addr => PC_out_s,
            inst => inst_s
        );

    PipeFetch_c : PipeFetch
        port map (
            clk   => clk,
            reset   => reset,
            stall => stall,
            inst_i   => inst_s,
            PC_i   => PC_out_s,
            inst_o   => inst,
            PC_o   => PC_out
        );
end Structural;
