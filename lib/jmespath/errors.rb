module JMESPath
  module Errors

    class Error < StandardError; end

    class RuntimeError < Error; end

    class SyntaxError < Error; end

    class InvalidType < Error; end

    class InvalidArity < Error; end

    class UnknownFunction < Error; end

  end
end
