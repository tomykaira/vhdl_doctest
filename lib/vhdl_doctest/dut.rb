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
        cases = extract_test_cases

        [entity, ports, cases.map{ |c| TestCase.new(Hash[ports.zip(c)]) }]
      end

      def extract_ports
        return @ports if @ports
        @ports = []
        definitions = @vhdl.match(/entity.*is\s+port\s*\((.*)\);\s*end/m)[1]
        definitions.split("\n").each do |l|
          names, attributes = l.strip.gsub(/;$/, '').split(":")
          next unless attributes
          destination, type = attributes.strip.split(' ', 2)
          names.split(',').each do |name|
            @ports << Port.new(name.strip, destination.to_sym, VhdlDoctest::Types.parse(type))
          end
        end
        @ports
      end

      def extract_test_cases
        definitions = @vhdl.match(/-- TEST\n(.*)-- \/TEST/m)[1]
        header, *body = definitions.split("\n").map { |l| l[3..-1].split("|").map(&:strip) }

        header.each_with_index do |h, idx|
          radix = 10
          if h.include?(' ')
            case h[-1]
            when 'b'
              radix = 2
            when 'h', 'x'
              radix = 16
            end
          end
          prev = ''
          body.each do |l|
            if l[idx].empty?
              l[idx] = prev
            else
              prev = l[idx] = l[idx].to_i(radix)
            end
          end
        end
        body
      end
    end
  end
end
