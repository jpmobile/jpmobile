require File.dirname(__FILE__) + '/../spec_helper'

describe "H11T モバイルブラウザからのアクセス", :behaviour_type=>:controller do
  before do
    request.user_agent = "emobile/1.0.0 (H11T; like Gecko; Wireless) NetFront/3.4"
    request.env['HTTP_X_EM_UID'] = "u00000000000000000"
    request.env['REMOTE_ADDR'] = "117.55.1.232"
  end
  controller_name :mobile_spec
  it "request.mobile は Emobile のインスタンスであること" do
    request.mobile.should be_an_instance_of(Jpmobile::Mobile::Emobile)
  end
  it "request.mobile? は true であること" do
    request.mobile?.should be_true
  end
  it "のsubscribe番号を取得できること" do
    request.mobile.ident_subscriber.should == "u00000000000000000"
  end
  it "のIPアドレス空間を正しく検証できること" do
    request.mobile.valid_ip?.should be_true
  end
end

describe "S11HT からのアクセス", :behaviour_type=>:controller do
  before do
    request.user_agent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows CE; IEMobile 7.7) S11HT"
  end
  controller_name :mobile_spec
  it "request.mobile は Emobile のインスタンスであること" do
    request.mobile.should be_an_instance_of(Jpmobile::Mobile::Emobile)
  end
  it "request.mobile? は true であること" do
    request.mobile?.should be_true
  end
end
