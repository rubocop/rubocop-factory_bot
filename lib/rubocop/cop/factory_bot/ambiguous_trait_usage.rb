# frozen_string_literal: true

module RuboCop
  module Cop
    module FactoryBot
      # Avoid ambiguous implicit trait usage in nested factories.
      #
      # A bare name can be read as either an implicit trait or an association.
      # This cop checks only traits declared directly in the parent factory and
      # bare calls directly in a nested factory. A bare call may still refer
      # to an association or another method, so it does not autocorrect.
      #
      # @example
      #   # bad
      #   FactoryBot.define do
      #     factory :word do
      #       trait :article do
      #         type { :article }
      #       end
      #
      #       factory :the do
      #         article
      #       end
      #     end
      #   end
      #
      #   # good
      #   FactoryBot.define do
      #     factory :word do
      #       trait :article do
      #         type { :article }
      #       end
      #
      #       # Apply the trait explicitly.
      #       factory :the, traits: [:article] do
      #         letters { 'the' }
      #       end
      #
      #       # Define an association explicitly.
      #       factory :the_with_article do
      #         association :article
      #       end
      #     end
      #   end
      class AmbiguousTraitUsage < RuboCop::Cop::Base
        include RuboCop::FactoryBot::Language

        MSG = 'Ambiguous bare call to `%<name>s`; use explicit syntax ' \
              'for its intended meaning.'

        def on_block(node)
          return unless factory_block?(node)
          return unless inside_factory_bot_definition?(node)

          traits = statements(node).filter_map do |statement|
            trait_name(statement)
          end
          return if traits.empty?

          statements(node).each do |child|
            next unless factory_block?(child)

            report_ambiguous_calls(child, traits)
          end
        end
        alias on_itblock on_block
        alias on_numblock on_block

        private

        def report_ambiguous_calls(child, traits)
          statements(child).each do |statement|
            next unless ambiguous_bare_call?(statement, traits)

            message = format(MSG, name: statement.method_name)
            add_offense(statement, message: message)
          end
        end

        def ambiguous_bare_call?(statement, traits)
          statement.send_type? && statement.receiver.nil? &&
            statement.arguments.empty? && traits.include?(statement.method_name)
        end

        def inside_factory_bot_definition?(node)
          node.each_ancestor do |ancestor|
            next unless ancestor.block_type?

            return factory_bot?(ancestor.receiver) if ancestor.method?(:define)
          end

          false
        end

        def factory_block?(node)
          node.block_type? && node.receiver.nil? &&
            node.method?(:factory) &&
            %i[sym str].include?(node.send_node.first_argument&.type)
        end

        def trait_name(statement)
          send_node = statement.block_type? ? statement.send_node : statement
          return unless send_node.send_type? && send_node.receiver.nil?
          return unless send_node.method?(:trait)

          send_node.first_argument.value if send_node.first_argument&.sym_type?
        end

        def statements(block)
          body = block.body
          return [] unless body

          body.begin_type? ? body.children : [body]
        end
      end
    end
  end
end
