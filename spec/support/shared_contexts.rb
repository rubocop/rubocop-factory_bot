# frozen_string_literal: true

RSpec.shared_context 'with FactoryBot 6.0', :factory_bot60 do
  let(:all_cops_config) do
    super().merge('TargetFactoryBotVersion' => 6.0)
  end
end

RSpec.shared_context 'with FactoryBot 6.1', :factory_bot61 do
  let(:all_cops_config) do
    super().merge('TargetFactoryBotVersion' => 6.1)
  end
end
