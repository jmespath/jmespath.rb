require 'simplecov'
require 'jmespath'
require 'rspec'

SimpleCov.command_name('test:compliance')

describe 'Compliance' do
  Dir.glob('spec/compliance/*.json').each do |path|
    describe(File.basename(path).split('.').first) do
      JMESPath.load_json(path).each do |scenario|
        describe("Given #{JSON.dump(scenario['given'])}") do
          scenario['cases'].each do |test_case|

            if test_case['error']

              it "the expression #{test_case['expression'].inspect} raises a #{test_case['error']} error" do

                error_class = case test_case['error']
                  when 'runtime' then JMESPath::Errors::RuntimeError
                  when 'syntax' then JMESPath::Errors::SyntaxError
                  when 'invalid-type' then JMESPath::Errors::InvalidTypeError
                  when 'invalid-value' then JMESPath::Errors::InvalidValueError
                  when 'invalid-arity' then JMESPath::Errors::InvalidArityError
                  when 'unknown-function' then JMESPath::Errors::UnknownFunctionError
                  else raise "unhandled error type #{test_case['error']}"
                end

                raised = nil
                begin
                  JMESPath.search(test_case['expression'], scenario['given'])
                rescue JMESPath::Errors::Error => error
                  raised = error
                end

                expect(raised).to be_kind_of(error_class)
              end

            else

              it "searching #{test_case['expression'].inspect} returns #{JSON.dump(test_case['result'])}" do
                result = JMESPath.search(test_case['expression'], scenario['given'])
                expect(result).to eq(test_case['result'])
              end

            end
          end
        end
      end
    end
  end
end
