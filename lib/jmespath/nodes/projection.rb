module JMESPath
  # @api private
  module Nodes
    class Projection < Node
      attr_reader :children, :from

      def initialize(children, from)
        @children = children
        @from = from
      end

      def visit(value)
        # Interprets a projection node, passing the values of the left
        # child through the values of the right child and aggregating
        # the non-null results into the return value.
        left = @children[0].visit(value)
        if @from == :object && hash_like?(left)
          projection(left.values)
        elsif @from == :object && left == []
          projection(left)
        elsif @from == :array && Array === left
          projection(left)
        else
          nil
        end
      end

      def to_h
        {
          :type => :projection,
          :children => @children.map(&:to_h),
          :from => @from,
        }
      end

      private

      def projection(values)
        values.inject([]) do |list, v|
          list << @children[1].visit(v)
        end.compact
      end
    end
  end
end
