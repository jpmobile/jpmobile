# -*- coding: utf-8 -*-
require File.join(File.expand_path(File.dirname(__FILE__)), '../../rack_helper.rb')

describe Jpmobile::Rack::MobileCarrier, "Windows Phone" do
  include Rack::Test::Methods

  context "端末種別で" do
    it "WindowsPhone を判別できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => 'Mozilla/4.0 (Compatible; MSIE 6.0; Windows NT 5.1 T-01A_6.5; Windows Phone 6.5)')
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].class).to            eq(Jpmobile::Mobile::WindowsPhone)
      expect(env['rack.jpmobile'].position).to         be_nil
      expect(env['rack.jpmobile'].smart_phone?).to     be_truthy
      expect(env['rack.jpmobile'].supports_cookie?).to be_truthy
    end
  end
end
