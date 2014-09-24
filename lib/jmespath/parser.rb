# echo '{"foo":[{"bar":1}]}' | php bin/jp.php [Versions,DeleteMarkers][].Id

module JMESPath
  class Parser

    # @api private
    AFTER_DOT = Set.new([
        :identifier,        # foo.bar
        :quoted_identifier, # foo."bar"
        :star,              # foo.*
        :lbrace,            # foo[1]
        :lbracket,          # foo{a: 0}
        :function,          # foo.*.to_string(@)
        :filter,            # foo.[?bar==10]
    ])

    CURRENT_NODE = { type: :current }

    # @option options [Lexer] :lexer
    def initialize(options = {})
      @lexer = options[:lexer] || Lexer.new()
    end

    # @param [String<JMESPath>] expression
    def parse(expression)
      stream = TokenStream.new(expression, @lexer.tokenize(expression))
puts "\n" + stream.inspect + "\n\n"
      result = expr(stream)
      if stream.token.type != :eof
        raise "expected :eof got #{stream.token.type}"
      else
        result
      end
    end

    private

    # @param [TokenStream] stream
    # @param [Integer] rbp Right binding power
    def expr(stream, rbp = 0)
puts "nud_#{stream.token.type}"
      left = send("nud_#{stream.token.type}", stream)
      while rbp < stream.token.binding_power
puts "#{rbp} #{stream.token.binding_power} led_#{stream.token.type}"
        left = send("led_#{stream.token.type}", stream, left)
      end
      left
    end

    def nud_current(stream)
      raise NotImplementedError
    end

    def nud_expref(stream)
      raise NotImplementedError
    end

    def nud_filter(stream)
      raise NotImplementedError
    end

    def nud_flatten(stream)
      raise NotImplementedError
    end

    def nud_identifier(stream)
      token = stream.token
      stream.next
      { type: :field, key: token.value }
    end

    def nud_lbrace(stream)
      raise NotImplementedError
    end

    def nud_lbracket(stream)
      stream.next
      type = stream.token.type
      if type == :number || type == :colon
        parse_array_index_expression(stream)
      elsif type == :star && stream.lookahead(1).type == :rbracket
        parse_wildcard_array(stream)
      else
        parse_multi_select_list(stream)
      end
    end

    def nud_literal(stream)
      raise NotImplementedError
    end

    def nud_quoted_identifier(stream)
      token = stream.token
      stream.next
      if token.type == :lparen
        raise 'quoted identifiers are not allowed for function names'
      else
        { type: :field, key: token[:value] }
      end
    end

    def nud_star(stream)
      raise NotImplementedError
    end

    def led_comparator(stream, left)
      raise NotImplementedError
    end

    def led_dot(stream, left)
      stream.next(match:AFTER_DOT)
      if stream.token.type == :star
        parse_wildcard_object(stream, left)
      else
        {
          type: :subexpression,
          children: [
            left,
            parse_dot(stream, Token::BINDING_POWER[:dot])
          ]
        }
      end
    end

    def led_filter(stream, left)
      raise NotImplementedError
    end

    def led_flatten(stream, left)
      stream.next
      {
        type: :projection,
        from: :array,
        children: [
          { type: :flatten, children: [left] },
          parse_projection(stream, Token::BINDING_POWER[:flatten])
        ]
      }
    end

    def led_lbracket(stream, left)
      stream.next(match: Set.new([:number, :colon, :star]))
      type = stream.token.type
      if type == :number || type == :colon
        {
          type: :subexpression,
          children: [
            left,
            parse_array_index_expression(stream)
          ]
        }
      else
        parse_wildcard_array(left)
      end
    end

    def led_lparen(stream, left)
      raise NotImplementedError
    end

    def led_or(stream, left)
      raise NotImplementedError
    end

    def led_pipe(stream, left)
      raise NotImplementedError
    end

    def parse_array_index_expression(stream)
      pos = 0
      parts = [nil, nil, nil]
      begin
        if stream.token.type == :colon
          pos += 1
        else
          parts[pos] = stream.token.value
        end
        stream.next(match:Set.new([:number, :colon, :rbracket]))
      end while stream.token.type != :rbracket
      stream.next
      if pos == 0
        { type: :index, index: parts[0] }
      elsif pos > 2
        raise NotImplementedError, "slice not supported"
      end
    end

    def parse_dot(stream, binding_power)
      if stream.token.type == :lbracket
        stream.next
        parse_multi_select_list(stream)
      else
        expr(stream, binding_power)
      end
    end

    def parse_key_value_pair(stream)
      raise NotImplementedError
    end

    def parse_multi_select_list(stream)
      children = []
      begin
        children << expr(stream)
        if stream.token.type == :comma
          stream.next
          if stream.token.type == :rbracket
            raise 'expression epxected, found rbracket'
          end
        end
      end while stream.token.type != :rbracket
      stream.next
      {
        type: :multi_select_list,
        children: children
      }
    end

    def parse_projection(stream, binding_power)
      type = stream.token.type
      if stream.token.binding_power < 10
        CURRENT_NODE
      elsif type == :dot
        stream.next(match:AFTER_DOT)
        parse_dot(stream, binding_power)
      elsif type == :lbracket || type == :filter
        expr(stream, binding_power)
      else
        raise 'syntax error after projection'
      end
    end

    def parse_wildcard_array(stream)
      raise NotImplementedError
    end

    def parse_wildcard_object(stream)
      raise NotImplementedError
    end

  end
end
