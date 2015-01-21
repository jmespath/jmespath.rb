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
    end
  end
end
