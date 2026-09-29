# frozen_string_literal: true

module RuboCop
  module Cop
    module FactoryBot
      # Avoid hard-coding the strategy when defining an association.
      #
      # @safety
      #   This cop's autocorrection is unsafe because it changes the strategy.
      #
      # @example
      #   # bad
      #   factory :article do
      #     user { create(:user) }
      #   end
      #
      #   # good - implicit
      #   factory :article do
      #     user
      #   end
      #
      #   # good - explicit
      #   factory :article do
      #     association :user
      #   end
      #
      #   # good - inline
      #   factory :article do
      #     user { association(:user) }
      #   end
      class FactoryAssociationWithStrategy < RuboCop::Cop::Base
        extend AutoCorrector
        include RuboCop::FactoryBot::Language

        MSG = 'Avoid hard-coding the strategy when defining an association.'

        BUILD_METHOD_NAMES = %i[
          build
          build_stubbed
          create
        ].to_set.freeze

        # @!method factory_or_trait_declaration?(node)
        def_node_matcher :factory_or_trait_declaration?, <<~PATTERN
          (any_block (send nil? {:factory :trait} ...)
            ...
          )
        PATTERN

        # @!method hardcoded_association(node)
        def_node_matcher :hardcoded_association, <<~PATTERN
          (block
            (send nil? !#reserved_method?)
            (args)
            < $(send {nil? #factory_bot?} BUILD_METHOD_NAMES ...) ... >
          )
        PATTERN

        def on_block(node) # rubocop:disable InternalAffairs/NumblockHandler
          return unless factory_or_trait_declaration?(node)

          node.each_node do |factory_descendant|
            build_node = hardcoded_association(factory_descendant)
            next unless build_node
            next if inside_transient?(factory_descendant)

            add_offense(build_node) do |corrector|
              autocorrect(corrector, build_node)
            end
          end
        end
        alias on_itblock on_block

        def inside_transient?(node)
          node.each_ancestor.any? do |ancestor|
            ancestor.any_block_type? && ancestor.method?(:transient)
          end
        end

        def reserved_method?(method_name)
          RuboCop::FactoryBot.reserved_methods.include?(method_name)
        end

        def autocorrect(corrector, node)
          corrector.replace(
            node.source_range.with(end_pos: node.location.selector.end_pos),
            'association'
          )
        end
      end
    end
  end
end
