# frozen_string_literal: true

require 'rubocop'
require 'rubocop/rspec/support' # `expect_offense` etc

require 'simplecov' unless ENV['NO_COVERAGE']

module SpecHelper
  ROOT = Pathname.new(__dir__).parent.freeze
end

spec_helper_glob =
  '{support,shared,../lib/rubocop/factory_bot/shared_contexts}/*.rb'
Dir
  .glob(File.expand_path(spec_helper_glob, __dir__))
  .sort
  .each { |file| require file }

RSpec.configure do |config|
  # Set metadata so smoke tests are run on all cop specs
  config.define_derived_metadata(file_path: %r{/spec/rubocop/cop/}) do |meta|
    meta[:type] = :cop_spec
  end

  # Include config shared context for all cop specs
  config.define_derived_metadata(type: :cop_spec) do |meta|
    meta[:config] = true
  end

  config.order = :random

  # Run focused tests with `fdescribe`, `fit`, `:focus` etc.
  config.filter_run_when_matching :focus

  if ENV['PARSER_ENGINE'] == 'parser_prism'
    config.filter_run_excluding broken_on: :prism
  end

  # We should address configuration warnings when we upgrade
  config.raise_errors_for_deprecations!

  # RSpec gives helpful warnings when you are doing something wrong.
  # We should take their advice!
  config.raise_on_warning = true
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubocop-factory_bot'
require_relative 'support/shared_contexts'
