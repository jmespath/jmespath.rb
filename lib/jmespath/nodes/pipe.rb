module JMESPath
  # @api private
  module Nodes
    class Pipe < Node
      def initialize(left, right)
        @left = left
        @right = right
      end

      def visit(value)
        @right.visit(@left.visit(value))
      end
    end
  end
end
