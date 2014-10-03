# -*- coding: utf-8 -*-
require File.join(File.expand_path(File.dirname(__FILE__)), '../../rack_helper.rb')

describe Jpmobile::Rack::MobileCarrier, "iphone" do
  include Rack::Test::Methods

  context "端末種別で" do
    it "iPhone を判別できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; ja-jp) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16')
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].class).to            eq(Jpmobile::Mobile::Iphone)
      expect(env['rack.jpmobile'].position).to         be_nil
      expect(env['rack.jpmobile'].smart_phone?).to     be_truthy
      expect(env['rack.jpmobile'].supports_cookie?).to be_truthy
    end
  end

  context "IPアドレス制限で" do
    it "Softbank 網からのアクセスでも invalid になること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; ja-jp) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16',
        "REMOTE_ADDR"=>"202.179.204.1")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].valid_ip?).to be_falsey
    end
  end
end
