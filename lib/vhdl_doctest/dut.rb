module VhdlDoctest
  class DUT
    def self.parse(path)
      entity, ports, cases = DoctestParser.new(path).parse
      new(entity, ports, cases)
    end

    attr_accessor :entity, :ports, :cases
    def initialize(entity, ports, cases)
      @entity, @ports, @cases = entity, ports, cases
    end

    def test_file
      TestFile.new(@entity, @ports, @cases)
    end

    class DoctestParser
      def initialize(path)
        @vhdl = File.read(path)
      end

      def parse
        entity = @vhdl.match(/entity\s+(.*)\s+is/)[1]
        ports = extract_ports
        cases = TestParser.new(@vhdl).parse(ports)

        [entity, ports, cases]
      end

      # this assumes one-line one-port
      def extract_ports
        return @ports if @ports
        @ports = []
        definitions = @vhdl.match(/entity\s*(?<entity_name>[a-zA-Z_0-9]*)\s*is\s+port\s*\((?<ports>.*?)\);\s*end\s+\k<entity_name>\s*;/m)[:ports]
        definitions.split("\n").each do |l|
          names, attributes = l.strip.gsub(/;.*$/, '').split(":")
          next unless attributes
          destination, type = attributes.strip.split(' ', 2)
          names.split(',').each do |name|
            @ports << Port.new(name.strip, destination.to_sym, VhdlDoctest::Types.parse(type))
          end
        end
        @ports
      end
    end
  end
end
