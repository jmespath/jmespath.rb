module JMESPath
  # @api private
  module Nodes
    class Expression < Node
      attr_reader :node

      def initialize(node)
        @node = node
      end

      def visit(value)
        self
      end

      def to_h
        {
          :type => :expression,
          :children => @children.map(&:to_h),
        }
      end
    end
  end
end

