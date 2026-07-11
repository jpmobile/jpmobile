require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Jpmobile::Mobile::AbstractMobile do
  def build(request = nil)
    described_class.new({}, request)
  end

  describe '#params' do
    it 'request が parameters を持つ場合は parameters を参照すること' do
      mobile = build(double('request', parameters: { 'a' => '1' }))
      expect(mobile.send(:params)).to eq('a' => '1')
    end
  end
end
