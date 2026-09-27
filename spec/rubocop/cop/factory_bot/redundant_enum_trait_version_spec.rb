# frozen_string_literal: true

# Check version selection through the cop (factory_bot 6.0+).
RSpec.describe RuboCop::Cop::FactoryBot::RedundantEnumTrait, :config do
  let(:offensive_source) do
    <<~RUBY
      factory :task do
        trait :queued do
          status { Task.statuses[:queued] }
        end
      end
    RUBY
  end

  context 'without `TargetFactoryBotVersion`' do
    context 'when the lockfile has a supported factory_bot version' do
      let(:gem_versions) { { 'factory_bot' => '6.2.0' } }

      it 'registers an offense' do
        expect_offense(<<~RUBY)
          factory :task do
            trait :queued do
            ^^^^^^^^^^^^^^^^ This trait is redundant because enum traits are automatically defined.
              status { Task.statuses[:queued] }
            end
          end
        RUBY
      end
    end

    context 'when the lockfile has an unsupported version' do
      let(:gem_versions) { { 'factory_bot' => '5.2.0' } }

      it 'registers no offense' do
        expect_no_offenses(offensive_source)
      end
    end

    context 'when the lockfile does not mention factory_bot' do
      it 'registers an offense, assuming the default version' do
        expect_offense(<<~RUBY)
          factory :task do
            trait :queued do
            ^^^^^^^^^^^^^^^^ This trait is redundant because enum traits are automatically defined.
              status { Task.statuses[:queued] }
            end
          end
        RUBY
      end
    end
  end

  context 'with `TargetFactoryBotVersion`' do
    let(:all_cops_config) do
      super().merge('TargetFactoryBotVersion' => target_version)
    end

    context 'when it is supported and the lockfile is not' do
      let(:target_version) { 6.0 }
      let(:gem_versions) { { 'factory_bot' => '5.2.0' } }

      it 'takes precedence over the lockfile and registers an offense' do
        expect_offense(<<~RUBY)
          factory :task do
            trait :queued do
            ^^^^^^^^^^^^^^^^ This trait is redundant because enum traits are automatically defined.
              status { Task.statuses[:queued] }
            end
          end
        RUBY
      end
    end

    context 'when it is unsupported and the lockfile is not' do
      let(:target_version) { 5.2 }
      let(:gem_versions) { { 'factory_bot' => '6.2.0' } }

      it 'takes precedence over the lockfile and registers no offense' do
        expect_no_offenses(offensive_source)
      end
    end

    context 'when it is a version string with a patch version' do
      let(:target_version) { '5.2.1' }

      it 'registers no offense' do
        expect_no_offenses(offensive_source)
      end
    end
  end
end
