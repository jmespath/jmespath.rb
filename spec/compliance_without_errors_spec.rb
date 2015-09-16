require 'simplecov'
require 'jmespath'
require 'rspec'

SimpleCov.command_name('test:compliance')

describe 'Compliance' do
  PARSER = JMESPath::Parser.new(:disable_visit_errors => true)
  Dir.glob('spec/compliance/*.json').each do |path|
    describe(File.basename(path).split('.').first) do
      JMESPath.load_json(path).each do |scenario|
        describe("Given #{scenario['given'].inspect}") do
          scenario['cases'].each do |test_case|

            if test_case['error']

              if %w[invalid-type invalid-arity].include?(test_case['error'])
                it "the expression #{test_case['expression'].inspect} returns nil if disable_visit_errors is true" do

                  result = PARSER.parse(test_case['expression']).visit(scenario['given'])
                  expect(result).to be_nil
                end
              else
                it "the expression #{test_case['expression'].inspect} raises a #{test_case['error']} error when parsing even if disable_visit_errors is true" do

                  error_class = case test_case['error']
                    when 'syntax' then JMESPath::Errors::SyntaxError
                    when 'invalid-value' then JMESPath::Errors::InvalidValueError
                    when 'unknown-function' then JMESPath::Errors::UnknownFunctionError
                    else raise "unhandled error type #{test_case['error']}"
                  end

                  raised = nil
                  begin
                    PARSER.parse(test_case['expression']).visit(scenario['given'])
                  rescue JMESPath::Errors::Error => error
                    raised = error
                  end

                  expect(raised).to be_kind_of(error_class)
                end
              end
            end
          end
        end
      end
    end
  end
end
