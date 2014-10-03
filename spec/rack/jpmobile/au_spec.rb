# -*- coding: utf-8 -*-
require File.join(File.expand_path(File.dirname(__FILE__)), '../../rack_helper.rb')

describe Jpmobile::Rack::MobileCarrier, "au" do
  include Rack::Test::Methods

  context "端末種別で" do
    it "KDDI-CA32 で判別できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0",
        "HTTP_X_UP_SUBNO" => "00000000000000_mj.ezweb.ne.jp")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].class).to eq(Jpmobile::Mobile::Au)
      expect(env['rack.jpmobile'].subno).to eq("00000000000000_mj.ezweb.ne.jp")
      expect(env['rack.jpmobile'].ident).to eq("00000000000000_mj.ezweb.ne.jp")
      expect(env['rack.jpmobile'].ident_subscriber).to eq("00000000000000_mj.ezweb.ne.jp")

      expect(env['rack.jpmobile'].position).to be_nil
      expect(env['rack.jpmobile'].supports_cookie?).to be_truthy
    end

    it "TK22 で判別できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "UP.Browser/3.04-KCTA UP.Link/3.4.5.9")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].class).to eq(Jpmobile::Mobile::Au)
    end
  end

  context "GPS で" do
    it "緯度経度を取得できること(dgree)" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0",
        "QUERY_STRING" => "ver=1&datum=0&unit=1&lat=%2b43.07772&lon=%2b141.34114&alt=64&time=20061016192415&smaj=69&smin=18&vert=21&majaa=115&fm=1")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].position.lat).to eq(43.07772)
      expect(env['rack.jpmobile'].position.lon).to eq(141.34114)
    end

    it "緯度経度を取得できること(dms)" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0",
        "QUERY_STRING" => "ver=1&datum=0&unit=0&lat=%2b43.05.08.95&lon=%2b141.20.25.99&alt=155&time=20060521010328&smaj=76&smin=62&vert=65&majaa=49&fm=1")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].position.lat).to be_within(1e-7).of(43.08581944)
      expect(env['rack.jpmobile'].position.lon).to be_within(1e-7).of(141.3405528)
    end

    it "緯度経度を取得できること(dgree_tokyo)" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0",
        "QUERY_STRING" => "ver=1&datum=1&unit=1&lat=%2b43.07475&lon=%2b141.34259&alt=8&time=20061017182825&smaj=113&smin=76&vert=72&majaa=108&fm=1")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].position.lat).to be_within(1e-4).of(43.07719289)
      expect(env['rack.jpmobile'].position.lon).to be_within(1e-4).of(141.3389013)
    end

    it "緯度経度を取得できること(dgree_tokyo)" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0",
        "QUERY_STRING" => "ver=1&datum=1&unit=1&lat=%2b43.07475&lon=%2b141.34259&alt=8&time=20061017182825&smaj=113&smin=76&vert=72&majaa=108&fm=1")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].position.lat).to be_within(1e-4).of(43.07719289)
      expect(env['rack.jpmobile'].position.lon).to be_within(1e-4).of(141.3389013)
    end

    it "緯度経度を取得できること(dms_tokyo)" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0",
        "QUERY_STRING" => "datum=tokyo&unit=dms&lat=43.04.55.00&lon=141.20.50.75")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].position.lat).to be_within(1e-7).of(43.08194444)
      expect(env['rack.jpmobile'].position.lon).to be_within(1e-7).of(141.3474306)
    end

    it "緯度経度を取得できること(antenna)" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0",
        "QUERY_STRING" => "datum=tokyo&unit=dms&lat=43.04.55.00&lon=141.20.50.75")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].position.lat).to be_within(1e-7).of(43.08194444)
      expect(env['rack.jpmobile'].position.lon).to be_within(1e-7).of(141.3474306)
    end

    it "GeoKit がある場合に取得できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0",
        "QUERY_STRING" => "ver=1&datum=0&unit=1&lat=%2b43.07772&lon=%2b141.34114&alt=64&time=20061016192415&smaj=69&smin=18&vert=21&majaa=115&fm=1")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].position.lat).to eq(43.07772)
      expect(env['rack.jpmobile'].position.lon).to eq(141.34114)
      expect(env['rack.jpmobile'].position.ll).to  eq("43.07772,141.34114")
      if env['rack.jpmobile'].position.respond_to?(:distance_to) # GeoKit method
        expect(env['rack.jpmobile'].position.distance_to(env['rack.jpmobile'].position)).to eq(0)
      end
    end

    context "古い機種での取得可否で" do
      it "W31CA を判定できること" do
        res = Rack::MockRequest.env_for(
          'http://jpmobile-rails.org/',
          'HTTP_USER_AGENT' => "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0")
        env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

        expect(env['rack.jpmobile'].device_id).to eq("CA32")
        expect(env['rack.jpmobile'].supports_location?).to be_truthy
        expect(env['rack.jpmobile'].supports_gps?).to be_truthy
      end

      it "A1402S を判定できること" do
        res = Rack::MockRequest.env_for(
          'http://jpmobile-rails.org/',
          'HTTP_USER_AGENT' => "KDDI-SN26 UP.Browser/6.2.0.6.2 (GUI) MMP/2.0")
        env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

        expect(env['rack.jpmobile'].device_id).to eq("SN26")
        expect(env['rack.jpmobile'].supports_location?).to be_truthy
        expect(env['rack.jpmobile'].supports_gps?).to be_falsey
      end

      it "TK22 を判定できること" do
        res = Rack::MockRequest.env_for(
          'http://jpmobile-rails.org/',
          'HTTP_USER_AGENT' => "UP.Browser/3.04-KCTA UP.Link/3.4.5.9")
        env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

        expect(env['rack.jpmobile'].device_id).to eq("KCTA")
        expect(env['rack.jpmobile'].supports_location?).to be_falsey
        expect(env['rack.jpmobile'].supports_gps?).to be_falsey
      end
    end
  end

  context "IPアドレス制限で" do
    it "正しいIPアドレス空間からのアクセスを判断できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0",
        "REMOTE_ADDR" => "210.230.128.225")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].valid_ip?).to be_truthy
    end

    it "正しくないIPアドレス空間からのアクセスを判断できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0",
        "REMOTE_ADDR" => "127.0.0.1")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].valid_ip?).to be_falsey
    end
  end

  context "画面情報で" do
    it "端末の画面サイズを正しく取得できること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "KDDI-CA33 UP.Browser/6.2.0.10.4 (GUI) MMP/2.0",
        "HTTP_X_UP_DEVCAP_SCREENDEPTH" => "16,RGB565",
        "HTTP_X_UP_DEVCAP_SCREENPIXELS" => "240,346",
        "HTTP_X_UP_DEVCAP_ISCOLOR" => "1")
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]

      expect(env['rack.jpmobile'].display.width).to  eq(240)
      expect(env['rack.jpmobile'].display.height).to eq(346)
      expect(env['rack.jpmobile'].display.color?).to be_truthy
      expect(env['rack.jpmobile'].display.colors).to eq(65536)
    end

    it "端末の画面情報が渡ってない場合に正しく動作すること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => "KDDI-CA33 UP.Browser/6.2.0.10.4 (GUI) MMP/2.0")
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
