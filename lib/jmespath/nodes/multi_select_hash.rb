module JMESPath
  # @api private
  module Nodes
    class MultiSelectHash < Node
      def initialize(children)
        @children = children
      end

      def visit(value)
        if value.nil?
          nil
        else
          @children.each_with_object({}) do |pair, hash|
            hash[pair.key] = pair.value.visit(value)
          end
        end
      end

      class KeyValuePair
        attr_reader :key, :value

        def initialize(key, value)
          @key = key
          @value = value
        end
      end
    end
  end
end
