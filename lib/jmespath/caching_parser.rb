require 'thread'

module JMESPath
  class CachingParser

    def initialize(options = {})
      @parser = options[:parser] || Parser.new(options)
      @mutex = Mutex.new
      @cache = {}
    end

    def parse(expression)
      if cached = @cache[expression]
        cached
      else
        @mutex.synchronize { @cache[expression] = @parser.parse(expression) }
      end
    end

  end
end
