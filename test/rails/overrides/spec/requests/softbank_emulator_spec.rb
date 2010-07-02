# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

describe "Softbank Emulator からのアクセスのとき" do
  it "request.mobile は Softbank のインスタンスであること" do
    get "/mobile_spec/index", {}, {"HTTP_USER_AGENT" => "Semulator"}

    request.mobile.should be_an_instance_of(Jpmobile::Mobile::Softbank)
    request.mobile?.should be_true
  end
end

describe "Vodafone Emulator からのアクセスのとき" do
  it "request.mobile は Vodafone のインスタンスであること" do
    get "/mobile_spec/index", {}, {"HTTP_USER_AGENT" => "Vemulator"}

    request.mobile.should be_an_instance_of(Jpmobile::Mobile::Vodafone)
    request.mobile?.should be_true
  end
end
