require 'spec_helper'

module VhdlDoctest
  describe TestParser do
    let(:ports) {[
        Port.new("a",       :in, Types::StdLogicVector.new(32)),
        Port.new("b",       :in, Types::StdLogicVector.new(32)),
        Port.new("control", :in, Types::StdLogicVector.new(3)),
        Port.new("output",  :out, Types::StdLogicVector.new(32)),
        Port.new("zero",    :out, Types::StdLogic.new)
      ]}
    let(:cases) { TestParser.parse(ports, input) }

    describe 'header only' do
      let(:input) { %q{
-- TEST
-- a | b | control | output | zero
-- /TEST
}}
      it 'should not fail to parse' do
        expect(cases).to have(0).items
      end
    end
  end
end
