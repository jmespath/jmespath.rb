require 'thread'

module JMESPath
  # @api private
  class Runtime

    # @api private
    CACHE = {}

    MUTEX = Mutex.new

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
      @interpreter.visit(parse(expression), data)
    end

    private

    def parse(expression)
      if CACHE[expression]
        CACHE[expression]
      else
        MUTEX.synchronize { CACHE[expression] = @parser.parse(expression) }
      end
    end

    class << self

      # @api private
      def clear_cache
        MUTEX.synchronize { CACHE.clear }
      end

    end

  end
end
