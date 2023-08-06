library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

-- the ROM entity is model after LUT
entity ROM64x16 is
  generic(
    DATA_WIDTH_ROM : natural := 16;
    ADDR_WIDTH_ROM : natural := 6
  );
  --ROM acts in a combinatorial way, so it only need the addres as input and 16 wire for the output
  --since the ROM is a read only memory it does not need other input to determin the operation
  port (  
    address   : in  std_logic_vector(ADDR_WIDTH_ROM-1 downto 0);  -- address input
    rom_out   : out std_logic_vector(DATA_WIDTH_ROM-1 downto 0)   -- data output
  );
end entity;

architecture rtl of ROM64x16 is

  type LUT_t is array (natural range 0 to 63) of integer;
  constant LUT: LUT_t := (
    0 => 0,
    1 => 3212,
    2 => 6393,
    3 => 9512,
    4 => 12539,
    5 => 15446,
    6 => 18204,
    7 => 20787,
    8 => 23170,
    9 => 25329,
    10 => 27245,
    11 => 28898,
    12 => 30273,
    13 => 31356,
    14 => 32137,
    15 => 32609,
    16 => 32767,
    17 => 32609,
    18 => 32137,
    19 => 31356,
    20 => 30273,
    21 => 28898,
    22 => 27245,
    23 => 25329,
    24 => 23170,
    25 => 20787,
    26 => 18204,
    27 => 15446,
    28 => 12539,
    29 => 9512,
    30 => 6393,
    31 => 3212,
    32 => 0,
    33 => -3212,
    34 => -6393,
    35 => -9512,
    36 => -12539,
    37 => -15446,
    38 => -18204,
    39 => -20787,
    40 => -23170,
    41 => -25329,
    42 => -27245,
    43 => -28898,
    44 => -30273,
    45 => -31356,
    46 => -32137,
    47 => -32609,
    48 => -32767,
    49 => -32609,
    50 => -32137,
    51 => -31356,
    52 => -30273,
    53 => -28898,
    54 => -27245,
    55 => -25329,
    56 => -23170,
    57 => -20787,
    58 => -18204,
    59 => -15446,
    60 => -12539,
    61 => -9512,
    62 => -6393,
    63 => -3212
  );

begin
  rom_out <= std_logic_vector(to_signed(LUT(to_integer(unsigned(address))),16));
end architecture;
