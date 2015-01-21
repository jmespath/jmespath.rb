module JMESPath
  # @api private
  module Nodes
      attr_reader :value

    class Current < Leaf
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
