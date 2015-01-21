module JMESPath
  # @api private
  module Nodes
    class Field < Node
      def initialize(key)
        @key = key
      end

      def visit(value)
        case value
        when Hash then value.key?(@key) ? value[@key] : value[@key.to_sym]
        when Struct then value.respond_to?(@key) ? value[@key] : nil
        else nil
        end
      end

      def chains_with?(other)
        other.is_a?(Field)
      end

      def chain(other)
        ChainedField.new([@key, *other.keys])
      end

      protected

      def keys
        [@key]
      end
    end

    class ChainedField < Field
      def initialize(keys)
        @keys = keys
      end

      def visit(value)
        @keys.reduce(value) do |value, key|
          case value
          when Hash then value.key?(key) ? value[key] : value[key.to_sym]
          when Struct then value.respond_to?(key) ? value[key] : nil
          else nil
          end
        end
      end

      def chain(other)
        ChainedField.new([*@keys, *other.keys])
      end

      private

      attr_reader :keys
    end
  end
end
