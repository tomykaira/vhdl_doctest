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
      
    end
  end

  describe DUT::DoctestParser do
    describe 'ports' do
      let(:sample_vhdl) { 'examples/alu.vhd' }
      subject { described_class.new(sample_vhdl).extract_ports }

      it { should have(5).items }
      its('first.port_definition') { should == "a : in std_logic_vector(31 downto 0)" }
      its('last.port_definition') { should == "zero : out std_logic" }
    end
  end
end
