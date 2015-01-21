module JMESPath
  # @api private
  module Nodes
    class Condition < Node
      def initialize(test, child)
        @test = test
        @child = child
      end

      def visit(value)
        if @test.visit(value)
          @child.visit(value)
        else
          nil
        end
      end
    end
  end
end
