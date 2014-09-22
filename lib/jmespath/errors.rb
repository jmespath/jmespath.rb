module JMESPath
  module Errors

    class SyntaxError < ::SyntaxError

      # @param [String] message
      # @param [String<JMESPath>] expression
      # @param [Integer] offset
      def initialize(message, expression, offset)
        @expression = expression
        @offset = offset
        super(message)
      end

      # @return [String<JMESPath>]
      attr_reader :expression

      # @return [Integer]
      attr_reader :expression

    end
  end

end
