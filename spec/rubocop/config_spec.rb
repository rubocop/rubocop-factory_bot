# frozen_string_literal: true

RSpec.describe RuboCop::Config do
  include FileHelper

  subject(:configuration) { described_class.new(hash, loaded_path) }

  let(:loaded_path) { 'example/.rubocop.yml' }

  describe '#target_factory_bot_version' do
    context 'when TargetFactoryBotVersion is set' do
      let(:hash) do
        {
          'AllCops' => {
            'TargetFactoryBotVersion' => factory_bot_version
          }
        }
      end

      context 'with patch version' do
        let(:factory_bot_version) { '6.2.1' }
        let(:factory_bot_version_to_f) { 6.2 }

        it 'truncates the patch part and converts to a float' do
          expect(configuration.target_factory_bot_version).to eq factory_bot_version_to_f
        end
      end

      context 'correctly' do
        let(:factory_bot_version) { 6.2 }

        it 'uses TargetFactoryBotVersion' do
          expect(configuration.target_factory_bot_version).to eq factory_bot_version
        end
      end
    end

    context 'when TargetFactoryBotVersion is not set', :isolated_environment do
      let(:hash) do
        {
          'AllCops' => {}
        }
      end

      context 'and lock files do not exist' do
        it 'uses the default factory_bot version' do
          default = described_class::DEFAULT_FACTORY_BOT_VERSION
          expect(configuration.target_factory_bot_version).to eq default
        end
      end

      ['Gemfile.lock', 'gems.locked'].each do |file_name|
        context "and #{file_name} exists" do
          let(:base_path) { configuration.base_dir_for_path_parameters }
          let(:lock_file_path) { File.join(base_path, file_name) }

          it "uses the single digit FactoryBot version in #{file_name}" do
            content =
              <<~LOCKFILE
                GEM
                  remote: https://rubygems.org/
                  specs:
                    ffaker (2.20.0)
                    factory_bot (6.2.0)
                      activesupport (>= 4.2.0)

                PLATFORMS
                  ruby

                DEPENDENCIES
                  factory_bot (~> 6.2)

                BUNDLED WITH
                  2.3.14
              LOCKFILE
            create_file(lock_file_path, content)
            expect(configuration.target_factory_bot_version).to eq 6.2
          end

          it "uses the multi digit FactoryBot version in #{file_name}" do
            content =
              <<~LOCKFILE
                GEM
                  remote: https://rubygems.org/
                  specs:
                    factory_bot (100.22.33)
                      activesupport (>= 4.2.0)

                PLATFORMS
                  ruby

                DEPENDENCIES
                  factory_bot

                BUNDLED WITH
                  2.3.14
              LOCKFILE
            create_file(lock_file_path, content)
            expect(configuration.target_factory_bot_version).to eq 100.22
          end

          it "does not use the DEPENDENCIES FactoryBot version in #{file_name}" do
            content =
              <<~LOCKFILE
                GEM
                  remote: https://rubygems.org/
                  specs:
                    activesupport (7.0.3)

                PLATFORMS
                  ruby

                DEPENDENCIES
                  factory_bot (= 99.88.77)

                BUNDLED WITH
                  2.3.14
              LOCKFILE
            create_file(lock_file_path, content)
            expect(configuration.target_factory_bot_version).not_to eq 99.88
          end

          it "uses the default FactoryBot when FactoryBot is not in #{file_name}" do
            content =
              <<~LOCKFILE
                GEM
                  remote: https://rubygems.org/
                  specs:
                    addressable (2.5.2)
                    ast (2.4.0)

                PLATFORMS
                  ruby

                DEPENDENCIES
                  bundler (~> 2.3)

                BUNDLED WITH
                  2.3.14
              LOCKFILE
            create_file(lock_file_path, content)
            default = described_class::DEFAULT_FACTORY_BOT_VERSION
            expect(configuration.target_factory_bot_version).to eq default
          end
        end
      end
    end
  end
end
