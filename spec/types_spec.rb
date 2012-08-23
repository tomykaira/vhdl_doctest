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
    end
  end
end
