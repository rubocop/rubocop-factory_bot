# frozen_string_literal: true

module RuboCop
  module Cop
    module FactoryBot
      # Detects mutually exclusive traits that should be sub-factories instead.
      #
      # When multiple traits define the same attribute with different values,
      # they are likely mutually exclusive states that should be separate
      # factories. Using traits for mutually exclusive states can lead to unclear
      # intent and potential test bugs when multiple traits are accidentally
      # applied together.
      #
      # @example
      #   # bad - mutually exclusive traits
      #   factory :user do
      #     trait :active do
      #       status { 'active' }
      #     end
      #
      #     trait :inactive do
      #       status { 'inactive' }
      #     end
      #   end
      #
      #   # good - use sub-factories for mutually exclusive states
      #   factory :user do
      #     factory :active_user do
      #       status { 'active' }
      #     end
      #
      #     factory :inactive_user do
      #       status { 'inactive' }
      #     end
      #   end
      #
      #   # good - traits that don't conflict
      #   factory :user do
      #     trait :with_email do
      #       email { 'user@example.com' }
      #     end
      #
      #     trait :admin do
      #       role { 'admin' }
      #     end
      #   end
      #
      class ExclusiveTraits < ::RuboCop::Cop::Base
        MSG = 'Traits %<traits>s define the same attribute %<attributes>s ' \
              'with different values. Consider using sub-factories instead.'

        RESTRICT_ON_SEND = %i[factory].freeze

        # @!method factory_definition(node)
        def_node_matcher :factory_definition, <<~PATTERN
          (block (send nil? :factory ...) _ $_)
        PATTERN

        # @!method trait_definition(node)
        def_node_matcher :trait_definition, <<~PATTERN
          (block (send nil? :trait (sym $_)) _ $_)
        PATTERN

        def on_send(node)
          return unless (factory_body = factory_definition(node.block_node))

          traits = extract_traits(factory_body)
          return if traits.length < 2

          conflict_attr = find_conflict_attr(traits)
          return if conflict_attr.empty?

          report_offenses(conflict_attr, traits)
        end

        private

        def extract_traits(factory_body)
          factory_body.each_child_node(:block).each_with_object({}) do |node, acc|
            trait_definition(node) do |name, body|
              acc[name] = { node: node, attributes: extract_attributes(body) }
            end
          end
        end

        def extract_attributes(trait_body)
          return {} unless trait_body

          nodes = trait_body.begin_type? ? trait_body.children : [trait_body]
          nodes.each_with_object({}) do |node, acc|
            next unless attribute_node?(node)
            next if reserved_method?(node.method_name)

            acc[node.method_name] = node.body&.source
          end
        end

        def attribute_node?(node)
          node.block_type? && node.receiver.nil?
        end

        def find_conflict_attr(traits)
          attribute_map = build_attribute_map(traits)

          attribute_map.select do |_attribute, traits_with_values|
            traits_with_values.size >= 2 && traits_with_values.values.uniq.size >= 2
          end
        end

        def build_attribute_map(traits)
          traits.each_with_object(Hash.new do |h, k|
            h[k] = {}
          end) do |(trait_name, trait_data), acc|
            trait_data[:attributes].each do |attr_name, value|
              acc[attr_name][trait_name] = value
            end
          end
        end

        def report_offenses(conflict_attr, traits)
          offenses = build_offenses_by_trait(conflict_attr, traits)
          offenses.each do |trait_name, offense_data|
            conflict_peers = offense_data[:conflicts].values.flatten.uniq
            conflict_attrs = offense_data[:conflicts].keys
            msg = format(MSG,
                         traits: format_names([trait_name] + conflict_peers),
                         attributes: format_names(conflict_attrs))
            add_offense(offense_data[:node].send_node, message: msg)
          end
        end

        def build_offenses_by_trait(conflict_attr, traits)
          conflict_attr.each_with_object({}) do |(attr_name, traits_with_values), acc|
            trait_names = traits_with_values.keys
            trait_names.each do |trait_name|
              acc[trait_name] ||= { node: traits[trait_name][:node],
                                    conflicts: {} }
              peer_traits = trait_names - [trait_name]
              acc[trait_name][:conflicts][attr_name] = peer_traits
            end
          end
        end

        def format_names(names)
          formatted = names.map { |name| "`#{name}`" }
          case formatted.size
          when 1 then formatted.first
          else
            formatted.join(' and ')
          end
        end

        def reserved_method?(method_name)
          RuboCop::FactoryBot.reserved_methods.include?(method_name)
        end
      end
    end
  end
end
