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
      @ports ||=
        remove_comments(port_block).split(";").
        # "enable, push : in std_logic"
        map { |line| line.strip.split(':') }.
        # ["enable, push", "in std_logic"]
        select { |names, attrs| ! attrs.nil? }.
        map { |names, attrs| [names.split(','), *attrs.strip.split(' ', 2)]  }.
        # [["enable", " push"], in, std_logic]"
        map { |names, destination, type|
        names.map { |name| Port.new(name.strip, destination.to_sym, VhdlDoctest::Types.parse(type)) }
      }.flatten
    end

    def port_block
      @vhdl.match(/entity\s*(?<entity_name>[a-zA-Z_0-9]*)\s*is\s+port\s*\((?<ports>.*?)\);\s*end\s+\k<entity_name>\s*;/m)[:ports]
    end

    def remove_comments(vhdl)
      vhdl.gsub(/--.*$/, '')
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
  end
end
