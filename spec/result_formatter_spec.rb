require 'spec_helper'

module VhdlDoctest
  describe ResultFormatter do
    let(:dut_file) { "examples/alu.vhd/" }
    subject(:formatted_result) { described_class.new(output) }

    context "test did not run" do
      let(:output) { %q{
/tmp/main_decoder.vhd:193:27: ')' expected at end of interface list
/tmp/main_decoder.vhd:193:29: missing ";" at end of port clause
/tmp/main_decoder.vhd:193:29: 'end' is expected instead of 'out'
ghdl: compilation error
error: cannot find entity or configuration testbench_main_decoder
ghdl: compilation error
ghdl: file 'testbench_main_decoder' does not exists
ghdl: Please elaborate your design.
}}

      it { should be_compile_error }
      its(:format) { should match /FAIL/ }
      its(:format) { should match /Test did not run/ }
    end
  end
end
