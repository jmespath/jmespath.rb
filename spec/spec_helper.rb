require 'simplecov'
require 'jmespath'
require 'multi_json'
require 'rspec'

SimpleCov.command_name('test:unit')

def load_json(path)
  MultiJson.load(File.open(path, 'r', encoding:'UTF-8') { |f| f.read })
end
