# -*- coding: utf-8 -*-
require File.join(File.expand_path(File.dirname(__FILE__)), '../../rack_helper.rb')

describe Jpmobile::Rack::MobileCarrier, "Windows Phone" do
  include Rack::Test::Methods

  context "端末種別で" do
    it "BlackBerryを判別できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => 'BlackBerry9000/4.6.0.224 Profile/MIDP-2.0 Configuration/CLDC-1.1 VendorID/220')
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      env['rack.jpmobile'].class.should            == Jpmobile::Mobile::BlackBerry
      env['rack.jpmobile'].position.should         be_nil
      env['rack.jpmobile'].smart_phone?.should     be_true
      env['rack.jpmobile'].supports_cookie?.should be_true
    end
  end
end
