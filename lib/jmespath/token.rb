module JMESPath
  class Token < Struct.new(:type, :value, :position, :binding_power)

    # @api private
    NULL_TOKEN = Token.new(:eof, '', nil)

    # binding power
    # @api private
    BINDING_POWER = Hash.new do |h,k|
      raise ArgumentError, "invalid type #{k.inspect}"
    end

    {
      :eof               => 0,
      :quoted_identifier => 0,
      :identifier        => 0,
      :rbracket          => 0,
      :rparen            => 0,
      :comma             => 0,
      :rbrace            => 0,
      :number            => 0,
      :current           => 0,
      :expref            => 0,
      :pipe              => 1,
      :comparator        => 2,
      :or                => 5,
      :flatten           => 6,
      :star              => 20,
      :dot               => 40,
      :lbrace            => 50,
      :filter            => 50,
      :lbracket          => 50,
      :lparen            => 60,
    }.each do |k,v|
      BINDING_POWER[k] = v
    end

    # @param [Symbol] :type
    # @param [Mixed] :value
    # @param [Integer] :position
    def initialize(type, value, position)
      super(type, value, position, BINDING_POWER[type])
    end

  end
end
