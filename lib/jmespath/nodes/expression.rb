module JMESPath
  # @api private
  module Nodes
    class Expression < Node
      attr_reader :children

      def initialize(children)
        @children = children
      end

      def visit(value)
        ExprNode.new(@children[0])
      end

      def to_h
        {
          :type => :expression,
          :children => @children.map(&:to_h),
        }
      end

      class ExprNode
        attr_reader :node

        def initialize(node)
          @node = node
        end
      end
    end
  end
end

