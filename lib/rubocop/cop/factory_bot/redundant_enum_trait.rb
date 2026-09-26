# frozen_string_literal: true

module RuboCop
  module Cop
    module FactoryBot
      # Checks for redundant enum traits in FactoryBot definitions.
      #
      # Since factory_bot 6.0, traits for Active Record enums are defined
      # automatically, so a trait that only assigns the enum attribute the
      # value of the same name is redundant.
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
      class RedundantEnumTrait < RuboCop::Cop::Base
        extend TargetFactoryBotVersion
        extend AutoCorrector
        include RangeHelp

        MSG = 'This trait is redundant because enum traits are ' \
              'automatically defined.'
        RESTRICT_ON_SEND = %i[trait].freeze

        minimum_target_factory_bot_version 6.0

        # @!method enum_trait(node)
        def_node_matcher :enum_trait, <<~PATTERN
          (block
            (send nil? :trait (sym $_trait_name))
            (args)
            (block
              (send nil? $_attribute)
              (args)
              (send
                (send (const ...) $_enum_plural)
                :[]
                (sym $_enum_key))))
        PATTERN

        def on_send(node)
          trait = node.block_node
          return unless trait

          enum_trait(trait) do |trait_name, attribute, enum_plural, enum_key|
            next unless trait_name == enum_key
            next unless pluralized(attribute).include?(enum_plural)

            register_offense(trait)
          end
        end

        private

        def register_offense(node)
          add_offense(node) do |corrector|
            range_to_remove = range_by_whole_lines(
              node.source_range,
              include_final_newline: true
            )

            corrector.remove(range_to_remove)
          end
        end

        # Both plural forms are accepted, to tell `status`/`statuses` and
        # `state`/`states` apart without depending on an inflector.
        def pluralized(attribute)
          [:"#{attribute}s", :"#{attribute}es"]
        end
      end
    end
  end
end
