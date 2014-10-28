module JMESPath
  # @api private
  class Runtime

    # @api private
    CACHING_PARSER = CachingParser.new

    # @option options [Parser,CachingParser] :parser
    # @option options [Interpreter] :interpreter
    def initialize(options = {})
      @parser = options[:parser] || CACHING_PARSER
      @interpreter = options[:interpreter] || TreeInterpreter.new
    end

    # @param [String<JMESPath>] expression
    # @param [Hash] data
    # @return [Mixed,nil]
    def search(expression, data)
      @interpreter.visit(@parser.parse(expression), data)
    end

  end
end
