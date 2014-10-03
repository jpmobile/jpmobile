# -*- coding: utf-8 -*-
require File.join(File.expand_path(File.dirname(__FILE__)), '../../rack_helper.rb')

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
      expect(@env['rack.jpmobile'].class).to eq(Jpmobile::Mobile::Docomo)
    end

    it "#position などが nil になること" do
      expect(@env['rack.jpmobile'].position).to be_nil
      expect(@env['rack.jpmobile'].areacode).to be_nil
      expect(@env['rack.jpmobile'].serial_number).to be_nil
      expect(@env['rack.jpmobile'].icc).to be_nil
      expect(@env['rack.jpmobile'].ident).to be_nil
      expect(@env['rack.jpmobile'].ident_device).to be_nil
      expect(@env['rack.jpmobile'].ident_subscriber).to be_nil
    end

    it "#supports_cookie? などが false になること" do
      expect(@env['rack.jpmobile'].supports_cookie?).to be_falsey
    end

    it "#imode_browser_versionが1.0になること" do
      expect(@env['rack.jpmobile'].imode_browser_version).to eq('1.0')
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
      expect(@env['rack.jpmobile'].class).to eq(Jpmobile::Mobile::Docomo)
    end

    it "#position などが nil になること" do
      expect(@env['rack.jpmobile'].position).to be_nil
      expect(@env['rack.jpmobile'].areacode).to be_nil
      expect(@env['rack.jpmobile'].serial_number).to be_nil
      expect(@env['rack.jpmobile'].icc).to be_nil
      expect(@env['rack.jpmobile'].ident).to be_nil
      expect(@env['rack.jpmobile'].ident_device).to be_nil
      expect(@env['rack.jpmobile'].ident_subscriber).to be_nil
    end

    it "#supports_cookie? などが false になること" do
      expect(@env['rack.jpmobile'].supports_cookie?).to be_falsey
    end

    it "#imode_browser_versionが1.0になること" do
      expect(@env['rack.jpmobile'].imode_browser_version).to eq('1.0')
    end
  end

  context "P09A3で" do
    before(:each) do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "DoCoMo/2.0 P09A3(c500;TB;W20H12)")
      @env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]
    end

    it "#supports_cookie? が true になること" do
      expect(@env['rack.jpmobile'].supports_cookie?).to be_truthy
    end

    it "#imode_browser_versionが2.0になること" do
      expect(@env['rack.jpmobile'].imode_browser_version).to eq('2.0')
    end
  end

  context "P07A3で" do
    before(:each) do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "DoCoMo/2.0 P07A3(c500;TB;W24H15)")
      @env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]
    end

    it "#supports_cookie? が true になること" do
      expect(@env['rack.jpmobile'].supports_cookie?).to be_truthy
    end

    it "#imode_browser_versionが2.0になること" do
      expect(@env['rack.jpmobile'].imode_browser_version).to eq('2.0')
    end
  end

  context "L01Bで" do
    before(:each) do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "DoCoMo/2.0 L01B(c500;TB;W40H10)")
      @env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]
    end

    it "#supports_cookie? が true になること" do
      expect(@env['rack.jpmobile'].supports_cookie?).to be_truthy
    end

    it "#imode_browser_versionが2.0になること" do
      expect(@env['rack.jpmobile'].imode_browser_version).to eq('2.0LE')
    end
  end

  context "iエリアで" do
    it "データが取得できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "DoCoMo/1.0/SO506iC/c20/TB/W20H10",
        "QUERY_STRING" => "AREACODE=00100&ACTN=OK")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].areacode).to eq("00100")
    end

    it "位置情報も取得できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "DoCoMo/1.0/SO506iC/c20/TB/W20H10",
        "QUERY_STRING" => "LAT=%2B35.00.35.600&LON=%2B135.41.35.600&GEO=wgs84&POSINFO=2&AREACODE=00100&ACTN=OK")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].areacode).to eq("00100")

      expect(env['rack.jpmobile'].position.lat).to be_within(1e-7).of(35.00988889)
      expect(env['rack.jpmobile'].position.lon).to be_within(1e-7).of(135.6932222)
    end
  end

  context "GPS で" do
    it "位置が取得できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "DoCoMo/2.0 SA702i(c100;TB;W30H15)",
        "QUERY_STRING" => "lat=%2B35.00.35.600&lon=%2B135.41.35.600&geo=wgs84&x-acc=3")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].position.lat).to be_within(1e-7).of(35.00988889)
      expect(env['rack.jpmobile'].position.lon).to be_within(1e-7).of(135.6932222)
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

      expect(env['rack.jpmobile'].position.lat).to be_within(1e-7).of(35.00988889)
      expect(env['rack.jpmobile'].position.lon).to be_within(1e-7).of(135.6932222)
    end
  end

  context "端末番号が" do
    it "mova で取得できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "DoCoMo/1.0/SO505iS/c20/TC/W30H16/serXXXXX000000")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].serial_number).to eq("XXXXX000000")
      expect(env['rack.jpmobile'].ident).to         eq("XXXXX000000")
      expect(env['rack.jpmobile'].icc).to be_nil
      expect(env['rack.jpmobile'].ident_device).to  eq("XXXXX000000")
      expect(env['rack.jpmobile'].ident_subscriber).to be_nil
    end

    it "FOMA で取得できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "DoCoMo/2.0 D902i(c100;TB;W23H16;ser999999999999999;icc0000000000000000000f)")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].serial_number).to    eq("999999999999999")
      expect(env['rack.jpmobile'].icc).to              eq("0000000000000000000f")
      expect(env['rack.jpmobile'].ident).to            eq("0000000000000000000f")
      expect(env['rack.jpmobile'].ident_device).to     eq("999999999999999")
      expect(env['rack.jpmobile'].ident_subscriber).to eq("0000000000000000000f")
    end
  end

  context "IPアドレス制限で" do
    it "正しいIPアドレス空間からのアクセスを判断できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "DoCoMo/2.0 SH902i(c100;TB;W24H12)",
        "REMOTE_ADDR" => "210.153.84.1")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].valid_ip?).to be_truthy
    end

    it "正しくないIPアドレス空間からのアクセスを判断できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "DoCoMo/2.0 SH902i(c100;TB;W24H12)",
        "REMOTE_ADDR" => "127.0.0.1")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].valid_ip?).to be_falsey
    end
  end

  context "端末サイズ" do
    it "SO506iCのサイズを適切に取得できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "DoCoMo/1.0/SO506iC/c20/TB/W20H10")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].display.browser_width).to  eq(240)
      expect(env['rack.jpmobile'].display.browser_height).to eq(256)
      expect(env['rack.jpmobile'].display.width).to          eq(240)
      expect(env['rack.jpmobile'].display.height).to         eq(256)
      expect(env['rack.jpmobile'].display.color?).to be_truthy
      expect(env['rack.jpmobile'].display.colors).to         eq(262144)
    end
  end
end
