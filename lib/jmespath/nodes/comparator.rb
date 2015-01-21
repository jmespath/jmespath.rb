module JMESPath
  # @api private
  module Nodes
    class Comparator < Node
      def initialize(left, right)
        @left = left
        @right = right
      end

      def self.create(relation, left, right)
        type = begin
          case relation
          when '==' then EqComparator
          when '!=' then NeqComparator
          when '>' then GtComparator
          when '>=' then GteComparator
          when '<' then LtComparator
          when '<=' then LteComparator
          end
        end
        type.new(left, right)
      end

      def visit(value)
        check(@left.visit(value), @right.visit(value))
      end

      def optimize
        self.class.new(@left.optimize, @right.optimize)
      end

      private

      def check(left_value, right_value)
        nil
      end
    end

    class EqComparator < Comparator
      def check(left_value, right_value)
        left_value == right_value
      end
    end

    class NeqComparator < Comparator
      def check(left_value, right_value)
        left_value != right_value
      end
    end

    class GtComparator < Comparator
      def check(left_value, right_value)
        left_value.is_a?(Integer) && right_value.is_a?(Integer) && left_value > right_value
      end
    end

    class GteComparator < Comparator
      def check(left_value, right_value)
        left_value.is_a?(Integer) && right_value.is_a?(Integer) && left_value >= right_value
      end
    end

    class LtComparator < Comparator
      def check(left_value, right_value)
        left_value.is_a?(Integer) && right_value.is_a?(Integer) && left_value < right_value
      end
    end

    class LteComparator < Comparator
      def check(left_value, right_value)
        left_value.is_a?(Integer) && right_value.is_a?(Integer) && left_value <= right_value
      end
    end
  end
end
