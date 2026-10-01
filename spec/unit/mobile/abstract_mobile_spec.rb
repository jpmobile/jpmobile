require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Jpmobile::Mobile::AbstractMobile do
  def build(request = nil)
    described_class.new({}, request)
  end

  describe 'デフォルトの端末特性' do
    it 'cookie 非対応で、スマートフォン・タブレットではないこと' do
      mobile = build

      expect(mobile.supports_cookie?).to be(false)
      expect(mobile.smart_phone?).to be(false)
      expect(mobile.tablet?).to be(false)
    end

    it 'デフォルトの文字コードが UTF-8 であること' do
      expect(build.default_charset).to eq('UTF-8')
    end
  end

  describe '.check_client_hints' do
    it 'Client Hints に対応しない基底クラスでは nil を返すこと' do
      expect(described_class.check_client_hints({})).to be_nil
    end
  end

  describe '.add_user_agent_regexp' do
    it '既存の User-Agent 判定に正規表現を追加すること' do
      carrier = Class.new(described_class)
      carrier.const_set(:USER_AGENT_REGEXP, /BaseAgent/)

      carrier.add_user_agent_regexp(/AddedAgent/)

      expect(carrier.check_carrier('HTTP_USER_AGENT' => 'AddedAgent')).to be_truthy
      expect(carrier.check_carrier('HTTP_USER_AGENT' => 'OtherAgent')).to be_falsey
    end
  end

  describe '#params' do
    it 'request が parameters を持つ場合は parameters を参照すること' do
      mobile = build(double('request', parameters: { 'a' => '1' }))
      expect(mobile.send(:params)).to eq('a' => '1')
    end

    it 'request が parameters を持たない場合は params を参照すること' do
      mobile = build(double('request', params: { 'a' => '1' }))
      expect(mobile.send(:params)).to eq('a' => '1')
    end
  end

  describe 'carrier 判定メソッド' do
    it 'AbstractMobile 自身を carrier に含めても自己判定メソッドを追加しないこと' do
      expect(build).not_to respond_to(:abstractmobile?)
    end
  end
end
