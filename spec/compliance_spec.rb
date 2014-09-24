require 'spec_helper'

describe 'Compliance' do
  Dir.glob('spec/compliance/*.json').each do |path|

    next unless path.match(/basic/)

    describe(File.basename(path).split('.').first) do
      load_json(path).each do |scenario|
        describe("Given #{scenario['given'].inspect}") do
          scenario['cases'].each do |test_case|

            it "searching #{test_case['expression'].inspect} returns #{test_case['result'].inspect}" do

              result = JMESPath.search(test_case['expression'], scenario['given'])
              expect(result).to eq(test_case['result'])
            end

          end
        end
      end
    end
  end
end
