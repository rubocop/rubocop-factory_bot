# frozen_string_literal: true

RSpec.describe RuboCop::Cop::FactoryBot::SyntaxMethods do
  described_class::RESTRICT_ON_SEND.each do |method|
    it 'does not register an offense when used outside an example group' do
      expect_no_offenses(<<~RUBY)
        FactoryBot.#{method}(:bar)
      RUBY
    end

    it "does not register an offense for `#{method}`" do
      expect_no_offenses(<<~RUBY)
        RSpec.describe Foo do
          let(:bar) { #{method}(:bar) }
        end
      RUBY
    end

    it "registers an offense for `FactoryBot.#{method}`" do
      expect_offense(<<~RUBY, method: method)
        describe Foo do
          let(:bar) { FactoryBot.%{method}(:bar) }
                      ^^^^^^^^^^^^{method} Use `%{method}` from `FactoryBot::Syntax::Methods`.
        end
      RUBY

      expect_correction(<<~RUBY)
        describe Foo do
          let(:bar) { #{method}(:bar) }
        end
      RUBY
    end

    it "registers an offense for `FactoryBot.#{method}` used inside a module" do
      expect_offense(<<~RUBY, method: method)
        module Foo
          RSpec.describe Bar do
            let(:bar) { FactoryBot.%{method}(:bar) }
                        ^^^^^^^^^^^^{method} Use `%{method}` from `FactoryBot::Syntax::Methods`.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        module Foo
          RSpec.describe Bar do
            let(:bar) { #{method}(:bar) }
          end
        end
      RUBY
    end

    it "registers an offense for `FactoryBot.#{method}` in a shared group" do
      expect_offense(<<~RUBY, method: method)
        shared_examples_for Foo do
          let(:bar) { FactoryBot.%{method}(:bar) }
                      ^^^^^^^^^^^^{method} Use `%{method}` from `FactoryBot::Syntax::Methods`.
        end
      RUBY

      expect_correction(<<~RUBY)
        shared_examples_for Foo do
          let(:bar) { #{method}(:bar) }
        end
      RUBY
    end

    it "registers an offense for `::FactoryBot.#{method}`" do
      expect_offense(<<~RUBY, method: method)
        RSpec.describe Foo do
          let(:bar) { ::FactoryBot.%{method}(:bar) }
                      ^^^^^^^^^^^^^^{method} Use `%{method}` from `FactoryBot::Syntax::Methods`.
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe Foo do
          let(:bar) { #{method}(:bar) }
        end
      RUBY
    end
  end

  it 'registers an offense in an ActiveSupport test class' do
    expect_offense(<<~RUBY)
      class UserTest < ActiveSupport::TestCase
        def test_user
          FactoryBot.create(:user)
          ^^^^^^^^^^^^^^^^^ Use `create` from `FactoryBot::Syntax::Methods`.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class UserTest < ActiveSupport::TestCase
        def test_user
          create(:user)
        end
      end
    RUBY
  end

  it 'registers an offense in a Minitest test class' do
    expect_offense(<<~RUBY)
      class UserTest < Minitest::Test
        def test_user
          FactoryBot.create(:user)
          ^^^^^^^^^^^^^^^^^ Use `create` from `FactoryBot::Syntax::Methods`.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class UserTest < Minitest::Test
        def test_user
          create(:user)
        end
      end
    RUBY
  end

  context 'when Ruby 3.1', :ruby31 do
    it 'does not correct a call in Class.new inside an example group' do
      expect_no_offenses(<<~RUBY)
        describe User do
          Class.new do
            def make = FactoryBot.create(:user)
          end
        end
      RUBY
    end
  end

  it 'does not correct a call in a nested class' do
    expect_no_offenses(<<~RUBY)
      describe User do
        class Helper
          def make
            FactoryBot.create(:user)
          end
        end
      end
    RUBY
  end

  it 'does not correct a call in a module nested in a test class' do
    expect_no_offenses(<<~RUBY)
      class UserTest < ActiveSupport::TestCase
        module Helper
          FactoryBot.create(:user)
        end
      end
    RUBY
  end
end
