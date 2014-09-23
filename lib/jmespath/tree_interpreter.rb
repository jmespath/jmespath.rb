module JMESPath
  class TreeInterpreter

    def visit(node, data)
      dispatch(node, data)
    end

    private

    def dispatch(node, value)
      case node[:type]

      when :field
        if hash_like?(value)
          value[node[:key]]
        else
          nil
        end

      when :subexpression
        dispatch(node[:children][1], dispatch(node[:children][0], value))

      when :index
        if array_like?(value)
          value[node[:index]]
        else
          nil
        end

      when :projection
        # Interprets a projection node, passing the values of the left
        # child through the values of the right child and aggregating
        # the non-null results into the return value.
        left = dispatch(node[:children][0], value)

        if hash_like?(left)
          values = left.values
        elsif array_like?(left)
          values = left
        else
          return nil
        end

        values.inject([]) do |list, v|
          list << dispatch(node[:children][1], v)
        end.compact

      when :flatten
        value = dispatch(node[:children][0], value)
        if array_like?(value)
          value.inject([]) do |values, v|
            values + (array_like?(v) ? v : [v])
          end
        else
          nil
        end

      when :literal
        raise NotImplementedError

      when :current
        raise NotImplementedError

      when :or
        raise NotImplementedError

      when :pipe
        raise NotImplementedError

      when :multi_select_list
        if value.nil?
          value
        else
          node[:children].inject([]) do |collected, child_node|
            collected << dispatch(child_node, value)
          end
        end

      when :multi_select_hash
        raise NotImplementedError

      when :comparator
        raise NotImplementedError

      when :condition
        raise NotImplementedError

      when :function
        raise NotImplementedError

      when :slice
        raise NotImplementedError

      when :expression
        raise NotImplementedError

      else
        raise NotImplementedError
      end
    end

    def hash_like?(value)
      Hash === value || Struct === value
    end

    def array_like?(value)
      Array === value
    end

  end
end
