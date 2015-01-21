module JMESPath
  # @api private
  module Nodes
    class Literal < Node
      def initialize(value)
        @value = value
      end

      def visit(value)
        @value
      end
    end
  end
end
