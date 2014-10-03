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

      expect(env['rack.jpmobile'].class).to            eq(Jpmobile::Mobile::Softbank)
      expect(env['rack.jpmobile'].position).to be_nil
      expect(env['rack.jpmobile'].serial_number).to    eq("000000000000000")
      expect(env['rack.jpmobile'].ident).to            eq("000000000000000")
      expect(env['rack.jpmobile'].ident_device).to     eq("000000000000000")
      expect(env['rack.jpmobile'].ident_subscriber).to be_nil
      expect(env['rack.jpmobile'].supports_cookie?).to be_truthy
      expect(env['rack.jpmobile'].smart_phone?).to     be_falsey
    end

    it "X_JPHONE_UID 付きの 910T を判別できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1",
        "HTTP_X_JPHONE_UID" => "aaaaaaaaaaaaaaaa")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].serial_number).to    eq("000000000000000")
      expect(env['rack.jpmobile'].x_jphone_uid).to     eq("aaaaaaaaaaaaaaaa")
      expect(env['rack.jpmobile'].ident).to            eq("aaaaaaaaaaaaaaaa")
      expect(env['rack.jpmobile'].ident_device).to     eq("000000000000000")
      expect(env['rack.jpmobile'].ident_subscriber).to eq("aaaaaaaaaaaaaaaa")
      expect(env['rack.jpmobile'].supports_cookie?).to be_truthy
    end

    it "V903T を判別できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].class).to            eq(Jpmobile::Mobile::Vodafone)
      expect(env['rack.jpmobile'].position).to be_nil
      expect(env['rack.jpmobile'].ident).to be_nil
      expect(env['rack.jpmobile'].supports_cookie?).to be_truthy
    end
  end

  context "GPS で" do
    it "位置情報が取得できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0",
        "QUERY_STRING" => "pos=N43.3.18.42E141.21.1.88&geo=wgs84&x-acr=1")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].position.lat).to be_within(1e-7).of(43.05511667)
      expect(env['rack.jpmobile'].position.lon).to be_within(1e-7).of(141.3505222)
      expect(env['rack.jpmobile'].position.options['pos']).to   eq("N43.3.18.42E141.21.1.88")
      expect(env['rack.jpmobile'].position.options['geo']).to   eq("wgs84")
      expect(env['rack.jpmobile'].position.options['x-acr']).to eq("1")
    end
  end

  context "IPアドレス制限で" do
    it "正しいIPアドレス空間からのアクセスを判断できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0",
        "REMOTE_ADDR"=>"210.146.7.199")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].valid_ip?).to be_truthy
    end

    it "正しくないIPアドレス空間からのアクセスを判断できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0",
        "REMOTE_ADDR"=>"127.0.0.1")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].valid_ip?).to be_falsey
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

      expect(env['rack.jpmobile'].display.width).to           eq(240)
      expect(env['rack.jpmobile'].display.height).to          eq(320)
      expect(env['rack.jpmobile'].display.physical_width).to  eq(240)
      expect(env['rack.jpmobile'].display.physical_height).to eq(320)
      expect(env['rack.jpmobile'].display.color?).to be_truthy
      expect(env['rack.jpmobile'].display.colors).to          eq(262144)
    end

    it "端末の画面情報が渡ってない場合に正しく動作すること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].display.width).to  be_nil
      expect(env['rack.jpmobile'].display.height).to be_nil
      expect(env['rack.jpmobile'].display.browser_width).to   be_nil
      expect(env['rack.jpmobile'].display.browser_height).to  be_nil
      expect(env['rack.jpmobile'].display.physical_width).to  be_nil
      expect(env['rack.jpmobile'].display.physical_height).to be_nil
      expect(env['rack.jpmobile'].display.color?).to be_nil
      expect(env['rack.jpmobile'].display.colors).to be_nil
    end
  end
end
