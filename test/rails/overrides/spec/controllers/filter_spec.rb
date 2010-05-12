# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe "文字コードフィルタが動作しているとき", :shared => true do
  it "はhtml以外は変換しないこと" do
    get :rawdata
    response.charset.should be_nil
    response.body.should == "アブラカダブラ"
  end
  it "response.bodyが空のときは文字コードを変更しないこと" do
    get :empty
    response.charset.should_not == "Shift_JIS"
  end
end

describe "Shift_JISで通信する端末との通信", :shared => true do
  it "はShift_JISで携帯に送出されること" do
    get :abracadabra_utf8
    response.body.should == "アブラカダブラ".tosjis
    response.charset.should == "Shift_JIS"
  end
  it "はxhtmlでもShift_JISで携帯に送出されること" do
    get :abracadabra_xhtml_utf8
    response.body.should == "アブラカダブラ".tosjis
    response.charset.should == "Shift_JIS"
  end
  it "はShift_JISで渡されたパラメタがparamsにUTF-8に変換されて格納されること" do
    get :index, :q => "アブラカダブラ".tosjis
    assigns[:q].should == "アブラカダブラ"
  end
  it "は半角カナのparamsを変換しないこと" do
    get :index, :q => "\261\314\336\327\266\300\336\314\336\327" # アブラカダブラ半角,SJIS
    assigns[:q].should == "ｱﾌﾞﾗｶﾀﾞﾌﾞﾗ"
  end
  it_should_behave_like "文字コードフィルタが動作しているとき"
end

describe "UTF-8で通信する端末との通信", :shared => true do
  it "はUTF-8で携帯に送出されること" do
    get :abracadabra_utf8
    response.body.should == "アブラカダブラ"
    response.charset.should == "utf-8"
  end
  it "はxhtmlでもUTF-8で携帯に送出されること" do
    get :abracadabra_xhtml_utf8
    response.body.should == "アブラカダブラ"
    response.charset.should == "utf-8"
  end
  it "はparamsにUTF-8のまま格納されること" do
    get :index, :q => "アブラカダブラ"
    assigns[:q].should == "アブラカダブラ"
  end
  it "は半角カナのparamsを変換しないこと" do
    get :index, :q => "ｱﾌﾞﾗｶﾀﾞﾌﾞﾗ"
    assigns[:q].should == "ｱﾌﾞﾗｶﾀﾞﾌﾞﾗ"
  end
  it_should_behave_like "文字コードフィルタが動作しているとき"
end

describe "Shift_JISで通信する端末との通信(半角変換付き)", :shared => true do
  it "は半角に変換されShift_JISで携帯に送出されること" do
    get :abracadabra_utf8
    response.body.should == "\261\314\336\327\266\300\336\314\336\327" # アブラカダブラ半角,SJIS
    response.charset.should == "Shift_JIS"
  end
  it "はShift_JISで渡されたパラメタがparamsにUTF-8に変換されて格納されること" do
    get :index, :q => "アブラカダブラ".tosjis
    assigns[:q].should == "アブラカダブラ"
  end
  it "は半角Shift_JISで渡されたパラメタがparamsに全角UTF-8に変換されて格納されること" do
    get :index, :q => "\261\314\336\327\266\300\336\314\336\327" # アブラカダブラ半角,SJIS
    assigns[:q].should == "アブラカダブラ"
  end
  it_should_behave_like "文字コードフィルタが動作しているとき"
end

describe "UTF-8で通信する端末との通信(半角変換付き)", :shared => true do
  it "はUTF-8半角で携帯に送出されること" do
    get :abracadabra_utf8
    response.body.should == "ｱﾌﾞﾗｶﾀﾞﾌﾞﾗ"
    response.charset.should == "utf-8"
  end
  it "はparamsにUTF-8のまま格納されること" do
    get :index, :q => "アブラカダブラ"
    assigns[:q].should == "アブラカダブラ"
  end
  it "は半角で渡されたparamsを全角に変換して格納すること" do
    get :index, :q => "ｱﾌﾞﾗｶﾀﾞﾌﾞﾗ"
    assigns[:q].should == "アブラカダブラ"
  end
  it_should_behave_like "文字コードフィルタが動作しているとき"
end

#
# PCからのアクセス
#
describe FilterController, "PCからのアクセス" do
  it_should_behave_like "UTF-8で通信する端末との通信"
end

describe HankakuFilterController, "PCからのアクセス" do
  it_should_behave_like "UTF-8で通信する端末との通信"
end

#
# 携帯からのアクセス
#
describe FilterController, "DoCoMo SH902i からのアクセス" do
  before do
    request.user_agent = "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
  end
  it_should_behave_like "Shift_JISで通信する端末との通信"
end

describe FilterController, "au CA32 からのアクセス" do
  before do
    request.user_agent = "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0"
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

#
# 半角フィルタ
#
describe HankakuFilterController, "DoCoMo SH902i からのアクセス" do
  before do
    request.user_agent = "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
  end
  it_should_behave_like "Shift_JISで通信する端末との通信(半角変換付き)"
end

describe HankakuFilterController, "SoftBank 910T からのアクセス" do
  before do
    request.user_agent = "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
  end
  it_should_behave_like "UTF-8で通信する端末との通信(半角変換付き)"
end
