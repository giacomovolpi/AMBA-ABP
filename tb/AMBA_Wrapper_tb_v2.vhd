library IEEE;
use IEEE.std_logic_1164.all;

entity AMBA_Wrapper_tb_v2 is
    end entity;

architecture testbench of AMBA_Wrapper_tb_v2 is

    constant DATA_WIDTH_tb :natural :=16;
    constant ADDR_WIDTH_tb :natural := 7;
    constant T_CLK : time := 10 ns;
    constant T_RESET : time := 25 ns;

    signal clk_tb : std_logic := '0';
    signal arstn_tb : std_logic := '0';
    signal address_tb : std_logic_vector(ADDR_WIDTH_tb-1 downto 0)  := (others => '1');
    signal in_tb : std_logic_vector (DATA_WIDTH_tb-1 downto 0)  := (others => '0');
    signal out_tb : std_logic_vector (DATA_WIDTH_tb-1 downto 0);
    signal p_en_tb : std_logic := '0';
    signal p_select_tb : std_logic := '0';
    signal we_tb    :std_logic :='0';
    signal sim_stop : std_logic := '1';

    component apb_wrapper_sync_RAM is
        generic(
            DATA_WIDTH_WRAPPER :natural := 16;
            ADDR_WIDTH_WRAPPER :natural := 7
      );
      
      port(
        w_addr      : in  std_logic_vector(ADDR_WIDTH_WRAPPER-1 downto 0);
        w_rdata     : out std_logic_vector(DATA_WIDTH_WRAPPER-1 downto 0);
        w_wdata     : in std_logic_vector(DATA_WIDTH_WRAPPER-1 downto 0);
        w_enable    : in std_logic;
        w_write     : in std_logic;
        w_sel       : in std_logic;
        w_clk       : in std_logic;
        w_rst       : in std_logic
      );
    end component;

begin
    clk_tb <= not(clk_tb) and sim_stop after T_CLK/2;
    arstn_tb <= '1' after T_RESET;

    WRAPPER: apb_wrapper_sync_RAM
        generic map(
            DATA_WIDTH_WRAPPER =>DATA_WIDTH_tb,
            ADDR_WIDTH_WRAPPER =>ADDR_WIDTH_tb
        )
    
        port map(
            w_addr=>address_tb,
            w_rdata=>out_tb,
            w_wdata=>in_tb,
            w_enable => p_en_tb,
            w_write => we_tb,
            w_sel => p_select_tb,
            w_clk => clk_tb,
            w_rst => arstn_tb
        );

    STIMULI : process(clk_tb, arstn_tb)
        variable t : integer := 0;
    begin
        if arstn_tb = '0' then
            t :=0;
            elsif rising_edge(clk_tb) then
                case(t) is
                    when 2 => address_tb <="1110001"; in_tb <= "0000000011111111"; we_tb<='1'; p_select_tb<='1'; -- WRITE CYCLE
                    when 3 => p_en_tb<='1';
                    when 4 => p_en_tb<='0'; p_select_tb<='0';
                    
                    when 7 => we_tb<='0'; p_select_tb<='1'; -- READ CYCLE FROM RAM
                    when 8 => p_en_tb<='1';
                    when 9 => p_en_tb<='0';

                    when 12 => address_tb <="0000001"; p_select_tb<='0'; -- READ CYCLE FROM ROM
                    when 13 => p_en_tb<='1';
                    when 14 => p_en_tb<='0';
                    
                    when 16 => address_tb <="1110101"; in_tb <= "1111111111111111"; we_tb<='1'; p_select_tb<='0'; -- WRITE IN ROM (wrong behaviour)
                    when 17 => p_en_tb<='1';
                    when 18 => p_en_tb<='0';

                    when 20 => we_tb<='0'; p_select_tb<='1'; -- READ CYCLE FROM RAM
                    when 21 => p_en_tb<='1';
                    when 22 => p_en_tb<='0';

                    when 23 => address_tb <="1110001"; 
                    
                    when 25 => we_tb<='0'; p_select_tb<='1'; -- READ CYCLE FROM RAM WITH ADDR CHANGE (wrong behaviour)
                    when 26 => p_en_tb<='1'; 
                    when 27 => address_tb <="1110101"; 
                    when 28 => p_en_tb<='0';
                    

                    -- READ CYCLE FOLLOWING A WRITE CYCLE WITH ADDR CHANGE AND NO RESET OF VARIABLES (wrong behaviour)
                    when 30 => address_tb <="1111000"; in_tb <= "1111111100000000"; we_tb<='1'; p_select_tb<='1';
                    when 31 => p_en_tb<='1';
                    when 32 => address_tb <="1110001";
                    when 33 => we_tb<='0'; 

                    when 50 => sim_stop <= '0';
                    when others => null;
                end case;
                t := t+1;
            end if;
    end process;
end architecture;