# frozen_string_literal: true

RSpec.describe RuboCop::Cop::FactoryBot::ExclusiveTraits do
  context 'when traits define the same attribute with different values' do
    it 'registers an offense for each trait' do
      expect_offense(<<~RUBY)
        FactoryBot.define do
          factory :user do
            trait :active do
            ^^^^^^^^^^^^^ Traits `active` and `inactive` define the same attribute `status` with different values. Consider using sub-factories instead.
              status { 'active' }
            end

            trait :inactive do
            ^^^^^^^^^^^^^^^ Traits `inactive` and `active` define the same attribute `status` with different values. Consider using sub-factories instead.
              status { 'inactive' }
            end
          end
        end
      RUBY
    end
  end

  context 'when multiple pairs of conflicting traits exist' do
    it 'registers multiple offenses for each conflicting trait' do
      expect_offense(<<~RUBY)
        FactoryBot.define do
          factory :user do
            trait :active do
            ^^^^^^^^^^^^^ Traits `active` and `inactive` and `banned` define the same attribute `status` with different values. Consider using sub-factories instead.
              status { 'active' }
            end

            trait :inactive do
            ^^^^^^^^^^^^^^^ Traits `inactive` and `active` and `banned` define the same attribute `status` with different values. Consider using sub-factories instead.
              status { 'inactive' }
            end

            trait :banned do
            ^^^^^^^^^^^^^ Traits `banned` and `active` and `inactive` define the same attribute `status` with different values. Consider using sub-factories instead.
              status { 'banned' }
            end
          end
        end
      RUBY
    end
  end

  context 'when traits define different attributes' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        FactoryBot.define do
          factory :user do
            trait :with_email do
              email { 'user@example.com' }
            end

            trait :admin do
              role { 'admin' }
            end
          end
        end
      RUBY
    end
  end

  context 'when traits define the same attribute with the same value' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        FactoryBot.define do
          factory :user do
            trait :active do
              status { 'active' }
            end

            trait :verified do
              status { 'active' }
            end
          end
        end
      RUBY
    end
  end

  context 'when there is only one trait' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        FactoryBot.define do
          factory :user do
            trait :active do
              status { 'active' }
            end
          end
        end
      RUBY
    end
  end

  context 'when traits define multiple conflicting attributes' do
    it 'registers offenses for each conflicting attribute on each trait' do
      expect_offense(<<~RUBY)
        FactoryBot.define do
          factory :user do
            trait :active do
            ^^^^^^^^^^^^^ Traits `active` and `inactive` define the same attribute `status` and `account_type` with different values. Consider using sub-factories instead.
              status { 'active' }
              account_type { 'premium' }
            end

            trait :inactive do
            ^^^^^^^^^^^^^^^ Traits `inactive` and `active` define the same attribute `status` and `account_type` with different values. Consider using sub-factories instead.
              status { 'inactive' }
              account_type { 'free' }
            end
          end
        end
      RUBY
    end
  end

  context 'when traits have partial overlap' do
    it 'registers an offense only for conflicting attributes on each trait' do
      expect_offense(<<~RUBY)
        FactoryBot.define do
          factory :user do
            trait :active do
            ^^^^^^^^^^^^^ Traits `active` and `inactive` define the same attribute `status` with different values. Consider using sub-factories instead.
              status { 'active' }
              email { 'active@example.com' }
            end

            trait :inactive do
            ^^^^^^^^^^^^^^^ Traits `inactive` and `active` define the same attribute `status` with different values. Consider using sub-factories instead.
              status { 'inactive' }
              name { 'Inactive User' }
            end
          end
        end
      RUBY
    end
  end

  context 'when factory has no traits' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        FactoryBot.define do
          factory :user do
            name { 'John Doe' }
            email { 'john@example.com' }
          end
        end
      RUBY
    end
  end

  context 'when using different value types' do
    it 'registers an offense on each trait when values are clearly different' do
      expect_offense(<<~RUBY)
        FactoryBot.define do
          factory :user do
            trait :enabled do
            ^^^^^^^^^^^^^^ Traits `enabled` and `disabled` define the same attribute `active` with different values. Consider using sub-factories instead.
              active { true }
            end

            trait :disabled do
            ^^^^^^^^^^^^^^^ Traits `disabled` and `enabled` define the same attribute `active` with different values. Consider using sub-factories instead.
              active { false }
            end
          end
        end
      RUBY
    end
  end

  context 'when traits use method calls for values' do
    it 'registers an offense on each trait when method calls are different' do
      expect_offense(<<~RUBY)
        FactoryBot.define do
          factory :post do
            trait :published do
            ^^^^^^^^^^^^^^^^ Traits `published` and `draft` define the same attribute `published_at` with different values. Consider using sub-factories instead.
              published_at { Time.current }
            end

            trait :draft do
            ^^^^^^^^^^^^ Traits `draft` and `published` define the same attribute `published_at` with different values. Consider using sub-factories instead.
              published_at { nil }
            end
          end
        end
      RUBY
    end
  end

  context 'when using reserved methods' do
    it 'does not consider reserved methods as attributes' do
      expect_no_offenses(<<~RUBY)
        FactoryBot.define do
          factory :user do
            trait :with_posts do
              after(:create) do |user|
                create_list(:post, 3, user: user)
              end
            end

            trait :with_comments do
              after(:create) do |user|
                create_list(:comment, 5, user: user)
              end
            end
          end
        end
      RUBY
    end
  end

  context 'when traits define associations differently' do
    it 'registers an offense on each trait' do
      expect_offense(<<~RUBY)
        FactoryBot.define do
          factory :post do
            trait :with_admin_author do
            ^^^^^^^^^^^^^^^^^^^^^^^^ Traits `with_admin_author` and `with_regular_author` define the same attribute `author` with different values. Consider using sub-factories instead.
              author { create(:user, :admin) }
            end

            trait :with_regular_author do
            ^^^^^^^^^^^^^^^^^^^^^^^^^^ Traits `with_regular_author` and `with_admin_author` define the same attribute `author` with different values. Consider using sub-factories instead.
              author { create(:user) }
            end
          end
        end
      RUBY
    end
  end

  context 'when using integer values' do
    it 'registers an offense on each trait when values differ' do
      expect_offense(<<~RUBY)
        FactoryBot.define do
          factory :user do
            trait :basic do
            ^^^^^^^^^^^^ Traits `basic` and `premium` define the same attribute `max_projects` with different values. Consider using sub-factories instead.
              max_projects { 5 }
            end

            trait :premium do
            ^^^^^^^^^^^^^^ Traits `premium` and `basic` define the same attribute `max_projects` with different values. Consider using sub-factories instead.
              max_projects { 100 }
            end
          end
        end
      RUBY
    end
  end

  context 'when traits define complex expressions' do
    it 'registers an offense on each trait when expressions are different' do
      expect_offense(<<~RUBY)
        FactoryBot.define do
          factory :order do
            trait :discounted do
            ^^^^^^^^^^^^^^^^^ Traits `discounted` and `full_price` define the same attribute `price` with different values. Consider using sub-factories instead.
              price { base_price * 0.8 }
            end

            trait :full_price do
            ^^^^^^^^^^^^^^^^^ Traits `full_price` and `discounted` define the same attribute `price` with different values. Consider using sub-factories instead.
              price { base_price }
            end
          end
        end
      RUBY
    end
  end
end
