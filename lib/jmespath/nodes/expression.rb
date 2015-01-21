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
    end
  end
end

