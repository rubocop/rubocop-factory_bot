# frozen_string_literal: true

require 'open3'

require 'bundler'
require 'bundler/gem_tasks'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  warn e.message
  warn 'Run `bundle install` to install missing gems'
  exit e.status_code
end

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

Dir['tasks/**/*.rake'].each { |t| load t }

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

desc 'Run RuboCop over this gem'
RuboCop::RakeTask.new(:internal_investigation)

desc 'Build config/default.yml'
task :build_config do
  require 'yard'

  require 'rubocop-factory_bot'
  require 'rubocop/factory_bot/config_formatter'
  require 'rubocop/factory_bot/description_extractor'

  glob = File.join('lib', 'rubocop', 'cop', 'factory_bot', '*.rb')
  YARD::Tags::Library.define_tag('Cop Safety Information', :safety)
  YARD.parse(Dir[glob], [])

  descriptions =
    RuboCop::FactoryBot::DescriptionExtractor.new(
      YARD::Registry.all(:class)
    ).to_h
  current_config = if Psych::VERSION >= '4.0.0' # RUBY_VERSION >= '3.1.0'
                     YAML.unsafe_load_file('config/default.yml')
                   else
                     YAML.load_file('config/default.yml')
                   end

  File.write(
    'config/default.yml',
    RuboCop::FactoryBot::ConfigFormatter.new(current_config, descriptions).dump
  )
end

desc 'Confirm config/default.yml is up to date'
task confirm_config: :build_config do
  _, stdout, _, process =
    Open3.popen3('git diff --exit-code config/default.yml')

  raise <<~ERROR unless process.value.success?
    default.yml is out of sync:

    #{stdout.read}
    Please run `rake build_config`
  ERROR
end

desc 'Confirm documentation is up to date'
task confirm_documentation: :generate_cops_documentation do
  _, _, _, process =
    Open3.popen3('git diff --exit-code docs/')

  unless process.value.success?
    raise 'Please run `rake generate_cops_documentation` ' \
          'and add docs/ to the commit.'
  end
end

task default: %i[build_config spec
                 internal_investigation
                 confirm_config
                 documentation_syntax_check
                 confirm_documentation]

desc 'Generate a new cop template'
task :new_cop, [:cop] do |_task, args|
  require 'rubocop'
  require_relative 'lib/rubocop/factory_bot/cop/generator'

  cop_name = args.fetch(:cop) do
    warn "usage: bundle exec rake 'new_cop[Department/Name]'"
    exit!
  end

  generator = RuboCop::FactoryBot::Cop::Generator.new(cop_name)
  generator.write_source
  generator.write_spec
  generator.inject_require(
    root_file_path: 'lib/rubocop/cop/factory_bot_cops.rb'
  )
  generator.inject_config

  puts generator.todo
end
