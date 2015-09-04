module JMESPath
  # @api private
  class Runtime

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
    # `:cache_expressions => false` to the constructor or pass a custom
    # `:parser`.
    #
    # ## Optimizing
    #
    # By default the runtime will perform optimizations on the expression to
    # try to make it run searches as fast as possible. If all your searches
    # use different expressions this might not be worth the extra work, so you
    # can disable the optimizer by passing `:optimize_expression => false`. If
    # you disable caching it is also recommended that you disable optimizations,
    # but you don't have to The optimizer will be disabled if you pass a custom
    # parser with the `:parser` option.
    #
    # @example Re-use a Runtime, caching enabled by default
    #
    #   runtime = JMESPath::Runtime.new
    #   runtime.parser
    #   #=> #<JMESPath::CachingParser ...>
    #
    # @example Disable caching
    #
    #   runtime = JMESPath::Runtime.new(cache_expressions: false)
    #   runtime.parser
    #   #=> #<JMESPath::Parser ...>
    #
    # @option options [Boolean] :cache_expressions (true) When `false`, a non
    #   caching parser will be used. When `true`, a shared instance of
    #   {CachingParser} is used.  Defaults to `true`.
    #
    # @option options [Boolean] :optimize_expressions (true) When `false`,
    #   no additional optimizations will be performed on the expression,
    #   when `true` the expression will be analyzed and optimized. This
    #   increases the time it takes to parse, but improves the speed of
    #   searches, so it's highly recommended if you're using the same expression
    #   multiple times and have not disabled caching. Defaults to `true`.
    #
    # @option options [Parser] :parser
    #
    def initialize(options = {})
      @parser = options[:parser] || create_parser(options)
    end

    # @return [Parser]
    attr_reader :parser

    # @param [String<JMESPath>] expression
    # @param [Hash] data
    # @return [Mixed,nil]
    def search(expression, data)
      @parser.parse(expression).visit(data)
    end

    private

    def create_parser(options)
      parser = Parser.new
      unless options[:optimize_expression] == false
        parser = OptimizingParser.new(parser)
      end
      unless options[:cache_expressions] == false
        parser = CachingParser.new(parser)
      end
      parser
    end

  end
end
