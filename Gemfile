source 'https://rubygems.org'

gem 'rake', require: false

group :test do
  gem 'rspec', '~> 3.0'
  gem 'simplecov' unless RUBY_VERSION == '1.9.3'
end

group :docs do
  gem 'yard'
  gem 'yard-sitemap', '~> 1.0'
  gem 'rdiscount', require: false
end

group :release do
  gem 'octokit'
end

group :benchmark do
  gem 'absolute_time'
end
