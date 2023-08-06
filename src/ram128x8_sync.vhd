library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;
    use ieee.numeric_std.all;

entity ram128x8_sync is
    generic (
        DATA_WIDTH_RAM:integer := 8;
        ADDR_WIDTH_RAM :integer := 7
    );
    port (
        address         :in std_logic_vector (ADDR_WIDTH_RAM-1 downto 0);   -- address input
        data_in0        :in std_logic_vector (DATA_WIDTH_RAM-1 downto 0);   -- data input for lower byte
        data_in1        :in std_logic_vector (DATA_WIDTH_RAM-1 downto 0);   -- data input for upper byte
        data_output0    :out std_logic_vector (DATA_WIDTH_RAM-1 downto 0);  -- data output for lower byte
        data_output1    :out std_logic_vector (DATA_WIDTH_RAM-1 downto 0);  -- data output for upper byte
        en              :in std_logic;                                      -- enable input
        we              :in std_logic;                                      -- write = 1 | read = 0
        select_ram      :in std_logic;                                      -- select for the operation
        clock_ram       :in std_logic                                       -- clock
         
    );
end entity;
architecture RAM_test of ram128x8_sync is
    -- the RAM is model as an array of std_logic_vector of 1 byte
    -- this implementation is likely the cause of warning "Netlist 29-101" in Vivado
    type RAM is array(0 to 127) of std_logic_vector(7 downto 0);
    signal mem : RAM;

begin
    -- ram_work describe the synchronous process of writing
    ram_work: process (clock_ram)
    begin
        if (rising_edge(clock_ram)) then        --RAM synchronization with the system clock

        -- this loop can be used to set all location of the RAM to 0
        -- this avoid seeing the UUUUUUUU output in the ModelSim timewave
		-- if reset_ram= '0' then				--reset condition
		--	for i in 0 to 127 loop				-- loop to reset to 0 all RAM location
        --      mem(i) <= (others=>'0');
		--	end loop;

            if (we = '1' and en='1' and select_ram='1') then		-- write condition:
                mem(to_integer(unsigned(address))) <= data_in0;		
                mem(to_integer(unsigned(address+1))) <= data_in1;	-- data is written in the location according to little endian paradigm

            end if;
        end if;
        end process;

        data_output0 <= mem(to_integer(unsigned(address)));			
        data_output1 <= mem(to_integer(unsigned(address+1)));       -- data is read from the location accordimg to little endian paradigm
        
end architecture;