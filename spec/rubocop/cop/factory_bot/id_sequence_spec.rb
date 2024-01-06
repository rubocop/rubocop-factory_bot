# frozen_string_literal: true

RSpec.describe RuboCop::Cop::FactoryBot::IdSequence do
  it 'registers an offense with no block' do
    expect_offense(<<~RUBY)
      FactoryBot.define do
        factory :post do
          summary { "A summary" }
          sequence :id
          ^^^^^^^^^^^^ Do not create a sequence for an id attribute
          title { "A title" }
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      FactoryBot.define do
        factory :post do
          summary { "A summary" }
          title { "A title" }
        end
      end
    RUBY
  end

  it 'registers an offense with a default value' do
    expect_offense(<<~RUBY)
      FactoryBot.define do
        factory :post do
          summary { "A summary" }
          sequence(:id, 1000)
          ^^^^^^^^^^^^^^^^^^^ Do not create a sequence for an id attribute
          title { "A title" }
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      FactoryBot.define do
        factory :post do
          summary { "A summary" }
          title { "A title" }
        end
      end
    RUBY
  end

  it 'registers an offense across multiple lines' do
    expect_offense(<<~RUBY)
      FactoryBot.define do
        factory :post do
          summary { "A summary" }
          sequence(
          ^^^^^^^^^ Do not create a sequence for an id attribute
            :id,
            1000
          )
          title { "A title" }
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      FactoryBot.define do
        factory :post do
          summary { "A summary" }
          title { "A title" }
        end
      end
    RUBY
  end

  it 'registers an offense with a Enumerable of values' do
    expect_offense(<<~RUBY)
      FactoryBot.define do
        factory :post do
          summary { "A summary" }
          sequence(:id, (1..10).cycle)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not create a sequence for an id attribute
          title { "A title" }
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      FactoryBot.define do
        factory :post do
          summary { "A summary" }
          title { "A title" }
        end
      end
    RUBY
  end

  it 'does not register an offense for a non-id sequence' do
    expect_no_offenses(<<~RUBY)
      FactoryBot.define do
        factory :post do
          summary { "A summary" }
          sequence :something_else
          title { "A title" }
        end
      end
    RUBY
  end

  it 'does not register an offense for a `sequence` with non-symbol argment' do
    expect_no_offenses(<<~RUBY)
      FactoryBot.define do
        sequence(id)
      end
    RUBY
  end

  it 'does not register an offense for a `sequence` without argument' do
    expect_no_offenses(<<~RUBY)
      FactoryBot.define do
        sequence
      end
    RUBY
  end

  it 'does not register an offense for a `sequence` with receiver' do
    expect_no_offenses(<<~RUBY)
      FactoryBot.define do
        foo.sequence(:id)
      end
    RUBY
  end
end
