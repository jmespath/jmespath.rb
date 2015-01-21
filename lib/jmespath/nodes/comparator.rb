module JMESPath
  # @api private
  module Nodes
    class Comparator < Leaf
      def initialize(left, right, relation)
        @left = left
        @right = right
        @relation = relation
      end

      def visit(value)
        left_value = @left.visit(value)
        right_value = @right.visit(value)
        case @relation
        when '==' then left_value == right_value
        when '!=' then left_value != right_value
        when '>' then left_value.is_a?(Integer) && right_value.is_a?(Integer) && left_value > right_value
        when '>=' then left_value.is_a?(Integer) && right_value.is_a?(Integer) && left_value >= right_value
        when '<' then left_value.is_a?(Integer) && right_value.is_a?(Integer) && left_value < right_value
        when '<=' then left_value.is_a?(Integer) && right_value.is_a?(Integer) && left_value <= right_value
        end
      end

      def to_h
        {
          :type => :comparator,
          :children => [@left.to_h, @right.to_h],
          :relation => @relation,
        }
      end
    end
  end
end
