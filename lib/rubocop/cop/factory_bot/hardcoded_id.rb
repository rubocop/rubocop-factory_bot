# frozen_string_literal: true

module RuboCop
  module Cop
    module FactoryBot
      # Checks for an `id:` attribute passed to `create`.
      #
      # Forcing the primary key of a row the database is about to insert
      # collides with whatever else occupies it -- fixtures, the table's
      # own sequence -- and is a common source of flaky, order-dependent
      # failures. Let the database assign the id.
      #
      # @example
      #   # bad
      #   create(:company, id: 123)
      #   create(:company, 'id' => 123)
      #   create(:employee, id: company.id)
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

        MSG = 'Do not pass `id:` to `create`; let the database assign it.'
        RESTRICT_ON_SEND = %i[create].freeze

        # @!method create_with_id(node)
        def_node_matcher :create_with_id, <<~PATTERN
          (send #factory_call? :create ${sym str} ...
            (hash <$(pair {(sym :id) (str "id")} _) ...>))
        PATTERN

        def on_send(node)
          factory, id_pair = create_with_id(node)
          return unless id_pair
          return if allowed_factories.include?(factory.value.to_s)

          add_offense(id_pair)
        end

        private

        def allowed_factories
          @allowed_factories ||=
            Array(cop_config['AllowedFactories']).to_set(&:to_s)
        end
      end
    end
  end
end
