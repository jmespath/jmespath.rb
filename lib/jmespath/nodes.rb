module JMESPath
  # @api private
  module Nodes
    class Node
      def initialize(children)
        @children = children
      end

      def visit(value)
      end

      def hash_like?(value)
        Hash === value || Struct === value
      end
    end

    class Leaf
      def visit(value)
      end
    end

    autoload :Comparator, 'jmespath/nodes/comparator'
    autoload :Condition, 'jmespath/nodes/condition'
    autoload :Current, 'jmespath/nodes/current'
    autoload :Expression, 'jmespath/nodes/expression'
    autoload :Field, 'jmespath/nodes/field'
    autoload :Flatten, 'jmespath/nodes/flatten'
    autoload :Function, 'jmespath/nodes/function'
    autoload :Index, 'jmespath/nodes/index'
    autoload :Literal, 'jmespath/nodes/literal'
    autoload :MultiSelectHash, 'jmespath/nodes/multi_select_hash'
    autoload :MultiSelectList, 'jmespath/nodes/multi_select_list'
    autoload :Or, 'jmespath/nodes/or'
    autoload :Pipe, 'jmespath/nodes/pipe'
    autoload :Projection, 'jmespath/nodes/projection'
    autoload :Slice, 'jmespath/nodes/slice'
    autoload :Subexpression, 'jmespath/nodes/subexpression'
  end
end
