library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

--Main architecture of the AMBA-APB component
entity AMBA_APB_sync_RAM is
  generic(
    DATA_WIDTH_APB :integer := 16;
    ADDR_WIDTH_APB :integer := 7
  );
  port (
    p_addr    : in  std_logic_vector(ADDR_WIDTH_APB-1 downto 0);   -- address input
    p_rdata   : out std_logic_vector(DATA_WIDTH_APB-1 downto 0);   -- data output (for reading operations)
    p_wdata   : in std_logic_vector(DATA_WIDTH_APB-1 downto 0);    -- data input (for writing operations)
    p_enable  : in std_logic;                                      -- enable piloting input
    p_write   : in std_logic;                                      -- write piloting input
    p_sel     : in std_logic;                                      -- selection piloting input
    clk       : in std_logic;                                      -- clock
    rst       : in std_logic                                       -- reset
  );
end entity;

architecture my_AMBA_APB of AMBA_APB_sync_RAM is
  signal ROM_OUTPUT_TO_MULTIPLEXER : std_logic_vector(DATA_WIDTH_APB-1 downto 0);   -- signal connecting the output of the ROM to the input of the multiplexer
  signal RAM_OUTPUT_TO_MULTIPLEXER : std_logic_vector (DATA_WIDTH_APB-1 downto 0);  -- signal connecting the output of the RAM to the input of the multiplexer
  signal RAM_OUT_LSB : std_logic_vector(DATA_WIDTH_APB/2-1 downto 0);               -- signal tracking the least significant byte in output from the RAM
  signal RAM_OUT_MSB : std_logic_vector(DATA_WIDTH_APB/2-1 downto 0);               -- signal tracking the most significant byte in output from the RAM
  
  component multiplexer is
    generic(
      DATA_WIDTH_MULTI :integer := 16
    );
  
    port (
      mult_input_0  : in  std_logic_vector(DATA_WIDTH_MULTI-1 downto 0);    -- input from the ROM
      mult_input_1  : in  std_logic_vector(DATA_WIDTH_MULTI-1 downto 0);    -- input form the RAM
      output_mult   : out std_logic_vector(DATA_WIDTH_MULTI-1 downto 0);    -- output of the multiplexer
      p_sel_mult    : in  std_logic                                         -- input piloting the multiplexer
    );
  end component;

  component ram128x8_sync is 
    generic (
      DATA_WIDTH_RAM :integer := 8;
      ADDR_WIDTH_RAM :integer := 7
    );
    port (
      address       : in   std_logic_vector (ADDR_WIDTH_RAM-1 downto 0);   -- address input
      data_in0      : in   std_logic_vector (DATA_WIDTH_RAM-1 downto 0);   -- data input for lower byte
      data_in1      : in   std_logic_vector (DATA_WIDTH_RAM-1 downto 0);   -- data input for upper byte
      data_output0  : out  std_logic_vector (DATA_WIDTH_RAM-1 downto 0);   -- data output for lower byte
      data_output1  : out  std_logic_vector (DATA_WIDTH_RAM-1 downto 0);   -- data output for upper byte
      en            : in   std_logic;                                      -- enable input
      we            : in   std_logic;                                      -- write = 1 | read = 0
      select_ram    : in   std_logic;                                      -- select for the operation
      clock_ram     : in   std_logic                                       -- clock                          
    );
  end component;

  component ROM64x16 is 
    generic(
      DATA_WIDTH_ROM :integer := 16;
      ADDR_WIDTH_ROM :integer := 6
    );
    port (
      address   : in  std_logic_vector(ADDR_WIDTH_ROM-1 downto 0);  -- address input
      rom_out   : out std_logic_vector(DATA_WIDTH_ROM-1 downto 0)   -- data output
    );
  end component;
  
  begin

    ROM : ROM64x16 
    generic map(
      DATA_WIDTH_ROM => DATA_WIDTH_APB,
      ADDR_WIDTH_ROM => ADDR_WIDTH_APB-1
    )

    port map(
        address => p_addr(ADDR_WIDTH_APB-2 downto 0),   -- ROM only need 6 bits of input as addres
        rom_out => ROM_OUTPUT_TO_MULTIPLEXER            -- signal is used to pass data from the ROM to the multiplexer
    );

    RAM : ram128x8_sync
    generic map(
      DATA_WIDTH_RAM=>DATA_WIDTH_APB/2,
      ADDR_WIDTH_RAM=>ADDR_WIDTH_APB
    )

    port map(
        address => p_addr,                            
        data_output0 => RAM_OUT_LSB,                    -- map the least significant byte from the output of the RAM 
        data_output1 => RAM_OUT_MSB,                    -- map the most significant byte from the output of the RAM
        data_in0 => p_wdata(7 downto 0),                -- map the least significant byte to input of the RAM
        data_in1 => p_wdata(15 downto 8),               -- map the most significant byte to input of the RAM
        en => p_enable,
        we => p_write,
        clock_ram => clk,
        select_ram => p_sel
    );

    MULTI: multiplexer
    generic map(
      DATA_WIDTH_MULTI=>DATA_WIDTH_APB
    )

    port map(
        mult_input_0 => ROM_OUTPUT_TO_MULTIPLEXER,        -- map the input of the multiplexer coming from the ROM
        mult_input_1 =>RAM_OUTPUT_TO_MULTIPLEXER,         -- map the input of the multiplexer coming from the RAM
        output_mult => p_rdata, 
        p_sel_mult => p_sel
    );

    RAM_OUTPUT_TO_MULTIPLEXER <= RAM_OUT_MSB & RAM_OUT_LSB;   -- recombining the two signals into one 
    
    
end architecture;