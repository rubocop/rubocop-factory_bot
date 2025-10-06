# frozen_string_literal: true

module RuboCop
  module Cop
    module FactoryBot
      # Checks for redundant enum traits in FactoryBot definitions.
      #
      # @example
      #   # bad
      #   factory :task do
      #     trait :queued do
      #       status { Task.statuses[:queued] }
      #     end
      #   end
      #
      #   # good
      #   factory :task do
      #   end
      #
      class RedundantEnumTrait < Base
        extend TargetFactoryBotVersion
        extend AutoCorrector

        MSG = 'This trait is redundant because enum traits are ' \
              'automatically defined in FactoryBot 6.1 and later.'
        RESTRICT_ON_SEND = %i[trait].freeze
        minimum_target_factory_bot_version 6.1

        # @!method redundant_enum_trait_body?(node)
        def_node_matcher :redundant_enum_trait_body?, <<~PATTERN
          (block
            (send nil? $_attribute_name)
            (args)
            (send
              (send (const ...) $_enum_plural_name)
              :[]
              (sym $_enum_key_name)))
        PATTERN

        def on_send(node)
          add_offense(node)
          trait_block = node.last_argument
          return unless trait_block&.block_type?

          attribute_definition = trait_block.body
          return unless attribute_definition&.block_type?

          redundant_enum_trait_body?(attribute_definition) do |attr, enums, key|
            next unless redundant?(node.first_argument.value, attr, enums, key)

            add_offense(node) do |corrector|
              corrector.remove(node)
            end
          end
        end

        private

        def redundant?(trait_name, attribute_name, enum_plural_name,
                       enum_key_name)
          return false if trait_name != enum_key_name

          singular_enum = enum_plural_name.to_s.sub(/es$/, '').sub(/s$/, '')
          singular_enum.to_sym == attribute_name
        end
      end
    end
  end
end
