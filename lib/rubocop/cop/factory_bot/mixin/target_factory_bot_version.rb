# frozen_string_literal: true

module RuboCop
  module Cop
    module FactoryBot
      # Common functionality for checking target factory_bot version.
      #
      # A cop that only makes sense from a certain factory_bot version on
      # declares that version with `minimum_target_factory_bot_version`, and is
      # skipped for code that targets an older one.
      module TargetFactoryBotVersion
        TARGET_GEM_NAME = 'factory_bot' # :nodoc:

        # Used when neither `AllCops: TargetFactoryBotVersion` nor the target's
        # lockfile tells which factory_bot version the inspected code targets.
        DEFAULT_FACTORY_BOT_VERSION = '6.0'
        private_constant :DEFAULT_FACTORY_BOT_VERSION

        def self.extended(cop_class)
          cop_class.include(InstanceMethods)
        end

        # @param [Float, Integer, String] version the oldest factory_bot
        #   version the cop makes sense for, e.g. `6.0` or `'6.0.1'`.
        def minimum_target_factory_bot_version(version)
          requires_gem(TARGET_GEM_NAME, ">= #{version}")
        end

        # Included automatically when a cop extends `TargetFactoryBotVersion`.
        module InstanceMethods
          # The requirements declared with `minimum_target_factory_bot_version`
          # are checked against the version this returns.
          # Firstly, `AllCops: TargetFactoryBotVersion` is considered.
          # If it's not set, RuboCop will parse the `factory_bot` version in the
          # target's Gemfile.lock/gems.locked.
          # By default, RuboCop assumes FactoryBot 6.0.
          #
          # @param [String] gem_name
          # @return [Gem::Version, nil]
          def target_gem_version(gem_name)
            return super unless gem_name == TARGET_GEM_NAME

            configured_target_factory_bot_version ||
              super ||
              Gem::Version.new(DEFAULT_FACTORY_BOT_VERSION)
          end

          private

          # @return [Gem::Version, nil]
          def configured_target_factory_bot_version
            version = config.for_all_cops['TargetFactoryBotVersion']

            Gem::Version.new(version.to_s) if version
          end
        end
      end
    end
  end
end
