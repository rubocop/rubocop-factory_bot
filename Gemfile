# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'bump'
gem 'danger'
gem 'irb' # undeclared dependency of yard
gem 'rack'
gem 'rake'
gem 'rspec', '~> 3.11'

# FIXME: temporary, https://github.com/rubocop/rubocop/pull/15734
#        adds generic support for Target*Version
gem 'rubocop',
    git: 'https://github.com/koic/rubocop.git',
    branch: 'make_requires_gem_gating_go_through_target_gem_version'

gem 'rubocop-performance', '~> 1.24'
gem 'rubocop-rake', '~> 0.7'
gem 'rubocop-rspec', '~> 3.5'
gem 'rubydex', require: false, platforms: :ruby if RUBY_VERSION >= '3.2'
gem 'simplecov', '>= 0.19'
gem 'yard'

local_gemfile = 'Gemfile.local'
eval_gemfile(local_gemfile) if File.exist?(local_gemfile)
