module JMESPath
  # @api private
  class Runtime

    # @api private
    CACHING_PARSER = CachingParser.new

    # Constructs a new runtime object for evaluating JMESPath expressions.
    #
    #     runtime = JMESPath::Runtime.new
    #     runtime.search(expression, data)
    #     #=> ...
    #
    # ## Caching
    #
    # When constructing a {Runtime}, the default parser caches expressions.
    # This significantly speeds up calls to {#search} multiple times
    # with the same expression but different data. To disable caching, pass
    # your own instance of {Parser}.
    #
    # @example Caching enabled
    #
    #   runtime = JMESPath::Runtime.new
    #   runtime.parser
    #   #=> #<JMESPath::CachingParser ...>
    #
    # @example Caching disabled
    #
    #   runtime = JMESPath::Runtime.new(parser: JMESPath::Parser.new)
    #   runtime.parser
    #   #=> #<JMESPath::Parser ...>
    #
    # @option options [Parser,CachingParser] :parser
    # @option options [Interpreter] :interpreter
    def initialize(options = {})
      @parser = options[:parser] || CACHING_PARSER
      @interpreter = options[:interpreter] || TreeInterpreter.new
    end

    # @return [Parser, CachingParser]
    attr_reader :parser

    # @return [Interpreter]
    attr_reader :interpreter

    # @param [String<JMESPath>] expression
    # @param [Hash] data
    # @return [Mixed,nil]
    def search(expression, data)
      @interpreter.visit(@parser.parse(expression), data)
    end

  end
end
