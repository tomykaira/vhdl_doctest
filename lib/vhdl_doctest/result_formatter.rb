module VhdlDoctest
  class ResultFormatter
    def initialize(output)
      @output = output
    end

    # pretty print error message
    def format
      if compile_error?
        "FAILED: Test did not run because of compilation error"
      else
        format = []
        @output.split("\n").each do |l|
          if l.match(/(FAILED: .*) expected to (.*), but (.*)/)
            format << $1
            format << "  expected: " + $2
            format << "    actual: " + replace_binary($3)
          end
        end
        format.join("\n")
      end
    end

    def compile_error?
      @output.include?("ghdl: compilation error")
    end

    def succeeded?
      ! compile_error? && ! failed?
    end

    def failed?
      @output.include?("FAILED")
    end

    # convert binary expression in a string to decimal
    def replace_binary(str)
      str.gsub(/[01]+/) { |bin| bin.to_i(2).to_s(10) }
    end
  end
end
