# frozen_string_literal: true

RSpec.describe RuboCop::Cop::FactoryBot::AmbiguousTraitUsage do
  def inspected_source_filename
    'spec/factories.rb'
  end

  it 'flags a bare trait name in a directly nested factory' do
    expect_offense(<<~RUBY)
      FactoryBot.define do
        factory :word do
          trait :article do
            type { :article }
          end

          factory :the do
            article
            ^^^^^^^ Ambiguous bare call to `article`; use explicit syntax for its intended meaning.
          end
        end
      end
    RUBY
  end

  it 'also checks factories with string names' do
    expect_offense(<<~RUBY)
      FactoryBot.define do
        factory 'word' do
          trait :article do
            type { :article }
          end

          factory 'the' do
            article
            ^^^^^^^ Ambiguous bare call to `article`; use explicit syntax for its intended meaning.
          end
        end
      end
    RUBY
  end

  it 'does not flag explicit trait usage or a different bare name' do
    expect_no_offenses(<<~RUBY)
      FactoryBot.define do
        factory :word do
          trait :article do
            type { :article }
          end

          factory :the, traits: [:article] do
            author
          end
        end
      end
    RUBY
  end

  it 'does not flag a matching call in a nested attribute block' do
    expect_no_offenses(<<~RUBY)
      FactoryBot.define do
        factory :word do
          trait :article do
            type { :article }
          end

          factory :the do
            summary { article }
          end
        end
      end
    RUBY
  end

  it 'does not flag a matching call with a block or arguments' do
    expect_no_offenses(<<~RUBY)
      FactoryBot.define do
        factory :word do
          trait :article do
            type { :article }
          end

          factory :the do
            article { :value }
            article :value
            self.article
          end
        end
      end
    RUBY
  end

  it 'does not flag a name declared in a sequence or association' do
    expect_no_offenses(<<~RUBY)
      FactoryBot.define do
        factory :word do
          sequence :article
          association :author

          factory :the do
            article
            author
          end
        end
      end
    RUBY
  end

  it 'does not flag a trait from another factory' do
    expect_no_offenses(<<~RUBY)
      FactoryBot.define do
        factory :article

        factory :word do
          trait :article do
            type { :article }
          end
        end

        factory :sentence do
          factory :the do
            article
          end
        end
      end
    RUBY
  end

  it 'does not flag a bare call when the parent has no matching trait' do
    expect_no_offenses(<<~RUBY)
      FactoryBot.define do
        factory :article

        factory :word do
          factory :the do
            article
          end
        end
      end
    RUBY
  end

  it 'does not infer a trait name from a variable' do
    expect_no_offenses(<<~RUBY)
      FactoryBot.define do
        name = :article
        factory :word do
          trait name do
            type { :article }
          end

          factory :the do
            article
          end
        end
      end
    RUBY
  end

  it 'does not inspect factory-like calls outside FactoryBot.define' do
    expect_no_offenses(<<~RUBY)
      factory :word do
        trait :article do
          type { :article }
        end

        factory :the do
          article
        end
      end
    RUBY
  end

  it 'does not inspect another DSL that uses factory and trait methods' do
    expect_no_offenses(<<~RUBY)
      OtherDsl.define do
        factory :word do
          trait :article do
            type { :article }
          end

          factory :the do
            article
          end
        end
      end
    RUBY
  end

  it 'does not inspect another DSL nested inside FactoryBot.define' do
    expect_no_offenses(<<~RUBY)
      FactoryBot.define do
        OtherDsl.define do
          factory :word do
            trait :article do
              type { :article }
            end

            factory :the do
              article
            end
          end
        end
      end
    RUBY
  end

  it 'checks factory definitions inside a regular Ruby block' do
    expect_offense(<<~RUBY)
      FactoryBot.define do
        1.times do
          factory :word do
            trait :article do
              type { :article }
            end

            factory :the do
              article
              ^^^^^^^ Ambiguous bare call to `article`; use explicit syntax for its intended meaning.
            end
          end
        end
      end
    RUBY
  end
end
