module VhdlDoctest::Types
  class StdLogic
    def to_vhdl
      'std_logic'
    end

    def format(v)
      if [0, 1].include? v.to_i
        %Q{'#{v.to_i}'}
      else
        # TODO: define error class
        raise "unacceptable value error #{v}"
      end
    end
  end
end
