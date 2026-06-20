require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Jpmobile::Mobile::Willcom do
  def build(params: {})
    described_class.new({}, double('request', params: params))
  end

  describe '#position' do
    it 'pos が Willcom の形式でないと例外になること' do
      willcom = build(params: { 'pos' => 'invalid' })
      expect { willcom.position }.to raise_error('unsupported format')
    end
  end
end
