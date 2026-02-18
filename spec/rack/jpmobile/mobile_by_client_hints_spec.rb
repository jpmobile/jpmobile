require File.join(__dir__, '../../rack_helper.rb')

describe Jpmobile::MobileCarrier do
  include Rack::Test::Methods

  [
    [Jpmobile::Mobile::Iphone,        '"iOS"',     '?1'],
    [Jpmobile::Mobile::Ipad,          '"iOS"',     '?0'],
    [Jpmobile::Mobile::Android,       '"Android"', '?1'],
    [Jpmobile::Mobile::AndroidTablet, '"Android"', '?0'],
  ].each do |carrier, platform, mobile|
    it "#mobile should return #{carrier} when Sec-CH-UA-Platform=#{platform} Sec-CH-UA-Mobile=#{mobile}" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_SEC_CH_UA_PLATFORM' => platform,
        'HTTP_SEC_CH_UA_MOBILE' => mobile,
      )
      env = Jpmobile::MobileCarrier.new(UnitApplication.new).call(res)[1]
      expect(env['rack.jpmobile'].class).to eq(carrier)
    end
  end

  it 'Client Hints が無いときは UA にフォールバックすること' do
    res = Rack::MockRequest.env_for(
      'http://jpmobile-rails.org/',
      'HTTP_USER_AGENT' => 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; ja-jp) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16',
    )
    env = Jpmobile::MobileCarrier.new(UnitApplication.new).call(res)[1]
    expect(env['rack.jpmobile'].class).to eq(Jpmobile::Mobile::Iphone)
  end

  it 'Client Hints が UA より優先されること' do
    res = Rack::MockRequest.env_for(
      'http://jpmobile-rails.org/',
      'HTTP_USER_AGENT' => 'Mozilla/5.0 (Linux; Android 9; ...) Mobile Safari/537.36',
      'HTTP_SEC_CH_UA_PLATFORM' => '"iOS"',
      'HTTP_SEC_CH_UA_MOBILE' => '?1',
    )
    env = Jpmobile::MobileCarrier.new(UnitApplication.new).call(res)[1]
    expect(env['rack.jpmobile'].class).to eq(Jpmobile::Mobile::Iphone)
  end

  it 'Accept-CH ヘッダーがレスポンスに付与されること' do
    res = Rack::MockRequest.env_for('http://jpmobile-rails.org/')
    headers = Jpmobile::MobileCarrier.new(UnitApplication.new).call(res)[1]
    expect(headers['Accept-CH']).to eq('Sec-CH-UA-Mobile, Sec-CH-UA-Platform')
  end
end
