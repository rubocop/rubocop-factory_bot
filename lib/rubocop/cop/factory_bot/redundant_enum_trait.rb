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
      # @safety
      #   This cop cannot detect when automatic enum traits are disabled.
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
        extend AutoCorrector
        include RangeHelp

        MSG = 'This trait is redundant because enum traits are ' \
              'automatically defined.'
        RESTRICT_ON_SEND = %i[trait].freeze
        MINIMUM_FACTORY_BOT_VERSION = Gem::Version.new('6.0')

        # @!method enum_trait(node)
        def_node_matcher :enum_trait, <<~PATTERN
          (block
            (send nil? :trait (sym $_trait_name))
            (args)
            (block
              (send nil? $_attribute)
              (args)
              (send
                (send $(const ...) $_enum_plural)
                :[]
                (sym $_enum_key))))
        PATTERN

        def on_send(node)
          return if target_factory_bot_version < MINIMUM_FACTORY_BOT_VERSION

          trait = node.block_node
          return unless trait

          enum_trait(trait) do |trait_name, attribute, model, plural, key|
            next unless trait_name == key
            next unless pluralized(attribute).include?(plural)
            next unless factory_for_model?(trait, model)

            register_offense(trait)
          end
        end

        private

        def target_factory_bot_version
          configured = config.for_all_cops['TargetFactoryBotVersion']
          version = configured || target_gem_version('factory_bot') || '6.0'
          Gem::Version.new(version.to_s)
        end

        def factory_for_model?(trait, model)
          factory = trait.each_ancestor(:block).find do |ancestor|
            ancestor.method?(:factory)
          end
          return false unless factory

          call = factory.send_node
          return false unless call.arguments.one?
          return false unless call.first_argument.sym_type?

          call.first_argument.value.to_s == inferred_factory_name(model)
        end

        def inferred_factory_name(model)
          name = model.source.gsub('::', '/')
          name = name.gsub(/([A-Z]+)([A-Z][a-z])/, '\\1_\\2')
          name.gsub(/([a-z\d])([A-Z])/, '\\1_\\2').downcase
        end

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
