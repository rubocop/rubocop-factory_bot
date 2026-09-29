# frozen_string_literal: true

module RuboCop
  module Cop
    module FactoryBot
      # Use shorthands from `FactoryBot::Syntax::Methods` in your specs.
      #
      # @safety
      #   The autocorrection is marked as unsafe because the cop
      #   cannot verify whether you already include
      #   `FactoryBot::Syntax::Methods` in your test suite.
      #   It also stops at intervening class, module, and `Class.new` scopes,
      #   where the shorthand methods may not be available.
      #
      #   If you're using Rails, add the following configuration to
      #   `spec/support/factory_bot.rb` and be sure to require that file in
      #   `rails_helper.rb`:
      #
      #   [source,ruby]
      #   ----
      #   RSpec.configure do |config|
      #     config.include FactoryBot::Syntax::Methods
      #   end
      #   ----
      #
      #   If you're not using Rails:
      #
      #   [source,ruby]
      #   ----
      #   RSpec.configure do |config|
      #     config.include FactoryBot::Syntax::Methods
      #
      #     config.before(:suite) do
      #       FactoryBot.find_definitions
      #     end
      #   end
      #   ----
      #
      #   For Minitest, include the module in your test base class:
      #
      #   [source,ruby]
      #   ----
      #   ActiveSupport::TestCase.include FactoryBot::Syntax::Methods
      #   ----
      #
      # @example
      #   # bad
      #   FactoryBot.create(:bar)
      #   FactoryBot.build(:bar)
      #   FactoryBot.attributes_for(:bar)
      #
      #   # good
      #   create(:bar)
      #   build(:bar)
      #   attributes_for(:bar)
      #
      class SyntaxMethods < RuboCop::Cop::Base
        extend AutoCorrector
        include RangeHelp
        include RuboCop::FactoryBot::Language

        MSG = 'Use `%<method>s` from `FactoryBot::Syntax::Methods`.'

        RESTRICT_ON_SEND = RuboCop::FactoryBot::Language::METHODS

        # @!method spec_group?(node)
        def_node_matcher :spec_group?, <<~PATTERN
          (block
            (send
              {(const {nil? cbase} :RSpec) nil?}
              {
                :describe :context :feature :example_group
                :xdescribe :xcontext :xfeature
                :fdescribe :fcontext :ffeature
                :shared_examples :shared_examples_for
                :shared_context
              }
            ...)
          ...)
        PATTERN

        # @!method minitest_class?(node)
        def_node_matcher :minitest_class?, <<~PATTERN
          (class _ {
            (const (const {nil? cbase} :ActiveSupport) :TestCase)
            (const (const {nil? cbase} :Minitest) :Test)
          } ...)
        PATTERN

        # @!method class_new_block?(node)
        def_node_matcher :class_new_block?, <<~PATTERN
          (any_block (send (const {nil? cbase} :Class) :new ...) ...)
        PATTERN

        def on_send(node)
          return unless factory_bot?(node.receiver)

          return unless inside_spec_context?(node)

          message = format(MSG, method: node.method_name)

          add_offense(crime_scene(node), message: message) do |corrector|
            corrector.remove(offense(node))
          end
        end

        private

        def crime_scene(node)
          range_between(
            node.source_range.begin_pos,
            node.loc.selector.end_pos
          )
        end

        def offense(node)
          range_between(
            node.source_range.begin_pos,
            node.loc.selector.begin_pos
          )
        end

        def inside_spec_context?(node)
          node.each_ancestor do |parent|
            return true if spec_group?(parent) || minitest_class?(parent)
            if parent.type?(:class, :module) || class_new_block?(parent)
              return false
            end
          end

          false
        end
      end
    end
  end
end
