# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), '../../rack_helper.rb')

describe Jpmobile::Rack::MobileCarrier, "docomo" do
  include Rack::Test::Methods

  context "SH902i のとき" do
    before(:each) do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => 'DoCoMo/2.0 SH902i(c100;TB;W24H16)')
      @env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]
    end

    it "Jpmobile::Mobile::Docomo のインスタンスが env['rack.mobile'] にあること" do
      @env['rack.jpmobile'].class.should == Jpmobile::Mobile::Docomo
    end

    it "#position などが nil になること" do
      @env['rack.jpmobile'].position.should be_nil
      @env['rack.jpmobile'].areacode.should be_nil
      @env['rack.jpmobile'].serial_number.should be_nil
      @env['rack.jpmobile'].icc.should be_nil
      @env['rack.jpmobile'].ident.should be_nil
      @env['rack.jpmobile'].ident_device.should be_nil
      @env['rack.jpmobile'].ident_subscriber.should be_nil
    end

    it "#supports_cookie? などが false になること" do
      @env['rack.jpmobile'].supports_cookie?.should be_false
    end
  end

  context "SO506iC のとき" do
    before(:each) do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "DoCoMo/1.0/SO506iC/c20/TB/W20H10")
      @env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]
    end

    it "Jpmobile::Mobile::Docomo のインスタンスが env['rack.mobile'] にあること" do
      @env['rack.jpmobile'].class.should == Jpmobile::Mobile::Docomo
    end

    it "#position などが nil になること" do
      @env['rack.jpmobile'].position.should be_nil
      @env['rack.jpmobile'].areacode.should be_nil
      @env['rack.jpmobile'].serial_number.should be_nil
      @env['rack.jpmobile'].icc.should be_nil
      @env['rack.jpmobile'].ident.should be_nil
      @env['rack.jpmobile'].ident_device.should be_nil
      @env['rack.jpmobile'].ident_subscriber.should be_nil
    end

    it "#supports_cookie? などが false になること" do
      @env['rack.jpmobile'].supports_cookie?.should be_false
    end
  end

  context "iエリアで" do
    it "データが取得できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "DoCoMo/1.0/SO506iC/c20/TB/W20H10",
        "QUERY_STRING" => "AREACODE=00100&ACTN=OK")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      env['rack.jpmobile'].areacode.should == "00100"
    end

    it "位置情報も取得できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "DoCoMo/1.0/SO506iC/c20/TB/W20H10",
        "QUERY_STRING" => "LAT=%2B35.00.35.600&LON=%2B135.41.35.600&GEO=wgs84&POSINFO=2&AREACODE=00100&ACTN=OK")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      env['rack.jpmobile'].areacode.should == "00100"

      env['rack.jpmobile'].position.lat.should be_close(35.00988889, 1e-7)
      env['rack.jpmobile'].position.lon.should be_close(135.6932222, 1e-7)
    end
  end

  context "GPS で" do
    it "位置が取得できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "DoCoMo/2.0 SA702i(c100;TB;W30H15)",
        "QUERY_STRING" => "lat=%2B35.00.35.600&lon=%2B135.41.35.600&geo=wgs84&x-acc=3")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      env['rack.jpmobile'].position.lat.should be_close(35.00988889, 1e-7)
      env['rack.jpmobile'].position.lon.should be_close(135.6932222, 1e-7)
    end

    # DoCoMo, 903i, GPS
    # "WGS84"が大文字。altで高度が取得できているようだ。どちらも仕様書には記述がない。
    # http://www.nttdocomo.co.jp/service/imode/make/content/html/outline/gps.html
    it "903iでは高度があるが、正確にデータが取得できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "DoCoMo/2.0 SH903i(c100;TB;W24H16)",
        "QUERY_STRING" => "lat=%2B35.00.35.600&lon=%2B135.41.35.600&geo=WGS84&alt=%2B64.000&x-acc=1")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      env['rack.jpmobile'].position.lat.should be_close(35.00988889, 1e-7)
      env['rack.jpmobile'].position.lon.should be_close(135.6932222, 1e-7)
    end
  end

  context "端末番号が" do
    it "mova で取得できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "DoCoMo/1.0/SO505iS/c20/TC/W30H16/serXXXXX000000")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      env['rack.jpmobile'].serial_number.should == "XXXXX000000"
      env['rack.jpmobile'].ident.should         == "XXXXX000000"
      env['rack.jpmobile'].icc.should be_nil
      env['rack.jpmobile'].ident_device.should  == "XXXXX000000"
      env['rack.jpmobile'].ident_subscriber.should be_nil
    end

    it "FOMA で取得できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "DoCoMo/2.0 D902i(c100;TB;W23H16;ser999999999999999;icc0000000000000000000f)")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      env['rack.jpmobile'].serial_number.should    == "999999999999999"
      env['rack.jpmobile'].icc.should              == "0000000000000000000f"
      env['rack.jpmobile'].ident.should            == "0000000000000000000f"
      env['rack.jpmobile'].ident_device.should     == "999999999999999"
      env['rack.jpmobile'].ident_subscriber.should == "0000000000000000000f"
    end
  end

  context "IPアドレス制限で" do
    it "正しいIPアドレス空間からのアクセスを判断できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "DoCoMo/2.0 SH902i(c100;TB;W24H12)",
        "REMOTE_ADDR" => "210.153.84.1")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      env['rack.jpmobile'].valid_ip?.should be_true
    end

    it "正しくないIPアドレス空間からのアクセスを判断できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "DoCoMo/2.0 SH902i(c100;TB;W24H12)",
        "REMOTE_ADDR" => "127.0.0.1")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      env['rack.jpmobile'].valid_ip?.should be_false
    end
  end

  context "端末サイズ" do
    it "SO506iCのサイズを適切に取得できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "DoCoMo/1.0/SO506iC/c20/TB/W20H10")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      env['rack.jpmobile'].display.browser_width.should  == 240
      env['rack.jpmobile'].display.browser_height.should == 256
      env['rack.jpmobile'].display.width.should          == 240
      env['rack.jpmobile'].display.height.should         == 256
      env['rack.jpmobile'].display.color?.should be_true
      env['rack.jpmobile'].display.colors.should         == 262144
    end
  end
end
