#!/usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'jmespath'
require 'json'

expression = ARGV[0]
json = JSON.parse(STDIN.read)

$stdout.puts(JSON.dump(JMESPath.search(expression, json)))
