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
  end
end
