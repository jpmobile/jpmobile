require File.dirname(__FILE__) + '/../spec_helper'

describe "docomo_guid が起動しないとき", :shared => true do
  it "で link_to の自動書き換えが行われない" do
    get :link
    response.body.should =~ %r{^<a href="/.+?/link">linkto</a>$}
  end
end

describe "docomo_guid が起動するとき", :shared => true do
  it "で link_to の自動書き換えが行われる" do
    get :link
    response.body.should =~ %r{^<a href="/.+?/link\?guid=ON">linkto</a>$}
  end
end

describe DocomoGuidBaseController, "という docomo_guid が有効になっていないコントローラ" do
  controller_name :docomo_guid_base
  it "の docomo_guid_mode は nil" do
    controller.docomo_guid_mode.should be_nil
  end
  it_should_behave_like "docomo_guid が起動しないとき"
end

describe DocomoGuidAlwaysController, "という docomo_guid :always が指定されているコントローラ" do
  controller_name :docomo_guid_always
  it "の trans_sid_mode は :always" do
    controller.docomo_guid_mode.should == :always
  end
  it_should_behave_like "docomo_guid が起動するとき"
end

describe DocomoGuidDocomoController, "という docomo_guid :docomo が指定されているコントローラ" do
  controller_name :docomo_guid_docomo
  it "の docomo_guid_mode は :docomo" do
    controller.docomo_guid_mode.should == :docomo
  end
end

def describe_mobile_with_ua(user_agent, &block)
  describe("trans_sid :docomo が指定されているコントローラに #{user_agent} からアクセスしたとき") do
    controller_name :docomo_guid_docomo
    before do
      request.user_agent = user_agent
    end
    instance_eval(&block)
  end
end

describe_mobile_with_ua "DoCoMo/2.0 SH902i(c100;TB;W24H12)" do
  it_should_behave_like "docomo_guid が起動するとき"
end

describe_mobile_with_ua "J-PHONE/3.0/V301D" do
  it_should_behave_like "docomo_guid が起動しないとき"
end

describe_mobile_with_ua "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0" do
  it_should_behave_like "docomo_guid が起動しないとき"
end

describe_mobile_with_ua "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1" do
  it_should_behave_like "docomo_guid が起動しないとき"
end

describe_mobile_with_ua "Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0" do
  it_should_behave_like "docomo_guid が起動しないとき"
end

describe_mobile_with_ua "DoCoMo/1.0/N505i/c20/TB/W20H10 (compatible; Googlebot-Mobile/2.1; +http://www.google.com/bot.html)" do
  it_should_behave_like "docomo_guid が起動しないとき"
end


describe_mobile_with_ua "DoCoMo/2.0/SO502i (compatible; Y!J-SRD/1.0; http://help.yahoo.co.jp/help/jp/search/indexing/indexing-27.html)" do
  it_should_behave_like "docomo_guid が起動しないとき"
end
