Unreleased Changes
------------------

* Fix for Ruby 1.9.3. Older versions of Ruby ship with a version of the json
  gem that can not perform the following:

  ```ruby
  JSON.load('1')
  ```

  This results in the JMESPath library in assuming is parsing an unknown or
  invalid token. This works fine newer versions of Ruby. To resolve this issue
  the library is forcing a newer version of the `json` gem.

  [Fixes GitHub issue #11](https://github.com/jmespath/jmespath.rb/issues/11).

* Fix for boolean truthy checks.
  [See related GitHub issue #15](https://github.com/jmespath/jmespath.rb/pull/15).

* Updated code to pass the latest shared compliance tests.

* Added support for the `map` function.

* Added support for [JEP-9](https://github.com/jmespath/jmespath.site/blob/master/docs/proposals/improved-filters.rst),
  including unary filter expressions, and `&&` filter expressions.

1.1.3 (2015-09-16)
------------------

* Removed json gem dependency.

1.1.2 (2015-09-16)
------------------

* Resolved an issue preventing eager autoloading of comparator classes.

1.1.1 (2015-09-16)
------------------

* Fix for Ruby version 1.9.3 which does not support `#[]`
  on `Enumerable` from Ruby stdlib.

1.1.0 (2015-09-16)
------------------

* Updated the compliance tests. Pulled in the latest version from
  https://github.com/jmespath/jmespath.test/commit/47fa72339d0e5a4d0e9a12264048fc580ed0bfd8.

* Adds a new JIT-friendly interpreter and AST optimizations that evaluating
  expressions faster.

  See [related GitHub pull request](https://github.com/jmespath/jmespath.rb/pull/4).

* Removed dependency on `multi_json`.

* Now running compliance tests as part of release process.

1.0.2 (2014-12-04)
------------------

* Added a copy of the Apache 2.0 license to the project and now
  now bundling the license as part of the release.

1.0.1 (2014-10-28)
------------------

* Bug-fix, when accessing Struct objects with an invalid member
  `nil` is now returned, instead of raising an error.

1.0.0 (2014-10-28)
------------------

* The expression cache now has a maximum size.

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

