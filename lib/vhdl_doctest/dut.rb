module VhdlDoctest
  class DUT
    def self.parse(path)
      entity, ports, cases = DoctestParser.new(path).parse
      new(entity, ports, cases)
    end

    attr_accessor :entity, :ports, :cases
    def new(entity, ports, cases)
      @entity, @ports, @cases = entity, ports, cases
    end

    class DoctestParser
      def initialize(path)
        @vhdl = File.read(path)
      end

      def parse
        entity = @vhdl.match(/entity\s+(.*)\s+is/)[1]
        ports = extract_ports
        cases = extract_test_cases

        [entity, ports, Hash[cases.map { |c| ports.zip(c) }]]
      end

      def extract_ports
        ports = []
        definitions = @vhdl.match(/entity.*is\s+port\s*\((.*)\);\s*end/m)[1]
        definitions.split("\n").each do |l|
          names, attributes = l.strip.gsub(/;$/, '').split(":")
          next unless attributes
          destination, type = attributes.strip.split(' ', 2)
          names.split(',').each do |name|
            ports << Port.new(name.strip, destination.to_sym, VhdlDoctest::Types.parse(type))
          end
        end
        ports
      end
    end
  end
end
