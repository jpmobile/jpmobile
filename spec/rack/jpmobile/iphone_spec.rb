require File.join(__dir__, '../../rack_helper.rb')

describe Jpmobile::MobileCarrier, 'iphone' do
  include Rack::Test::Methods

  context '端末種別で' do
    it 'iPhone を判別できること' do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; ja-jp) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16',
      )
      env = Jpmobile::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].class).to            eq(Jpmobile::Mobile::Iphone)
      expect(env['rack.jpmobile'].smart_phone?).to     be_truthy
      expect(env['rack.jpmobile'].supports_cookie?).to be_truthy
    end
  end
end
