module JMESPath
  # @api private
  module Nodes
    class Projection < Node
      def initialize(left, right)
        @left = left
        @right = right
      end

      def visit(value)
        # Interprets a projection node, passing the values of the left
        # child through the values of the right child and aggregating
        # the non-null results into the return value.
        if (projectees = extract_projectees(@left.visit(value)))
          list = []
          projectees.each do |v|
            if (vv = @right.visit(v))
              list << vv
            end
          end
          list
        end
      end

      private

      def extract_projectees(left_value)
        nil
      end
    end

    class ArrayProjection < Projection
      def extract_projectees(left_value)
        if Array === left_value
          left_value
        else
          nil
        end
      end
    end

    class ObjectProjection < Projection
      EMPTY_ARRAY = [].freeze

      def extract_projectees(left_value)
        if hash_like?(left_value)
          left_value.values
        elsif left_value == EMPTY_ARRAY
          left_value
        else
          nil
        end
      end
    end
  end
end
