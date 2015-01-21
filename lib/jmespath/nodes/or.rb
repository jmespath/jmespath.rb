module JMESPath
  # @api private
  module Nodes
    class Or < Node
      def visit(value)
        result = @children[0].visit(value)
        if result.nil? or result.empty?
          @children[1].visit(value)
        else
          result
        end
      end

      def to_h
        {
          :type => :or,
          :children => @children.map(&:to_h),
        }
      end
    end
  end
end
