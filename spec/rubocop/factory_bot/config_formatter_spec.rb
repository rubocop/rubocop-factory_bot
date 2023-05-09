# frozen_string_literal: true

require 'rubocop/factory_bot/config_formatter'

RSpec.describe RuboCop::FactoryBot::ConfigFormatter do
  let(:config) do
    {
      'AllCops' => {
        'Setting' => 'forty two'
      },
      'FactoryBot/Foo' => {
        'Config' => 2,
        'Enabled' => true
      },
      'FactoryBot/Bar' => {
        'Enabled' => true,
        'Nullable' => nil
      },
      'FactoryBot/Baz' => {
        'Enabled' => true,
        'StyleGuide' => '#buzz'
      }
    }
  end

  let(:descriptions) do
    {
      'FactoryBot/Foo' => {
        'Description' => 'Blah'
      },
      'FactoryBot/Bar' => {
        'Description' => 'Wow'
      },
      'FactoryBot/Baz' => {
        'Description' => 'Woof'
      }
    }
  end

  it 'builds a YAML dump with spacing between cops' do
    formatter = described_class.new(config, descriptions)

    expect(formatter.dump).to eql(<<~YAML)
      ---
      AllCops:
        Setting: forty two

      FactoryBot/Foo:
        Config: 2
        Enabled: true
        Description: Blah
        Reference: https://www.rubydoc.info/gems/rubocop-factory_bot/RuboCop/Cop/FactoryBot/Foo

      FactoryBot/Bar:
        Enabled: true
        Nullable: ~
        Description: Wow
        Reference: https://www.rubydoc.info/gems/rubocop-factory_bot/RuboCop/Cop/FactoryBot/Bar

      FactoryBot/Baz:
        Enabled: true
        StyleGuide: "#buzz"
        Description: Woof
        Reference: https://www.rubydoc.info/gems/rubocop-factory_bot/RuboCop/Cop/FactoryBot/Baz
    YAML
  end
end
