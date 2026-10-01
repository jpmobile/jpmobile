require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

describe Jpmobile::Configuration::RailsConfiguration do
  it 'Rails configuration から共有の Jpmobile 設定を参照できること' do
    configuration_class = Class.new do
      include Jpmobile::Configuration::RailsConfiguration
    end
    configuration = configuration_class.new

    expect(configuration.jpmobile).to equal(Jpmobile.config)
    expect(configuration.jpmobile).to equal(configuration.jpmobile)
  end
end

describe Jpmobile::Configuration do
  it '登録した session store を実行し、未登録なら nil を返すこと' do
    configuration = described_class.instance
    original_session_store = configuration.instance_variable_get(:@session_store)
    configuration.remove_instance_variable(:@session_store) if configuration.instance_variable_defined?(:@session_store)

    expect(configuration.mount_session_store).to be_nil

    configuration.session_store { :mounted }
    expect(configuration.mount_session_store).to eq(:mounted)
  ensure
    configuration.instance_variable_set(:@session_store, original_session_store)
  end
end
