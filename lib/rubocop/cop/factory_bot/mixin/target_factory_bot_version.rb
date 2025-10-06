# frozen_string_literal: true

module RuboCop
  module Cop
    module FactoryBot
      # Common functionality for checking target factory_bot version.
      module TargetFactoryBotVersion
        # Informs the base RuboCop gem that it the FactoryBot version is checked
        # via `requires_gem` API, without needing to call this
        # `#support_target_factory_bot_version` method.
        USES_REQUIRES_GEM_API = true
        TARGET_GEM_NAME = 'factory_bot' # :nodoc:

        def minimum_target_factory_bot_version(version)
          if respond_to?(:requires_gem)
            case version
            when Integer, Float then requires_gem(TARGET_GEM_NAME,
                                                  ">= #{version}")
            when String then requires_gem(TARGET_GEM_NAME, version)
            end
          else
            # Fallback path for previous versions of RuboCop which don't support
            # the `requires_gem` API yet.
            @minimum_target_factory_bot_version = version
          end
        end

        def support_target_factory_bot_version?(version)
          pp version
          if respond_to?(:requires_gem)
            return false unless gem_requirements

            gem_requirement = gem_requirements[TARGET_GEM_NAME]
            # If we have no requirement, then we support all versions
            return true unless gem_requirement

            pp gem_requirement

            gem_requirement.satisfied_by?(Gem::Version.new(version))
          else
            # Fallback path for previous versions of RuboCop which don't support
            # the `requires_gem` API yet.
            @minimum_target_factory_bot_version <= version
          end
        end
      end
    end
  end
end
