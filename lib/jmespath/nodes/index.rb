module JMESPath
  # @api private
  module Nodes
    class Index < Node
      def initialize(index)
        @index = index
      end

      def visit(value)
        if Array === value
          value[@index]
        else
          nil
        end
      end

      def chains_with?(other)
        other.is_a?(Index)
      end

      def chain(other)
        ChainedIndex.new([*indexes, *other.indexes])
      end

      protected

      def indexes
        [@index]
      end
    end

    class ChainedIndex < Index
      def initialize(indexes)
        @indexes = indexes
      end

      def visit(value)
        @indexes.reduce(value) do |v, index|
          if Array === v
            v[index]
          else
            nil
          end
        end
      end

      private

      attr_reader :indexes
    end
  end
end
