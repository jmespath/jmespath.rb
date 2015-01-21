module JMESPath
  # @api private
  module Nodes
      attr_reader :index

    class Index < Leaf
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

      def to_h
        {
          :type => :index,
          :index => @index,
        }
      end
    end
  end
end
