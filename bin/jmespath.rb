#!/usr/bin/env ruby

root = File.dirname(File.dirname(__FILE__))
$:.unshift(File.join(root, 'lib'))

require 'jmespath'
require 'multi_json'

expression = ARGV[0]
json = MultiJson.load(STDIN.read)

$stdout.puts(MultiJson.dump(JMESPath.search(expression, json)))
