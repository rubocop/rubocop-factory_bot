# frozen_string_literal: true

RSpec.describe RuboCop::Cop::FactoryBot::FactoryAssociationWithStrategy do
  context 'with inline association' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        factory :article do
          user { association(:user) }
        end
      RUBY
    end
  end

  context 'with explicit association' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        factory :article do
          association :user
        end
      RUBY
    end
  end

  context 'with implicit association' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        factory :article do
          user
        end
      RUBY
    end
  end

  context 'with hard-coded `build` association' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        factory :article do
          user { build(:user) }
                 ^^^^^^^^^^^^ Avoid hard-coding the strategy when defining an association.
        end
      RUBY

      expect_correction(<<~RUBY)
        factory :article do
          user { association(:user) }
        end
      RUBY
    end
  end

  context 'with hard-coded `build_stubbed` association' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        factory :article do
          user { build_stubbed(:user) }
                 ^^^^^^^^^^^^^^^^^^^^ Avoid hard-coding the strategy when defining an association.
        end
      RUBY

      expect_correction(<<~RUBY)
        factory :article do
          user { association(:user) }
        end
      RUBY
    end
  end

  context 'with hard-coded `create` association' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        factory :article do
          user { create(:user) }
                 ^^^^^^^^^^^^^ Avoid hard-coding the strategy when defining an association.
        end
      RUBY

      expect_correction(<<~RUBY)
        factory :article do
          user { association(:user) }
        end
      RUBY
    end
  end

  context 'with hard-coded association and traits and attributes' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        factory :article do
          user { create(:user, :trait1, :trait2, attribute1: 'value1', attribute2: 'value2') }
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid hard-coding the strategy when defining an association.
        end
      RUBY

      expect_correction(<<~RUBY)
        factory :article do
          user { association(:user, :trait1, :trait2, attribute1: 'value1', attribute2: 'value2') }
        end
      RUBY
    end
  end

  context 'with multiple hard-coded associations' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        factory :article do
          user1 { build(:user1) }
                  ^^^^^^^^^^^^^ Avoid hard-coding the strategy when defining an association.

          user2 { create(:user2) }
                  ^^^^^^^^^^^^^^ Avoid hard-coding the strategy when defining an association.
        end
      RUBY
    end
  end

  context 'with hard-coded association inside `trait`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        trait :with_user do
          user { create(:user) }
                 ^^^^^^^^^^^^^ Avoid hard-coding the strategy when defining an association.
        end
      RUBY

      expect_correction(<<~RUBY)
        trait :with_user do
          user { association(:user) }
        end
      RUBY
    end
  end

  context 'with hard-coded association inside `transient`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        factory :article do
          transient do
            user { create(:user) }
                   ^^^^^^^^^^^^^ Avoid hard-coding the strategy when defining an association.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        factory :article do
          transient do
            user { association(:user) }
          end
        end
      RUBY
    end
  end
end
