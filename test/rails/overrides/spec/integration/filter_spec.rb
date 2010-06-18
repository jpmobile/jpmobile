# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe "文字コードフィルタが動作しているとき", :shared => true do
  it "はhtml以外は変換しないこと" do
    get "/#{@controller}/rawdata", {}, {"USER_AGENT" => @user_agent}
    response.charset.should be_nil
    response.body.should == "アブラカダブラ"
  end
  it "response.bodyが空のときは文字コードを変更しないこと" do
    get "/#{@controller}/empty", {}, {"USER_AGENT" => @user_agent}
    response.charset.should_not == "Shift_JIS"
  end
end

describe "Shift_JISで通信する端末との通信", :shared => true do
  it "はShift_JISで携帯に送出されること" do
    get "/#{@controller}/abracadabra_utf8", {}, {"USER_AGENT" => @user_agent}
    response.body.should == to_sjis("アブラカダブラ")
    response.charset.should == "Shift_JIS"
  end
  it "はxhtmlでもShift_JISで携帯に送出されること" do
    get "/#{@controller}/abracadabra_xhtml_utf8", {}, {"USER_AGENT" => @user_agent}
    response.body.should == to_sjis("アブラカダブラ")
    response.charset.should == "Shift_JIS"
  end
  it "はShift_JISで渡されたパラメタがparamsにUTF-8に変換されて格納されること" do
    get "/#{@controller}", {:q => to_sjis("アブラカダブラ")}, {"USER_AGENT" => @user_agent}
    assigns(:q).should == "アブラカダブラ"
  end
  it "は半角カナのparamsを変換しないこと" do
    # アブラカダブラ半角,SJIS
    get "/#{@controller}", {:q => sjis("\261\314\336\327\266\300\336\314\336\327")}, {"USER_AGENT" => @user_agent}
    assigns(:q).should == "ｱﾌﾞﾗｶﾀﾞﾌﾞﾗ"
  end
  it_should_behave_like "文字コードフィルタが動作しているとき"
end

describe "UTF-8で通信する端末との通信", :shared => true do
  it "はUTF-8で携帯に送出されること" do
    get "/#{@controller}/abracadabra_utf8", {}, {"USER_AGENT" => @user_agent}
    response.body.should == "アブラカダブラ"
    response.charset.should == "utf-8"
  end
  it "はxhtmlでもUTF-8で携帯に送出されること" do
    get "/#{@controller}/abracadabra_xhtml_utf8", {}, {"USER_AGENT" => @user_agent}
    response.body.should == "アブラカダブラ"
    response.charset.should == "utf-8"
  end
  it "はparamsにUTF-8のまま格納されること" do
    get "/#{@controller}/index", {:q => "アブラカダブラ"}, {"USER_AGENT" => @user_agent}
    assigns(:q).should == "アブラカダブラ"
  end
  it "は半角カナのparamsを変換しないこと" do
    get "/#{@controller}/index", {:q => "ｱﾌﾞﾗｶﾀﾞﾌﾞﾗ"}, {"USER_AGENT" => @user_agent}
    assigns(:q).should == "ｱﾌﾞﾗｶﾀﾞﾌﾞﾗ"
  end
  it_should_behave_like "文字コードフィルタが動作しているとき"
end

describe "Shift_JISで通信する端末との通信(半角変換付き)", :shared => true do
  it "は半角に変換されShift_JISで携帯に送出されること" do
    get "/#{@controller}/abracadabra_utf8", {}, {"USER_AGENT" => @user_agent}
    response.body.should == sjis("\261\314\336\327\266\300\336\314\336\327") # アブラカダブラ半角,SJIS
    response.charset.should == "Shift_JIS"
  end
  it "はShift_JISで渡されたパラメタがparamsにUTF-8に変換されて格納されること" do
    get "/#{@controller}/index", {:q => to_sjis("アブラカダブラ")}, {"USER_AGENT" => @user_agent}
    assigns(:q).should == "アブラカダブラ"
  end
  it "は半角Shift_JISで渡されたパラメタがparamsに全角UTF-8に変換されて格納されること" do
    # アブラカダブラ半角,SJIS
    get "/#{@controller}/index", {:q => sjis("\261\314\336\327\266\300\336\314\336\327")}, {"USER_AGENT" => @user_agent}
    assigns(:q).should == "アブラカダブラ"
  end
  it_should_behave_like "文字コードフィルタが動作しているとき"
end

describe "UTF-8で通信する端末との通信(半角変換付き)", :shared => true do
  it "はUTF-8半角で携帯に送出されること" do
    get "/#{@controller}/abracadabra_utf8", {}, {"USER_AGENT" => @user_agent}
    response.body.should == "ｱﾌﾞﾗｶﾀﾞﾌﾞﾗ"
    response.charset.should == "utf-8"
  end
  it "はparamsにUTF-8のまま格納されること" do
    get "/#{@controller}/index", {:q => "アブラカダブラ"}, {"USER_AGENT" => @user_agent}
    assigns(:q).should == "アブラカダブラ"
  end
  it "は半角で渡されたparamsを全角に変換して格納すること" do
    get "/#{@controller}/index", {:q => "ｱﾌﾞﾗｶﾀﾞﾌﾞﾗ"}, {"USER_AGENT" => @user_agent}
    assigns(:q).should == "アブラカダブラ"
  end
  it_should_behave_like "文字コードフィルタが動作しているとき"
end

#
# PCからのアクセス
#
describe FilterController, "PCからのアクセス" do
  before(:each) do
    @user_agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"
    @controller = "filter"
  end
  it_should_behave_like "UTF-8で通信する端末との通信"
end

describe HankakuFilterController, "PCからのアクセス" do
  before(:each) do
    @user_agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"
    @controller = "hankaku_filter"
  end
  it_should_behave_like "UTF-8で通信する端末との通信"
end

#
# 携帯からのアクセス
#
describe FilterController, "DoCoMo SH902i からのアクセス" do
  before do
    @user_agent = "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
    @controller = "filter"
  end
  it_should_behave_like "Shift_JISで通信する端末との通信"
end

describe FilterController, "au CA32 からのアクセス" do
  before do
    @user_agent = "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0"
    @controller = "filter"
  end
  it_should_behave_like "Shift_JISで通信する端末との通信"
end

describe FilterController, "Vodafone V903T からのアクセス" do
  before do
    @user_agent = "Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0"
    @controller = "filter"
  end
  it_should_behave_like "UTF-8で通信する端末との通信"
end

describe FilterController, "SoftBank 910T からのアクセス" do
  before do
    @user_agent = "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
    @controller = "filter"
  end
  it_should_behave_like "UTF-8で通信する端末との通信"
end

#
# 半角フィルタ
#
describe HankakuFilterController, "DoCoMo SH902i からのアクセス" do
  before do
    @user_agent = "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
    @controller = "hankaku_filter"
  end
  it_should_behave_like "Shift_JISで通信する端末との通信(半角変換付き)"
end

describe HankakuFilterController, "SoftBank 910T からのアクセス" do
  before do
    @user_agent = "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
    @controller = "hankaku_filter"
  end
  it_should_behave_like "UTF-8で通信する端末との通信(半角変換付き)"
end
