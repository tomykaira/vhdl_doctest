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
      if @functions && fun = @functions[function]
        fun.call(value)
      else
        self.__send__(function || 'd', value)
      end
    end

    # convert decoder definition string to lambda
    # Example:
    #     def f { |x| x.include?(".") ? [x.to_f].pack('f').unpack('I').first : x.to_i }
    #     => #<Proc>
    def def_to_lambda(def_string)
      if def_string.match(/def\s+([[:alnum:]]*)\s+{([^}]*)}/)
        [$1, eval("lambda { #{ $2 } }")]
      end
    end

    def register_function(defs)
      @functions = Hash[defs.map{ |d| def_to_lambda(d) }]
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

    def test_block(vhdl)
      lines = vhdl.match(/-- TEST\n(.*)-- \/TEST/m)[1].
        gsub(/\#.*$/, '').     # remove comments
        gsub(/^---*[ \t]*/, '').  # remove VHDL comments
        gsub(/^\s*\n/m, '').    # remove blank lines
        split("\n")
    end

    def test_definition(vhdl)
      empty = { aliases: [], functions: [], cases: [] }
      test_block(vhdl).reduce(empty) do |m, l|
        case l
        when /^alias/; m[:aliases]   << l
        when /^def/;   m[:functions] << l
        else;          m[:cases]     << l
        end
        m
      end
    rescue
      raise "Test definition not found"
    end

    def replace_aliases(aliases, case_table)
      pairs = aliases.map { |l| l.match(/alias\s+(.*)\s+(.*)$/)[1..2] }
      case_table.each { |l| pairs.each { |p| l.gsub!(p[0], p[1]) } }
      case_table
    end

    def extract_values(vhdl)
      definition = test_definition(vhdl)
      register_function(definition[:functions])
      table = replace_aliases(definition[:aliases], definition[:cases])
      header, *body = table.map { |l| extract_fields l }
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
