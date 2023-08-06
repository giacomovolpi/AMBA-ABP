library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

entity multiplexer is
  generic(
    DATA_WIDTH_MULTI :integer := 16
  );

  port (
    mult_input_0  : in  std_logic_vector(DATA_WIDTH_MULTI-1 downto 0);    -- input from the ROM
    mult_input_1  : in  std_logic_vector(DATA_WIDTH_MULTI-1 downto 0);    -- input form the RAM
    output_mult   : out std_logic_vector(DATA_WIDTH_MULTI-1 downto 0);    -- output of the multiplexer
    p_sel_mult    : in  std_logic                                         -- input piloting the multiplexer
  );
end entity;

architecture my_multiplexer of multiplexer is
begin

  -- PROC describe the process for generating the output of the multiplexer
  -- based upon the selection input
  PROC : process (mult_input_0, mult_input_1, p_sel_mult)
  begin
    if (p_sel_mult = '0') then    -- read from ROM
      output_mult <= mult_input_0;
    else                          -- read from RAM
      output_mult <= mult_input_1;
    end if;
  end process;

end architecture;