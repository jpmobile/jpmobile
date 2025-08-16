require File.join(__dir__, '../../rack_helper.rb')

describe Jpmobile::ClientHintsCarrier do
  include Rack::Test::Methods

  context 'Client Hints を使用した端末判別' do
    context 'Android スマートフォン' do
      it 'Client Hints から Android を判別できること' do
        res = Rack::MockRequest.env_for(
          'http://jpmobile-rails.org/',
          'HTTP_SEC_CH_UA' => '"Google Chrome";v="91", "Chromium";v="91", " Not;A Brand";v="99"',
          'HTTP_SEC_CH_UA_MOBILE' => '?1',
          'HTTP_SEC_CH_UA_PLATFORM' => '"Android"',
          'HTTP_SEC_CH_UA_MODEL' => '"Pixel 5"',
        )
        env = Jpmobile::ClientHintsCarrier.new(UnitApplication.new).call(res)[1]

        expect(env['rack.jpmobile'].class).to eq(Jpmobile::Mobile::Android)
        expect(env['rack.jpmobile'].smart_phone?).to be_truthy
        expect(env['rack.jpmobile'].supports_cookie?).to be_truthy
      end
    end

    context 'Android タブレット' do
      it 'Client Hints から Android Tablet を判別できること（mobile=false）' do
        res = Rack::MockRequest.env_for(
          'http://jpmobile-rails.org/',
          'HTTP_SEC_CH_UA' => '"Google Chrome";v="91", "Chromium";v="91", " Not;A Brand";v="99"',
          'HTTP_SEC_CH_UA_MOBILE' => '?0',
          'HTTP_SEC_CH_UA_PLATFORM' => '"Android"',
          'HTTP_SEC_CH_UA_MODEL' => '"Galaxy Tab S7"',
        )
        env = Jpmobile::ClientHintsCarrier.new(UnitApplication.new).call(res)[1]

        expect(env['rack.jpmobile'].class).to eq(Jpmobile::Mobile::AndroidTablet)
        expect(env['rack.jpmobile'].tablet?).to be_truthy
        expect(env['rack.jpmobile'].supports_cookie?).to be_truthy
      end

      it 'Client Hints から Android Tablet を判別できること（mobile=true but model contains tab）' do
        res = Rack::MockRequest.env_for(
          'http://jpmobile-rails.org/',
          'HTTP_SEC_CH_UA' => '"Google Chrome";v="91", "Chromium";v="91", " Not;A Brand";v="99"',
          'HTTP_SEC_CH_UA_MOBILE' => '?1',
          'HTTP_SEC_CH_UA_PLATFORM' => '"Android"',
          'HTTP_SEC_CH_UA_MODEL' => '"Samsung Galaxy Tab A"',
        )
        env = Jpmobile::ClientHintsCarrier.new(UnitApplication.new).call(res)[1]

        expect(env['rack.jpmobile'].class).to eq(Jpmobile::Mobile::AndroidTablet)
        expect(env['rack.jpmobile'].tablet?).to be_truthy
      end
    end

    context 'iPhone' do
      it 'Client Hints から iPhone を判別できること' do
        res = Rack::MockRequest.env_for(
          'http://jpmobile-rails.org/',
          'HTTP_SEC_CH_UA' => '"Google Chrome";v="91", "Chromium";v="91", " Not;A Brand";v="99"',
          'HTTP_SEC_CH_UA_MOBILE' => '?1',
          'HTTP_SEC_CH_UA_PLATFORM' => '"iOS"',
          'HTTP_SEC_CH_UA_MODEL' => '"iPhone"',
        )
        env = Jpmobile::ClientHintsCarrier.new(UnitApplication.new).call(res)[1]

        expect(env['rack.jpmobile'].class).to eq(Jpmobile::Mobile::Iphone)
        expect(env['rack.jpmobile'].smart_phone?).to be_truthy
        expect(env['rack.jpmobile'].supports_cookie?).to be_truthy
      end
    end

    context 'iPad' do
      it 'Client Hints から iPad を判別できること（mobile=false）' do
        res = Rack::MockRequest.env_for(
          'http://jpmobile-rails.org/',
          'HTTP_SEC_CH_UA' => '"Google Chrome";v="91", "Chromium";v="91", " Not;A Brand";v="99"',
          'HTTP_SEC_CH_UA_MOBILE' => '?0',
          'HTTP_SEC_CH_UA_PLATFORM' => '"iOS"',
          'HTTP_SEC_CH_UA_MODEL' => '"iPad"',
        )
        env = Jpmobile::ClientHintsCarrier.new(UnitApplication.new).call(res)[1]

        expect(env['rack.jpmobile'].class).to eq(Jpmobile::Mobile::Ipad)
        expect(env['rack.jpmobile'].tablet?).to be_truthy
        expect(env['rack.jpmobile'].supports_cookie?).to be_truthy
      end

      it 'Client Hints から iPad を判別できること（iPadOS）' do
        res = Rack::MockRequest.env_for(
          'http://jpmobile-rails.org/',
          'HTTP_SEC_CH_UA' => '"Google Chrome";v="91", "Chromium";v="91", " Not;A Brand";v="99"',
          'HTTP_SEC_CH_UA_MOBILE' => '?0',
          'HTTP_SEC_CH_UA_PLATFORM' => '"iPadOS"',
          'HTTP_SEC_CH_UA_MODEL' => '"iPad Pro"',
        )
        env = Jpmobile::ClientHintsCarrier.new(UnitApplication.new).call(res)[1]

        expect(env['rack.jpmobile'].class).to eq(Jpmobile::Mobile::Ipad)
        expect(env['rack.jpmobile'].tablet?).to be_truthy
      end
    end

    context 'Windows Phone' do
      it 'Client Hints から Windows Phone を判別できること' do
        res = Rack::MockRequest.env_for(
          'http://jpmobile-rails.org/',
          'HTTP_SEC_CH_UA' => '"Microsoft Edge";v="91", "Chromium";v="91", " Not;A Brand";v="99"',
          'HTTP_SEC_CH_UA_MOBILE' => '?1',
          'HTTP_SEC_CH_UA_PLATFORM' => '"Windows"',
          'HTTP_SEC_CH_UA_MODEL' => '"Lumia 950"',
        )
        env = Jpmobile::ClientHintsCarrier.new(UnitApplication.new).call(res)[1]

        expect(env['rack.jpmobile'].class).to eq(Jpmobile::Mobile::WindowsPhone)
        expect(env['rack.jpmobile'].smart_phone?).to be_truthy
      end
    end

    context 'BlackBerry' do
      it 'Client Hints から BlackBerry を判別できること' do
        res = Rack::MockRequest.env_for(
          'http://jpmobile-rails.org/',
          'HTTP_SEC_CH_UA' => '"BlackBerry";v="10", "WebKit";v="537", " Not;A Brand";v="99"',
          'HTTP_SEC_CH_UA_MOBILE' => '?1',
          'HTTP_SEC_CH_UA_PLATFORM' => '"BlackBerry"',
          'HTTP_SEC_CH_UA_MODEL' => '"BlackBerry KEY2"',
        )
        env = Jpmobile::ClientHintsCarrier.new(UnitApplication.new).call(res)[1]

        expect(env['rack.jpmobile'].class).to eq(Jpmobile::Mobile::BlackBerry)
        expect(env['rack.jpmobile'].smart_phone?).to be_truthy
      end
    end
  end

  context 'Client Hints パーサーのテスト' do
    let(:middleware) { Jpmobile::ClientHintsCarrier.new(UnitApplication.new) }

    it 'Sec-CH-UA ヘッダーを正しく解析できること' do
      parser_method = middleware.method(:parse_client_hints)
      result = parser_method.call(
        '"Google Chrome";v="91", "Chromium";v="91", " Not;A Brand";v="99"',
        '?1',
        '"Android"',
        '"Pixel 5"',
        nil,
      )

      expect(result[:brands]).to eq([
        { brand: 'Google Chrome', version: '91' },
        { brand: 'Chromium', version: '91' },
        { brand: ' Not;A Brand', version: '99' },
      ])
      expect(result[:mobile]).to be_truthy
      expect(result[:platform]).to eq('Android')
      expect(result[:model]).to eq('Pixel 5')
    end

    it 'boolean hint を正しく解析できること' do
      parser_method = middleware.method(:parse_boolean_hint)

      expect(parser_method.call('?1')).to be_truthy
      expect(parser_method.call('?0')).to be_falsey
      expect(parser_method.call(nil)).to be_nil
    end

    it 'string hint を正しく解析できること' do
      parser_method = middleware.method(:parse_string_hint)

      expect(parser_method.call('"Android"')).to eq('Android')
      expect(parser_method.call('Android')).to eq('Android')
      expect(parser_method.call(nil)).to be_nil
    end
  end

  context 'User-Agent フォールバック' do
    it 'Client Hints がない場合に User-Agent で判別すること' do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => 'Mozilla/5.0 (Linux; U; Android 1.6; ja-jp; SonyEriccsonSO-01B Build/R1EA018) AppleWebKit/528.5+ (KHTML, like Gecko) Version/3.1.2 Mobile Safari/525.20.1',
      )
      env = Jpmobile::ClientHintsCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].class).to eq(Jpmobile::Mobile::Android)
      expect(env['rack.jpmobile'].smart_phone?).to be_truthy
    end

    it 'Client Hints が不完全な場合に User-Agent で判別すること' do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_SEC_CH_UA' => '"Google Chrome";v="91"',
        'HTTP_USER_AGENT' => 'DoCoMo/2.0 SH902i(c100;TB;W24H12)',
      )
      env = Jpmobile::ClientHintsCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].class).to eq(Jpmobile::Mobile::Docomo)
    end
  end

  context 'PC ブラウザ' do
    it 'PC ブラウザの場合は nil を返すこと' do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_SEC_CH_UA' => '"Google Chrome";v="91", "Chromium";v="91", " Not;A Brand";v="99"',
        'HTTP_SEC_CH_UA_MOBILE' => '?0',
        'HTTP_SEC_CH_UA_PLATFORM' => '"Windows"',
        'HTTP_SEC_CH_UA_MODEL' => '""',
      )
      env = Jpmobile::ClientHintsCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile']).to be_nil
    end
  end

  context 'エラーハンドリング' do
    it '不正な Client Hints ヘッダーでもエラーにならないこと' do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_SEC_CH_UA' => 'invalid header format',
        'HTTP_SEC_CH_UA_MOBILE' => 'invalid',
        'HTTP_SEC_CH_UA_PLATFORM' => nil,
      )

      expect {
        Jpmobile::ClientHintsCarrier.new(UnitApplication.new).call(res)[1]
      }.not_to raise_error
    end
  end

  context 'タブレット判定ロジック' do
    let(:middleware) { Jpmobile::ClientHintsCarrier.new(UnitApplication.new) }

    it 'Android タブレットのモデル名を正しく判定できること' do
      tablet_method = middleware.method(:android_tablet?)

      expect(tablet_method.call({ model: 'Galaxy Tab S7' })).to be_truthy
      expect(tablet_method.call({ model: 'iPad Pro' })).to be_truthy
      expect(tablet_method.call({ model: 'Nexus 7' })).to be_truthy
      expect(tablet_method.call({ model: 'Nexus 10' })).to be_truthy
      expect(tablet_method.call({ model: 'Kindle Fire' })).to be_truthy
      expect(tablet_method.call({ model: 'Pixel 5' })).to be_falsey
      expect(tablet_method.call({ model: nil })).to be_falsey
    end
  end
end
