require File.dirname(__FILE__) + '/../spec_helper'

describe "DoCoMo SH902i からのアクセス" do
  before do
    request.user_agent = "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
  end
  controller_name :mobile_spec
  it "request.mobile は Docomo のインスタンスであるべき" do
    request.mobile.should be_an_instance_of(Jpmobile::Mobile::Docomo)
  end
  it "request.mobile? は true であるべき" do
    request.mobile?.should be_true
  end
end

describe "DoCoMo SH902i からguid付きのアクセス" do
  controller_name :mobile_spec
  before do
    request.user_agent = "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
    request.env['HTTP_X_DCMGUID'] = "000000a"
  end
  it "guidを正しく取得できること" do
    request.mobile.guid.should == "000000a"
  end
  it "ident_subscriberでも正しく取得できること" do
    request.mobile.ident_subscriber.should == "000000a"
  end
end
