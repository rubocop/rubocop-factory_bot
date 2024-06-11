# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'rubocop/factory_bot/version'

Gem::Specification.new do |spec|
  spec.name = 'rubocop-factory_bot'
  spec.summary = 'Code style checking for factory_bot files'
  spec.description = <<~DESCRIPTION
    Code style checking for factory_bot files.
    A plugin for the RuboCop code style enforcing & linting tool.
  DESCRIPTION
  spec.homepage = 'https://github.com/rubocop/rubocop-factory_bot'
  spec.authors = ['John Backus', 'Ian MacLeod', 'Phil Pirozhkov',
                  'Maxim Krizhanovsky', 'Andrew Bromwich']
  spec.licenses = ['MIT']

  spec.version = RuboCop::FactoryBot::Version::STRING
  spec.platform = Gem::Platform::RUBY
  spec.required_ruby_version = '>= 2.7.0'

  spec.require_paths = ['lib']
  spec.files = Dir[
    'lib/**/*',
    'config/*',
    '*.md'
  ]
  spec.extra_rdoc_files = ['MIT-LICENSE.md', 'README.md']

  spec.metadata = {
    'changelog_uri' => 'https://github.com/rubocop/rubocop-factory_bot/blob/master/CHANGELOG.md',
    'documentation_uri' => 'https://docs.rubocop.org/rubocop-factory_bot/',
    'rubygems_mfa_required' => 'true'
  }

  spec.add_runtime_dependency 'rubocop', '~> 1.61'
end
