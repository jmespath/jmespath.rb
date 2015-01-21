module JMESPath
  # @api private
  module Nodes
      attr_reader :value

    class Literal < Leaf
      def initialize(value)
        @value = value
      end

      def visit(value)
        @value
      end

      def to_h
        {
          :type => :literal,
          :value => @value,
        }
      end
    end
  end
end
