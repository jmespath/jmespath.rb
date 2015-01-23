require 'spec_helper'

module JMESPath
  module Nodes
    describe Index do
      let :index do
        described_class.new(3)
      end

      describe '#visit' do
        context 'when given an Array' do
          it 'returns the nth element' do
            value = index.visit([:foo, :bar, :baz, :qux])
            expect(value).to eq(:qux)
          end

          it 'returns nil when the index is out of bounds' do
            value = index.visit([:foo, :bar])
            expect(value).to be_nil
          end
        end

        context 'when given something that is not an Array' do
          it 'returns nil' do
            value = index.visit({:foo => :bar})
            expect(value).to be_nil
            value = index.visit(nil)
            expect(value).to be_nil
            value = index.visit(true)
            expect(value).to be_nil
            value = index.visit(3)
            expect(value).to be_nil
          end
        end
      end

      describe '#chain_with?' do
        it 'chains with other Index nodes' do
          expect(index.chains_with?(Index.new(3))).to be_truthy
        end

        it 'chains with Field nodes' do
          expect(index.chains_with?(described_class.new('bar'))).to be_truthy
        end

        it 'does not chain with anything else' do
          expect(index.chains_with?(Literal.new('boo'))).to be_falsy
          expect(index.chains_with?(Current.new)).to be_falsy
          expect(index.chains_with?(Projection.new(Field.new('foo'), Current.new))).to be_falsy
        end
      end

      describe '#chain' do
        it 'returns a new node that performs the same job as itself and the given node' do
          value = [1, [2, 3]]
          index1 = described_class.new(1)
          index2 = described_class.new(1)
          chained = index1.chain(index2)
          expect(index2.visit(index1.visit(value))).to eq(3)
          expect(chained.visit(value)).to eq(3)
        end

        it 'can be recursively chained' do
          value = [1, [2, [3, [4, 5]]]]
          index1 = described_class.new(1)
          index2 = described_class.new(1)
          index3 = described_class.new(1)
          index4 = described_class.new(1)
          chained = index1.chain(index2).chain(index3).chain(index4)
          expect(chained.visit(value)).to eq(5)
        end

        it 'can be chained with another chain' do
          value = [1, [2, [3, [4, 5]]]]
          index1 = described_class.new(1)
          index2 = described_class.new(1)
          index3 = described_class.new(1)
          index4 = described_class.new(1)
          chained1 = index1.chain(index2).chain(index3.chain(index4))
          chained2 = index1.chain(index2.chain(index3.chain(index4)))
          expect(chained1.visit(value)).to eq(5)
          expect(chained2.visit(value)).to eq(5)
        end
      end
    end
  end
end
