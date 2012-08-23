module VhdlDoctest
  module TestParser
    extend self
    def parse(ports, vhdl)
      vectors = extract_values(vhdl)
      vectors.map { |v| TestCase.new(Hash[ports.zip(v)]) }
    end

    private
    def extract_values(vhdl)
      definitions = vhdl.match(/-- TEST\n(.*)-- \/TEST/m)[1]
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
