# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

shared_examples_for "docomo_guid が起動しないとき" do
  it "で link_to の自動書き換えが行われない" do
    get "/#{@controller}/link", {}, {"HTTP_USER_AGENT" => @user_agent}

    response.should have_tag('a') do |a|
      a.first['href'].should match(/^\/.+?\/link$/)
    end
  end
end

shared_examples_for "docomo_guid が起動するとき" do
  it "で link_to の自動書き換えが行われる" do
    get "/#{@controller}/link", {}, {"HTTP_USER_AGENT" => @user_agent}

    response.should have_tag('a') do |a|
      a.first['href'].should match(/^\/.+?\/link\?guid=ON$/)
    end
  end
end

describe DocomoGuidBaseController, "という docomo_guid が有効になっていないコントローラ" do
  before(:each) do
    @controller = "docomo_guid_base"
    @user_agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"
  end

  it "の docomo_guid_mode は nil" do
    get "/#{@controller}/link", {}, {"HTTP_USER_AGENT" => @user_agent}

    controller.docomo_guid_mode.should be_nil
  end
  it_should_behave_like "docomo_guid が起動しないとき"
end

describe DocomoGuidAlwaysController, "という docomo_guid :always が指定されているコントローラ" do
  before(:each) do
    @controller = "docomo_guid_always"
    @user_agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"
  end

  it "の docomo_guid_always は :always" do
    get "/#{@controller}/link", {}, {"HTTP_USER_AGENT" => @user_agent}

    controller.docomo_guid_mode.should == :always
  end
  it_should_behave_like "docomo_guid が起動するとき"
end

describe DocomoGuidDocomoController, "という docomo_guid :docomo が指定されているコントローラ" do
  before(:each) do
    @controller = "docomo_guid_docomo"
    @user_agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"
  end

  it "の docomo_guid_mode は :docomo" do
    get "/#{@controller}/link", {}, {"HTTP_USER_AGENT" => @user_agent}

    controller.docomo_guid_mode.should == :docomo
  end
end

def describe_mobile_with_ua(user_agent, &block)
  describe("docomo_guid :docomo が指定されているコントローラに #{user_agent} からアクセスしたとき") do
    before do
      @controller = "docomo_guid_docomo"
      @user_agent  = user_agent
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
