module JMESPath
  # @api private
  module Nodes
    class MultiSelectHash < Node
      attr_reader :children

      def initialize(children)
        @children = children
      end

      def visit(value)
        if value.nil?
          nil
        else
          @children.each.with_object({}) do |child, hash|
            hash[child.key] = child.children[0].visit(value)
          end
        end
      end

      def to_h
        {
          :type => :multi_select_hash,
          :children => @children.map(&:to_h),
        }
      end

      class KeyValuePair
        attr_reader :children, :key

        def initialize(children, key)
          @children = children
          @key = key
        end

        def to_h
          {
            :type => :key_value_pair,
            :children => @children.map(&:to_h),
            :key => @key,
          }
        end
      end
    end
  end
end
