# frozen_string_literal: true

module RuboCop
  # Extension of RuboCop's Config class.
  class Config
    DEFAULT_FACTORY_BOT_VERSION = 6.0

    def target_factory_bot_version
      @target_factory_bot_version ||=
        if for_all_cops['TargetFactoryBotVersion']
          for_all_cops['TargetFactoryBotVersion'].to_f
        elsif target_factory_bot_version_from_bundler_lock_file
          target_factory_bot_version_from_bundler_lock_file
        else
          DEFAULT_FACTORY_BOT_VERSION
        end
    end

    # @return [Float, nil] The FactoryBot version as a `major.minor` Float.
    def target_factory_bot_version_from_bundler_lock_file
      @target_factory_bot_version_from_bundler_lock_file ||=
        read_factory_bot_version_from_bundler_lock_file
    end

    # @return [Float, nil] The FactoryBot version as a `major.minor` Float.
    def read_factory_bot_version_from_bundler_lock_file
      return unless gem_versions_in_target

      factory_bot_in_target = gem_versions_in_target['factory_bot']
      return unless factory_bot_in_target

      gem_version_to_major_minor_float(factory_bot_in_target)
    end
  end
end
