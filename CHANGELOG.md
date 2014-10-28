Unreleased Changes
------------------

* Documented the `rake benchmark` and `rake benchmark:cached` tasks.

* You can now disable expression caching when constructing a Runtime by
  passing `:cache_expressions => false`. Caching is still enabled by
  default.

  ```ruby
  # disable caching
  runtime = JMESPath::Runtime.new(cache_expressions: false)
  runtime.search(expression, data)
  ```

* Adding a missing require statement for Pathname to the JMESPath module.

0.9.0 (2014-10-27)
------------------

* Addded support for searching over hashes with symbolized keys and Struct
  objects indifferently

  ```ruby
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
  ```

* Added a simple thread-safe expression parser cache; This significantly speeds
  up searching multiple times with the same expression. This cache is enabled
  by default when calling `JMESPath.search`

* Added simple benchmark suite. You can execute benchmarks with with `rake benchmark`
  or `CACHE=1 rake benchmark`; Caching is disabled by default in the benchmarks.

0.2.0 (2014-10-24)
------------------

* Passing all of the JMESPath compliance tests.

