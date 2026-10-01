require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

describe Jpmobile::Configuration::RailsConfiguration do
  it 'Rails configuration から共有の Jpmobile 設定を参照できること' do
    configuration_class = Class.new do
      include Jpmobile::Configuration::RailsConfiguration
    end
    configuration = configuration_class.new

    expect(configuration.jpmobile).to equal(Jpmobile.config)
  end
end
