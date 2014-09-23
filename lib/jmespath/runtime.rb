module JMESPath
  class Runtime

    # @option options [Parser] :parser
    # @option options [Interpreter] :interpreter
    def initialize(options = {})
      @parser = options[:parser] || Parser.new
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
