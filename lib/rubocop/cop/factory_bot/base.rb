# frozen_string_literal: true

module RuboCop
  module Cop
    module FactoryBot
      # Base class for FactoryBot cops.
      class Base < ::RuboCop::Cop::Base
        def target_factory_bot_version
          @config.target_factory_bot_version
        end
      end
    end
  end
end
