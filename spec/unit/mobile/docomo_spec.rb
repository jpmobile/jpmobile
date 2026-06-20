require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Jpmobile::Mobile::Docomo do
  def build(params: {}, env: {})
    described_class.new(env, double('request', params: params, env: env))
  end

  describe '#position' do
    it '緯度が DoCoMo の dms 形式でないと例外になること' do
      docomo = build(params: { 'lat' => '35.40.30.5', 'lon' => '+139.40.30.5', 'geo' => 'wgs84' })
      expect { docomo.position }.to raise_error('Unsuppoted')
    end

    it '経度が DoCoMo の dms 形式でないと例外になること' do
      docomo = build(params: { 'lat' => '+35.40.30.5', 'lon' => '139.40.30.5', 'geo' => 'wgs84' })
      expect { docomo.position }.to raise_error('Unsuppoted')
    end
  end

  describe '#to_external' do
    it 'content_type が変換対象外なら Shift_JIS 変換せず charset を維持すること' do
      _str, charset = build.to_external('あ', 'application/json', 'UTF-8')
      expect(charset).to eq('UTF-8')
    end

    it '空文字なら charset を default に上書きしないこと' do
      _str, charset = build.to_external('', nil, 'UTF-8')
      expect(charset).to eq('UTF-8')
    end
  end

  describe '#imode_browser_version' do
    it 'DoCoMo/1.0/・DoCoMo/2.0 以外（DoCoMo/3.0 等）は 2.0 を返すこと' do
      docomo = build(env: { 'HTTP_USER_AGENT' => 'DoCoMo/3.0 N01A(c500;TB;W24H16)' })
      expect(docomo.imode_browser_version).to eq('2.0')
    end
  end

  describe '#model_name' do
    it 'DoCoMo のモデル名パターンに一致しない UA では nil を返すこと' do
      docomo = build(env: { 'HTTP_USER_AGENT' => 'Mozilla/5.0' })
      expect(docomo.model_name).to be_nil
    end
  end
end
