module VhdlDoctest::Types
  class StdLogicVector
    def initialize(length)
      @length = length
    end

    def to_vhdl
      "std_logic_vector(#{@length-1} downto 0)"
    end

    def format(v)
      '"' + v.to_s(2).rjust(@length, '0')+ '"'
    end

    def self.parse(str)
      if str.strip.match(/\Astd_logic_vector\s*\((\d+)\s+downto\s+0\)\Z/i)
        new($1.to_i + 1)
      end
    end
  end
end
