# frozen_string_literal: true

module RuboCop
  module Cop
    # Cops for the `FactoryBot` department. The department's cops are
    # registered for lazy loading and their files are loaded on demand.
    module FactoryBot
      extend LazyLoader

      register_cop :AssociationStyle, "#{__dir__}/factory_bot/association_style"
      register_cop :AttributeDefinedStatically, "#{__dir__}/factory_bot/attribute_defined_statically"
      register_cop :ConsistentParenthesesStyle, "#{__dir__}/factory_bot/consistent_parentheses_style"
      register_cop :CreateList, "#{__dir__}/factory_bot/create_list"
      register_cop :ExcessiveCreateList, "#{__dir__}/factory_bot/excessive_create_list"
      register_cop :FactoryAssociationWithStrategy, "#{__dir__}/factory_bot/factory_association_with_strategy"
      register_cop :FactoryClassName, "#{__dir__}/factory_bot/factory_class_name"
      register_cop :FactoryNameStyle, "#{__dir__}/factory_bot/factory_name_style"
      register_cop :HardcodedId, "#{__dir__}/factory_bot/hardcoded_id"
      register_cop :IdSequence, "#{__dir__}/factory_bot/id_sequence"
      register_cop :RedundantFactoryOption, "#{__dir__}/factory_bot/redundant_factory_option"
      register_cop :SyntaxMethods, "#{__dir__}/factory_bot/syntax_methods"
    end
  end
end
