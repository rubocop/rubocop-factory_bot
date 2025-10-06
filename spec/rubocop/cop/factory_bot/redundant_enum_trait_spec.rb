# frozen_string_literal: true

RSpec.describe RuboCop::Cop::FactoryBot::RedundantEnumTrait, :config do
  context 'when FactoryBot 6.1', :factory_bot61 do
    it 'registers an offense and corrects a redundant enum trait' do
      expect_offense(<<~RUBY)
        FactoryBot.define do
          factory :task do
            trait :queued do
            ^^^^^^^^^^^^^^^ This trait is redundant because enum traits are automatically defined in FactoryBot 6.1 and later.
              status { Task.statuses[:queued] }
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        FactoryBot.define do
          factory :task do
          end
        end
      RUBY
    end

    it 'registers an offense for different attribute and model names' do
      expect_offense(<<~RUBY)
        factory :job do
          trait :failed do
          ^^^^^^^^^^^^^^ This trait is redundant because enum traits are automatically defined in FactoryBot 6.1 and later.
            state { Job.states[:failed] }
          end
        end
      RUBY
    end

    it 'does not register an offense when trait name and enum key mismatch' do
      expect_no_offenses(<<~RUBY)
        factory :task do
          trait :in_progress do
            status { Task.statuses[:started] }
          end
        end
      RUBY
    end

    it 'does not register an offense for traits with different structures' do
      expect_no_offenses(<<~RUBY)
        factory :task do
          trait :queued do
            status { :queued }
          end
        end
      RUBY
    end

    it 'does not register an offense for traits with multiple attributes' do
      expect_no_offenses(<<~RUBY)
        factory :task do
          trait :queued do
            name { 'A queued task' }
            status { Task.statuses[:queued] }
          end
        end
      RUBY
    end
  end

  context 'when FactoryBot 6.0', :factory_bot60 do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        FactoryBot.define do
          factory :task do
            trait :queued do
              status { Task.statuses[:queued] }
            end
          end
        end
      RUBY
    end
  end
end
