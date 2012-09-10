module VhdlDoctest
  class ResultFormatter
    def initialize(output)
      @output = output
    end

    def format
      if compile_error?
        "FAILED: Test did not run because of compilation error"
      else
        @output
      end
    end

    def compile_error?
      @output.include?("ghdl: compilation error")
    end
  end
end
