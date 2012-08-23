module VhdlDoctest
  class TestCase
    def initialize(mapping)
      @in_mapping, @out_mapping = mapping.partition{ |port, _| port.in? }
    end

    def to_vhdl
      stimuli.join("\n") + "wait for 10 ns;\n" + assertion
    end

    private
    def stimuli
      @in_mapping.map do |port, value|
        port.assignment(value)
      end
    end

    def assertion
      cond = @out_mapping.map { |port, value| port.equation(value) }.join(" and ")
      inputs = @in_mapping.map { |port, value| "#{port.name} = #{value}" }.join(", ")
      expected = @out_mapping.map { |port, value| "#{port.name} = #{value}" }.join(", ")
      actual = @out_mapping.map { |port, value| "#{port.name} = \" & to_string(#{port.name}) & \"" }.join(", ")
      %Q{assert #{ cond } report "FAILED: #{inputs} expected to #{expected}, but #{actual}" severity warning;}
    end
  end
end
