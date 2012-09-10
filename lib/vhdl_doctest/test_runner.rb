module VhdlDoctest
  class TestRunner
    def initialize(out, dut_path, test_file)
      @out = out
      @dut_path = File.expand_path(dut_path)
      @test_file = test_file
    end

    def run
      create_files
      run_test
      report_result
    end

    private
    def create_files
      require 'tmpdir'
      @dir = Dir.mktmpdir
      @test_file.create(@dir)
    end

    def run_test
      @result = ""

      sh = File.join(@dir, "run.sh")
      File.open(sh, 'w') do |f|
        f << "#!/bin/sh -e\n\n"
        f << "cd #{@dir}\n"
        f << "ghdl -a --ieee=synopsys -fexplicit --warn-default-binding --warn-binding --warn-library --warn-body --warn-specs --warn-unused #{@dut_path} #{@test_file.path}\n"
        f << "ghdl -e -Plibs/unisim --ieee=synopsys -fexplicit #{@test_file.test_name}\n"
        f << "ghdl -r #{@test_file.test_name} --vcd=out.vcd --stop-time=10ms\n"
      end

      IO.popen("sh #{sh} 2>&1") do |f|
        output = f.read
        @result << output
        @out << output
      end
    end

    def report_result
      formatter = ResultFormatter.new(@result)
      @out << "\n\n\n"
      @out << formatter.format
      unless formatter.compile_error?
        @out << "\n#{@test_file.cases.size} examples, #{formatter.count_failure} failures\n"
      end
      @out << "\nTest directory: #{@dir}\n"
    end
  end
end
