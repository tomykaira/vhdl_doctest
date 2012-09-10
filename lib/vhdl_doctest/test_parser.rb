module VhdlDoctest
  class OutOfRangeSymbolError < RuntimeError
    def initialize(bad_value, allowed)
      super("#{ bad_value } includes not allowed symbol(s): #{ allowed }")
    end
  end

  class TestParser
    def initialize(vhdl)
      @vhdl = vhdl
      d = lambda do |x|
        assert_in_range(("0".."9").to_a + %w{ - }, x)
        x.to_i
      end

      h = lambda do |x|
        assert_in_range(("0".."9").to_a + ("a".."f").to_a, x)
        x.to_i(16)
      end

      b = lambda do |x|
        assert_in_range(%w{ 0 1 }, x)
        x.to_i(2)
      end
      @decoders = { 'd' => d, 'h' => h, 'x' => h, 'b' => b }
    end

    def parse(ports)
      names, vectors = extract_values(@vhdl)
      defined_ports = names.map { |name| ports.find { |p| p.name == name } }
      vectors.map { |v| TestCase.new(Hash[defined_ports.zip(v)]) }
    end

    # find decoder to decode given value
    def decode(decoder, value)
      if fun = @decoders[decoder || 'd']
        fun.call(value)
      else
        raise "Cannot decode #{value} with decoder #{decoder}.  Unknown decoder."
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

    def register_decoder(defs)
      @decoders.merge! Hash[defs.map{ |d| def_to_lambda(d) }]
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
        gsub(/\#.*$/, '').        # remove comments
        gsub(/^---*[ \t]*/, '').  # remove VHDL comments
        gsub(/^\s*\n/m, '').      # remove blank lines
        split("\n")
    end

    def test_definition(vhdl)
      empty = { aliases: [], decoders: [], cases: [] }
      test_block(vhdl).reduce(empty) do |m, l|
        case l
        when /^alias/; m[:aliases]  << l
        when /^def/;   m[:decoders] << l
        else;          m[:cases]    << l
        end
        m
      end
    rescue
      raise "Test definition not found"
    end

    def replace_aliases(aliases, case_table)
      pairs = aliases.map { |l| l.match(/alias\s+(.*)\s+(.*)$/)[1..2] }
      pairs.sort_by! { |k,v| -k.length }  # use longer alias first
      case_table.each { |l| pairs.each { |p| l.gsub!(p[0], p[1]) } }
      case_table
    end

    def remove_invalid_lines(body, idx)
      body.select do |l|
        if l.empty?
          false
        elsif ! l[idx]
          warn l.join(" | ") + " does not have enough columns"
          false
        else
          true
        end
      end
    end

    # fill empty cells inheriting the above value
    # decode string into :dont_care or integer
    # destructively change body
    def normalize_testcases(body, idx, decoder)
      prev = ''
      body.each do |l|
        if l[idx].empty?
          l[idx] = prev
        else
          if l[idx].strip.match(/^-+$/)
            l[idx] = :dont_care
          else
            l[idx] = decode(decoder, l[idx])
          end
          prev = l[idx]
        end
      end
    end

    def extract_values(vhdl)
      definition = test_definition(vhdl)
      register_decoder(definition[:decoders])
      table = replace_aliases(definition[:aliases], definition[:cases])
      header, *body = table.map { |l| extract_fields l }
      port_names = []

      header.each_with_index do |h, idx|
        port_name, decoder_name = h.split(' ', 2)
        port_names << port_name
        body = remove_invalid_lines(body, idx)
        normalize_testcases(body, idx, decoder_name)
      end
      [port_names, body]
    end
  end
end
