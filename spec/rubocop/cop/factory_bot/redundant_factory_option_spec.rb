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
    it 'registers no offense' do
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
end
