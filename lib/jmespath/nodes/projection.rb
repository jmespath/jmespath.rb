module JMESPath
  # @api private
  module Nodes
    class Projection < Node
      def initialize(target, projection)
        @target = target
        @projection = projection
      end

      def visit(value)
        if (targets = extract_targets(@target.visit(value)))
          list = []
          targets.each do |v|
            if (vv = @projection.visit(v))
              list << vv
            end
          end
          list
        end
      end

      private

      def extract_targets(left_value)
        nil
      end
    end

    class ArrayProjection < Projection
      def extract_targets(target)
        if Array === target
          target
        else
          nil
        end
      end
    end

    class ObjectProjection < Projection
      EMPTY_ARRAY = [].freeze

      def extract_targets(target)
        if hash_like?(target)
          target.values
        elsif target == EMPTY_ARRAY
          EMPTY_ARRAY
        else
          nil
        end
      end
    end
  end
end
