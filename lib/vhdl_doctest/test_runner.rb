module VhdlDoctest
  class TestRunner
    def initialize(out, dut_path, test_file, dependencies = [])
      @out = out
      @dut_path = File.expand_path(dut_path)
      @test_file = test_file
      @dependencies = dependencies

      require 'tmpdir'
      @dir = Dir.mktmpdir
    end

    def run
      create_files
      run_test
      report_result
    end

    def create_files
      @test_file.create(@dir)
      create_runner_script
    end

    def dependencies
      dut_dir = File.dirname(@dut_path)
      @dependencies.map { |path| File.expand_path(path, dut_dir) }
    end

    def create_runner_script
      @sh = File.join(@dir, "run.sh")
      File.open(@sh, 'w') do |f|
        f << "#!/bin/sh -e\n\n"
        f << "cd #{@dir}\n"
        f << "ghdl -a --ieee=synopsys -fexplicit --warn-default-binding --warn-binding --warn-library --warn-body --warn-specs --warn-unused #{dependencies.join(" ")} #{@dut_path} #{@test_file.path}\n"
        f << "ghdl -e -Plibs/unisim --ieee=synopsys -fexplicit #{@test_file.test_name}\n"
        f << "ghdl -r #{@test_file.test_name} --vcd=out.vcd --stop-time=10ms\n"
      end
    end

    private
    def run_test
      @result = ""

      IO.popen("sh #{@sh} 2>&1") do |f|
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
