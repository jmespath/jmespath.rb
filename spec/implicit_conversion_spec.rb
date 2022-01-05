require 'spec_helper'

module Wrapper
  def self.wrap(o)
    o.respond_to?(:to_ary) ? Arrayish.new(o) : o.respond_to?(:to_hash) ? Hashish.new(o) : o
  end
end

class Arrayish
  def initialize(ary)
    @ary = ary.to_ary
  end

  attr_reader :ary

  def to_ary
    @ary.map { |e| Wrapper.wrap(e) }
  end
end

class Hashish
  def initialize(hash)
    @hash = hash.to_hash
  end

  attr_reader :hash

  def to_hash
    to_hash = {}
    @hash.each_pair { |k, v| to_hash[k] = Wrapper.wrap(v) }
    to_hash
  end
end

module JMESPath
  describe '.search' do
    describe 'implicit conversion' do

      it 'searches hash/array structures' do
        data = Hashish.new({'foo' => {'bar' => ['value']}})
        result = JMESPath.search('foo.bar', data)
        expect(result).to be_instance_of(Arrayish)
        expect(result.ary).to eq(['value'])
      end

      it 'searches with flatten' do
        data = Hashish.new({'foo' => [[{'bar' => 0}], [{'baz' => 0}]]})
        result = JMESPath.search('foo[]', data)
        expect(result.size).to eq(2)
        expect(result[0]).to be_instance_of(Hashish)
        expect(result[0].hash).to eq({'bar' => 0})
        expect(result[1]).to be_instance_of(Hashish)
        expect(result[1].hash).to eq({'baz' => 0})
      end

    end
  end
end
