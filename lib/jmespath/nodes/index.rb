module JMESPath
  # @api private
  module Nodes
    class Index < Field
      def initialize(index)
        super(index)
      end

      def visit(value)
        if value.is_a?(Array)
          value[@key]
        else
          nil
        end
      end
    end
  end
end
