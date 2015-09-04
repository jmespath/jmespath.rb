module JMESPath
  class OptimizingParser

    def initialize(parser)
      @parser = parser
    end

    def parse(expression)
      @parser.parse(expression).optimize
    end
  end
end
