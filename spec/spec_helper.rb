# frozen_string_literal: true

# Using Bundler.require intentionally to simulate environments that have already
# required a specific version of the `json` or `json_pure` gems. The actual version
# loaded is decided by the specific gemfile being loaded from the gemfiles directory.
require 'bundler'
Bundler.require

require 'jmespath'
