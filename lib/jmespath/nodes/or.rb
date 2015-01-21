module JMESPath
  # @api private
  module Nodes
    class Or < Leaf
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

      def to_h
        {
          :type => :or,
          :children => [@left.to_h, @right.to_h],
        }
      end
    end
  end
end
