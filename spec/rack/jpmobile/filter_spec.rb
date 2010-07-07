# -*- coding: utf-8 -*-
require File.join(File.expand_path(File.dirname(__FILE__)), '../../rack_helper.rb')

describe Jpmobile::Rack::Filter do
  include Rack::Test::Methods
  include Jpmobile::RackHelper

  context "漢字コード変換" do
    before(:each) do
      @utf8 = "ゆーてぃーえふえいとの日本語ですが何か"
      @sjis = utf8_to_sjis(@utf8)
    end

    context "docomo のとき" do
      it "Shift_JIS に変換されること" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => 'DoCoMo/2.0 SH906i(c100;TB;W24H16)')
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8))).call(res)
        res[1]['Content-Type'].should == "text/html; charset=Shift_JIS"
        response_body(res) == @sjis
      end
    end

    context "au のとき" do
      it "Shift_JIS に変換されること" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0")
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8))).call(res)
        res[1]['Content-Type'].should == "text/html; charset=Shift_JIS"
        response_body(res) == @sjis
      end
    end

    context "softbank のとき" do
      it "変換されないこと" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1")
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8))).call(res)
        res[1]['Content-Type'].should == "text/html"
        response_body(res) == @utf8
      end
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
      @softbank_emoji = utf8("\x1b\x24Fd\x0f")
    end

    context "docomo のとき" do
      it "数値参照絵文字が変換されること" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => 'DoCoMo/2.0 SH906i(c100;TB;W24H16)')
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8 + @emoji_docomo_cr))).call(res)
        response_body(res) == @sjis + @docomo_emoji
      end

      it "docomo のUTF-8絵文字が変換されること" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => 'DoCoMo/2.0 SH906i(c100;TB;W24H16)')
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8 + @emoji_docomo_utf8))).call(res)
        response_body(res) == @sjis + @docomo_emoji
      end

      it "au のUTF-8絵文字が変換されること" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => 'DoCoMo/2.0 SH906i(c100;TB;W24H16)')
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8 + @emoji_au_utf8))).call(res)
        response_body(res) == @sjis + @docomo_emoji
      end

      it "softbank のUTF-8絵文字が変換されること" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => 'DoCoMo/2.0 SH906i(c100;TB;W24H16)')
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8 + @emoji_softbank_utf8))).call(res)
        response_body(res) == @sjis + @docomo_emoji
      end
    end

    context "au のとき" do
      it "数値参照絵文字が変換されること" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0")
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8 + @emoji_au_cr))).call(res)
        response_body(res) == @sjis + @au_emoji
      end

      it "docomo のUTF-8絵文字が変換されること" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0")
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8 + @emoji_docomo_utf8))).call(res)
        response_body(res) == @sjis + @au_emoji
      end

      it "au のUTF-8絵文字が変換されること" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0")
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8 + @emoji_au_utf8))).call(res)
        response_body(res) == @sjis + @au_emoji
      end

      it "softbank のUTF-8絵文字が変換されること" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0")
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8 + @emoji_softbank_utf8))).call(res)
        response_body(res) == @sjis + @au_emoji
      end
    end

    context "softbank のとき" do
      it "数値参照絵文字が変換されること" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1")
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8 + @emoji_softbank_cr))).call(res)
        response_body(res) == @utf8 + @softbank_emoji
      end

      it "docomo のUTF-8絵文字が変換されること" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1")
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8 + @emoji_docomo_utf8))).call(res)
        response_body(res) == @utf8 + @softbank_emoji
      end

      it "au のUTF-8絵文字が変換されること" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1")
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8 + @emoji_au_utf8))).call(res)
        response_body(res) == @utf8 + @softbank_emoji
      end

      it "softbank のUTF-8絵文字が変換されること" do
        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "GET",
          'HTTP_USER_AGENT' => "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1")
        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@utf8 + @emoji_softbank_utf8))).call(res)
        response_body(res) == @utf8 + @softbank_emoji
      end
    end
  end
end
