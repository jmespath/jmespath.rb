module JMESPath
  # @api private
  module Nodes
    class Subexpression < Leaf
      def initialize(left, right)
        @left = left
        @right = right
      end

      def visit(value)
        @right.visit(@left.visit(value))
      end

      def to_h
        {
          :type => :subexpression,
          :children => [@left.to_h, @right.to_h],
        }
      end
    end
  end
end
