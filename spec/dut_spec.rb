require 'spec_helper'

module VhdlDoctest
  sample_vhdl = 'examples/alu.vhd'
  describe DUT do
    subject { DUT.parse(sample_vhdl) }

    its(:entity) { should == "alu" }
    it { should have(5).ports }
    it { should have(8).cases }

    its('test_file.test_name') { should == 'testbench_alu' }
    its(:test_file) { should have(8).cases }
  end

  describe DUT::DoctestParser do
    describe 'ports' do
      subject { described_class.new(sample_vhdl).extract_ports }

      it { should have(5).items }
      its('first.port_definition') { should == "a : in std_logic_vector(31 downto 0)" }
      its('last.port_definition') { should == "zero : out std_logic" }
    end
  end
end
