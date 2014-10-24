module JMESPath

  autoload :Errors, 'jmespath/errors'
  autoload :ExprNode, 'jmespath/expr_node'
  autoload :Lexer, 'jmespath/lexer'
  autoload :Parser, 'jmespath/parser'
  autoload :Runtime, 'jmespath/runtime'
  autoload :Token, 'jmespath/token'
  autoload :TokenStream, 'jmespath/token_stream'
  autoload :TreeInterpreter, 'jmespath/tree_interpreter'
  autoload :VERSION, 'jmespath/version'

  class << self

    # @param [String<JMESPath>] expression
    # @param [Hash] data
    # @return [Mixed,nil]
    def search(expression, data)
      Runtime.new.search(expression, data)
    end

  end
end
