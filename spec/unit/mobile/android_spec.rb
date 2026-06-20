require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Jpmobile::Mobile::Android do
  describe '.check_client_hints' do
    it 'Client Hints が Android を示さないときは nil を返すこと' do
      expect(described_class.check_client_hints({})).to be_nil
    end
  end
end
