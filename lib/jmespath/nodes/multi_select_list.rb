module JMESPath
  # @api private
  module Nodes
    class MultiSelectList < Node
      def visit(value)
        if value.nil?
          value
        else
          @children.map { |n| n.visit(value) }
        end
      end

      def to_h
        {
          :type => :multi_select_list,
          :children => @children.map(&:to_h),
        }
      end
    end
  end
end
