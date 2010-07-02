# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

def get_with_session(controller, action, user_agent)
  open_session do |sess|
    sess.get "/#{controller}/#{action}", {}, {"HTTP_USER_AGENT" => user_agent}
  end
end

shared_examples_for "trans_sid が起動しないとき" do
  it "で link_to の自動書き換えが行われない" do
    res = get_with_session(@controller, "link", @user_agent)

    res.response.body.should =~ /<a href=\"\/.+?\/link\">linkto<\/a>/
  end
  it "で form の自動書き換えが行われない" do
    res = get_with_session(@controller, "form", @user_agent)

    res.response.body.should =~ /<form action=\"\/.+?\/form\"/
  end
  it "で redirect の自動書き換えが行われない" do
    res = get_with_session(@controller, "redirect", @user_agent)

    res.response.header['Location'] =~ /\/$/
  end
end

shared_examples_for "trans_sid が起動するとき" do
  it "で link_to の自動書き換えが行われる" do
    res = get_with_session(@controller, "link", @user_agent)

    res.response.body.should =~ /<a href=\"\/.+?\/link\?_session_id=[a-zA-Z0-9]{32}\">linkto<\/a>/
  end
  it "で form の自動書き換えが行われる" do
    res = get_with_session(@controller, "form", @user_agent)

    res.response.body.should =~ /<form action=\"\/.+?\/form\?_session_id=[a-zA-Z0-9]{32}\"/
  end
  it "で redirect の自動書き換えが行われる" do
    res = get_with_session(@controller, "redirect", @user_agent)

    res.response.header['Location'] =~ /\?_session_id=[a-zA-Z0-9]{32}$/
  end
end

describe TransSidBaseController, "という trans_sid が有効になっていないコントローラ" do
  before(:each) do
    @controller = "trans_sid_base"
    @user_agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"
  end

  it "の trans_sid_mode は nil" do
    get "/#{@controller}/link", {}, {"HTTP_USER_AGENT" => @user_agent}

    controller.trans_sid_mode.should be_nil
  end
  it_should_behave_like "trans_sid が起動しないとき"
end

describe TransSidNoneController, "という trans_sid :none が指定されているコントローラ" do
  before(:each) do
    @controller = "trans_sid_none"
    @user_agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"
  end

  it "の trans_sid_mode は :none" do
    get "/#{@controller}/link", {}, {"HTTP_USER_AGENT" => @user_agent}

    controller.trans_sid_mode.should == :none
  end
  it_should_behave_like "trans_sid が起動しないとき"
end

describe TransSidAlwaysController, "という trans_sid :always が指定されているコントローラ" do
  before(:each) do
    @controller = "trans_sid_always"
    @user_agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"
  end

  it "の trans_sid_mode は :always" do
    get "/#{@controller}/link", {}, {"HTTP_USER_AGENT" => @user_agent}

    controller.trans_sid_mode.should == :always
  end
  it_should_behave_like "trans_sid が起動するとき"
end

describe TransSidMobileController, "という trans_sid :mobile が指定されているコントローラ" do
  before(:each) do
    @controller = "trans_sid_mobile"
    @user_agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"
  end

  it "の trans_sid_mode は :mobile" do
    get "/#{@controller}/link", {}, {"HTTP_USER_AGENT" => @user_agent}

    controller.trans_sid_mode.should == :mobile
  end
end

def describe_mobile_with_ua(user_agent, &block)
  describe("trans_sid :mobile が指定されているコントローラに #{user_agent} からアクセスしたとき") do
    before(:each) do
      @controller = "trans_sid_mobile"
      @user_agent = user_agent
    end

    instance_eval(&block)
  end
end

# NOTE: Rails 3.0b4 では session_id が自動的に生成されるようなので、強制的に書き換わってしまう。
# describe TransSidAlwaysAndSessionOffController, "という trans_sid :always が指定されていて session がロードされていないとき" do
#   before(:each) do
#     @controller = "trans_sid_always_and_session_off"
#     @user_agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"
#   end

#   it "の trans_sid_mode は :always" do
#     res = get_with_session(@controller, "link", @user_agent)

#     res.controller.trans_sid_mode.should == :always
#   end
#   it_should_behave_like "trans_sid が起動しないとき"
# end

describe_mobile_with_ua "DoCoMo/2.0 SH902i(c100;TB;W24H12)" do
  it_should_behave_like "trans_sid が起動するとき"
end

describe_mobile_with_ua "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0" do
  it_should_behave_like "trans_sid が起動しないとき"
end

describe_mobile_with_ua "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1" do
  it_should_behave_like "trans_sid が起動しないとき"
end

describe_mobile_with_ua "Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0" do
  it_should_behave_like "trans_sid が起動しないとき"
end
