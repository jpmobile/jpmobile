require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Jpmobile::Mobile::Au do
  def build(params: {}, env: {})
    request = double('request', params: params, env: env)
    described_class.new(env, request)
  end

  describe '#position' do
    it 'unit=dms で緯度が dms 形式でないと例外になること' do
      au = build(params: { 'lat' => 'invalid', 'lon' => '141.20.50.75', 'unit' => 'dms' })
      expect { au.position }.to raise_error('Invalid dms form')
    end

    it 'unit=dms で経度が dms 形式でないと例外になること' do
      au = build(params: { 'lat' => '43.04.55.00', 'lon' => 'invalid', 'unit' => 'dms' })
      expect { au.position }.to raise_error('Invalid dms form')
    end

    it 'unit が 1/0/dms のいずれでもないときは nil を返すこと' do
      au = build(params: { 'lat' => '43.04.55.00', 'lon' => '141.20.50.75', 'unit' => '99' })
      expect(au.position).to be_nil
    end
  end

  describe '#device_id' do
    it 'User-Agent が Au の正規表現に一致しないときは nil を返すこと' do
      au = build(env: { 'HTTP_USER_AGENT' => 'Mozilla/5.0' })
      expect(au.device_id).to be_nil
    end
  end

  describe '#supports_cookie?' do
    it 'scheme を持たない request では protocol を見て判定すること' do
      request = double('legacy request', params: {}, protocol: 'http://example.jp')
      au = described_class.new({}, request)
      expect(au.supports_cookie?).to be_truthy
    end
  end

  describe '#to_external' do
    it 'content_type が変換対象外のときは Shift_JIS 変換せず charset を維持すること' do
      _str, charset = build.to_external('あ', 'application/json', 'UTF-8')
      expect(charset).to eq('UTF-8')
    end

    it '空文字のときは charset を default に上書きしないこと' do
      _str, charset = build.to_external('', nil, 'UTF-8')
      expect(charset).to eq('UTF-8')
    end
  end
end
