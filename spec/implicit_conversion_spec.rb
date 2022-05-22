# frozen_string_literal: true

require 'spec_helper'

module Wrapper
  def self.wrap(o)
    if o.respond_to?(:to_ary)
      Arrayish.new(o)
    else
      o.respond_to?(:to_hash) ? Hashish.new(o) : o
    end
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
        data = Hashish.new({ 'foo' => { 'bar' => ['value'] } })
        result = JMESPath.search('foo.bar', data)
        expect(result).to be_instance_of(Arrayish)
        expect(result.ary).to eq(['value'])
      end

      it 'searches with flatten' do
        data = Hashish.new({ 'foo' => [[{ 'bar' => 0 }], [{ 'baz' => 0 }]] })
        result = JMESPath.search('foo[]', data)
        expect(result.size).to eq(2)
        expect(result[0]).to be_instance_of(Hashish)
        expect(result[0].hash).to eq({ 'bar' => 0 })
        expect(result[1]).to be_instance_of(Hashish)
        expect(result[1].hash).to eq({ 'baz' => 0 })
      end
    end

    describe 'Compliance' do
      Dir.glob('spec/{compliance,legacy}/*.json').each do |path|
        test_file = File.basename(path).split('.').first
        next if test_file == 'benchmarks'
        next if ENV['TEST_FILE'] && ENV['TEST_FILE'] != test_file

        describe(test_file) do
          JMESPath.load_json(path).each do |scenario|
            describe("Given #{scenario['given'].to_json}") do
              scenario['cases'].each do |test_case|
                next if test_case['error']

                it "searching #{test_case['expression'].inspect} returns #{test_case['result'].to_json}" do
                  result = JMESPath.search(test_case['expression'], Wrapper.wrap(scenario['given']))

                  expect(JMESPath::Util.as_json(result)).to eq(test_case['result'])
                end
              end
            end
          end
        end
      end
    end
  end
end
