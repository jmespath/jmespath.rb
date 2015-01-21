module JMESPath
  # @api private
  module Nodes
    class Condition < Node
      attr_reader :children

      def initialize(children)
        @children = children
      end

      def visit(value)
        true == @children[0].visit(value) ?
          @children[1].visit(value) :
          nil
      end

      def to_h
        {
          :type => :condition,
          :children => @children.map(&:to_h),
        }
      end
    end
  end
end
