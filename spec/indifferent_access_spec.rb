require 'spec_helper'

module JMESPath
  describe '.search' do
    describe 'indifferent access' do

      it 'treats hashes indifferently with symbols/strings' do
        data = {foo:{bar:{yuck:'abc'}}}
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

    end
  end
end
