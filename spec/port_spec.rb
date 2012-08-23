require 'spec_helper'

module VhdlDoctest
  describe Port do
    subject { Port.new('test', :in, Types::StdLogic.new) }

    its(:mapping){ should == "test => test" }

    describe '#assignment' do
      subject { port.assignment(value) }

      describe 'std_logic' do
        let(:port) { Port.new('test', :in, Types::StdLogic.new) }

        context 'value = 0' do
          let(:value) { 0 }
          it { should == "test <= '0';" }
        end

        context 'value = 1' do
          let(:value) { 1 }
          it { should == "test <= '1';" }
        end
      end
      describe 'std_logic_vector(8)' do
        let(:port) { Port.new('test', :in, Types::StdLogicVector.new(8)) }

        context 'value = 0' do
          let(:value) { 0 }
          it { should == 'test <= "00000000";' }
        end
      end
    end
  end
end
