# -*- coding: utf-8 -*-
require File.join(File.expand_path(File.dirname(__FILE__)), '../../rack_helper.rb')

describe Jpmobile::Rack::MobileCarrier, "android" do
  include Rack::Test::Methods

  context "端末種別で" do
    it "Android を判別できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => 'Mozilla/5.0 (Linux; U; Android 1.6; ja-jp; SonyEriccsonSO-01B Build/R1EA018) AppleWebKit/528.5+ (KHTML, like Gecko) Version/3.1.2 Mobile Safari/525.20.1')
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      env['rack.jpmobile'].class.should            == Jpmobile::Mobile::Android
      env['rack.jpmobile'].position.should         be_nil
      env['rack.jpmobile'].smart_phone?.should     be_true
      env['rack.jpmobile'].supports_cookie?.should be_true
    end
  end
end
