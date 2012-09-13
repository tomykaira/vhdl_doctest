module VhdlDoctest
  class DUT
    def self.parse(path)
      new(File.read(path))
    end

    attr_accessor :entity, :ports, :cases
    def initialize(vhdl)
      @vhdl = vhdl
    end

    def test_file
      TestFile.new(entity, ports, cases)
    end

    def ports
      extract_ports
    end

    def entity
      @vhdl.match(/entity\s+(.*)\s+is/)[1]
    end

    def cases
      TestParser.new(@vhdl).parse(ports)
    end

    def dependencies
      @vhdl.split("\n").
        select { |line| line.include?('DOCTEST DEPENDENCIES') }.
        map { |line| line.split(":")[1].split(",") }.
        flatten.
        map { |file| file.strip }
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
