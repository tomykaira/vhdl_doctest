module VhdlDoctest
  class OutOfRangeSymbolError < RuntimeError
    def initialize(allowed, bad_value)
      super("#{ bad_value } includes not allowed symbol(s)")
    end
  end

  module TestParser
    extend self
    def parse(ports, vhdl)
      names, vectors = extract_values(vhdl)
      defined_ports = names.map { |name| ports.find { |p| p.name == name } }
      vectors.map { |v| TestCase.new(Hash[defined_ports.zip(v)]) }
    end

    # read given string as decimal
    # Return: integer
    def d(x)
      assert_in_range(("0".."9").to_a + %w{ - }, x)
      x.to_i
    end

    # read given sring as hex
    # Return: integer
    def h(x)
      assert_in_range(("0".."9").to_a + ("a".."f").to_a, x)
      x.to_i(16)
    end
    alias_method :x, :h

    # read given sring as binary
    # Return: integer
    def b(x)
      assert_in_range(%w{ 0 1 }, x)
      x.to_i(2)
    end

    def decode(function, value)
      self.__send__(function || 'd', value)
    end

    private
    def assert_in_range(allowed, string)
      unless string.split(//).all? { |s| allowed.include? s }
        raise OutOfRangeSymbolError.new(string, allowed)
      end
    end

    def remove_comment(line)
      line.match(/--\s*([^#]*)/)[1]
    rescue
      raise "line: #{line} is not formatted correctly"
    end

    def extract_fields(line)
      line.split("|").map(&:strip)
    end

    def test_definitions(vhdl)
      lines = vhdl.match(/-- TEST\n(.*)-- \/TEST/m)[1].
        gsub(/\#.*$/, '').     # remove comments
        gsub(/--\s*\n/m, '').  # remove blank lines
        split("\n")
      lines.partition { |l| l.include? 'alias' }
    rescue
      raise "Test definition not found"
    end

    def radix(attr)
      if attr
        case attr[-1]
        when 'b';      2
        when 'h', 'x'; 16
        end
      else
        10
      end
    end

    def replace_aliases(defs, table)
      pairs = defs.map { |l| l.match(/alias\s+(.*)\s+(.*)$/)[1..2] }
      table.each { |l| pairs.each { |p| l.gsub!(p[0], p[1]) } }
      table
    end

    def extract_values(vhdl)
      table = replace_aliases(*test_definitions(vhdl))
      header, *body = table.map { |l| extract_fields remove_comment l }
      port_names = []

      header.each_with_index do |h, idx|
        port_name, attr = h.split(' ', 2)
        port_names << port_name
        prev = ''
        body.select! do |l|
          if l.empty?
            false
          elsif ! l[idx]
            warn l.join(" | ") + " does not have enough columns"
            false
          else
            true
          end
        end
        body.each do |l|
          if l[idx].empty?
            l[idx] = prev
          else
            if l[idx].strip.match(/^-+$/)
              l[idx] = :dont_care
            else
              l[idx] = decode(attr, l[idx])
            end
            prev = l[idx]
          end
        end
      end
      [port_names, body]
    end
  end
end
