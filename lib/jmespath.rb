if Object.const_defined?(:JSON) && JSON::VERSION < '1.8.1'
  warn("WARNING: jmespath gem requires json gem >= 1.8.1; json #{JSON::VERSION} already loaded")
else
  begin
    # Attempt to load the native version if available, not availble
    # by default for Ruby 1.9.3.
    gem('json', '>= 1.8.1')
    require 'json'
  rescue Gem::LoadError
    # Fallback on the json_pure gem dependency.
    gem('json_pure', '>= 1.8.1')
    require 'json'
  end
end

require 'stringio'
require 'pathname'

module JMESPath

  autoload :CachingParser, 'jmespath/caching_parser'
  autoload :Errors, 'jmespath/errors'
  autoload :ExprNode, 'jmespath/expr_node'
  autoload :Lexer, 'jmespath/lexer'
  autoload :Nodes, 'jmespath/nodes'
  autoload :Parser, 'jmespath/parser'
  autoload :Runtime, 'jmespath/runtime'
  autoload :Token, 'jmespath/token'
  autoload :TokenStream, 'jmespath/token_stream'
  autoload :Util, 'jmespath/util'
  autoload :VERSION, 'jmespath/version'

  class << self

    # @param [String] expression A valid
    #   [JMESPath](https://github.com/boto/jmespath) expression.
    # @param [Hash] data
    # @return [Mixed,nil] Returns the matched values. Returns `nil` if the
    #   expression does not resolve inside `data`.
    def search(expression, data, runtime_options = {})
      data = case data
        when Hash, Struct then data # check for most common case first
        when Pathname then load_json(data)
        when IO, StringIO then JSON.load(data.read)
        else data
        end
      Runtime.new(runtime_options).search(expression, data)
    end

    # @api private
    def load_json(path)
      JSON.load(File.open(path, 'r', encoding: 'UTF-8') { |f| f.read })
    end

  end
end
