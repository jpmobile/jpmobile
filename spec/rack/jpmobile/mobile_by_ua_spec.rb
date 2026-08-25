require File.join(__dir__, '../../rack_helper.rb')

describe Jpmobile::MobileCarrier do
  include Rack::Test::Methods

  [
    [Jpmobile::Mobile::Iphone, 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; ja-jp) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16'],
    [Jpmobile::Mobile::Android, 'Mozilla/5.0 (Linux; U; Android 1.6; ja-jp; SonyEriccsonSO-01B Build/R1EA018) AppleWebKit/528.5+ (KHTML, like Gecko) Version/3.1.2 Mobile Safari/525.20.1'],
    [Jpmobile::Mobile::Android, 'Mozilla/5.0 (Linux; Android 9; ANE-LX2J Build/HUAWEIANE-LX2J; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/88.0.4324.93 Mobile Safari/537.36 Instagram 172.0.0.21.123 Android (28/9; 480dpi; 1080x2060; HUAWEI; ANE-LX2J; HWANE; hi6250; ja_JP; 269790805)'],
    [Jpmobile::Mobile::WindowsPhone, 'Mozilla/4.0 (Compatible; MSIE 6.0; Windows NT 5.1 T-01A_6.5; Windows Phone 6.5)'],
    [Jpmobile::Mobile::BlackBerry, 'BlackBerry9000/4.6.0.224 Profile/MIDP-2.0 Configuration/CLDC-1.1 VendorID/220'],
    [Jpmobile::Mobile::Ipad, 'Mozilla/5.0 (iPad; U; CPU OS 4_3 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8F191 Safari/6533.18.5'],
    [Jpmobile::Mobile::AndroidTablet, 'Mozilla/5.0 (Linux; U; Android 2.2; ja-jp; SC-01C Build/FROYO) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1'],
    [Jpmobile::Mobile::AndroidTablet, 'Mozilla/5.0 (Linux; U; Android 3.2; ja-jp; Sony Tablet S Build/THMAS11002) AppleWebKit/534.13 (KHTML, like Gecko) Version/4.0 Safari/534.13'],
  ].each do |carrier, user_agent|
    it "#mobile should return #{carrier} when take #{user_agent} as UserAgent" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => user_agent,
      )
      env = Jpmobile::MobileCarrier.new(UnitApplication.new).call(res)[1]
      expect(env['rack.jpmobile'].class).to eq(carrier)
    end
  end

  it "Googlebot のときは rack['rack.jpmobile.carrier'] が nil になること" do
    res = Rack::MockRequest.env_for(
      'http://jpmobile-rails.org/',
      'HTTP_USER_AGENT' => 'Googlebot',
    )
    env = Jpmobile::MobileCarrier.new(UnitApplication.new).call(res)[1]
    expect(env['rack.jpmobile']).to be_nil
  end
end
