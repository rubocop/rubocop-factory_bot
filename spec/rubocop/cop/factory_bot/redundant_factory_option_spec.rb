# frozen_string_literal: true

RSpec.describe RuboCop::Cop::FactoryBot::RedundantFactoryOption do
  context 'when `association` has no factory option' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        association :user
      RUBY
    end
  end

  context 'when `association` has no factory option but other option' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        association :user, strtaegy: :build
      RUBY
    end
  end

  context 'when `association` has non-redundant factory option' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        association :author, factory: :user
      RUBY
    end
  end

  context 'when `association` has non-redundant factory option in Array' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        association :user, factory: %i[user admin]
      RUBY
    end
  end

  context 'when `association` has redundant factory option' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        association :user, factory: :user
                           ^^^^^^^^^^^^^^ Remove redundant `factory` option.
      RUBY

      expect_correction(<<~RUBY)
        association :user
      RUBY
    end
  end

  context 'when `association` has redundant factory option in Array' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        association :user, factory: %i[user]
                           ^^^^^^^^^^^^^^^^^ Remove redundant `factory` option.
      RUBY

      expect_correction(<<~RUBY)
        association :user
      RUBY
    end
  end

  context 'when `association` has redundant factory option with traits' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        association :user, :admin, factory: :user
                                   ^^^^^^^^^^^^^^ Remove redundant `factory` option.
      RUBY

      expect_correction(<<~RUBY)
        association :user, :admin
      RUBY
    end
  end

  it 'removes an empty braced options hash' do
    expect_offense(<<~RUBY)
      association :user, { factory: :user }
                           ^^^^^^^^^^^^^^ Remove redundant `factory` option.
    RUBY

    expect_correction(<<~RUBY)
      association :user
    RUBY
  end

  it 'keeps other options in a braced hash' do
    expect_offense(<<~RUBY)
      association :user, { factory: :user, strategy: :build }
                           ^^^^^^^^^^^^^^ Remove redundant `factory` option.
    RUBY

    expect_correction(<<~RUBY)
      association :user, { strategy: :build }
    RUBY
  end

  it 'removes a redundant string factory name' do
    expect_offense(<<~RUBY)
      association :user, factory: 'user'
                         ^^^^^^^^^^^^^^^ Remove redundant `factory` option.
    RUBY

    expect_correction(<<~RUBY)
      association :user
    RUBY
  end

  it 'removes a redundant factory option from an implicit association' do
    expect_offense(<<~RUBY)
      factory :post do
        title { 'A title' }
        user factory: :user
             ^^^^^^^^^^^^^^ Remove redundant `factory` option.
      end
    RUBY

    expect_correction(<<~RUBY)
      factory :post do
        title { 'A title' }
        user
      end
    RUBY
  end

  it 'removes the option when it is the only factory body entry' do
    expect_offense(<<~RUBY)
      factory :post do
        user factory: :user
             ^^^^^^^^^^^^^^ Remove redundant `factory` option.
      end
    RUBY

    expect_correction(<<~RUBY)
      factory :post do
        user
      end
    RUBY
  end

  it 'does not assume a dynamic association name is redundant' do
    expect_no_offenses(<<~RUBY)
      association name, factory: :user
    RUBY
  end

  it 'does not inspect a call nested inside a callback' do
    expect_no_offenses(<<~RUBY)
      factory :post do
        after(:build) do
          user factory: :user
        end
      end
    RUBY
  end
end
