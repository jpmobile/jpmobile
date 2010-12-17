# -*- coding: utf-8 -*-
require File.join(File.expand_path(File.dirname(__FILE__)), '../../rack_helper.rb')

describe Jpmobile::Rack::Filter do
  include Rack::Test::Methods
  include Jpmobile::RackHelper

  context "漢字コード変換" do
    before(:each) do
      @utf8 = "ゆーてぃーえふえいとの\n日本語ですが何か"
      @sjis = utf8_to_sjis(@utf8)
    end

    context "docomo のとき" do
      it "Shift_JIS に変換されること" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => 'DoCoMo/2.0 SH906i(c100;TB;W24H16)',
          'Content-Type' => 'text/html; charset=utf-8')
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8))).call(res)
        res[1]['Content-Type'].should == "text/html; charset=Shift_JIS"
        response_body(res).should == @sjis
      end

      context "Content-Type" do
        it "が application/xhtml+xml のときに変換されること" do
          res = Rack::MockRequest.env_for(
            "/",
            "REQUEST_METHOD" => "GET",
            'HTTP_USER_AGENT' => 'DoCoMo/2.0 SH906i(c100;TB;W24H16)',
            'Content-Type' => 'application/xhtml+xml; charset=utf-8')
          res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8))).call(res)
          res[1]['Content-Type'].should == "application/xhtml+xml; charset=Shift_JIS"
          response_body(res).should == @sjis
        end

        it "が application/xml のときに変換されないこと" do
          res = Rack::MockRequest.env_for(
            "/",
            "REQUEST_METHOD" => "GET",
            'HTTP_USER_AGENT' => 'DoCoMo/2.0 SH906i(c100;TB;W24H16)',
            'Content-Type' => 'application/xml; charset=utf-8')
          res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8))).call(res)
          res[1]['Content-Type'].should == "application/xml; charset=utf-8"
          response_body(res).should == @utf8
        end

        it "が image/jpeg のときに変換されないこと" do
          res = Rack::MockRequest.env_for(
            "/",
            "REQUEST_METHOD" => "GET",
            'HTTP_USER_AGENT' => 'DoCoMo/2.0 SH906i(c100;TB;W24H16)',
            'Content-Type' => 'image/jpeg')
          res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8))).call(res)
          res[1]['Content-Type'].should == "image/jpeg"
          response_body(res).should == @utf8
        end

        it "が application/octet-stream のときに変換されないこと" do
          res = Rack::MockRequest.env_for(
            "/",
            "REQUEST_METHOD" => "GET",
            'HTTP_USER_AGENT' => 'DoCoMo/2.0 SH906i(c100;TB;W24H16)',
            'Content-Type' => 'application/octet-stream')
          res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8))).call(res)
          res[1]['Content-Type'].should == "application/octet-stream"
          response_body(res).should == @utf8
        end

        it "が video/mpeg のときに変換されないこと" do
          res = Rack::MockRequest.env_for(
            "/",
            "REQUEST_METHOD" => "GET",
            'HTTP_USER_AGENT' => 'DoCoMo/2.0 SH906i(c100;TB;W24H16)',
            'Content-Type' => 'video/mpeg')
          res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8))).call(res)
          res[1]['Content-Type'].should == "video/mpeg"
          response_body(res).should == @utf8
        end
      end
    end

    context "au のとき" do
      it "Shift_JIS に変換されること" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0",
          'Content-Type' => 'text/html; charset=utf-8')
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8))).call(res)
        res[1]['Content-Type'].should == "text/html; charset=Shift_JIS"
        response_body(res).should == @sjis
      end
    end

    context "softbank のとき" do
      it "変換されないこと" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1",
          'Content-Type' => 'text/html; charset=utf-8')
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8))).call(res)
        res[1]['Content-Type'].should == "text/html; charset=utf-8"
        response_body(res).should == @utf8
      end
    end

    it "_snowman が出力されないこと" do
      req = Rack::MockRequest.env_for(
        "/",
        "REQUEST_METHOD" => "GET",
        'HTTP_USER_AGENT' => 'DoCoMo/2.0 SH906i(c100;TB;W24H16)',
        'Content-Type' => 'text/html; charset=utf-8')
      res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new('<input name="utf8" type="hidden" value="&#x2713;" />'))).call(req)
      res[1]['Content-Type'].should == "text/html; charset=Shift_JIS"
      response_body(res).should == " "

      res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new('<input name="utf8" type="hidden" value="&#x2713;">'))).call(req)
      res[1]['Content-Type'].should == "text/html; charset=Shift_JIS"
      response_body(res).should == " "
    end

    it "Nokogiri 経由の _snowman が出力されないこと" do
      req = Rack::MockRequest.env_for(
        "/",
        "REQUEST_METHOD" => "GET",
        'HTTP_USER_AGENT' => 'DoCoMo/2.0 SH906i(c100;TB;W24H16)',
        'Content-Type' => 'text/html; charset=utf-8')
      res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new("<input name=\"utf8\" type=\"hidden\" value=\"#{[10003].pack("U")}\" />"))).call(req)
      res[1]['Content-Type'].should == "text/html; charset=Shift_JIS"
      response_body(res).should == " "

      res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new("<input name=\"utf8\" type=\"hidden\" value=\"#{[10003].pack("U")}\">"))).call(req)
      res[1]['Content-Type'].should == "text/html; charset=Shift_JIS"
      response_body(res).should == " "
    end
  end

  context "絵文字変換" do
    before(:each) do
      @utf8                = "ゆーてぃーえふえいとの日本語ですが何か"
      @emoji_docomo_cr     = "&#xe64b;"
      @emoji_au_cr         = "&#xe494;"
      @emoji_softbank_cr   = "&#xf244;"
      @emoji_docomo_utf8   = utf8([0xe64b].pack('U'))
      @emoji_au_utf8       = utf8([0xe494].pack('U'))
      @emoji_softbank_utf8 = utf8([0xf244].pack('U'))

      @sjis           = utf8_to_sjis(@utf8)
      @docomo_emoji   = sjis("\xf8\xac")
      @au_emoji       = sjis("\xf6\x6c")
      @softbank_emoji = utf8("\356\211\204")
    end

    context "docomo のとき" do
      it "数値参照絵文字が変換されること" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => 'DoCoMo/2.0 SH906i(c100;TB;W24H16)',
          'Content-Type' => 'text/html; charset=utf-8')
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8 + @emoji_docomo_cr))).call(res)
        response_body(res).should == @sjis + @docomo_emoji
      end

      it "docomo のUTF-8絵文字が変換されること" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => 'DoCoMo/2.0 SH906i(c100;TB;W24H16)',
          'Content-Type' => 'text/html; charset=utf-8')
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8 + @emoji_docomo_utf8))).call(res)
        response_body(res).should == @sjis + @docomo_emoji
      end

      it "au のUTF-8絵文字が変換されること" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => 'DoCoMo/2.0 SH906i(c100;TB;W24H16)',
          'Content-Type' => 'text/html; charset=utf-8')
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8 + @emoji_au_utf8))).call(res)
        response_body(res).should == @sjis + @docomo_emoji
      end

      it "softbank のUTF-8絵文字が変換されること" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => 'DoCoMo/2.0 SH906i(c100;TB;W24H16)',
          'Content-Type' => 'text/html; charset=utf-8')
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8 + @emoji_softbank_utf8))).call(res)
        response_body(res).should == @sjis + @docomo_emoji
      end
    end

    context "au のとき" do
      it "数値参照絵文字が変換されること" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0",
          'Content-Type' => 'text/html; charset=utf-8')
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8 + @emoji_au_cr))).call(res)
        response_body(res).should == @sjis + @au_emoji
      end

      it "docomo のUTF-8絵文字が変換されること" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0",
          'Content-Type' => 'text/html; charset=utf-8')
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8 + @emoji_docomo_utf8))).call(res)
        response_body(res).should == @sjis + @au_emoji
      end

      it "au のUTF-8絵文字が変換されること" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0",
          'Content-Type' => 'text/html; charset=utf-8')
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8 + @emoji_au_utf8))).call(res)
        response_body(res).should == @sjis + @au_emoji
      end

      it "softbank のUTF-8絵文字が変換されること" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0",
          'Content-Type' => 'text/html; charset=utf-8')
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8 + @emoji_softbank_utf8))).call(res)
        response_body(res).should == @sjis + @au_emoji
      end
    end

    context "softbank のとき" do
      it "数値参照絵文字が変換されること" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1",
          'Content-Type' => 'text/html; charset=utf-8')
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8 + @emoji_softbank_cr))).call(res)
        response_body(res).should == @utf8 + @softbank_emoji
      end

      it "docomo のUTF-8絵文字が変換されること" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1",
          'Content-Type' => 'text/html; charset=utf-8')
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8 + @emoji_docomo_utf8))).call(res)
        response_body(res).should == @utf8 + @softbank_emoji
      end

      it "au のUTF-8絵文字が変換されること" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1",
          'Content-Type' => 'text/html; charset=utf-8')
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8 + @emoji_au_utf8))).call(res)
        response_body(res).should == @utf8 + @softbank_emoji
      end

      it "softbank のUTF-8絵文字が変換されること" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1",
          'Content-Type' => 'text/html; charset=utf-8')
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8 + @emoji_softbank_utf8))).call(res)
        response_body(res).should == @utf8 + @softbank_emoji
      end
    end
  end
end
