module JMESPath
  # @api private
  module Nodes
    class Expression < Node
      attr_reader :expression

      def initialize(expression)
        @expression = expression
      end

      def visit(value)
        self
      end

      def eval(value)
        @expression.visit(value)
      end
    end
  end
end

