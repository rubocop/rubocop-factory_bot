# frozen_string_literal: true

module RuboCop
  module Cop
    module FactoryBot
      # Use string value when setting the class attribute explicitly.
      #
      # This cop would promote faster tests by lazy-loading of
      # application files. Also, this could help you suppress potential bugs
      # in combination with external libraries by avoiding a preload of
      # application files from the factory files.
      #
      # @example
      #   # bad
      #   factory :foo, class: Foo do
      #   end
      #
      #   # good
      #   factory :foo, class: 'Foo' do
      #   end
      #
      # @example AllowedClasses: ['Hash', 'OpenStruct', 'Money::Amount']
      #   # good
      #   factory :amount, class: Money::Amount
      #
      class FactoryClassName < RuboCop::Cop::Base
        extend AutoCorrector

        MSG = "Pass '%<class_name>s' string instead of `%<class_name>s` " \
              'constant.'
        RESTRICT_ON_SEND = %i[factory].freeze

        # @!method class_name(node)
        def_node_matcher :class_name, <<~PATTERN
          (send _ :factory _ (hash <(pair (sym :class) $(const ...)) ...>))
        PATTERN

        def on_send(node)
          class_name(node) do |cn|
            next if cop_config['AllowedClasses'].include?(cn.const_name)

            msg = format(MSG, class_name: cn.const_name)
            add_offense(cn, message: msg) do |corrector|
              corrector.replace(cn, "'#{cn.source}'")
            end
          end
        end
      end
    end
  end
end
