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
      it { should_not be_succeeded }
      its(:format) { should match /FAIL/ }
      its(:format) { should match /Test did not run/ }
    end

    context "test run, but one case failed" do
      let(:output) { %q{/tmp/d20120910-14672-k0mvgz/testbench_main_decoder.vhd:587:1:@790ns:(assertion warning): FAILED: op = 44, rx_done = 0, stage = 1 expected to next_stage = 2, bus_to_reg = 0, alu_src = 0, pc_src = 0, reg_dst = 1, alu_control = 0, mem_write = 0, send_enable = 0, reg_write = 0, rx_enable = 0, but next_stage = 0010, bus_to_reg = 0, alu_src = 1, pc_src = 000, reg_dst = 0, alu_control = 0000, mem_write = 0, send_enable = 0, reg_write = 0, rx_enable = 0} }

      it { should_not be_compile_error  }
      it { should_not be_succeeded }
      it "should pretty print the result" do
        subject.format.should include %q{
FAILED: op = 44, rx_done = 0, stage = 1
  expected: next_stage = 2, bus_to_reg = 0, alu_src = 0, pc_src = 0, reg_dst = 1, alu_control = 0, mem_write = 0, send_enable = 0, reg_write = 0, rx_enable = 0
    actual: next_stage = 2, bus_to_reg = 0, alu_src = 1, pc_src = 0, reg_dst = 0, alu_control = 0, mem_write = 0, send_enable = 0, reg_write = 0, rx_enable = 0
}.strip
      end
      its(:count_failure) { should == 1 }
    end

    describe '#replace_binary' do
      def replace_binary(str)
        ResultFormatter.new('').replace_binary(str)
      end

      specify do
        expect(replace_binary('next_stage = 0010')).to eq('next_stage = 2')
      end

      specify do
        expect(replace_binary('next_stage = 0010, alu_control = 0000')).
          to eq('next_stage = 2, alu_control = 0')
      end
    end
  end
end
