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

      def to_h
        {
          :type => :condition,
          :children => [@test.to_h, @child.to_h],
        }
      end
    end
  end
end
