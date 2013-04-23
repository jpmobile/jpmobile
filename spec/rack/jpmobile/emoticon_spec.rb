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
      response_body(response).should == @docomo_cr
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_utf8))).call(@res)[2]
      response_body(response).should == @docomo_utf8
    end

    it "au 絵文字が変換されないこと" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@au_cr))).call(@res)[2]
      response_body(response).should == @au_cr
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@au_utf8))).call(@res)[2]
      response_body(response).should == @au_utf8
    end

    it "softbank 絵文字が変換されないこと" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_cr))).call(@res)[2]
      response_body(response).should == @softbank_cr
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_utf8))).call(@res)[2]
      response_body(response).should == @softbank_utf8
    end
  end

  context "PC で絵文字を変換するとき" do
    before(:each) do
      unless FileTest.exist?(File.join(File.expand_path(File.dirname(__FILE__)), '../../../tmp/emoticon.yaml')) and
          FileTest.directory?(File.join(File.expand_path(File.dirname(__FILE__)), '../../../tmp/emoticons'))
        pending "emoticon.yaml and emoticons directory don't exists"
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
      Jpmobile::Emoticon.pc_emoticon?.should be_true
    end

    it "docomo 絵文字が画像に変換されること" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_cr))).call(@res)[2]
      response_body(response).should == "<img src=\"#{@path}/sun.gif\" alt=\"sun\" />"
    end

    it "docomo 絵文字コードが画像に変換されること" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_utf8))).call(@res)[2]
      response_body(response).should == "<img src=\"#{@path}/sun.gif\" alt=\"sun\" />"
    end

    it "au 絵文字が画像に変換されること" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@au_cr))).call(@res)[2]
      response_body(response).should == "<img src=\"#{@path}/sun.gif\" alt=\"sun\" />"
    end

    it "au 絵文字コードが画像に変換されること" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@au_utf8))).call(@res)[2]
      response_body(response).should == "<img src=\"#{@path}/sun.gif\" alt=\"sun\" />"
    end

    it "softbank 絵文字が画像に変換されること" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_cr))).call(@res)[2]
      response_body(response).should == "<img src=\"#{@path}/sun.gif\" alt=\"sun\" />"
    end

    it "softbank 絵文字コードが画像に変換されること" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_utf8))).call(@res)[2]
      response_body(response).should == "<img src=\"#{@path}/sun.gif\" alt=\"sun\" />"
    end

    it "Content-Type が変換できないものである場合には変換しないこと" do
      @res = Rack::MockRequest.env_for("/", 'Content-Type' => 'image/jpeg')
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_utf8))).call(@res)[2]
      response_body(response).should == @softbank_utf8
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
      response_body(response).should == sjis("\xf8\x9f")
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_utf8))).call(@res)[2]
      response_body(response).should == sjis("\xf8\x9f")

      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_docomopoint))).call(@res)[2]
      response_body(response).should == sjis("\xf9\x79")
    end

    it "au 絵文字が変換されること" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@au_cr))).call(@res)[2]
      response_body(response).should == sjis("\xf8\x9f")
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@au_utf8))).call(@res)[2]
      response_body(response).should == sjis("\xf8\x9f")
    end

    it "softbank 絵文字が変換されること" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_cr))).call(@res)[2]
      response_body(response).should == sjis("\xf8\x9f")
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_utf8))).call(@res)[2]
      response_body(response).should == sjis("\xf8\x9f")
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
      response_body(response).should == sjis("\xf6\x60")
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_utf8))).call(@res)[2]
      response_body(response).should == sjis("\xf6\x60")

      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_docomopoint))).call(@res)[2]
      response_body(response).should == utf8_to_sjis("［ドコモポイント］")
    end

    it "au 絵文字が変換されること" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@au_cr))).call(@res)[2]
      response_body(response).should == sjis("\xf6\x60")
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@au_utf8))).call(@res)[2]
      response_body(response).should == sjis("\xf6\x60")
    end

    it "softbank 絵文字が変換されること" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_cr))).call(@res)[2]
      response_body(response).should == sjis("\xf6\x60")
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_utf8))).call(@res)[2]
      response_body(response).should == sjis("\xf6\x60")
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
      response_body(response).should == [0xe04a].pack('U')
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_utf8))).call(@res)[2]
      response_body(response).should == [0xe04a].pack('U')

      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_docomopoint))).call(@res)[2]
      response_body(response).should == "［ドコモポイント］"
    end

    it "au 絵文字が変換されること" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@au_cr))).call(@res)[2]
      response_body(response).should == [0xe04a].pack('U')
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@au_utf8))).call(@res)[2]
      response_body(response).should == [0xe04a].pack('U')
    end

    it "softbank 絵文字が変換されること" do
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_cr))).call(@res)[2]
      response_body(response).should == [0xe04a].pack('U')
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_utf8))).call(@res)[2]
      response_body(response).should == [0xe04a].pack('U')
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
      response_body(response).should == [0xe04a].pack('U')
      response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_utf8))).call(@res)[2]
      response_body(response).should == [0xe04a].pack('U')
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
        response_body(response).should == [0xe04a].pack('U')
        response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_utf8))).call(@res)[2]
        response_body(response).should == [0xe04a].pack('U')
      end

      it 'should not convert 〓' do
        response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new('〓'))).call(@res)[2]
        response_body(response).should == '〓'
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
        response_body(response).should == [0x2600].pack('U*')
        response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@unicode_multi))).call(@res)[2]
        response_body(response).should == [0x26C5].pack('U*')
      end

      it 'should not convert 〓' do
        response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new('〓'))).call(@res)[2]
        response_body(response).should == '〓'
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
        response_body(response).should == [0xFE000].pack('U*')
        response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@google_multi))).call(@res)[2]
        response_body(response).should == [0xFE00F].pack('U*')
      end

      it 'should not convert 〓' do
        response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new('〓'))).call(@res)[2]
        response_body(response).should == '〓'
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
        response_body(response).should == [0xFE000].pack('U*')
        response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@google_multi))).call(@res)[2]
        response_body(response).should == [0xFE00F].pack('U*')
      end

      it 'should not convert 〓' do
        response = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new('〓'))).call(@res)[2]
        response_body(response).should == '〓'
      end
    end
  end

  describe 'QueryStringで渡された時' do
    it "UTF8がUTF8のままであること" do
      query_string = ascii_8bit("q=" + URI.encode(utf8("\xe3\x81\x82")))

      res = Rack::MockRequest.env_for("/?#{query_string}", 'Content-Type' => 'text/html; charset=utf-8')
      res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::ParamsFilter.new(Jpmobile::Rack::Filter.new(RenderParamApp.new))).call(res)
      req = Rack::Request.new(res[1])
      req.params['q'].should == utf8("\xe3\x81\x82")
    end

    it "Shift_JISがUTF8に変換されること" do
      query_string = ascii_8bit("q=" + URI.encode(sjis("\xb1")))

      res = Rack::MockRequest.env_for("/?#{query_string}", 'Content-Type' => 'text/html; charset=utf-8')
      res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::ParamsFilter.new(Jpmobile::Rack::Filter.new(RenderParamApp.new))).call(res)
      req = Rack::Request.new(res[1])
      req.params['q'].should == utf8("\xef\xbd\xb1")
    end

    it "docomo 絵文字が変換されること" do
      query_string = ascii_8bit("q=" + URI.encode(sjis("\xf8\x9f")))

      res = Rack::MockRequest.env_for("/?#{query_string}", 'Content-Type' => 'text/html; charset=utf-8')
      res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::ParamsFilter.new(Jpmobile::Rack::Filter.new(RenderParamApp.new))).call(res)
      req = Rack::Request.new(res[1])
      req.params['q'].should == utf8("\xee\x98\xbe")
    end

    it "au 絵文字が変換されること" do
      query_string = ascii_8bit("q=" + URI.encode(sjis("\xf6\x60")))

      res = Rack::MockRequest.env_for("/?#{query_string}", 'Content-Type' => 'text/html; charset=utf-8')
      res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::ParamsFilter.new(Jpmobile::Rack::Filter.new(RenderParamApp.new))).call(res)
      req = Rack::Request.new(res[1])
      req.params['q'].should == [0xe488].pack("U")
    end

    it "softbank 絵文字が変換されること" do
      query_string = "q=" + URI.encode([0xe04A].pack("U"))

      res = Rack::MockRequest.env_for("/?#{query_string}", 'Content-Type' => 'text/html; charset=utf-8')
      res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::ParamsFilter.new(Jpmobile::Rack::Filter.new(RenderParamApp.new))).call(res)
      req = Rack::Request.new(res[1])
      req.params['q'].should == [0xf04a].pack("U")
    end

    describe 'スマートフォン絵文字変換設定が有効なとき' do
      before(:each) do
        @smart_phone_emoticon_compatibility = Jpmobile.config.smart_phone_emoticon_compatibility
        Jpmobile.config.smart_phone_emoticon_compatibility = true
      end

      after(:each) do
        Jpmobile.config.smart_phone_emoticon_compatibility = @smart_phone_emoticon_compatibility
      end

      it "unicode 絵文字が変換されること" do
        query_string = "q=" + URI.encode("\342\233\205")

        res = Rack::MockRequest.env_for("/?#{query_string}", 'Content-Type' => 'text/html; charset=utf-8')
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::ParamsFilter.new(Jpmobile::Rack::Filter.new(RenderParamApp.new))).call(res)
        req = Rack::Request.new(res[1])
        req.params['q'].should == utf8("\xef\x81\x8a\x2c\xef\x81\x89")
      end

      it "google 絵文字が変換されること" do
        query_string = "q=" + URI.encode("\363\276\200\217")

        res = Rack::MockRequest.env_for("/?#{query_string}", 'Content-Type' => 'text/html; charset=utf-8')
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::ParamsFilter.new(Jpmobile::Rack::Filter.new(RenderParamApp.new))).call(res)
        req = Rack::Request.new(res[1])
        req.params['q'].should == [0xe63e, 0xe63f].pack("U*")
      end
    end

    describe 'スマートフォン絵文字変換設定が無効なとき' do
      before(:each) do
        @smart_phone_emoticon_compatibility = Jpmobile.config.smart_phone_emoticon_compatibility
        Jpmobile.config.smart_phone_emoticon_compatibility = false
      end

      after(:each) do
        Jpmobile.config.smart_phone_emoticon_compatibility = @smart_phone_emoticon_compatibility
      end

      it "unicode 絵文字が変換されないこと" do
        query_string = "q=" + URI.encode("\342\233\205")

        res = Rack::MockRequest.env_for("/?#{query_string}", 'Content-Type' => 'text/html; charset=utf-8')
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::ParamsFilter.new(Jpmobile::Rack::Filter.new(RenderParamApp.new))).call(res)
        req = Rack::Request.new(res[1])
        req.params['q'].should == [0x26C5].pack('U*')
      end

      it "google 絵文字が変換されないこと" do
        query_string = "q=" + URI.encode("\363\276\200\217")

        res = Rack::MockRequest.env_for("/?#{query_string}", 'Content-Type' => 'text/html; charset=utf-8')
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::ParamsFilter.new(Jpmobile::Rack::Filter.new(RenderParamApp.new))).call(res)
        req = Rack::Request.new(res[1])
        req.params['q'].should == utf8("\363\276\200\217")
      end
    end
  end
end
