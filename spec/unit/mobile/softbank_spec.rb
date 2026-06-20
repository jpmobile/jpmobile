require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Jpmobile::Mobile::Softbank do
  def build(params: {}, env: {})
    described_class.new(env, double('request', params: params, env: env))
  end

  describe '#position' do
    it 'geo が wgs84 でないと例外になること' do
      sb = build(params: { 'pos' => 'N35.40.30.5E139.40.30.5', 'geo' => 'tokyo' })
      expect { sb.position }.to raise_error('Unsupported datum')
    end

    it '南緯・西経（S/W）の座標を負の値として扱うこと' do
      sb = build(params: { 'pos' => 'S35.40.30.5W139.40.30.5', 'geo' => 'wgs84' })
      expect(sb.position.lat).to be < 0
      expect(sb.position.lon).to be < 0
    end
  end
end
