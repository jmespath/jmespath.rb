# frozen_string_literal: true
require 'spec_helper'

module JMESPath
  describe '.search' do
    describe 'indifferent access' do
      it 'treats hashes indifferently with symbols/strings' do
        data = { foo: { bar: { yuck: 'abc' } } }
        expect(JMESPath.search('foo.bar.yuck', data)).to eq('abc')
      end

      it 'supports searching over strucures' do
        data = Struct.new(:foo).new(
          Struct.new(:bar).new(
            Struct.new(:yuck).new('abc')
          )
        )
        expect(JMESPath.search('foo.bar.yuck', data)).to eq('abc')
      end

      it 'does not raise an error when accessing non-valid struct members' do
        data = Struct.new(:foo).new(
          Struct.new(:bar).new(
            Struct.new(:yuck).new('abc')
          )
        )
        expect(JMESPath.search('foo.baz.yuck', data)).to be(nil)
      end
    end
  end
end
