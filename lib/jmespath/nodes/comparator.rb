module JMESPath
  # @api private
  module Nodes
    class Comparator < Node
      attr_reader :relation

      def initialize(children, relation)
        super(children)
        @relation = relation
      end

      def visit(value)
        left = @children[0].visit(value)
        right = @children[1].visit(value)
        case @relation
        when '==' then left == right
        when '!=' then left != right
        when '>' then left.is_a?(Integer) && right.is_a?(Integer) && left > right
        when '>=' then left.is_a?(Integer) && right.is_a?(Integer) && left >= right
        when '<' then left.is_a?(Integer) && right.is_a?(Integer) && left < right
        when '<=' then left.is_a?(Integer) && right.is_a?(Integer) && left <= right
        end
      end

      def to_h
        {
          :type => :comparator,
          :children => @children.map(&:to_h),
          :relation => @relation,
        }
      end
    end
  end
end
