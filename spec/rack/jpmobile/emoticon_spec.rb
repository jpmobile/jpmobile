# -*- coding: utf-8 -*-
require File.join(File.expand_path(File.dirname(__FILE__)), '../../rack_helper.rb')

describe "絵文字が" do
  include Rack::Test::Methods
  include Jpmobile::RackHelper
  include Jpmobile::Util

  before(:each) do
    Jpmobile.config.smart_phone_emoticon_compatibility = true

    @docomo_cr          = "&#xE63E;";
    @docomo_utf8        = [0xe63e].pack("U")
    @docomo_docomopoint = "&#xE6D5;"

    @au_cr              = "&#xE488;"
    @au_utf8            = [0xe488].pack("U")

    @softbank_cr        = "&#xF04A;"
    @softbank_utf8      = [0xf04a].pack("U")

    @emoticon_yaml   = File.join(File.expand_path(File.dirname(__FILE__)), "../../../tmp/emoticon.yml")
    @emoticon_images = File.join(File.expand_path(File.dirname(__FILE__)), "../../../tmp/emoticons")
  end

  context "PC のとき" do
    before(:each) do
      @res = Rack::MockRequest.env_for("/", 'Content-Type' => 'text/html; charset=utf-8')
    end

    it "docomo 絵文字が変換されないこと" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_cr))).call(@res)[2]
      expect(response_body(response)).to eq(@docomo_cr)
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_utf8))).call(@res)[2]
      expect(response_body(response)).to eq(@docomo_utf8)
    end

    it "au 絵文字が変換されないこと" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@au_cr))).call(@res)[2]
      expect(response_body(response)).to eq(@au_cr)
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@au_utf8))).call(@res)[2]
      expect(response_body(response)).to eq(@au_utf8)
    end

    it "softbank 絵文字が変換されないこと" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_cr))).call(@res)[2]
      expect(response_body(response)).to eq(@softbank_cr)
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_utf8))).call(@res)[2]
      expect(response_body(response)).to eq(@softbank_utf8)
    end
  end

  context "PC で絵文字を変換するとき" do
    before(:each) do
      unless FileTest.exist?(File.join(File.expand_path(File.dirname(__FILE__)), '../../../tmp/emoticon.yaml')) and
          FileTest.directory?(File.join(File.expand_path(File.dirname(__FILE__)), '../../../tmp/emoticons'))
        skip "emoticon.yaml and emoticons directory don't exists"
      end

      @res = Rack::MockRequest.env_for("/", 'Content-Type' => 'text/html; charset=utf-8')

      Jpmobile::Emoticon.pc_emoticon_yaml               = "tmp/emoticon.yaml"
      Jpmobile::Emoticon.pc_emoticon_image_path = @path = "tmp/emoticons"
    end

    after(:each) do
      Jpmobile::Emoticon.pc_emoticon_yaml       = nil
      Jpmobile::Emoticon.pc_emoticon_image_path = nil
    end

    it "Jpmobile::Emoticon.pc_emoticon? がtrueになること" do
      expect(Jpmobile::Emoticon.pc_emoticon?).to be_truthy
    end

    it "docomo 絵文字が画像に変換されること" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_cr))).call(@res)[2]
      expect(response_body(response)).to eq("<img src=\"#{@path}/sun.gif\" alt=\"sun\" />")
    end

    it "docomo 絵文字コードが画像に変換されること" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_utf8))).call(@res)[2]
      expect(response_body(response)).to eq("<img src=\"#{@path}/sun.gif\" alt=\"sun\" />")
    end

    it "au 絵文字が画像に変換されること" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@au_cr))).call(@res)[2]
      expect(response_body(response)).to eq("<img src=\"#{@path}/sun.gif\" alt=\"sun\" />")
    end

    it "au 絵文字コードが画像に変換されること" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@au_utf8))).call(@res)[2]
      expect(response_body(response)).to eq("<img src=\"#{@path}/sun.gif\" alt=\"sun\" />")
    end

    it "softbank 絵文字が画像に変換されること" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_cr))).call(@res)[2]
      expect(response_body(response)).to eq("<img src=\"#{@path}/sun.gif\" alt=\"sun\" />")
    end

    it "softbank 絵文字コードが画像に変換されること" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_utf8))).call(@res)[2]
      expect(response_body(response)).to eq("<img src=\"#{@path}/sun.gif\" alt=\"sun\" />")
    end

    it "Content-Type が変換できないものである場合には変換しないこと" do
      @res = Rack::MockRequest.env_for("/", 'Content-Type' => 'image/jpeg')
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_utf8))).call(@res)[2]
      expect(response_body(response)).to eq(@softbank_utf8)
    end
  end

  context "docomo のとき" do
    before(:each) do
      @res = Rack::MockRequest.env_for(
        "/",
        'HTTP_USER_AGENT' => "DoCoMo/2.0 SH902i(c100;TB;W24H12)",
        'Content-Type' => 'text/html; charset=utf-8')
    end

    it "docomo 絵文字が変換されること" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_cr))).call(@res)[2]
      expect(response_body(response)).to eq(sjis("\xf8\x9f"))
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_utf8))).call(@res)[2]
      expect(response_body(response)).to eq(sjis("\xf8\x9f"))

      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_docomopoint))).call(@res)[2]
      expect(response_body(response)).to eq(sjis("\xf9\x79"))
    end

    it "au 絵文字が変換されること" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@au_cr))).call(@res)[2]
      expect(response_body(response)).to eq(sjis("\xf8\x9f"))
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@au_utf8))).call(@res)[2]
      expect(response_body(response)).to eq(sjis("\xf8\x9f"))
    end

    it "softbank 絵文字が変換されること" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_cr))).call(@res)[2]
      expect(response_body(response)).to eq(sjis("\xf8\x9f"))
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_utf8))).call(@res)[2]
      expect(response_body(response)).to eq(sjis("\xf8\x9f"))
    end

    it "パラメータが変換されること" do
      query_string = ascii_8bit("q=" + URI.encode(sjis("\xf8\x9f")))

      res = Rack::MockRequest.env_for(
        "/?#{query_string}",
        "REQUEST_METHOD" => "GET",
        'HTTP_USER_AGENT' => 'DoCoMo/2.0 SH906i(c100;TB;W24H16)',
        'Content-Type' => 'text/html; charset=utf-8')
      res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::ParamsFilter.new(Jpmobile::Rack::Filter.new(RenderParamApp.new))).call(res)
      req = Rack::Request.new(res[1])
      expect(req.params['q']).to eq(utf8("\xee\x98\xbe"))
      expect(response_body(res)).to eq(sjis("\xf8\x9f"))
    end
  end

  context "au のとき" do
    before(:each) do
      @res = Rack::MockRequest.env_for(
        "/",
        'HTTP_USER_AGENT' => "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0",
        'Content-Type' => 'text/html; charset=utf-8')
    end

    it "docomo 絵文字が変換されること" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_cr))).call(@res)[2]
      expect(response_body(response)).to eq(sjis("\xf6\x60"))
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_utf8))).call(@res)[2]
      expect(response_body(response)).to eq(sjis("\xf6\x60"))

      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_docomopoint))).call(@res)[2]
      expect(response_body(response)).to eq(utf8_to_sjis("［ドコモポイント］"))
    end

    it "au 絵文字が変換されること" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@au_cr))).call(@res)[2]
      expect(response_body(response)).to eq(sjis("\xf6\x60"))
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@au_utf8))).call(@res)[2]
      expect(response_body(response)).to eq(sjis("\xf6\x60"))
    end

    it "softbank 絵文字が変換されること" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_cr))).call(@res)[2]
      expect(response_body(response)).to eq(sjis("\xf6\x60"))
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_utf8))).call(@res)[2]
      expect(response_body(response)).to eq(sjis("\xf6\x60"))
    end

    it "パラメータが変換されること" do
      query_string = ascii_8bit("q=" + URI.encode(sjis("\xf6\x60")))

      res = Rack::MockRequest.env_for(
        "/?#{query_string}",
        "REQUEST_METHOD" => "GET",
        'HTTP_USER_AGENT' => "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0",
        'Content-Type' => 'text/html; charset=utf-8')
      res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::ParamsFilter.new(Jpmobile::Rack::Filter.new(RenderParamApp.new))).call(res)
      req = Rack::Request.new(res[1])
      expect(req.params['q']).to eq([0xe488].pack("U"))
      expect(response_body(res)).to eq(sjis("\xf6\x60"))
    end
  end

  context "softbank のとき" do
    before(:each) do
      @res = Rack::MockRequest.env_for(
        "/",
        'HTTP_USER_AGENT' => "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1",
        'Content-Type' => 'text/html; charset=utf-8')
    end

    it "docomo 絵文字が変換されること" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_cr))).call(@res)[2]
      expect(response_body(response)).to eq([0xe04a].pack('U'))
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_utf8))).call(@res)[2]
      expect(response_body(response)).to eq([0xe04a].pack('U'))

      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_docomopoint))).call(@res)[2]
      expect(response_body(response)).to eq("［ドコモポイント］")
    end

    it "au 絵文字が変換されること" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@au_cr))).call(@res)[2]
      expect(response_body(response)).to eq([0xe04a].pack('U'))
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@au_utf8))).call(@res)[2]
      expect(response_body(response)).to eq([0xe04a].pack('U'))
    end

    it "softbank 絵文字が変換されること" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_cr))).call(@res)[2]
      expect(response_body(response)).to eq([0xe04a].pack('U'))
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_utf8))).call(@res)[2]
      expect(response_body(response)).to eq([0xe04a].pack('U'))
    end

    it "パラメータが変換されること" do
      query_string = "q=" + URI.encode([0xe04A].pack("U"))

      res = Rack::MockRequest.env_for(
        "/?#{query_string}",
        "REQUEST_METHOD" => "GET",
        'HTTP_USER_AGENT' => "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1",
        'Content-Type' => 'text/html; charset=utf-8')
      res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::ParamsFilter.new(Jpmobile::Rack::Filter.new(RenderParamApp.new))).call(res)
      req = Rack::Request.new(res[1])
      expect(req.params['q']).to eq([0xf04a].pack("U"))
      expect(response_body(res)).to eq([0xe04a].pack('U'))
    end
  end

  context "Vodafone のとき" do
    before(:each) do
      @res = Rack::MockRequest.env_for(
        "/",
        'HTTP_USER_AGENT' => "Vodafone/1.0/V705SH/SHJ001/SN000000000000000 Browser/VF-NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1",
        'Content-Type' => 'text/html; charset=utf-8')
    end

    it "softbank 絵文字が変換されること" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_cr))).call(@res)[2]
      expect(response_body(response)).to eq([0xe04a].pack('U'))
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_utf8))).call(@res)[2]
      expect(response_body(response)).to eq([0xe04a].pack('U'))
    end

    it "パラメータが変換されること" do
      query_string = "q=" + URI.encode([0xe04A].pack("U"))

      res = Rack::MockRequest.env_for(
        "/?#{query_string}",
        "REQUEST_METHOD" => "GET",
        'HTTP_USER_AGENT' => "Vodafone/1.0/V705SH/SHJ001/SN000000000000000 Browser/VF-NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1",
        'Content-Type' => 'text/html; charset=utf-8')
      res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::ParamsFilter.new(Jpmobile::Rack::Filter.new(RenderParamApp.new))).call(res)
      req = Rack::Request.new(res[1])
      expect(req.params['q']).to eq([0xf04a].pack("U"))
      expect(response_body(res)).to eq([0xe04a].pack('U'))
    end
  end

  context 'for iPhone' do
    context 'lower iOS 4' do
      before(:each) do
        @res = Rack::MockRequest.env_for(
          "/",
          'HTTP_USER_AGENT' => "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0_1 like Mac OS X; ja-jp) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A306 Safari/6531.22.7",
          'Content-Type' => 'text/html; charset=utf-8')
      end

      it 'should convert Softbank emoticon' do
        response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_cr))).call(@res)[2]
        expect(response_body(response)).to eq([0xe04a].pack('U'))
        response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_utf8))).call(@res)[2]
        expect(response_body(response)).to eq([0xe04a].pack('U'))
      end

      it "converts query parameters" do
        query_string = "q=" + URI.encode([0xe04A].pack("U"))

        res = Rack::MockRequest.env_for(
          "/?#{query_string}",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0_1 like Mac OS X; ja-jp) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A306 Safari/6531.22.7",
          'Content-Type' => 'text/html; charset=utf-8')
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::ParamsFilter.new(Jpmobile::Rack::Filter.new(RenderParamApp.new))).call(res)
        req = Rack::Request.new(res[1])
        expect(req.params['q']).to eq([0xf04a].pack("U"))
        expect(response_body(res)).to eq([0xe04a].pack('U'))
      end

      it 'should not convert 〓' do
        response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new('〓'))).call(@res)[2]
        expect(response_body(response)).to eq('〓')
      end
    end

    context 'upper iOS 5' do
      before(:each) do
        @res = Rack::MockRequest.env_for(
          "/",
          'HTTP_USER_AGENT' => "Mozilla/5.0 (iPhone; U; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Mobile/9A334 Safari/7534.48.3",
          'Content-Type' => 'text/html; charset=utf-8')
        @unicode_single = "\342\230\200"
        @unicode_multi  = "\342\233\205"
      end

      it "should convert Unicode emoticon" do
        response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@unicode_single))).call(@res)[2]
        expect(response_body(response)).to eq([0x2600].pack('U*'))
        response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@unicode_multi))).call(@res)[2]
        expect(response_body(response)).to eq([0x26C5].pack('U*'))
      end

      it "converts query parameters" do
        query_string = "q=" + URI.encode(@unicode_multi)

        res = Rack::MockRequest.env_for(
          "/?#{query_string}",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0_1 like Mac OS X; ja-jp) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A306 Safari/6531.22.7",
          'Content-Type' => 'text/html; charset=utf-8')
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::ParamsFilter.new(Jpmobile::Rack::Filter.new(RenderParamApp.new))).call(res)
        req = Rack::Request.new(res[1])
        expect(req.params['q']).to eq([0x26C5].pack("U"))
        expect(response_body(res)).to eq([0x26C5].pack('U'))
      end

      it 'should not convert 〓' do
        response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new('〓'))).call(@res)[2]
        expect(response_body(response)).to eq('〓')
      end
    end
  end

  context 'for Android' do
    before(:each) do
      @google_single = "\363\276\200\200"
      @google_multi  = "\363\276\200\217"
    end

    context 'mobile' do
      before(:each) do
        @res = Rack::MockRequest.env_for(
          "/",
          'HTTP_USER_AGENT' => 'Mozilla/5.0 (Linux; U; Android 1.6; ja-jp; SonyEriccsonSO-01B Build/R1EA018) AppleWebKit/528.5+ (KHTML, like Gecko) Version/3.1.2 Mobile Safari/525.20.1',
          'Content-Type' => 'text/html; charset=utf-8')
      end

      it "should convert Google emoticon" do
        response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@google_single))).call(@res)[2]
        expect(response_body(response)).to eq([0xFE000].pack('U*'))
        response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@google_multi))).call(@res)[2]
        expect(response_body(response)).to eq([0xFE00F].pack('U*'))
      end

      it "converts query parameters irreversibly" do
        query_string = "q=" + URI.encode(@google_multi)

        res = Rack::MockRequest.env_for(
          "/?#{query_string}",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => 'Mozilla/5.0 (Linux; U; Android 1.6; ja-jp; SonyEriccsonSO-01B Build/R1EA018) AppleWebKit/528.5+ (KHTML, like Gecko) Version/3.1.2 Mobile Safari/525.20.1',
          'Content-Type' => 'text/html; charset=utf-8')
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::ParamsFilter.new(Jpmobile::Rack::Filter.new(RenderParamApp.new))).call(res)
        req = Rack::Request.new(res[1])
        expect(req.params['q']).to eq([0xe63e, 0xe63f].pack("U*"))
        expect(response_body(res)).to eq([0xfe000, 0xfe001].pack("U*"))
      end

      it 'should not convert 〓' do
        response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new('〓'))).call(@res)[2]
        expect(response_body(response)).to eq('〓')
      end
    end

    context 'tablet' do
      before(:each) do
        @res = Rack::MockRequest.env_for(
          "/",
          'HTTP_USER_AGENT' => 'Mozilla/5.0 (Linux; U; Android 2.2; ja-jp; SC-01C Build/FROYO) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1',
          'Content-Type' => 'text/html; charset=utf-8')
      end

      it "should convert Google emoticon" do
        response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@google_single))).call(@res)[2]
        expect(response_body(response)).to eq([0xFE000].pack('U*'))
        response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@google_multi))).call(@res)[2]
        expect(response_body(response)).to eq([0xFE00F].pack('U*'))
      end

      it "converts query parameters irreversibly" do
        query_string = "q=" + URI.encode(@google_multi)

        res = Rack::MockRequest.env_for(
          "/?#{query_string}",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => 'Mozilla/5.0 (Linux; U; Android 2.2; ja-jp; SC-01C Build/FROYO) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1',
          'Content-Type' => 'text/html; charset=utf-8')
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::ParamsFilter.new(Jpmobile::Rack::Filter.new(RenderParamApp.new))).call(res)
        req = Rack::Request.new(res[1])
        expect(req.params['q']).to eq([0xe63e, 0xe63f].pack("U*"))
        expect(response_body(res)).to eq([0xfe000, 0xfe001].pack("U*"))
      end

      it 'should not convert 〓' do
        response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new('〓'))).call(@res)[2]
        expect(response_body(response)).to eq('〓')
      end

      it 'should convert unsupported emoticon to "〓"' do
        query_string = "q=" + URI.encode("\xF3\xBE\x93\xA4")

        res = Rack::MockRequest.env_for(
          "/?#{query_string}",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => 'Mozilla/5.0 (Linux; U; Android 2.2; ja-jp; SC-01C Build/FROYO) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1',
          'Content-Type' => 'text/html; charset=utf-8')
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::ParamsFilter.new(Jpmobile::Rack::Filter.new(RenderParamApp.new))).call(res)
        req = Rack::Request.new(res[1])
        expect(req.params['q']).to eq('〓')
        expect(response_body(res)).to eq('〓')
      end
    end
  end
end
