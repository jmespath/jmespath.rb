module JMESPath
  # @api private
  module Nodes
    class Current < Node
      def visit(value)
        value
      end

      def to_h
        {
          :type => :current,
        }
      end
    end
  end
end
