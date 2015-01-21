module JMESPath
  # @api private
  module Nodes
    class Projection < Node
      def initialize(left, right, from)
        @left = left
        @right = right
        @from = from
      end

      def visit(value)
        # Interprets a projection node, passing the values of the left
        # child through the values of the right child and aggregating
        # the non-null results into the return value.
        left_value = @left.visit(value)
        if @from == :object && hash_like?(left_value)
          left_value = left_value.values
        elsif !(@from == :object && left_value == EMPTY_ARRAY) && !(@from == :array && Array === left_value)
          left_value = nil
        end
        if left_value
          list = []
          left_value.each do |v|
            if (vv = @right.visit(v))
              list << vv
            end
          end
          list
        end
      end

      def to_h
        {
          :type => :projection,
          :children => [@left.to_h, @right.to_h],
          :from => @from,
        }
      end

      EMPTY_ARRAY = [].freeze
    end
  end
end
