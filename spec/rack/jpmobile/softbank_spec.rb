# -*- coding: utf-8 -*-
require File.join(File.expand_path(File.dirname(__FILE__)), '../../rack_helper.rb')

describe Jpmobile::Rack::MobileCarrier, "softbank" do
  include Rack::Test::Methods

  context "端末種別で" do
    it "910T を判別できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      env['rack.jpmobile'].class.should            == Jpmobile::Mobile::Softbank
      env['rack.jpmobile'].position.should be_nil
      env['rack.jpmobile'].serial_number.should    == "000000000000000"
      env['rack.jpmobile'].ident.should            == "000000000000000"
      env['rack.jpmobile'].ident_device.should     == "000000000000000"
      env['rack.jpmobile'].ident_subscriber.should be_nil
      env['rack.jpmobile'].supports_cookie?.should be_true
    end

    it "X_JPHONE_UID 付きの 910T を判別できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1",
        "HTTP_X_JPHONE_UID" => "aaaaaaaaaaaaaaaa")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      env['rack.jpmobile'].serial_number.should    == "000000000000000"
      env['rack.jpmobile'].x_jphone_uid.should     == "aaaaaaaaaaaaaaaa"
      env['rack.jpmobile'].ident.should            == "aaaaaaaaaaaaaaaa"
      env['rack.jpmobile'].ident_device.should     == "000000000000000"
      env['rack.jpmobile'].ident_subscriber.should == "aaaaaaaaaaaaaaaa"
      env['rack.jpmobile'].supports_cookie?.should be_true
    end

    it "V903T を判別できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      env['rack.jpmobile'].class.should            == Jpmobile::Mobile::Vodafone
      env['rack.jpmobile'].position.should be_nil
      env['rack.jpmobile'].ident.should be_nil
      env['rack.jpmobile'].supports_cookie?.should be_true
    end
  end

  context "GPS で" do
    it "位置情報が取得できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0",
        "QUERY_STRING" => "pos=N43.3.18.42E141.21.1.88&geo=wgs84&x-acr=1")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      env['rack.jpmobile'].position.lat.should be_close(43.05511667, 1e-7)
      env['rack.jpmobile'].position.lon.should be_close(141.3505222, 1e-7)
      env['rack.jpmobile'].position.options['pos'].should   == "N43.3.18.42E141.21.1.88"
      env['rack.jpmobile'].position.options['geo'].should   == "wgs84"
      env['rack.jpmobile'].position.options['x-acr'].should == "1"
    end
  end

  context "IPアドレス制限で" do
    it "正しいIPアドレス空間からのアクセスを判断できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0",
        "REMOTE_ADDR"=>"202.179.204.1")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      env['rack.jpmobile'].valid_ip?.should be_true
    end

    it "正しくないIPアドレス空間からのアクセスを判断できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0",
        "REMOTE_ADDR"=>"127.0.0.1")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      env['rack.jpmobile'].valid_ip?.should be_false
    end
  end

  context "画面情報で" do
    it "端末の画面サイズを正しく取得できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0",
        "HTTP_X_JPHONE_DISPLAY"=>"240*320",
        "HTTP_X_JPHONE_COLOR"=>"C262144")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      env['rack.jpmobile'].display.width.should           == 240
      env['rack.jpmobile'].display.height.should          == 320
      env['rack.jpmobile'].display.physical_width.should  == 240
      env['rack.jpmobile'].display.physical_height.should == 320
      env['rack.jpmobile'].display.color?.should be_true
      env['rack.jpmobile'].display.colors.should          == 262144
    end

    it "端末の画面情報が渡ってない場合に正しく動作すること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      env['rack.jpmobile'].display.width.should  be_nil
      env['rack.jpmobile'].display.height.should be_nil
      env['rack.jpmobile'].display.browser_width.should   be_nil
      env['rack.jpmobile'].display.browser_height.should  be_nil
      env['rack.jpmobile'].display.physical_width.should  be_nil
      env['rack.jpmobile'].display.physical_height.should be_nil
      env['rack.jpmobile'].display.color?.should be_nil
      env['rack.jpmobile'].display.colors.should be_nil
    end
  end
end
