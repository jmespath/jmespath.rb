require 'jmespath'
require 'rspec'

begin
  require 'simplecov'
  SimpleCov.command_name('test:unit')
rescue LoadError
end

