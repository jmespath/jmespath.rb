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
        if node[:from] == :object && hash_like?(left)
          projection(left.values, node)
        elsif node[:from] == :array && array_like?(left)
          projection(left, node)
        else
          nil
        end

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
        node[:value]

      when :current
        value

      when :or
        result = dispatch(node[:children][0], value)
        if result.nil? or result.empty?
          dispatch(node[:children][1], value)
        else
          result
        end

      when :pipe
        dispatch(node[:children][1], dispatch(node[:children][0], value))

      when :multi_select_list
        if value.nil?
          value
        else
          node[:children].inject([]) do |collected, child_node|
            collected << dispatch(child_node, value)
          end
        end

      when :multi_select_hash
        if value.nil?
          nil
        else
          node[:children].each.with_object({}) do |child, hash|
            hash[child[:key]] = dispatch(child[:children][0], value)
          end
        end


      when :comparator
        raise NotImplementedError

      when :condition
        raise NotImplementedError

      when :function
        args = node[:children].map { |child| dispatch(child, value) }
        send("function_#{node[:fn]}", *args)

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

    def projection(values, node)
      values.inject([]) do |list, v|
        list << dispatch(node[:children][1], v)
      end.compact
    end

    def function_sort(values)
      values.sort
    end

  end
end
