module JMESPath
  # @api private
  module Nodes
    class Index < Node
      def initialize(index)
        @index = index
      end

      def visit(value)
        if Array === value
          value[@index]
        else
          nil
        end
      end
    end
  end
end
