module JMESPath
  # @api private
  module Nodes
    class Field < Node
      def initialize(key)
        @key = key
        @key_sym = key.respond_to?(:to_sym) ? key.to_sym : nil
      end

      def visit(value)
        case value
        when Array
          if @key.is_a?(Integer)
            value[@key]
          end
        when Hash
          if value.key?(@key)
            value[@key]
          elsif @key_sym
            value[@key_sym]
          end
        when Struct
          if value.respond_to?(@key)
            value[@key]
          end
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
        @key_syms = keys.each_with_object({}) do |k, syms|
          if k.respond_to?(:to_sym)
            syms[k] = k.to_sym
          end
        end
      end

      def visit(value)
        @keys.reduce(value) do |value, key|
          case value
          when Array
            if key.is_a?(Integer)
              value[key]
            end
          when Hash
            if value.key?(key)
              value[key]
            elsif (sym = @key_syms[key])
              value[sym]
            end
          when Struct
            if value.respond_to?(key)
              value[key]
            end
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
