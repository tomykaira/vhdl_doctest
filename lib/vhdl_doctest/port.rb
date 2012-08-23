module VhdlDoctest
  class Port
    attr_reader :name

    def initialize(name, direction, type)
      @name, @direction, @type = name, direction, type
    end

    def port_definition
      "#@name : #@direction #{@type.to_vhdl}"
    end

    def signal_definition
      "signal #@name : #{@type.to_vhdl};"
    end

    def mapping
      "#@name => #@name"
    end

    def assignment(value)
      "#@name <= #{@type.format(value)};"
    end

    def equation(value)
      "#@name = #{@type.format(value)}"
    end

    def in?
      @direction == :in
    end
  end
end
