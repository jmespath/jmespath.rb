Next Release (TBD)
------------------

0.9.0 (2014-10-27)
------------------

* Addded support for searching over hashes with symbolized keys and Struct
  objects indifferently.

      # symbolized hash keys
      data = {
        foo: {
          bar: {
            yuck: 'value'
          }
        }
      }
      JMESPath.search('foo.bar.yuck', data)
      #=> 'value'

      # Struct objects
      data = Struct.new(:foo).new(
        Struct.new(:bar).new(
          Struct.new(:yuck).new('value')
        )
      )
      JMESPath.search('foo.bar.yuck', data)
      #=> 'value'

* Added a simple thread-safe expression parser cache; This significantly speeds
  up searching multiple times with the same expression. This cache is enabled
  by default when calling `JMESPath.search`

* Added simple benchmark suite

      # caching disabled
      rake benchmark

      # caching enabled
      CACHE=1 rake benchmark

0.2.0 (2014-10-24)
------------------

* Passing all of the JMESPath compliance tests.

