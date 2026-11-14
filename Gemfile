# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'bump'
gem 'danger'
gem 'rack'
gem 'rake'
gem 'rspec', '~> 3.11'
gem 'rubocop-performance', '~> 1.24'
gem 'rubocop-rake', '~> 0.7'
gem 'rubocop-rspec', '~> 3.5'
gem 'rubydex', require: false, platforms: :ruby if RUBY_VERSION >= '3.2'
gem 'simplecov', '>= 1.3' if RUBY_VERSION >= '3.3'
gem 'yard'

local_gemfile = 'Gemfile.local'
eval_gemfile(local_gemfile) if File.exist?(local_gemfile)
