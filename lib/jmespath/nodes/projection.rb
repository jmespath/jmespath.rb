module JMESPath
  # @api private
  module Nodes
    class Projection < Node
      def initialize(children, from)
        super(children)
        @from = from
      end

      def visit(value)
        # Interprets a projection node, passing the values of the left
        # child through the values of the right child and aggregating
        # the non-null results into the return value.
        left = @children[0].visit(value)
        if @from == :object && hash_like?(left)
          left = left.values
        elsif !(@from == :object && left == EMPTY_ARRAY) && !(@from == :array && Array === left)
          left = nil
        end
        if left
          list = []
          left.each do |v|
            if (vv = @children[1].visit(v))
              list << vv
            end
          end
          list
        end
      end

      def to_h
        {
          :type => :projection,
          :children => @children.map(&:to_h),
          :from => @from,
        }
      end

      EMPTY_ARRAY = [].freeze
    end
  end
end
