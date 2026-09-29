# frozen_string_literal: true

module RuboCop
  module Cop
    module FactoryBot
      # Do not create a FactoryBot sequence for an id column.
      #
      # @example
      #   # bad - can lead to conflicts between FactoryBot and DB sequences
      #   factory :foo do
      #     sequence :id
      #     sequence 'id'
      #   end
      #
      #   # good - a non-id column
      #   factory :foo do
      #     sequence :some_non_id_column
      #   end
      #
      #   # good - a global sequence used with generate(:id)
      #   FactoryBot.define do
      #     sequence(:id) { |n| n + 1000 }
      #   end
      #   generate(:id)
      #
      class IdSequence < RuboCop::Cop::Base
        extend AutoCorrector
        include RangeHelp
        include RuboCop::FactoryBot::Language

        MSG = 'Do not create a sequence for an id attribute'
        RESTRICT_ON_SEND = %i[sequence].freeze

        # @!method factory_definition?(node)
        def_node_matcher :factory_definition?, <<~PATTERN
          (any_block (send nil? :factory ...) ...)
        PATTERN

        # @!method id_sequence?(node)
        def_node_matcher :id_sequence?, <<~PATTERN
          (send {nil? #factory_bot?} :sequence {(sym :id) (str "id")} ...)
        PATTERN

        def on_send(node)
          return unless id_sequence?(node) && inside_factory?(node)

          add_offense(node) do |corrector|
            range_to_remove = range_by_whole_lines(
              (node.block_node || node).source_range,
              include_final_newline: true
            )

            corrector.remove(range_to_remove)
          end
        end

        private

        def inside_factory?(node)
          node.ancestors.any? { |ancestor| factory_definition?(ancestor) }
        end
      end
    end
  end
end
