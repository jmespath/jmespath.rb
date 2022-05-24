# frozen_string_literal: true
require 'spec_helper'

describe 'Compliance' do
  Dir.glob('spec/{compliance,legacy}/*.json').each do |path|
    test_file = File.basename(path).split('.').first
    next if test_file == 'benchmarks'
    next if ENV['TEST_FILE'] && ENV['TEST_FILE'] != test_file

    describe(test_file) do
      JMESPath.load_json(path).each do |scenario|
        describe("Given #{scenario['given'].to_json}") do
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

              it "searching #{test_case['expression'].inspect} returns #{test_case['result'].to_json}" do
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
