# frozen_string_literal: true

RSpec.describe RuboCop::Cop::FactoryBot::FactoryClassName do
  context 'when passing block' do
    it 'flags passing a class' do
      expect_offense(<<~RUBY)
        factory :foo, class: Foo do
                             ^^^ Pass 'Foo' string instead of `Foo` constant.
        end
      RUBY

      expect_correction(<<~RUBY)
        factory :foo, class: 'Foo' do
        end
      RUBY
    end

    it 'flags passing a class from global namespace' do
      expect_offense(<<~RUBY)
        factory :foo, class: ::Foo do
                             ^^^^^ Pass 'Foo' string instead of `Foo` constant.
        end
      RUBY

      expect_correction(<<~RUBY)
        factory :foo, class: '::Foo' do
        end
      RUBY
    end

    it 'flags passing a subclass' do
      expect_offense(<<~RUBY)
        factory :foo, class: Foo::Bar do
                             ^^^^^^^^ Pass 'Foo::Bar' string instead of `Foo::Bar` constant.
        end
      RUBY

      expect_correction(<<~RUBY)
        factory :foo, class: 'Foo::Bar' do
        end
      RUBY
    end

    it 'ignores passing class name' do
      expect_no_offenses(<<~RUBY)
        factory :foo, class: 'Foo' do
        end
      RUBY
    end

    it 'ignores passing Hash' do
      expect_no_offenses(<<~RUBY)
        factory :foo, class: Hash do
        end
      RUBY
    end

    it 'ignores passing OpenStruct' do
      expect_no_offenses(<<~RUBY)
        factory :foo, class: OpenStruct do
        end
      RUBY
    end
  end

  context 'when not passing block' do
    it 'flags passing a class' do
      expect_offense(<<~RUBY)
        factory :foo, class: Foo
                             ^^^ Pass 'Foo' string instead of `Foo` constant.
      RUBY

      expect_correction(<<~RUBY)
        factory :foo, class: 'Foo'
      RUBY
    end

    it 'ignores passing class name' do
      expect_no_offenses(<<~RUBY)
        factory :foo, class: 'Foo'
      RUBY
    end
  end

  context 'with AllowedClasses' do
    let(:cop_config) { { 'AllowedClasses' => %w[Hash Money::Amount] } }

    it 'ignores a configured class' do
      expect_no_offenses(<<~RUBY)
        factory :amount, class: Money::Amount
      RUBY
    end

    it 'still flags a class outside the configured list' do
      expect_offense(<<~RUBY)
        factory :foo, class: Foo
                             ^^^ Pass 'Foo' string instead of `Foo` constant.
      RUBY
    end
  end

  context 'with an empty AllowedClasses list' do
    let(:cop_config) { { 'AllowedClasses' => [] } }

    it 'flags a formerly allowed class' do
      expect_offense(<<~RUBY)
        factory :foo, class: Hash
                             ^^^^ Pass 'Hash' string instead of `Hash` constant.
      RUBY
    end
  end
end
