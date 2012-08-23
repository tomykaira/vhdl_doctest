require 'spec_helper'

module VhdlDoctest
  describe Types do
    describe ".parse" do
      subject { Types.parse(string) }

      describe 'std_logic' do
        let(:string) { 'std_logic' }
        it { should be_a Types::StdLogic }
      end

      describe 'std_logic_vector' do
        let(:string) { 'std_logic_vector(8 downto 0)' }
        it { should be_a Types::StdLogicVector }
      end

      describe 'std_logic_vector, but not in format' do
        let(:string) { 'std_logic_vector(0 upto 8)' }
        specify { expect { subject }.to raise_error }
      end

      describe 'upcase STD_LOGIC' do
        let(:string) { 'STD_LOGIC' }
        it { should be_a Types::StdLogic }
      end

      describe 'upcase STD_LOGIC_VECTOR' do
        let(:string) { 'STD_LOGIC_VECTOR(2 DOWNTO 0)' }
        it { should be_a Types::StdLogicVector }
      end

      describe 'unknown' do
        let(:string) { 'unkonwn' }
        specify { expect { subject }.to raise_error }
      end
    end
  end
end
