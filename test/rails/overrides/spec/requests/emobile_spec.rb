# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

describe "H11T モバイルブラウザからのアクセス" do
  before do
    @headers = {
      "HTTP_USER_AGENT"  => "emobile/1.0.0 (H11T; like Gecko; Wireless) NetFront/3.4",
      "HTTP_X_EM_UID"    => "u00000000000000000",
      "REMOTE_ADDR" => "117.55.1.232",
    }
  end

  it "request.mobile は Emobile のインスタンスであること" do
    get "/mobile_spec/index", {}, @headers

    request.mobile.should be_an_instance_of(Jpmobile::Mobile::Emobile)
  end
  it "request.mobile? は true であること" do
    get "/mobile_spec/index", {}, @headers

    request.mobile?.should be_true
  end
  it "のsubscribe番号を取得できること" do
    get "/mobile_spec/index", {}, @headers

    request.mobile.ident_subscriber.should == "u00000000000000000"
  end
  it "のIPアドレス空間を正しく検証できること" do
    get "/mobile_spec/index", {}, @headers

    request.mobile.valid_ip?.should be_true
  end
end

describe "S11HT からのアクセス" do
  before do
    @headers = {
      "HTTP_USER_AGENT"  => "Mozilla/4.0 (compatible; MSIE 6.0; Windows CE; IEMobile 7.7) S11HT",
    }
  end

  it "request.mobile は Emobile のインスタンスであること" do
    get "/mobile_spec/index", {}, @headers

    request.mobile.should be_an_instance_of(Jpmobile::Mobile::Emobile)
  end
  it "request.mobile? は true であること" do
    get "/mobile_spec/index", {}, @headers

    request.mobile?.should be_true
  end
end
