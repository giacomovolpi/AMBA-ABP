library IEEE;
use IEEE.std_logic_1164.all;

-- the wrapper is used since Vivado only evaluates timing on Register-Logic-Register paths
entity apb_wrapper_sync_RAM is 
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
end entity;




architecture struct of apb_wrapper_sync_RAM is 
    -- the signal are used to pass the data from the register to the AMBA_APB logic
    signal address_signal : std_logic_vector(ADDR_WIDTH_WRAPPER-1 downto 0);
    signal data_signal_input : std_logic_vector(DATA_WIDTH_WRAPPER-1 downto 0);
    signal data_signal_output : std_logic_vector(DATA_WIDTH_WRAPPER-1 downto 0);
    signal w_enable_signal : std_logic;
    signal w_sel_signal : std_logic;
    signal w_write_signal : std_logic;

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

    AMBA: AMBA_APB_sync_RAM 
    generic map(
        DATA_WIDTH_APB => DATA_WIDTH_WRAPPER,
        ADDR_WIDTH_APB => ADDR_WIDTH_WRAPPER
    )
    
    port map(
        p_addr => address_signal,
        p_rdata => data_signal_output,
        p_wdata => data_signal_input,
        p_enable => w_enable_signal,
        p_write => w_write_signal,
        p_sel => w_sel_signal,
        clk => w_clk,
        rst => w_rst
    );


    -- the process mimic the register to implement the paradigm of register-logic-register for Vivado
    wrapper: process (w_clk)
	begin
		if (rising_edge (w_clk)) then
			if(w_rst = '0') then
				w_sel_signal <= '0';
				w_write_signal <= '0';
				data_signal_input <= (others => '0');
				address_signal <= (others => '0');
                w_rdata <= (others => '0');
				w_enable_signal <= '0';
			else
                w_sel_signal <= w_sel;
				w_write_signal <= w_write;
				data_signal_input <= w_wdata;
                w_rdata<=data_signal_output;
				address_signal <= w_addr;
				w_enable_signal <= w_enable;
			end if;
		end if;
    end process;
			
end architecture;
	
	
	