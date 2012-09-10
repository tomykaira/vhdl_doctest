module VhdlDoctest::Types
  class StdLogicVector
    def initialize(length)
      @length = length
    end

    def to_vhdl
      "std_logic_vector(#{@length-1} downto 0)"
    end

    def format(v)
      '"' + (2**@length + v).to_s(2)[-@length.. -1]+ '"'
    end

    def self.parse(str)
      str = str.strip
      if str.match(/\Astd_logic_vector/i)
        if str.strip.match(/\((\d+)\s+downto\s+0\)\Z/i)
          new($1.to_i + 1)
        else
          raise "#{ str } is std_logic_vector, but not 'x downto 0'"
        end
      end
    end
  end
end
