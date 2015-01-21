module JMESPath
  # @api private
  module Nodes
    class Comparator < Node
      attr_reader :children, :relation

      def initialize(children, relation)
        @children = children
        @relation = relation
      end

      def visit(value)
        left = @children[0].visit(value)
        right = @children[1].visit(value)
        case @relation
        when '==' then compare_values(left, right)
        when '!=' then !compare_values(left, right)
        when '>' then is_int(left) && is_int(right) && left > right
        when '>=' then is_int(left) && is_int(right) && left >= right
        when '<' then is_int(left) && is_int(right) && left < right
        when '<=' then is_int(left) && is_int(right) && left <= right
        end
      end

      def to_h
        {
          :type => :comparator,
          :children => @children.map(&:to_h),
          :relation => @relation,
        }
      end

      private

      def compare_values(a, b)
        if a == b
          true
        else
          false
        end
      end

      def is_int(value)
        Integer === value
      end
    end
  end
end
