module JMESPath
  # @api private
  module Nodes
    class Pipe < Node
      def visit(value)
        @children[1].visit(@children[0].visit(value))
      end

      def to_h
        {
          :type => :pipe,
          :children => @children.map(&:to_h),
        }
      end
    end
  end
end