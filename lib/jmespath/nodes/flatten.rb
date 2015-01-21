module JMESPath
  # @api private
  module Nodes
    class Flatten < Node
      attr_reader :children

      def initialize(children)
        @children = children
      end

      def visit(value)
        value = @children[0].visit(value)
        if Array === value
          value.each_with_object([]) do |v, values|
            if Array === v
              values.concat(v)
            else
              values.push(v)
            end
          end
        else
          nil
        end
      end

      def to_h
        {
          :type => :flatten,
          :children => @children.map(&:to_h),
        }
      end
    end
  end
end
