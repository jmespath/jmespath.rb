# frozen_string_literal: true
require 'thread'

module JMESPath
  # @api private
  class CachingRuntime < Runtime
    def initialize(options = {})
      super(options.merge(cache_expressions: false))
      @mutex = Mutex.new
      @cache = {}
    end

    def search(expression, data)
      if cached = @cache[expression]
        cached.visit(data)
      else
        cache_expression(expression).visit(data)
      end
    end

    private

    def cache_expression(expression)
      @mutex.synchronize do
        @cache.clear if @cache.size > 1000
        @cache[expression] ||= @parser.parse(expression).optimize
      end
    end
  end
end
