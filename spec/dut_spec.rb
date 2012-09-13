require 'spec_helper'

module VhdlDoctest
  describe DUT do
    let(:sample_vhdl) { 'examples/alu.vhd' }
    subject { DUT.parse(sample_vhdl) }

    its(:entity) { should == "alu" }
    it { should have(5).ports }
    it { should have(8).cases }

    its('test_file.test_name') { should == 'testbench_alu' }
    its(:test_file) { should have(8).cases }

    describe 'dependencies' do
      subject(:dut) { DUT.new(vhdl) }

      context 'actual file' do
        let(:vhdl) { File.read('examples/alu_depending.vhd') }
        its(:dependencies) { should == ['test.vhd'] }
      end

      context 'multi files' do
        let(:vhdl) { %q{
-- DOCTEST DEPENDENCIES: test.vhd, another.vhd
} }

        its(:dependencies) { should == ['test.vhd', 'another.vhd'] }
      end

      context 'multi definition lines' do
        let(:vhdl) { %q{
-- DOCTEST DEPENDENCIES: test.vhd
-- DOCTEST DEPENDENCIES: another.vhd
} }

        its(:dependencies) { should == ['test.vhd', 'another.vhd'] }
      end
    end

    describe 'ports' do
      subject(:ports) { DUT.parse(sample_vhdl).ports }

      it { should have(5).items }
      its('first.port_definition') { should == "a : in std_logic_vector(31 downto 0)" }
      its('last.port_definition') { should == "zero : out std_logic" }
    end
  end
end
