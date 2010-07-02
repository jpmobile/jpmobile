# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

#
# 携帯からのアクセス
#
describe TemplatePathController, "DoCoMo SH902i からのアクセス" do
  before do
    @user_agent = "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
  end

  it 'テンプレートの探索順が正しいこと' do
    get "/template_path/index", {}, { "HTTP_USER_AGENT" => @user_agent}

    controller.view_paths.mobile_template_candidates.should == [ 'mobile_docomo', 'mobile' ]
  end
end

describe TemplatePathController, "au CA32 からのアクセス" do
  before do
    @user_agent = "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0"
  end
  it 'テンプレートの探索順が正しいこと' do
    get "/template_path/index", {}, { "HTTP_USER_AGENT" => @user_agent}

    controller.view_paths.mobile_template_candidates.should == [ 'mobile_au', 'mobile' ]
  end
end

describe TemplatePathController, "Vodafone V903T からのアクセス" do
  before do
    @user_agent = "Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0"
  end
  it 'テンプレートの探索順が正しいこと' do
    get "/template_path/index", {}, { "HTTP_USER_AGENT" => @user_agent}

    controller.view_paths.mobile_template_candidates.should == [ 'mobile_vodafone', 'mobile_softbank', 'mobile' ]
  end
end

describe TemplatePathController, "SoftBank 910T からのアクセス" do
  before do
    @user_agent = "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
  end
  it 'テンプレートの探索順が正しいこと' do
    get "/template_path/index", {}, { "HTTP_USER_AGENT" => @user_agent}

    controller.view_paths.mobile_template_candidates.should == [ 'mobile_softbank', 'mobile' ]
  end
end

describe TemplatePathController, "integrated_views" do
  describe "index" do
    context "PCからのアクセスの場合" do
      before do
        @user_agent = "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; .NET CLR 1.1.4322)"
      end
      it 'index.html.erbが使用されること' do
        get "/template_path/index", {}, { "HTTP_USER_AGENT" => @user_agent}

        response.should have_tag("h1", :content => "index.html.erb")
      end
    end
    context "DoCoMoからのアクセスの場合" do
      before do
        @user_agent = "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
      end
      it 'index_mobile_docomo.html.erbが使用されること' do
        get "/template_path/index", {}, { "HTTP_USER_AGENT" => @user_agent}

        response.should have_tag("h1", :content => "index_mobile_docomo.html.erb")
      end
    end
    context "SoftBankからのアクセスの場合" do
      before do
        @user_agent = "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
      end
      it 'index_mobile.html.erbが使用されること' do
        get "/template_path/index", {}, { "HTTP_USER_AGENT" => @user_agent}

        response.should have_tag("h1", :content => "index_mobile.html.erb")
      end
    end
  end
  describe "partial" do
    context "PCからのアクセスの場合" do
      before do
        @user_agent = "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; .NET CLR 1.1.4322)"
      end
      it '_partial.html.erbが使用されること' do
        get "/template_path/partial", {}, { "HTTP_USER_AGENT" => @user_agent}

        response.should have_tag("h2", :content => "_partial.html.erb")
      end
    end
    context "DoCoMoからのアクセスの場合" do
      before do
        @user_agent = "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
      end
      it '_partial_mobile_docomo.html.erbが使用されること' do
        get "/template_path/partial", {}, { "HTTP_USER_AGENT" => @user_agent}

        response.should have_tag("h2", :content => "_partial_mobile_docomo.html.erb")
      end
    end
    context "SoftBankからのアクセスの場合" do
      before do
        @user_agent = "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
      end
      it '_partial_mobile.html.erbが使用されること' do
        get "/template_path/partial", {}, { "HTTP_USER_AGENT" => @user_agent}

        response.should have_tag("h2", :content => "_partial_mobile.html.erb")
      end
    end
  end
end
