require 'spec_helper'

module JMESPath
  describe '.search' do

    it 'searches data' do
      expression = 'foo.bar'
      data = {'foo' => {'bar' => 'value'}}
      expect(JMESPath.search(expression, data)).to eq('value')
    end

  end
end
