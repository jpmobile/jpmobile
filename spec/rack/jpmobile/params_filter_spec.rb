# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), '../../rack_helper.rb')

describe Jpmobile::Rack::ParamsFilter do
  include Rack::Test::Methods
  include Jpmobile::RackHelper
  include Jpmobile::Util

  context "漢字コード変換" do
    before(:each) do
      @query_params = {
        "hoge"       => "ほげ",
        "パラメータ" => "テストです■",
      }
      @form_params = {
        "bar"        => "万葉集",
        "アジャイル" => "僕の♪",
      }
    end

    context "Shift_JIS 変換の " do
      before(:each) do
        @query_string = @query_params.map {|k, v|
          "%s=%s" % [::Rack::Utils.escape(NKF.nkf("-sWx", k)), ::Rack::Utils.escape(NKF.nkf("-sWx", v))]
        }.join("&")
        @form_string = @form_params.map {|k, v|
          "%s=%s" % [NKF.nkf("-sWx", k), NKF.nkf("-sWx", v)]
        }.join("&")
      end

      context "docomo のとき" do
        it "Shift_JIS が UTF-8 に変換されること" do
          res = Rack::MockRequest.env_for(
            "/?#{@query_string}",
            "REQUEST_METHOD" => "POST",
            "CONTENT_TYPE" => 'application/x-www-form-urlencoded',
            'HTTP_USER_AGENT' => 'DoCoMo/2.0 SH906i(c100;TB;W24H16)',
            :input => @form_string)

          res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::ParamsFilter.new(UnitApplication.new)).call(res)
          req = Rack::Request.new(res[1])
          req.params.size.should == 4

          req.params[ascii_8bit(@query_params.keys.first.dup)].should == ascii_8bit(@query_params[@query_params.keys.first])
          req.params[ascii_8bit(@query_params.keys.last.dup)].should  == ascii_8bit(@query_params[@query_params.keys.last])

          req.params[ascii_8bit(@form_params.keys.first.dup)].should == ascii_8bit(@form_params[@form_params.keys.first])
          req.params[ascii_8bit(@form_params.keys.last.dup)].should  == ascii_8bit(@form_params[@form_params.keys.last])
        end
      end

      context "au のとき" do
        it "Shift_JIS が UTF-8 に変換されること" do
          res = Rack::MockRequest.env_for(
            "/?#{@query_string}",
            "REQUEST_METHOD" => "POST",
            "CONTENT_TYPE" => 'application/x-www-form-urlencoded',
            'HTTP_USER_AGENT' => "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0",
            :input => @form_string)

          res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::ParamsFilter.new(UnitApplication.new)).call(res)
          req = Rack::Request.new(res[1])
          req.params.size.should == 4

          req.params[ascii_8bit(@query_params.keys.first.dup)].should == ascii_8bit(@query_params[@query_params.keys.first])
          req.params[ascii_8bit(@query_params.keys.last.dup)].should  == ascii_8bit(@query_params[@query_params.keys.last])

          req.params[ascii_8bit(@form_params.keys.first.dup)].should == ascii_8bit(@form_params[@form_params.keys.first])
          req.params[ascii_8bit(@form_params.keys.last.dup)].should  == ascii_8bit(@form_params[@form_params.keys.last])
        end
      end
    end

    context "UTF-8 の" do
      before(:each) do
        @query_string = @query_params.map {|k, v|
          "%s=%s" % [::Rack::Utils.escape(k), ::Rack::Utils.escape(v)]
        }.join("&")
        @form_string = @form_params.map {|k, v|
          "%s=%s" % [k, v]
        }.join("&")
      end

      context "softbank のとき" do
        it "変換されないこと" do
          res = Rack::MockRequest.env_for(
            "/?#{@query_string}",
            "REQUEST_METHOD" => "POST",
            "CONTENT_TYPE" => 'application/x-www-form-urlencoded',
            'HTTP_USER_AGENT' => "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1",
            :input => @form_string)

          res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::ParamsFilter.new(UnitApplication.new)).call(res)
          req = Rack::Request.new(res[1])
          req.params.size.should == 4

          req.params[ascii_8bit(@query_params.keys.first.dup)].should == ascii_8bit(@query_params[@query_params.keys.first])
          req.params[ascii_8bit(@query_params.keys.last.dup)].should  == ascii_8bit(@query_params[@query_params.keys.last])

          req.params[ascii_8bit(@form_params.keys.first.dup)].should == ascii_8bit(@form_params[@form_params.keys.first])
          req.params[ascii_8bit(@form_params.keys.last.dup)].should  == ascii_8bit(@form_params[@form_params.keys.last])
        end
      end
    end
  end

  context "絵文字変換" do
    context "docomo の場合" do
      it "Shift_JIS 絵文字がUTF-8に変換されること" do
        query_string = "hoge=" + ::Rack::Utils.escape(sjis("\xf8\x9f"))
        form_string  = "foo="  + sjis("\xf8\xa1")

        res = Rack::MockRequest.env_for(
          "/?#{query_string}",
          "REQUEST_METHOD" => "POST",
          "CONTENT_TYPE" => 'application/x-www-form-urlencoded',
          'HTTP_USER_AGENT' => 'DoCoMo/2.0 SH906i(c100;TB;W24H16)',
          :input => form_string)

        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::ParamsFilter.new(UnitApplication.new)).call(res)
        req = Rack::Request.new(res[1])
        req.params.size.should == 2

        req.params["hoge"].should == ascii_8bit("\356\230\276")
        req.params["foo"].should  == ascii_8bit("\356\231\200")
      end
    end

    context "au の場合" do
      it "Shift_JIS 絵文字がUTF-8に変換されること" do
        query_string = "hoge=" + ::Rack::Utils.escape(sjis("\xf6\x59"))
        form_string  = "foo="  + sjis("\xf6\xfb")

        res = Rack::MockRequest.env_for(
          "/?#{query_string}",
          "REQUEST_METHOD" => "POST",
          "CONTENT_TYPE" => 'application/x-www-form-urlencoded',
          'HTTP_USER_AGENT' => "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0",
          :input => form_string)

        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::ParamsFilter.new(UnitApplication.new)).call(res)
        req = Rack::Request.new(res[1])
        req.params.size.should == 2

        req.params["hoge"].should == ascii_8bit("\356\222\201")
        req.params["foo"].should  == ascii_8bit("\356\224\242")
      end
    end

    context "Softbank の場合" do
      it "UTF-8 絵文字がUTF-8に変換されること" do
        query_string = ascii_8bit("hoge=" + ::Rack::Utils.escape([0xe001].pack('U')))
        form_string  = ascii_8bit("foo="  + [0xe21c].pack('U'))

        res = Rack::MockRequest.env_for(
          "/?#{query_string}",
          "REQUEST_METHOD" => "POST",
          "CONTENT_TYPE" => 'application/x-www-form-urlencoded',
          'HTTP_USER_AGENT' => "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1",
          :input => form_string)

        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::ParamsFilter.new(UnitApplication.new)).call(res)
        req = Rack::Request.new(res[1])
        req.params.size.should == 2

        req.params["hoge"].should == ascii_8bit("\xef\x80\x81")
        req.params["foo"].should  == ascii_8bit("\xef\x88\x9c")
      end
    end
  end

  context "パラメータの変換で" do
    context "値として" do
      it "+ が入ってるものが正確に取得できること(token)" do
        token = "lm/3Pu6RrY+kp8hsnEWp2xygYLInZIxwsB3UWeksaHQ="
        form_string  = ascii_8bit("foo=#{::Rack::Utils.escape(token)}")

        res = Rack::MockRequest.env_for(
          "/",
          "REQUEST_METHOD" => "POST",
          "CONTENT_TYPE" => 'application/x-www-form-urlencoded',
          'HTTP_USER_AGENT' => "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1",
          :input => form_string)

        res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::ParamsFilter.new(UnitApplication.new)).call(res)
        req = Rack::Request.new(res[1])
        req.params.size.should == 1

        req.params["foo"].should  == ascii_8bit(token)
      end
    end
  end
end
