require 'spec_helper'

module JMESPath
  describe '.search' do

    it 'searches data' do
      expression = 'foo.bar'
      data = {'foo' => {'bar' => 'value'}}
      expect(JMESPath.search(expression, data)).to eq('value')
    end

    it 'accepts data as a Pathname' do
      file_path = File.join(File.dirname(__FILE__), 'fixtures', 'sample.json')
      file_path = Pathname.new(file_path)
      expect(JMESPath.search('foo.*.baz', file_path)).to eq([1,2,3])
    end

    it 'accepts data as an IO object' do
      file_path = File.join(File.dirname(__FILE__), 'fixtures', 'sample.json')
      File.open(file_path, 'r') do |file|
        expect(JMESPath.search('foo.*.baz', file)).to eq([1,2,3])
      end
    end

    it 'accepts data as an Struct' do
      data = Struct.new(:foo).new(Struct.new(:bar).new('baz'))
      expect(JMESPath.search('foo.bar', data)).to eq('baz')
    end

    it 'supports bare JSON literals' do
      # this is problematic in older Ruby versions that ship with
      # older versions of the json gem. This will only work
      # with version 1.8.1+ of the json gem.
      expect(JMESPath.search('`1` < `2`', {})).to be(true)
    end

  end
end
