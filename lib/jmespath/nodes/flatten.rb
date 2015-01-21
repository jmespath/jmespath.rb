module JMESPath
  # @api private
  module Nodes
    class Flatten < Node
      def initialize(child)
        @child = child
      end

      def visit(value)
        value = @child.visit(value)
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
    end
  end
end
