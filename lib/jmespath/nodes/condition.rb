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

      def optimize
        test = @test.optimize
        if (new_type = ComparatorCondition::COMPARATOR_TO_CONDITION[@test.class])
          new_type.new(test.left, test.right, @child).optimize
        else
          self.class.new(test, @child.optimize)
        end
      end
    end

    class ComparatorCondition < Node
      COMPARATOR_TO_CONDITION = {}

      def initialize(left, right, child)
        @left = left
        @right = right
        @child = child
      end

      def visit(value)
        nil
      end
    end

    class EqCondition < ComparatorCondition
      COMPARATOR_TO_CONDITION[EqComparator] = self

      def visit(value)
        @left.visit(value) == @right.visit(value) ? @child.visit(value) : nil
      end
    end

    class NeqCondition < ComparatorCondition
      COMPARATOR_TO_CONDITION[NeqComparator] = self

      def visit(value)
        @left.visit(value) != @right.visit(value) ? @child.visit(value) : nil
      end
    end

    class GtCondition < ComparatorCondition
      COMPARATOR_TO_CONDITION[GtComparator] = self

      def visit(value)
        left_value = @left.visit(value)
        right_value = @right.visit(value)
        left_value.is_a?(Integer) && right_value.is_a?(Integer) && left_value > right_value ? @child.visit(value) : nil
      end
    end

    class GteCondition < ComparatorCondition
      COMPARATOR_TO_CONDITION[GteComparator] = self

      def visit(value)
        left_value = @left.visit(value)
        right_value = @right.visit(value)
        left_value.is_a?(Integer) && right_value.is_a?(Integer) && left_value >= right_value ? @child.visit(value) : nil
      end
    end

    class LtCondition < ComparatorCondition
      COMPARATOR_TO_CONDITION[LtComparator] = self

      def visit(value)
        left_value = @left.visit(value)
        right_value = @right.visit(value)
        left_value.is_a?(Integer) && right_value.is_a?(Integer) && left_value < right_value ? @child.visit(value) : nil
      end
    end

    class LteCondition < ComparatorCondition
      COMPARATOR_TO_CONDITION[LteComparator] = self

      def visit(value)
        left_value = @left.visit(value)
        right_value = @right.visit(value)
        left_value.is_a?(Integer) && right_value.is_a?(Integer) && left_value <= right_value ? @child.visit(value) : nil
      end
    end
  end
end
