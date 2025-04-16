library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity Cache is 
    generic (
        CACHE_SIZE : integer := 64  -- número de líneas de caché (potencia de 2)
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
        miss     : out STD_LOGIC
    );
end Cache;


architecture Behavioral of Cache is

    constant INDEX_WIDTH  : integer := integer(ceil(log2(real(CACHE_SIZE))));
    constant OFFSET_WIDTH : integer := 2; -- palabra = 4 bytes
    constant TAG_WIDTH    : integer := 32 - INDEX_WIDTH - OFFSET_WIDTH;

    type cache_data_array is array (0 to CACHE_SIZE-1) of STD_LOGIC_VECTOR(31 downto 0);
    type tag_array        is array (0 to CACHE_SIZE-1) of STD_LOGIC_VECTOR(TAG_WIDTH-1 downto 0);
    type bit_array        is array (0 to CACHE_SIZE-1) of STD_LOGIC;

    signal data  : cache_data_array := (others => (others => '0'));
    signal tag   : tag_array        := (others => (others => '0'));
    signal valid : bit_array        := (others => '0');

    signal index       : integer range 0 to CACHE_SIZE-1;
    signal addr_tag    : STD_LOGIC_VECTOR(TAG_WIDTH-1 downto 0);
    signal hit         : STD_LOGIC;
    signal byte_offset : integer range 0 to 3;

    signal ram_re : STD_LOGIC := '0';
    signal ram_dout       : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal ram_funct3   : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');

    signal dout_comb : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    -- signal dout_reg  : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

    signal miss_int  : STD_LOGIC := '0';


    signal state : STD_LOGIC_VECTOR(1 downto 0) := "00";

    constant IDLE          : STD_LOGIC_VECTOR(1 downto 0) := "00";
    constant WAIT_READ     : STD_LOGIC_VECTOR(1 downto 0) := "01";
    constant WRITE_THROUGH : STD_LOGIC_VECTOR(1 downto 0) := "10";

    -- funct3 codes
    constant F3_BYTE    : STD_LOGIC_VECTOR(2 downto 0) := "000";
    constant F3_HALF    : STD_LOGIC_VECTOR(2 downto 0) := "001";
    constant F3_WORD    : STD_LOGIC_VECTOR(2 downto 0) := "010";
    constant F3_BYTE_U  : STD_LOGIC_VECTOR(2 downto 0) := "100";
    constant F3_HALF_U  : STD_LOGIC_VECTOR(2 downto 0) := "101";

    component RAM is
        Port (
            clk      : in  STD_LOGIC;
            reset    : in  STD_LOGIC;
            we       : in  STD_LOGIC;
            re       : in  STD_LOGIC;
            addr     : in  STD_LOGIC_VECTOR(31 downto 0);
            din      : in  STD_LOGIC_VECTOR(31 downto 0);
            funct3   : in  STD_LOGIC_VECTOR(2 downto 0);
            dout     : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

begin

    -- Address decoding
    index      <= to_integer(unsigned(addr(INDEX_WIDTH + OFFSET_WIDTH - 1 downto OFFSET_WIDTH)));
    addr_tag   <= addr(31 downto 32 - TAG_WIDTH);
    byte_offset <= to_integer(unsigned(addr(1 downto 0)));
    hit        <= '1' when valid(index) = '1' and tag(index) = addr_tag else '0';

    -- Miss flag combinacional
    miss_int <= '1' when (re = '1' and hit = '0') else '0';
    miss <= miss_int;

    -- Selección de salida: combinacional si hit, registrada si miss
    dout <= dout_comb when (re = '1' and hit = '1') else (others => '0');
    -- dout <= dout_comb when (re = '1' and hit = '1') else dout_reg;

    -- Read always a Word form RAM so the cache has all de bytes
    ram_funct3 <= F3_WORD when ram_re = '1' else funct3;

    -- Combinacional para lectura inmediata
    process(clk, reset, addr, din, we, re, funct3, byte_offset, data, index, ram_dout)
        variable temp_byte : STD_LOGIC_VECTOR(7 downto 0);
        variable temp_half : STD_LOGIC_VECTOR(15 downto 0);
    begin
        dout_comb <= (others => '0');

        if re = '1' and hit = '1' then
            case funct3 is
                when F3_BYTE | F3_BYTE_U =>
                    case byte_offset is
                        when 0 => temp_byte := data(index)(7 downto 0);
                        when 1 => temp_byte := data(index)(15 downto 8);
                        when 2 => temp_byte := data(index)(23 downto 16);
                        when 3 => temp_byte := data(index)(31 downto 24);
                        when others => temp_byte := (others => '0');
                    end case;
                    if funct3 = F3_BYTE then
                        dout_comb <= (31 downto 8 => temp_byte(7)) & temp_byte;
                    else
                        dout_comb <= (31 downto 8 => '0') & temp_byte;
                    end if;

                when F3_HALF | F3_HALF_U =>
                    if byte_offset = 0 then
                        temp_half := data(index)(15 downto 0);
                    elsif byte_offset = 2 then
                        temp_half := data(index)(31 downto 16);
                    else
                        temp_half := (others => '0');
                    end if;
                    if funct3 = F3_HALF then
                        dout_comb <= (31 downto 16 => temp_half(15)) & temp_half;
                    else
                        dout_comb <= (31 downto 16 => '0') & temp_half;
                    end if;

                when F3_WORD =>
                    dout_comb <= data(index);

                when others =>
                    dout_comb <= data(index);
            end case;
        end if;
    end process;

    -- Memoria principal
    RAM_inst : RAM
        port map (
            clk    => clk,
            reset  => reset,
            we     => we,
            re     => ram_re,
            addr   => addr,
            din    => din,
            funct3 => ram_funct3,
            dout   => ram_dout
        );

    -- Control principal de la caché
    process(clk)
        variable temp_word : STD_LOGIC_VECTOR(31 downto 0);
    begin
        if rising_edge(clk) then
            if reset = '1' then
                valid     <= (others => '0');
                ram_re    <= '0';
                state     <= IDLE;
               -- dout_reg  <= (others => '0');

            else
                case state is
                    when IDLE =>
                        ram_re <= '0';

                        if re = '1' and hit = '0' then
                            ram_re <= '1';
                            state  <= WAIT_READ;

                        elsif we = '1' then
                            temp_word := data(index);
                            case funct3 is
                                when F3_BYTE =>
                                    case byte_offset is
                                        when 0 => temp_word(7 downto 0) := din(7 downto 0);
                                        when 1 => temp_word(15 downto 8) := din(7 downto 0);
                                        when 2 => temp_word(23 downto 16) := din(7 downto 0);
                                        when 3 => temp_word(31 downto 24) := din(7 downto 0);
                                        when others => null;
                                    end case;
                                when F3_HALF =>
                                    if byte_offset = 0 then
                                        temp_word(15 downto 0) := din(15 downto 0);
                                    elsif byte_offset = 2 then
                                        temp_word(31 downto 16) := din(15 downto 0);
                                    end if;
                                when F3_WORD =>
                                    temp_word := din;
                                when others =>
                                    temp_word := din;
                            end case;

                            data(index)  <= temp_word;
                            tag(index)   <= addr_tag;
                            valid(index) <= '1';

                            state  <= IDLE;
                        end if;

                    when WAIT_READ =>
                        ram_re <= '0';
                        data(index)   <= ram_dout;
                        tag(index)    <= addr_tag;
                        valid(index)  <= '1';
                      --  dout_reg      <= ram_dout; -- capturamos valor para miss
                        state         <= IDLE;

                    when WRITE_THROUGH =>
                        state  <= IDLE;
                    when others =>
                        valid     <= (others => '0');
                        ram_re    <= '0';
                        state     <= IDLE;
                       -- dout_reg  <= (others => '0');
                end case;
            end if;
        end if;
    end process;

end Behavioral;

