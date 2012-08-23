module VhdlDoctest
  class TestCase
    attr_reader :in_mapping, :out_mapping
    def initialize(mapping)
      @in_mapping, @out_mapping = mapping.partition{ |port, _| port.in? }
      if @in_mapping.find { |_, v| v == :dont_care }
        raise NotImplementedError.new("Don't care for input value is not supported")
      end
      @out_mapping.select!{ |k, v| v != :dont_care }
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
      inputs = @in_mapping.map { |port, value| "#{port.name} = #{value}" }.join(", ")
      if @out_mapping.empty?
        warn "There is no assertion for #{inputs}."
        return ''
      end
      cond = @out_mapping.map { |port, value| port.equation(value) }.join(" and ")
      expected = @out_mapping.map { |port, value| "#{port.name} = #{value}" }.join(", ")
      actual = @out_mapping.map { |port, value| "#{port.name} = \" & to_string(#{port.name}) & \"" }.join(", ")
      %Q{assert #{ cond } report "FAILED: #{inputs} expected to #{expected}, but #{actual}" severity warning;}
    end
  end
end
