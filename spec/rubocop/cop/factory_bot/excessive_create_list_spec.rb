# frozen_string_literal: true

RSpec.describe RuboCop::Cop::FactoryBot::ExcessiveCreateList do
  let(:cop_config) do
    { 'MaxAmount' => max_amount }
  end

  let(:max_amount) { 10 }

  it 'ignores code that does not contain create_list' do
    expect_no_offenses(<<~RUBY)
      expect(true).to be_truthy
    RUBY
  end

  it 'ignores create_list with non-integer value' do
    expect_no_offenses(<<~RUBY)
      create_list(:merge_requests, value)
    RUBY
  end

  it 'ignores create_list with less than 10 items' do
    expect_no_offenses(<<~RUBY)
      create_list(:merge_requests, 9)
    RUBY
  end

  it 'ignores create_list for 10 items' do
    expect_no_offenses(<<~RUBY)
      create_list(:merge_requests, 10)
    RUBY
  end

  it 'registers an offense for create_list for more than 10 items' do
    expect_offense(<<~RUBY)
      create_list(:merge_requests, 11)
                                   ^^ Avoid using `create_list` with more than 10 items.
    RUBY
  end

  it 'registers an offense for FactoryBot.create_list' do
    expect_offense(<<~RUBY)
      FactoryBot.create_list(:merge_requests, 11)
                                              ^^ Avoid using `create_list` with more than 10 items.
    RUBY
  end

  context 'when create_list has the factory name as a string' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        FactoryBot.create_list('warehouse/user', 11)
                                                 ^^ Avoid using `create_list` with more than 10 items.
      RUBY
    end
  end
end
