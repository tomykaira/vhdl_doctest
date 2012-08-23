# VhdlDoctest

This is a simple doctest-like test runner for VHDL.

## Dependency

This uses GHDL for compiling and running VHDL.  Please download from [GHDL Main/Home Page](http://ghdl.free.fr), and install.

## Installation

    $ gem install vhdl_doctest

Install GHDL from [GHDL Main/Home Page](http://ghdl.free.fr).

## Usage

White parameterized test in your VHDL file.  Current version is only for combination circuit.

    entity alu is
    
      port (
        a, b    : in  std_logic_vector(31 downto 0);
        control : in  std_logic_vector(2 downto 0);
        output  : out std_logic_vector(31 downto 0);
        zero    : out std_logic);
    
    end alu;

For this module, you can write the following test in the same file.  You should not miss `-- TEST` and `-- /TEST`.  Space after `--` is necessary.

    -- TEST
    -- a  |b   |control b|output|zero
    -- 18 |9   |000      |0     |1
    --    |    |001      |27    |0
    --    |    |010      |27    |0
    --    |    |110      |9     |0
    --    |    |111      |0     |1
    -- 18 |18  |111      |0     |1
    -- 18 |19  |         |1     |0
    -- 18 |100 |         |1     |0
    -- /TEST

- Each field should be separated with `|`.
- If the header column includes space followed by "b" or "h" or "x", that column's values are interpreted as binary (for "b") or "hex" (for "h" or "x").  The default interpretation is decimal.
- Blank field inherits the value of the previous row.
- Edge cases are not supported.  If you find out a buggy case, tell me through [ITS in github](https://github.com/tomykaira/vhdl_doctest/issues).

This generates code like this.

    a <= "00000000000000000000000000010010";
    b <= "00000000000000000000000000001001";
    control <= "000";wait for 10 ns;
    assert output = "00000000000000000000000000000000" and zero = '1' report "FAILED: a = 18, b = 9, control = 0 expected to output = 0, zero = 1, but output = " & to_string(output) & ", zero = " & to_string(zero) & "" severity warning;

CAUTION: a file can have only one TEST block.

## Issues And Features

If you found a bug (or unexpected movement), let me know.  Please attach your vhd file (as far as possible), and describe your intention precisely.

Any feature request is welcome.  I appreciate if it have an example, or a test case.

I am noob about hardware, and VHDL.  If you have knowledge about hardware testing, give me advice.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Write tests with rspec for your changes
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

## References

Utility functions in a generated test file are from http://www.eda-stds.org/vhdl-200x/vhdl-200x-ft/packages_old/ .
