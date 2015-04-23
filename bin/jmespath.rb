#!/usr/bin/env ruby

root = File.dirname(File.dirname(__FILE__))
$:.unshift(File.join(root, 'lib'))

require 'jmespath'
require 'json'

expression = ARGV[0]
json = JSON.load(STDIN.read)

$stdout.puts(JSON.dump(JMESPath.search(expression, json)))
