# -*- coding: utf-8 -*-
require 'rails_helper'

shared_examples_for "docomo_guid が起動しないとき" do
  render_views

  it "で link_to の自動書き換えが行われない" do
    get :link

    expect(response.body).to match(/href=\".+\/link\"/)
  end
end

shared_examples_for "docomo_guid が起動するとき" do
  it "で link_to の自動書き換えが行われる" do
    get :link

    expect(response.body).to match(/href=\".+\/link\?guid=ON\"/)
  end
end

describe DocomoGuidBaseController, :type => :controller do
  before(:each) do
    request.user_agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"
  end

  it "の docomo_guid_mode は nil" do
    get :link

    expect(controller.docomo_guid_mode).to be_nil
  end
  it_should_behave_like "docomo_guid が起動しないとき"
end

describe DocomoGuidAlwaysController, :type => :controller do
  before(:each) do
    request.user_agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"
  end

  it "の docomo_guid_always は :always" do
    get :link

    expect(controller.docomo_guid_mode).to eq(:always)
  end
  it_should_behave_like "docomo_guid が起動するとき"
end

describe DocomoGuidDocomoController, :type => :controller do
  before(:each) do
    request.user_agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"
  end

  it "の docomo_guid_mode は :docomo" do
    get :link

    expect(controller.docomo_guid_mode).to eq(:docomo)
  end

  shared_examples_for 'describe_mobile_with_ua' do |user_agent, example_name|
    before do
      request.user_agent = user_agent
    end

    it_should_behave_like example_name
  end

  it_should_behave_like 'describe_mobile_with_ua', "DoCoMo/2.0 SH902i(c100;TB;W24H12)", "docomo_guid が起動するとき"
  it_should_behave_like 'describe_mobile_with_ua', "J-PHONE/3.0/V301D", "docomo_guid が起動しないとき"
  it_should_behave_like 'describe_mobile_with_ua', "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0", "docomo_guid が起動しないとき"
  it_should_behave_like 'describe_mobile_with_ua', "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1", "docomo_guid が起動しないとき"
  it_should_behave_like 'describe_mobile_with_ua', "Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0", "docomo_guid が起動しないとき"
  it_should_behave_like 'describe_mobile_with_ua', "DoCoMo/1.0/N505i/c20/TB/W20H10 (compatible; Googlebot-Mobile/2.1; +http://www.google.com/bot.html)", "docomo_guid が起動しないとき"
  it_should_behave_like 'describe_mobile_with_ua', "DoCoMo/2.0/SO502i (compatible; Y!J-SRD/1.0; http://help.yahoo.co.jp/help/jp/search/indexing/indexing-27.html)", "docomo_guid が起動しないとき"
end
