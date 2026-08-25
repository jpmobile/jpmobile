require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

describe Jpmobile::Position do
  it '南半球・東経のケープタウンを方角付きで表すこと' do
    position = described_class.new
    position.lat = -33.9249
    position.lon = 18.4241

    expect(position.to_s).to match(/\AS.*E/)
  end

  it '北半球・西経のニューヨークを方角付きで表すこと' do
    position = described_class.new
    position.lat = 40.7128
    position.lon = -74.0060

    expect(position.to_s).to match(/\AN.*W/)
  end
end
