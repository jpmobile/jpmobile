# -*- coding: utf-8 -*-
require File.join(File.expand_path(File.dirname(__FILE__)), '../../rack_helper.rb')

describe Jpmobile::Rack::MobileCarrier, "willcom" do
  include Rack::Test::Methods

  context "端末種別で" do
    it "WX310K が判別できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "Mozilla/3.0(WILLCOM;KYOCERA/WX310K/2;1.2.2.16.000000/0.1/C100) Opera 7.0")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      env['rack.jpmobile'].class.should == Jpmobile::Mobile::Willcom
      env['rack.jpmobile'].position.should be_nil
      env['rack.jpmobile'].ident.should be_nil
      env['rack.jpmobile'].supports_cookie?.should be_true
    end

    it "AH-H3001V が判別できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "Mozilla/3.0(DDIPOCKET;KYOCERA/AH-K3001V/1.8.2.71.000000/0.1/C100) Opera 7.0")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      env['rack.jpmobile'].class.should == Jpmobile::Mobile::Ddipocket
      env['rack.jpmobile'].position.should be_nil
      env['rack.jpmobile'].ident.should be_nil
      env['rack.jpmobile'].supports_cookie?.should be_true
    end
  end

  context "GPS で" do
    it "緯度経度を取得できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "Mozilla/3.0(WILLCOM;KYOCERA/WX310K/2;1.2.2.16.000000/0.1/C100) Opera 7.0",
        "QUERY_STRING" => "pos=N43.04.34.049E141.21.03.279")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      env['rack.jpmobile'].position.lat.should be_close(43.078568, 1e-4)
      env['rack.jpmobile'].position.lon.should be_close(141.347223, 1e-4)
    end
  end

  context "IPアドレス制限で" do
    it "正しいIPアドレス空間からのアクセスを判断できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "Mozilla/3.0(WILLCOM;KYOCERA/WX310K/2;1.2.2.16.000000/0.1/C100) Opera 7.0",
        "REMOTE_ADDR" => "61.198.142.1")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      env['rack.jpmobile'].valid_ip?.should be_true
    end

    it "正しくないIPアドレス空間からのアクセスを判断できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "Mozilla/3.0(WILLCOM;KYOCERA/WX310K/2;1.2.2.16.000000/0.1/C100) Opera 7.0",
        "REMOTE_ADDR" => "127.0.0.1")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      env['rack.jpmobile'].valid_ip?.should be_false
    end
  end
end
