require 'spec_helper'

module VhdlDoctest
  # Expect TestCase to set given hash pairs as stimulus
  RSpec::Matchers.define :set do |expected|
    match do |actual|
      expected.all? { |k, v| actual.in_mapping.
        find { |port, value| port.name == k.to_s && v == value } }
    end
  end

  # Expect TestCase to assert given hash pairs
  RSpec::Matchers.define :assert do |expected|
    match do |actual|
      expected.all? { |k, v| actual.out_mapping.
        find { |port, value| port.name == k.to_s && (v == nil || v == value) } }
    end
  end

  describe TestParser do
    let(:ports) {[
        Port.new("a",       :in, Types::StdLogicVector.new(32)),
        Port.new("b",       :in, Types::StdLogicVector.new(32)),
        Port.new("control", :in, Types::StdLogicVector.new(3)),
        Port.new("output",  :out, Types::StdLogicVector.new(32)),
        Port.new("zero",    :out, Types::StdLogic.new)
      ]}
    subject(:cases) { TestParser.parse(ports, input) }

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

    describe 'single case' do
      let(:input) { %q{
-- TEST
-- a | b | control | output | zero
-- 3 | 5 | 2       | 8      | 0
-- /TEST
}}

      it { should have(1).item }
      its(:first) { should set(a: 3, b: 5, control: 2) }
      its(:first) { should assert(output: 8, zero: 0) }
    end

    describe 'two cases with an empty column' do
      let(:input) { %q{
-- TEST
-- a | b | control | output | zero
-- 3 | 5 | 2       | 8      | 0
-- 9 |   | 2       | 14     | 0
-- /TEST
}}

      it { should have(2).items }
      its(:last) { should set(a: 9, b: 5, control: 2) }
    end

    describe 'field redix specification' do
      let(:input) { %q{
-- TEST
-- a h | b x | control b | output | zero
-- 10  | 20  | 010       | 8      | 0
-- /TEST
}}

      specify { cases.first.should set(a: 16, b: 32, control: 2) }
    end

    describe 'wrong input for redix' do
      let(:input) { %q{
-- TEST
-- a h | b x | control b | output | zero
-- 10  | 20  | 012       | 8      | 0
-- /TEST
}}

      it { expect{ cases }.to raise_error(OutOfRangeSymbolError, /control.*binary.*012/) }
    end

    describe 'dont care in assertion' do
      let(:input) { %q{
-- TEST
-- a   | b   | control b | output | zero
-- 10  | 20  | 010       | 30     | 0
-- 10  | -10 |           | 0      | -
-- /TEST
}}

      specify('second') { cases[0].should assert(output: 30, zero: 0) }
      specify('second') { cases[1].should set(a: 10, b: -10, control: 2) }
      specify('second') { cases[1].should_not assert([:zero]) }
    end
  end
end
