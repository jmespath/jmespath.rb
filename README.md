jmespath.rb
===========
[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/trevorrowe/jmespath.rb?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) [![Build Status](https://travis-ci.org/trevorrowe/jmespath.rb.png?branch=master)](https://travis-ci.org/trevorrowe/jmespath.rb)

An implementation of [JMESPath](https://github.com/boto/jmespath) for Ruby.

## Basic Usage

`JMESPath.search` evalues a valid [JMESPath](https://github.com/boto/jmespath)
expression against a Ruby hash object returning the results.

```ruby
require 'jmespath'

JMESPath.search('foo.bar', { "foo" => { "bar" => "yuck" }})
#=> "yuck"
```
