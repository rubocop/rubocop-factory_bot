# frozen_string_literal: true

RSpec.describe RuboCop::Cop::FactoryBot::CreateList do
  let(:cop_config) do
    { 'EnforcedStyle' => enforced_style, 'ExplicitOnly' => explicit_only }
  end
  let(:explicit_only) { false }

  context 'when EnforcedStyle is :create_list' do
    let(:enforced_style) { :create_list }

    it 'flags usage of n.times with no arguments' do
      expect_offense(<<~RUBY)
        3.times { create :user }
        ^^^^^^^ Prefer create_list.
      RUBY

      expect_correction(<<~RUBY)
        create_list :user, 3
      RUBY
    end

    it 'ignores usage of 1.times' do
      expect_no_offenses(<<~RUBY)
        1.times { create :user }
      RUBY
    end

    it 'flags usage of n.times when FactoryGirl.create is used' do
      expect_offense(<<~RUBY)
        3.times { FactoryGirl.create :user }
        ^^^^^^^ Prefer create_list.
      RUBY

      expect_correction(<<~RUBY)
        FactoryGirl.create_list :user, 3
      RUBY
    end

    it 'flags usage of n.times when FactoryBot.create is used' do
      expect_offense(<<~RUBY)
        3.times { FactoryBot.create :user }
        ^^^^^^^ Prefer create_list.
      RUBY

      expect_correction(<<~RUBY)
        FactoryBot.create_list :user, 3
      RUBY
    end

    it 'ignores create method of other object' do
      expect_no_offenses(<<~RUBY)
        3.times { SomeFactory.create :user }
      RUBY
    end

    it 'ignores create in other block' do
      expect_no_offenses(<<~RUBY)
        allow(User).to receive(:create) { create :user }
      RUBY
    end

    it 'ignores n.times with n as argument' do
      expect_no_offenses(<<~RUBY)
        3.times { |n| create :user, position: n }
      RUBY
    end

    it 'flags n.times when create call doesn\'t have method calls' do
      expect_offense(<<~RUBY)
        3.times { |n| create :user, :active }
        ^^^^^^^ Prefer create_list.
        3.times { |n| create :user, password: '123' }
        ^^^^^^^ Prefer create_list.
        3.times { |n| create :user, :active, password: '123' }
        ^^^^^^^ Prefer create_list.
      RUBY
    end

    it 'ignores n.times when create call does have method calls ' \
       'and repeat multiple times' do
      expect_no_offenses(<<~RUBY)
        3.times { |n| create :user, repositories_count: rand }
      RUBY
    end

    it 'ignores n.times when create call does have method calls ' \
       'and repeat multiple times with other argument' do
      expect_no_offenses(<<~RUBY)
        3.times { |n| create :user, :admin, repositories_count: rand }
      RUBY
    end

    it 'ignores n.times when create call does have method calls ' \
       'and not repeat' do
      expect_no_offenses(<<~RUBY)
        1.times { |n| create :user, repositories_count: rand }
      RUBY
    end

    it 'ignores n.times when there is no create call inside' do
      expect_no_offenses(<<~RUBY)
        3.times { do_something }
      RUBY
    end

    it 'ignores empty n.times' do
      expect_no_offenses(<<~RUBY)
        3.times {}
      RUBY
    end

    it 'ignores n.times when there is other calls but create' do
      expect_no_offenses(<<~RUBY)
        used_passwords = []
        3.times do
          u = create :user
          expect(used_passwords).not_to include(u.password)
          used_passwords << u.password
        end
      RUBY
    end

    it 'flags FactoryGirl.create calls with a block' do
      expect_offense(<<~RUBY)
        3.times do
        ^^^^^^^ Prefer create_list.
          create(:user) { |user| create :account, user: user }
        end
      RUBY

      expect_correction(<<~RUBY)
        create_list(:user, 3) { |user| create :account, user: user }
      RUBY
    end

    it 'flags usage of n.times with arguments' do
      expect_offense(<<~RUBY)
        5.times { create(:user, :trait) }
        ^^^^^^^ Prefer create_list.
      RUBY

      expect_correction(<<~RUBY)
        create_list(:user, 5, :trait)
      RUBY
    end

    it 'flags usage of n.times with block argument' do
      expect_offense(<<~RUBY)
        3.times do
        ^^^^^^^ Prefer create_list.
          create(:user, :trait) { |user| create :account, user: user }
        end
      RUBY

      expect_correction(<<~RUBY)
        create_list(:user, 3, :trait) { |user| create :account, user: user }
      RUBY
    end

    it 'flags usage of n.times with nested block arguments' do
      expect_offense(<<~RUBY)
        3.times do
        ^^^^^^^ Prefer create_list.
          create(:user, :trait) do |user|
            create :account, user: user
            create :profile, user: user
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        create_list(:user, 3, :trait) do |user|
            create :account, user: user
            create :profile, user: user
        end
      RUBY
    end

    it 'flags usage of n.times.map' do
      expect_offense(<<~RUBY)
        3.times.map { create :user }
        ^^^^^^^^^^^ Prefer create_list.
      RUBY

      expect_correction(<<~RUBY)
        create_list :user, 3
      RUBY
    end

    it 'ignores n.times.map when create call does have method calls' do
      expect_no_offenses(<<~RUBY)
        3.times.map { create :user, repositories_count: rand }
      RUBY
    end

    it 'flags usage of Array.new(n) with no arguments' do
      expect_offense(<<~RUBY)
        Array.new(3) { create(:user) }
        ^^^^^^^^^^^^ Prefer create_list.
      RUBY

      expect_correction(<<~RUBY)
        create_list(:user, 3)
      RUBY
    end

    it 'flags usage of Array.new(n) with block argument' do
      expect_offense(<<~RUBY)
        Array.new(3) do
        ^^^^^^^^^^^^ Prefer create_list.
          create(:user) { |user| create(:account, user: user) }
        end
      RUBY

      expect_correction(<<~RUBY)
        create_list(:user, 3) { |user| create(:account, user: user) }
      RUBY
    end

    context 'with empty array' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          []
        RUBY
      end
    end

    context 'with different `create` nodes in array' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          [create(:user), create(:user, age: 18)]
        RUBY
      end
    end

    context 'with one `create` node in array' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          [create(:user)]
        RUBY
      end
    end

    context 'with same `create` nodes in array' do
      it 'registers and corrects an offense' do
        expect_offense(<<~RUBY)
          [create(:user), create(:user)]
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer create_list.
        RUBY

        expect_correction(<<~RUBY)
          create_list(:user, 2)
        RUBY
      end
    end

    context 'with same `create` nodes in array with method calls' do
      it 'registers and corrects an offense' do
        expect_offense(<<~RUBY)
          [create(:user, point: rand), create(:user, point: rand)]
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer 2.times.map.
        RUBY

        expect_correction(<<~RUBY)
          2.times.map { create(:user, point: rand) }
        RUBY
      end
    end

    context 'when ExplicitOnly is false' do
      let(:explicit_only) { false }

      it 'registers an offense when using n.times with no arguments ' \
         'and an explicit receiver' do
        expect_offense(<<~RUBY)
          3.times { FactoryBot.create :user }
          ^^^^^^^ Prefer create_list.
        RUBY

        expect_correction(<<~RUBY)
          FactoryBot.create_list :user, 3
        RUBY
      end

      it 'registers an offense when using n.times with no arguments ' \
         'and no explicit receiver' do
        expect_offense(<<~RUBY)
          3.times { create :user }
          ^^^^^^^ Prefer create_list.
        RUBY

        expect_correction(<<~RUBY)
          create_list :user, 3
        RUBY
      end
    end

    context 'when ExplicitOnly is true' do
      let(:explicit_only) { true }

      it 'registers an offense when using n.times with no arguments ' \
         'and an explicit receiver' do
        expect_offense(<<~RUBY)
          3.times { FactoryBot.create :user }
          ^^^^^^^ Prefer create_list.
        RUBY

        expect_correction(<<~RUBY)
          FactoryBot.create_list :user, 3
        RUBY
      end

      it 'dose not register an offense when using n.times with no arguments ' \
         'and no explicit receiver' do
        expect_no_offenses(<<~RUBY)
          3.times { create :user }
        RUBY
      end
    end
  end

  context 'when EnforcedStyle is :n_times' do
    let(:enforced_style) { :n_times }

    it 'flags usage of create_list' do
      expect_offense(<<~RUBY)
        create_list :user, 3
        ^^^^^^^^^^^ Prefer 3.times.map.
      RUBY

      expect_correction(<<~RUBY)
        3.times.map { create :user }
      RUBY
    end

    it 'ignores create_list :user, 1' do
      expect_no_offenses(<<~RUBY)
        create_list :user, 1
      RUBY
    end

    it 'flags usage of create_list with argument' do
      expect_offense(<<~RUBY)
        create_list(:user, 3, :trait)
        ^^^^^^^^^^^ Prefer 3.times.map.
      RUBY

      expect_correction(<<~RUBY)
        3.times.map { create(:user, :trait) }
      RUBY
    end

    it 'flags usage of create_list with keyword arguments' do
      expect_offense(<<~RUBY)
        create_list :user, 3, :trait, key: val
        ^^^^^^^^^^^ Prefer 3.times.map.
      RUBY

      expect_correction(<<~RUBY)
        3.times.map { create :user, :trait, key: val }
      RUBY
    end

    it 'flags usage of FactoryGirl.create_list' do
      expect_offense(<<~RUBY)
        FactoryGirl.create_list :user, 3
                    ^^^^^^^^^^^ Prefer 3.times.map.
      RUBY

      expect_correction(<<~RUBY)
        3.times.map { FactoryGirl.create :user }
      RUBY
    end

    it 'flags usage of FactoryGirl.create_list with a block' do
      expect_offense(<<~RUBY)
        FactoryGirl.create_list(:user, 3) { |user| user.points = rand(1000) }
                    ^^^^^^^^^^^ Prefer 3.times.map.
      RUBY

      expect_correction(<<~RUBY)
        3.times.map { FactoryGirl.create(:user) { |user| user.points = rand(1000) } }
      RUBY
    end

    it 'ignores create method of other object' do
      expect_no_offenses(<<~RUBY)
        SomeFactory.create_list :user, 3
      RUBY
    end

    context 'when ExplicitOnly is false' do
      let(:explicit_only) { false }

      it 'registers an offense when using create_list ' \
         'with no arguments and an explicit receiver' do
        expect_offense(<<~RUBY)
          FactoryBot.create_list :user, 3
                     ^^^^^^^^^^^ Prefer 3.times.map.
        RUBY

        expect_correction(<<~RUBY)
          3.times.map { FactoryBot.create :user }
        RUBY
      end

      it 'registers an offense when using create_list ' \
         'with no arguments and no explicit receiver' do
        expect_offense(<<~RUBY)
          create_list :user, 3
          ^^^^^^^^^^^ Prefer 3.times.map.
        RUBY

        expect_correction(<<~RUBY)
          3.times.map { create :user }
        RUBY
      end
    end

    context 'when ExplicitOnly is true' do
      let(:explicit_only) { true }

      it 'registers an offense when using create_list ' \
         'with no arguments and an explicit receiver' do
        expect_offense(<<~RUBY)
          FactoryBot.create_list :user, 3
                     ^^^^^^^^^^^ Prefer 3.times.map.
        RUBY

        expect_correction(<<~RUBY)
          3.times.map { FactoryBot.create :user }
        RUBY
      end

      it 'dose not register an offense when using create_list ' \
         'with no arguments and no explicit receiver' do
        expect_no_offenses(<<~RUBY)
          create_list :user, 3
        RUBY
      end
    end

    context 'when Ruby 2.7', :ruby27 do
      it 'ignores n.times with numblock' do
        expect_no_offenses(<<~RUBY)
          3.times { create :user, position: _1 }
        RUBY
      end
    end

    context 'with same `create` nodes in array' do
      it 'registers and corrects an offense' do
        expect_offense(<<~RUBY)
          [create(:user), create(:user)]
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer 2.times.map.
        RUBY

        expect_correction(<<~RUBY)
          2.times.map { create(:user) }
        RUBY
      end
    end

    context 'with same `create` nodes in array with method calls' do
      it 'registers and corrects an offense' do
        expect_offense(<<~RUBY)
          [create(:user, point: rand), create(:user, point: rand)]
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer 2.times.map.
        RUBY

        expect_correction(<<~RUBY)
          2.times.map { create(:user, point: rand) }
        RUBY
      end
    end
  end
end
