# frozen_string_literal: true

RSpec.describe RuboCop::Cop::FactoryBot::HardcodedId do
  let(:cop_config) { { 'ExplicitOnly' => false } }

  it 'registers an offense for a hardcoded `id:`' do
    expect_offense(<<~RUBY)
      create(:company, id: 123)
                       ^^^^^^^ Do not pass `id:` to `create`; let the database assign it.
    RUBY
  end

  it 'registers an offense for a string id' do
    expect_offense(<<~RUBY)
      create(:company, id: '123456789')
                       ^^^^^^^^^^^^^^^ Do not pass `id:` to `create`; let the database assign it.
    RUBY
  end

  it 'registers an offense for a string-rocket key' do
    expect_offense(<<~RUBY)
      create(:company, 'id' => 123)
                       ^^^^^^^^^^^ Do not pass `id:` to `create`; let the database assign it.
    RUBY
  end

  it 'registers an offense for a string factory name' do
    expect_offense(<<~RUBY)
      create('company', id: 123)
                        ^^^^^^^ Do not pass `id:` to `create`; let the database assign it.
    RUBY
  end

  it 'registers an offense beside other attributes' do
    expect_offense(<<~RUBY)
      create(:company, name: 'Acme', id: 123, active: true)
                                     ^^^^^^^ Do not pass `id:` to `create`; let the database assign it.
    RUBY
  end

  it 'registers an offense after a trait' do
    expect_offense(<<~RUBY)
      create(:company, :active, id: 123)
                                ^^^^^^^ Do not pass `id:` to `create`; let the database assign it.
    RUBY
  end

  it 'registers an offense for a braced attribute hash' do
    expect_offense(<<~RUBY)
      create(:company, { id: 123 })
                         ^^^^^^^ Do not pass `id:` to `create`; let the database assign it.
    RUBY
  end

  it 'registers an offense on an explicit `FactoryBot` receiver' do
    expect_offense(<<~RUBY)
      FactoryBot.create(:company, id: 123)
                                  ^^^^^^^ Do not pass `id:` to `create`; let the database assign it.
    RUBY
  end

  it 'does not register an offense without an id' do
    expect_no_offenses(<<~RUBY)
      create(:company, name: 'Acme')
    RUBY
  end

  it 'does not register an offense without attributes' do
    expect_no_offenses(<<~RUBY)
      create(:company)
    RUBY
  end

  it 'registers an offense for a referenced id' do
    expect_offense(<<~RUBY)
      create(:employee, id: company.id)
                        ^^^^^^^^^^^^^^ Do not pass `id:` to `create`; let the database assign it.
    RUBY
  end

  it 'registers an offense for an id held in a variable' do
    expect_offense(<<~RUBY)
      create(:employee, id: company_id)
                        ^^^^^^^^^^^^^^ Do not pass `id:` to `create`; let the database assign it.
    RUBY
  end

  it 'does not register an offense for a keyword splat' do
    expect_no_offenses(<<~RUBY)
      create(:company, **attributes)
    RUBY
  end

  it 'registers an offense beside a keyword splat' do
    expect_offense(<<~RUBY)
      create(:company, **attributes, id: 123)
                                     ^^^^^^^ Do not pass `id:` to `create`; let the database assign it.
    RUBY
  end

  it 'does not register an offense for a key that merely ends in id' do
    expect_no_offenses(<<~RUBY)
      create(:employee, company_id: 123)
    RUBY
  end

  it 'does not register an offense for a non-literal key' do
    expect_no_offenses(<<~RUBY)
      create(:company, attribute => 123)
    RUBY
  end

  it 'does not register an offense for `build`' do
    expect_no_offenses(<<~RUBY)
      build(:company, id: 123)
      build_stubbed(:company, id: 123)
    RUBY
  end

  it 'does not register an offense for a non-factory receiver' do
    expect_no_offenses(<<~RUBY)
      Reporting::Row.create(:company, id: 123)
    RUBY
  end

  it 'does not register an offense for a non-symbol factory name' do
    expect_no_offenses(<<~RUBY)
      create(described_class, id: 123)
    RUBY
  end

  context 'with AllowedFactories' do
    let(:cop_config) do
      { 'ExplicitOnly' => false, 'AllowedFactories' => ['money'] }
    end

    it 'does not register an offense for an allowed factory' do
      expect_no_offenses(<<~RUBY)
        create(:money, id: 123)
      RUBY
    end

    it 'still registers an offense for other factories' do
      expect_offense(<<~RUBY)
        create(:company, id: 123)
                         ^^^^^^^ Do not pass `id:` to `create`; let the database assign it.
      RUBY
    end
  end

  context 'with ExplicitOnly' do
    let(:cop_config) { { 'ExplicitOnly' => true } }

    it 'does not register an offense for an implicit call' do
      expect_no_offenses(<<~RUBY)
        create(:company, id: 123)
      RUBY
    end

    it 'registers an offense for an explicit call' do
      expect_offense(<<~RUBY)
        FactoryBot.create(:company, id: 123)
                                    ^^^^^^^ Do not pass `id:` to `create`; let the database assign it.
      RUBY
    end
  end
end
