module JMESPath
  # @api private
  module Nodes
    class Or < Node
      def initialize(left, right)
        @left = left
        @right = right
      end

      def visit(value)
        result = @left.visit(value)
        if result.nil? or result.empty?
          @right.visit(value)
        else
          result
        end
      end
    end
  end
end
