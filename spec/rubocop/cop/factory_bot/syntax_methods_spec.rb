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

  context 'with example groups configured in the RSpec DSL' do
    let(:other_cops) do
      {
        'RSpec' => {
          'Language' => {
            'ExampleGroups' => { 'Regular' => %w[detail] },
            'SharedGroups' => { 'Examples' => %w[shared_behavior] }
          }
        }
      }
    end

    it 'registers an offense inside a configured example group' do
      expect_offense(<<~RUBY)
        RSpec.detail Foo do
          let(:bar) { FactoryBot.create(:bar) }
                      ^^^^^^^^^^^^^^^^^ Use `create` from `FactoryBot::Syntax::Methods`.
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.detail Foo do
          let(:bar) { create(:bar) }
        end
      RUBY
    end

    it 'registers an offense inside a configured shared group' do
      expect_offense(<<~RUBY)
        shared_behavior 'foo' do
          let(:bar) { FactoryBot.build(:bar) }
                      ^^^^^^^^^^^^^^^^ Use `build` from `FactoryBot::Syntax::Methods`.
        end
      RUBY
    end

    it 'still registers an offense inside a default example group' do
      expect_offense(<<~RUBY)
        describe Foo do
          let(:bar) { FactoryBot.create(:bar) }
                      ^^^^^^^^^^^^^^^^^ Use `create` from `FactoryBot::Syntax::Methods`.
        end
      RUBY
    end

    it 'does not register an offense inside an unknown block' do
      expect_no_offenses(<<~RUBY)
        RSpec.unknown Foo do
          let(:bar) { FactoryBot.create(:bar) }
        end
      RUBY
    end
  end
end
