# frozen_string_literal: true

RSpec.describe RuboCop::Cop::FactoryBot::FactoryAssociationWithStrategy do
  context 'when passing an hardcoded strategy' do
    context 'when passing a `create` strategy' do
      it 'flags the strategy' do
        expect_offense(<<~RUBY)
          factory :foo, class: 'FOOO' do
            profile { create(:profile) }
                      ^^^^^^^^^^^^^^^^ Use an implicit, explicit or inline definition instead of hard coding a strategy for setting association within factory.
          end
        RUBY
      end
    end

    context 'when passing a `build` strategy' do
      it 'flags the strategy' do
        expect_offense(<<~RUBY)
          factory :foo do
            profile { build(:profile) }
                      ^^^^^^^^^^^^^^^ Use an implicit, explicit or inline definition instead of hard coding a strategy for setting association within factory.
          end
        RUBY
      end
    end

    context 'when passing a `build_stubbed` strategy' do
      it 'flags the strategy' do
        expect_offense(<<~RUBY)
          factory :foo do
            profile { build_stubbed(:profile) }
                      ^^^^^^^^^^^^^^^^^^^^^^^ Use an implicit, explicit or inline definition instead of hard coding a strategy for setting association within factory.
          end
        RUBY
      end
    end

    context 'when passing an additional argument' do
      it 'flags the strategy' do
        expect_offense(<<~RUBY)
          factory :foo do
            profile { build_stubbed(:profile, :qualified) }
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use an implicit, explicit or inline definition instead of hard coding a strategy for setting association within factory.
          end
        RUBY
      end
    end

    context 'when having multiple hardcoded strategies' do
      it 'flags all the strategies' do
        expect_offense(<<~RUBY)
          factory :foo do
            profile { build_stubbed(:profile) }
                      ^^^^^^^^^^^^^^^^^^^^^^^ Use an implicit, explicit or inline definition instead of hard coding a strategy for setting association within factory.

            area { create(:area) }
                   ^^^^^^^^^^^^^ Use an implicit, explicit or inline definition instead of hard coding a strategy for setting association within factory.
          end
        RUBY
      end
    end
  end

  context 'when passing a block who does not use strategy' do
    context 'when passing an inline association' do
      it 'does not flag' do
        expect_no_offenses(<<~RUBY)
          factory :foo do
            profile { association :profile }
          end
        RUBY
      end
    end

    context 'when passing an implicit association' do
      it 'does not flag' do
        expect_no_offenses(<<~RUBY)
          factory :foo do
            profile
          end
        RUBY
      end
    end

    context 'when passing an explicit association' do
      it 'does not flag' do
        expect_no_offenses(<<~RUBY)
          factory :foo do
            association :profile
          end
        RUBY
      end
    end
  end
end
