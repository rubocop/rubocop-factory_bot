# frozen_string_literal: true

module RuboCop
  module Cop
    module FactoryBot
      # Remove redundant `factory` option.
      #
      # @example
      #   # bad
      #   association :user, factory: :user
      #   association :user, { factory: 'user' }
      #   factory :post do
      #     user factory: :user
      #   end
      #
      #   # good
      #   association :user
      #   factory :post do
      #     user
      #   end
      class RedundantFactoryOption < RuboCop::Cop::Base
        extend AutoCorrector

        include RangeHelp

        MSG = 'Remove redundant `factory` option.'

        # @!method factory_or_trait_definition?(node)
        def_node_matcher :factory_or_trait_definition?, <<~PATTERN
          (any_block (send nil? {:factory :trait} ...) ...)
        PATTERN

        # @!method with_factory_option(node)
        def_node_matcher :with_factory_option, <<~PATTERN
          (send nil? _
            ...
            (hash
              <$(pair
                  (sym :factory)
                  {
                    (sym $_factory_name)
                    (str $_factory_name)
                    (array (sym $_factory_name))
                    (array (str $_factory_name))
                  }
                )
                ...
              >
            )
          )
        PATTERN

        def on_send(node)
          return unless node.receiver.nil? && node.last_argument&.hash_type?

          association_name = association_name(node)
          return unless association_name

          with_factory_option(node) do |factory_option, factory_name|
            next unless association_name.to_s == factory_name.to_s

            add_offense(factory_option) do |corrector|
              autocorrect(corrector, factory_option)
            end
          end
        end

        private

        def association_name(node)
          if node.method?(:association)
            name = node.first_argument
            name.value if %i[sym str].include?(name&.type)
          elsif implicit_association?(node)
            node.method_name
          end
        end

        def implicit_association?(node)
          reserved_methods = RuboCop::FactoryBot.reserved_methods
          return false if reserved_methods.include?(node.method_name)

          container = node.parent
          container = container.parent if container&.begin_type?
          factory_or_trait_definition?(container)
        end

        def autocorrect(corrector, node)
          hash = node.parent
          target = hash.braces? && hash.children.one? ? hash : node
          first_pair = hash.children.first == node
          side = hash.braces? && target == node && first_pair ? :right : :left

          corrector.remove(removal_range(target.source_range, side))
        end

        def removal_range(range, side)
          if side == :right
            range_with_surrounding_space(
              range_with_surrounding_comma(range, :right), side: :right
            )
          else
            range_with_surrounding_comma(
              range_with_surrounding_space(range, side: :left), :left
            )
          end
        end
      end
    end
  end
end
