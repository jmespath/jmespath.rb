require 'spec_helper'

module JMESPath
  module Nodes
    describe Field do
      let :field do
        described_class.new('foo')
      end

      shared_examples 'field_given_a_string_hash' do
        it 'returns the value for the key' do
          value = field.visit({'foo' => 'bar'})
          expect(value).to eq('bar')
        end

        it 'does not care about the type of the returned value' do
          value = field.visit({'foo' => 1})
          expect(value).to eq(1)
          value = field.visit({'foo' => {'bar' => 'baz'}})
          expect(value).to eq({'bar' => 'baz'})
          value = field.visit({'foo' => ['bar']})
          expect(value).to eq(['bar'])
          value = field.visit({'foo' => nil})
          expect(value).to eq(nil)
          value = field.visit({'foo' => false})
          expect(value).to eq(false)
        end

        it 'returns nil when the hash does not have the key' do
          value = field.visit({'bar' => 'foo'})
          expect(value).to be_nil
          value = field.visit({})
          expect(value).to be_nil
        end
      end

      shared_examples 'field_given_a_symbol_hash' do
        it 'returns the value for the key' do
          value = field.visit({:foo => 'bar'})
          expect(value).to eq('bar')
        end

        it 'does not care about the type of the returned value' do
          value = field.visit({:foo => 1})
          expect(value).to eq(1)
          value = field.visit({:foo => {:bar => 'baz'}})
          expect(value).to eq({:bar => 'baz'})
          value = field.visit({:foo => ['bar']})
          expect(value).to eq(['bar'])
          value = field.visit({:foo => nil})
          expect(value).to eq(nil)
          value = field.visit({:foo => false})
          expect(value).to eq(false)
        end

        it 'returns nil when the hash does not have the key' do
          value = field.visit({:bar => 'foo'})
          expect(value).to be_nil
          value = field.visit({})
          expect(value).to be_nil
        end
      end

      shared_examples 'field_given_a_struct' do
        let :struct do
          Struct.new(:foo, :bar)
        end

        it 'returns the value for the key' do
          value = field.visit(struct.new('bar', 'bar'))
          expect(value).to eq('bar')
        end

        it 'does not care about the type of the returned value' do
          value = field.visit(struct.new(1, 'bar'))
          expect(value).to eq(1)
          value = field.visit(struct.new({'bar' => 'baz'}, 'bar'))
          expect(value).to eq({'bar' => 'baz'})
          value = field.visit(struct.new(['bar'], 'bar'))
          expect(value).to eq(['bar'])
          value = field.visit(struct.new(nil, 'bar'))
          expect(value).to eq(nil)
          value = field.visit(struct.new(false, 'bar'))
          expect(value).to eq(false)
        end

        it 'returns nil when the value does not respond to the key' do
          value = field.visit(Struct.new(:bar, :baz).new(1, 2))
          expect(value).to be_nil
        end
      end

      describe '#visit' do
        context 'when given a Hash with string keys' do
          include_examples 'field_given_a_string_hash'
        end

        context 'when given a Hash with symbol keys' do
          include_examples 'field_given_a_symbol_hash'
        end

        context 'when given a Struct value' do
          include_examples 'field_given_a_struct'
        end

        context 'when optimized' do
          let :field do
            super().optimize
          end

          context 'and given a Hash with string keys' do
            include_examples 'field_given_a_string_hash'
          end

          context 'and given a Hash with symbol keys' do
            include_examples 'field_given_a_symbol_hash'
          end

          context 'and given a Struct' do
            include_examples 'field_given_a_struct'
          end
        end
      end

      describe '#chain_with?' do
        it 'chains with other Field nodes' do
          expect(field.chains_with?(described_class.new('bar'))).to be_truthy
        end

        it 'chains with Index nodes' do
          expect(field.chains_with?(Index.new(3))).to be_truthy
        end

        it 'does not chain with anything else' do
          expect(field.chains_with?(Literal.new('boo'))).to be_falsy
          expect(field.chains_with?(Current.new)).to be_falsy
          expect(field.chains_with?(Projection.new(Field.new('foo'), Current.new))).to be_falsy
        end
      end

      describe '#chain' do
        it 'returns a new node that performs the same job as itself and the given node' do
          value = {'foo' => {'bar' => 42}}
          field1 = described_class.new('foo')
          field2 = described_class.new('bar')
          chained = field1.chain(field2)
          expect(field2.visit(field1.visit(value))).to eq(42)
          expect(chained.visit(value)).to eq(42)
        end

        it 'can be recursively chained' do
          value = {'foo' => {'bar' => {'baz' => {'qux' => 42}}}}
          field1 = described_class.new('foo')
          field2 = described_class.new('bar')
          field3 = described_class.new('baz')
          field4 = described_class.new('qux')
          chained = field1.chain(field2).chain(field3).chain(field4)
          expect(chained.visit(value)).to eq(42)
        end

        it 'can be chained with another chain' do
          value = {'foo' => {'bar' => {'baz' => {'qux' => 42}}}}
          field1 = described_class.new('foo')
          field2 = described_class.new('bar')
          field3 = described_class.new('baz')
          field4 = described_class.new('qux')
          chained1 = field1.chain(field2).chain(field3.chain(field4))
          chained2 = field1.chain(field2.chain(field3.chain(field4)))
          expect(chained1.visit(value)).to eq(42)
          expect(chained2.visit(value)).to eq(42)
        end
      end
    end
  end
end
