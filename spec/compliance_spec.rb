require 'spec_helper'

describe 'Compliance' do
  Dir.glob('spec/compliance/*.json').each do |path|

    next unless [
     'basic',
     'escape',
      #'filters',
      #'functions',
     'identifiers',
     'indices',
      'literal',
      'multiselect',
      'ormatch',
      'pipes',
      'slice',
      #'syntax',
      'unicode',
      'wildcard',
    ].any? { |type| path.match(type) }

    describe(File.basename(path).split('.').first) do
      load_json(path).each do |scenario|
        describe("Given #{scenario['given'].inspect}") do
          scenario['cases'].each do |test_case|

            it "searching #{test_case['expression'].inspect} returns #{test_case['result'].inspect} #{test_case['error']}" do

              begin
                result = JMESPath.search(test_case['expression'], scenario['given'])
                expect(result).to eq(test_case['result'])
              rescue JMESPath::Errors::RuntimeError
                expect(test_case['error']).to eq('runtime')
              rescue JMESPath::Errors::SyntaxError
                expect(test_case['error']).to eq('syntax')
              rescue JMESPath::Errors::InvalidType
                expect(test_case['error']).to eq('invalid-type')
              rescue JMESPath::Errors::InvalidArity
                expect(test_case['error']).to eq('invalid-arity')
              rescue JMESPath::Errors::UnknownFunction
                expect(test_case['error']).to eq('unknown-function')
              end
            end

          end
        end
      end
    end
  end
end
