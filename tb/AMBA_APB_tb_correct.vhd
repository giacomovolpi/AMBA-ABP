library IEEE;
use IEEE.std_logic_1164.all;

entity AMBA_APB_tb_correct is
    end entity;

architecture testbench of AMBA_APB_tb_correct is

    constant DATA_WIDTH_tb :natural :=16;
    constant ADDR_WIDTH_tb :natural := 7;
    constant T_CLK : time := 10 ns;
    constant T_RESET : time := 5 ns;

    signal clk_tb : std_logic := '0';
    signal arstn_tb : std_logic := '0';
    signal address_tb : std_logic_vector(ADDR_WIDTH_tb-1 downto 0)  := (others => '1');
    signal in_tb : std_logic_vector (DATA_WIDTH_tb-1 downto 0)  := (others => '0');
    signal out_tb : std_logic_vector (DATA_WIDTH_tb-1 downto 0);
    signal p_en_tb : std_logic := '0';
    signal p_select_tb : std_logic := '0';
    signal we_tb    :std_logic :='0';
    signal sim_stop : std_logic := '1';

    component AMBA_APB_sync_RAM is
        generic(
        DATA_WIDTH_APB :natural := 16;
        ADDR_WIDTH_APB :natural := 7
    );
    port (
        p_addr      : in  std_logic_vector(ADDR_WIDTH_APB-1 downto 0);
        p_rdata     : out std_logic_vector(DATA_WIDTH_APB-1 downto 0);
        p_wdata     : in std_logic_vector(DATA_WIDTH_APB-1 downto 0);
        p_enable    : in std_logic;
        p_write     : in std_logic;
        p_sel       : in std_logic;
        clk         : in std_logic;
        rst         : in std_logic
    );
    end component;

begin
    clk_tb <= not(clk_tb) and sim_stop after T_CLK/2;
    arstn_tb <= '1' after T_RESET;

    AMBA: AMBA_APB_sync_RAM
        generic map(
            DATA_WIDTH_APB =>DATA_WIDTH_tb,
            ADDR_WIDTH_APB =>ADDR_WIDTH_tb
        )
    
        port map(
            p_addr=>address_tb,
            p_rdata=>out_tb,
            p_wdata=>in_tb,
            p_enable => p_en_tb,
            p_write => we_tb,
            p_sel => p_select_tb,
            clk => clk_tb,
            rst => arstn_tb
        );

    STIMULI : process(clk_tb, arstn_tb)
        variable t : integer := 0;
    begin
        if arstn_tb = '0' then
            t :=0;
            elsif rising_edge(clk_tb) then
                case(t) is
                    when 1 => address_tb <="1110001"; in_tb <= "1111111100110011"; we_tb<='1'; p_select_tb<='1'; -- WRITE IN RAM
                    when 2 => p_en_tb<='1';
                    when 3 => p_en_tb<='0'; p_select_tb <= '0';     
                    when 4 => address_tb <="1111111";


                    when 8 => address_tb <="1110001"; we_tb<='0'; p_select_tb<='1'; -- READ IN RAM
                    when 9 => p_en_tb<='1';
                    when 10 => p_en_tb <='0';  p_select_tb<='0';

                    when 14 => address_tb <="1100110"; we_tb<='0'; p_select_tb<='0'; -- READ IN ROM
                    when 15 => p_en_tb <= '1';
                    when 16 => p_en_tb <='0';  p_select_tb<='1';
                    
                    when 20 => sim_stop <= '0';
                    when others => null;
                end case;
                t := t+1;
            end if;
    end process;
end architecture;