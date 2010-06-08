# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), '../../rack_helper.rb')
require 'uri'

describe Jpmobile::Rack::ParamsFilter do
  include Rack::Test::Methods

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
        "%s=%s" % [URI.encode(NKF.nkf("-sWx", k)), URI.encode(NKF.nkf("-sWx", v))]
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

        req.params[@query_params.keys.first].should == @query_params[@query_params.keys.first]
        req.params[@query_params.keys.last].should  == @query_params[@query_params.keys.last]

        req.params[@form_params.keys.first].should == @form_params[@form_params.keys.first]
        req.params[@form_params.keys.last].should  == @form_params[@form_params.keys.last]
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

        req.params[@query_params.keys.first].should == @query_params[@query_params.keys.first]
        req.params[@query_params.keys.last].should  == @query_params[@query_params.keys.last]

        req.params[@form_params.keys.first].should == @form_params[@form_params.keys.first]
        req.params[@form_params.keys.last].should  == @form_params[@form_params.keys.last]
      end
    end
  end
end
