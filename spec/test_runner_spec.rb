require 'spec_helper'

module VhdlDoctest
  describe TestRunner do
    let(:dut_file) { "examples/alu.vhd/" }
    describe "#run" do
      let(:out) { StringIO.new }
      subject { out.rewind; out.read }
      before { described_class.new(out, dut_file, file).run }

      context "3 successful examples" do
        let(:file) { test_file([[18, 9, 0, 0, 1], [18, 18, 7, 0, 1], [18, 19, 7, 1, 0]]) }

        it { should match "3 examples, 0 failures" }
      end

      context "1 successful examples" do
        let(:file) { test_file([[18, 9, 0, 0, 1]]) }

        it { should match "1 examples, 0 failures" }
      end

      context "1 failing examples" do
        let(:file) { test_file([[18, 9, 0, 0, 0]]) }

        it { should match "1 examples, 1 failures" }
        it { should match "actual:" }
      end

      context "stimuli including minus" do
        let(:file) { test_file([[18, -9, 2, 9, 0]]) }

        it { should match "1 examples, 0 failures" }
      end
    end

    def test_file(cases)
      ports = [
        Port.new("a",       :in, Types::StdLogicVector.new(32)),
        Port.new("b",       :in, Types::StdLogicVector.new(32)),
        Port.new("control", :in, Types::StdLogicVector.new(3)),
        Port.new("output",  :out, Types::StdLogicVector.new(32)),
        Port.new("zero",    :out, Types::StdLogic.new)
      ]
      TestFile.new("alu", ports, cases.map{ |c| TestCase.new(Hash[ports.zip(c)]) })
    end
  end
end
