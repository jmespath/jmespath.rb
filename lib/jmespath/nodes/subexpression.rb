module JMESPath
  # @api private
  module Nodes
    class Subexpression < Node
      attr_reader :children

      def initialize(children)
        @children = children
      end

      def visit(value)
        @children[1].visit(@children[0].visit(value))
      end

      def to_h
        {
          :type => :subexpression,
          :children => @children.map(&:to_h),
        }
      end
    end
  end
end
