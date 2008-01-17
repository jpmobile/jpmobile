require File.dirname(__FILE__) + '/../spec_helper'

describe "文字コードフィルタが動作しているとき", :shared => true do
  it "はhtml以外は変換しない" do
    get :rawdata
    response.charset.should be_nil
    response.body.should == "あいう"
  end
end

describe "Shift_JISで通信する端末との通信", :shared => true do
  it "はShift_JISで携帯に送出されること" do
    get :aiu_utf8
    response.body.should == "あいう".tosjis
    response.charset.should == "Shift_JIS"
  end
  it "はShift_JISで渡されたパラメタがparamsにUTF-8に変換されて格納されること" do
    get :index, :q => "アブラカダブラ".tosjis
    assigns[:q].should == "アブラカダブラ"
  end
  it_should_behave_like "文字コードフィルタが動作しているとき"
end

describe "UTF-8で通信する端末との通信", :shared => true do
  it "はUTF-8で携帯に送出されること" do
    get :aiu_utf8
    response.body.should == "あいう"
    response.charset.should == "utf-8"
  end
  it "はparamsにUTF-8のまま格納されること" do
    get :index, :q => "アブラカダブラ"
    assigns[:q].should == "アブラカダブラ"
  end
  it_should_behave_like "文字コードフィルタが動作しているとき"
end

describe FilterController, "DoCoMo SH902i からのアクセス" do
  before do
    request.user_agent = "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
  end
  it_should_behave_like "Shift_JISで通信する端末との通信"
end

describe FilterController, "J-PHONE V401SH からのアクセス" do
  before do
    request.user_agent = "J-PHONE/3.0/V401SH"
  end
  it_should_behave_like "Shift_JISで通信する端末との通信"
end

describe FilterController, "Vodafone V903T からのアクセス" do
  before do
    request.user_agent = "Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0"
  end
  it_should_behave_like "UTF-8で通信する端末との通信"
end

describe FilterController, "SoftBank 910T からのアクセス" do
  before do
    request.user_agent = "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
  end
  it_should_behave_like "UTF-8で通信する端末との通信"
end
