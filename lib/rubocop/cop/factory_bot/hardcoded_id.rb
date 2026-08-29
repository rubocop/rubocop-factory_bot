# frozen_string_literal: true

module RuboCop
  module Cop
    module FactoryBot
      # Checks for a hardcoded `id:` passed to `create`.
      #
      # Forcing the primary key of a row the database is about to insert
      # collides with whatever else occupies it -- fixtures, parallel
      # workers, the table's own sequence -- and is a common source of
      # flaky, order-dependent failures. Let the database assign the id and
      # reference the record `create` returns.
      #
      # Only `create` is checked. `build` and `build_stubbed` never insert,
      # so nothing can collide with what they return.
      #
      # Both `id:` and `'id' =>` count, since FactoryBot symbolizes override
      # keys and a string-rocket key forces the same primary key.
      #
      # Only literal values are flagged, because a literal is the only value
      # the cop can see. An id read from a variable or a `let` is the same
      # hazard when it holds a constant, but telling that apart from
      # `id: company.id` means following the assignment.
      #
      # @example
      #   # bad
      #   create(:company, id: 123)
      #   create(:company, 'id' => 123)
      #
      #   # good - the database assigns the id
      #   company = create(:company)
      #   create(:employee, company: company)
      #
      # @example AllowedFactories: ['money'] (default: [])
      #   # good - a `skip_create` factory builds a value object rather than
      #   # a row, so `id:` is that object's own identity and is often
      #   # required
      #   create(:money, id: 123)
      #
      # @example ExplicitOnly: false (default)
      #   # bad
      #   create(:company, id: 123)
      #   FactoryBot.create(:company, id: 123)
      #
      # @example ExplicitOnly: true
      #   # good
      #   create(:company, id: 123)
      #
      #   # bad
      #   FactoryBot.create(:company, id: 123)
      #
      class HardcodedId < RuboCop::Cop::Base
        include ConfigurableExplicitOnly

        MSG = 'Do not pass a hardcoded `id:` to `create`; ' \
              'let the database assign it.'
        RESTRICT_ON_SEND = %i[create].freeze

        # @!method create_attributes(node)
        def_node_matcher :create_attributes, <<~PATTERN
          (send #factory_call? :create ${sym str} ... (hash $...))
        PATTERN

        def on_send(node)
          factory, attributes = create_attributes(node)
          return unless attributes
          return if allowed_factories.include?(factory.value.to_s)

          attributes.each do |pair|
            add_offense(pair) if hardcoded_id?(pair)
          end
        end

        private

        def hardcoded_id?(pair)
          return false unless pair.pair_type?
          return false unless pair.key.type?(:sym, :str)

          pair.key.value.to_s == 'id' && pair.value.type?(:int, :str)
        end

        def allowed_factories
          @allowed_factories ||=
            Array(cop_config['AllowedFactories']).to_set(&:to_s)
        end
      end
    end
  end
end
