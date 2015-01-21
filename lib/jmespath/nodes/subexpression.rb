module JMESPath
  # @api private
  module Nodes
    class Subexpression < Node
      def initialize(left, right)
        @left = left
        @right = right
      end

      def visit(value)
        @right.visit(@left.visit(value))
      end

      def optimize
        left = @left.optimize
        right = @right.optimize
        if left.is_a?(Field) && right.is_a?(Field)
          left.chain(right)
        else
          self
        end
      end

      protected

      attr_reader :left, :right
    end
  end
end
