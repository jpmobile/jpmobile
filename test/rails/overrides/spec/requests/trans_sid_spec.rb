require 'rails_helper'

def get_with_session(controller, action, user_agent)
  open_session do |sess|
    sess.get "/#{controller}/#{action}", {}, {"HTTP_USER_AGENT" => user_agent}
  end
end

def describe_mobile_with_ua(user_agent, charset, &block)
  describe("trans_sid :mobile が指定されているコントローラに #{user_agent} からアクセスしたとき") do
    before(:each) do
      @controller = "trans_sid_mobile"
      @user_agent = user_agent
      @charset    = charset
    end

    instance_eval(&block)
  end
end

describe "trans_sid functional", :type => :request do
  before(:each) do
    @user ||= User.create(:name => "hoge")
  end

  shared_examples_for "trans_sid が起動しないとき" do
    it "で link_to の自動書き換えが行われない" do
      res = get_with_session(@controller, "link", @user_agent)

      expect(res.response.body).to match(/<a href=\"\/.+?\/link\">linkto<\/a>/)
    end
    it "で form の自動書き換えが行われない" do
      res = get_with_session(@controller, "form", @user_agent)

      expect(res.response.body).to match(/<form.*action=\"\/.+?\/form\".*accept-charset="#{@charset}"/)
    end
    it "で redirect の自動書き換えが行われない" do
      res = get_with_session(@controller, "redirect", @user_agent)

      res.response.header['Location'] =~ /\/$/
    end
  end

  shared_examples_for "trans_sid が起動するとき" do
    it "で link_to の自動書き換えが行われる" do
      res = get_with_session(@controller, "link", @user_agent)

      expect(res.response.body).to match(/<a href=\"\/.+?\/link\?_session_id=[a-zA-Z0-9]{32}\">linkto<\/a>/)
    end
    it "で form内にhiddenが差し込まれる" do
      res = get_with_session(@controller, "form", @user_agent)
      expect(res.response.body).to match(/<input type=\"hidden\" name=\".+\" value=\"[a-zA-Z0-9]{32}\"/)
    end
    it "で form の自動書き換えが行われる" do
      res = get_with_session(@controller, "form", @user_agent)

      expect(res.response.body).to match(/<form.*action=\"\/.+?\/form\?_session_id=[a-zA-Z0-9]{32}\".*accept-charset="#{@charset}"/)
    end
    it "で redirect の自動書き換えが行われる" do
      res = get_with_session(@controller, "redirect", @user_agent)

      res.response.header['Location'] =~ /\?_session_id=[a-zA-Z0-9]{32}$/
    end

    # resource paths
    it "で @user の link_to の自動書き換えが行われる" do
      res = get_with_session(@controller, "link_path", @user_agent)

      expect(res.response.body).to match(/<a href=\"\/users\/1\?_session_id=[a-zA-Z0-9]{32}\">linkto<\/a>/)
    end
    it "で @user の form の自動書き換えが行われる" do
      res = get_with_session(@controller, "form_path", @user_agent)

      expect(res.response.body).to match(/<form.*action=\"\/users\/1\?_session_id=[a-zA-Z0-9]{32}\".*accept-charset="#{@charset}"/)
    end
    it "で @path の redirect の自動書き換えが行われる" do
      res = get_with_session(@controller, "redirect_path", @user_agent)

      res.response.header['Location'] =~ /\?_session_id=[a-zA-Z0-9]{32}$/
    end

    # resource path with prefix
    it "で [:admin, @user] の link_to の自動書き換えが行われる" do
      res = get_with_session(@controller, "link_path_admin", @user_agent)

      expect(res.response.body).to match(/<a href=\"\/admin\/users\/1\?_session_id=[a-zA-Z0-9]{32}\">linkto<\/a>/)
    end
    it "で [:admin, @user] の form の自動書き換えが行われる" do
      res = get_with_session(@controller, "form_path_admin", @user_agent)

      expect(res.response.body).to match(/<form.*action=\"\/admin\/users\/1\?_session_id=[a-zA-Z0-9]{32}\".* accept-charset="#{@charset}"/)
    end
    it "で [:admin, @path] の redirect の自動書き換えが行われる" do
      res = get_with_session(@controller, "redirect_path_admin", @user_agent)

      res.response.header['Location'] =~ /\?_session_id=[a-zA-Z0-9]{32}$/
    end
  end

  describe TransSidBaseController, "という trans_sid が有効になっていないコントローラ" do
    before(:each) do
      @controller = "trans_sid_base"
      @user_agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"
      @charset    = "UTF-8"
    end

    it "の trans_sid_mode は nil" do
      get "/#{@controller}/link", {}, {"HTTP_USER_AGENT" => @user_agent}

      expect(controller.trans_sid_mode).to be_nil
    end
    it_should_behave_like "trans_sid が起動しないとき"
  end

  describe TransSidNoneController, "という trans_sid :none が指定されているコントローラ" do
    before(:each) do
      @controller = "trans_sid_none"
      @user_agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"
      @charset    = "UTF-8"
    end

    it "の trans_sid_mode は :none" do
      get "/#{@controller}/link", {}, {"HTTP_USER_AGENT" => @user_agent}

      expect(controller.trans_sid_mode).to eq(:none)
    end
    it_should_behave_like "trans_sid が起動しないとき"
  end

  describe TransSidAlwaysController, "という trans_sid :always が指定されているコントローラ" do
    before(:each) do
      @controller = "trans_sid_always"
      @user_agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"
      @charset    = "UTF-8"
    end

    it "の trans_sid_mode は :always" do
      get "/#{@controller}/link", {}, {"HTTP_USER_AGENT" => @user_agent}

      expect(controller.trans_sid_mode).to eq(:always)
    end
    it_should_behave_like "trans_sid が起動するとき"
  end

  describe TransSidMetalController, "という ActionController::Metal のコントローラ" do
    before(:each) do
      @controller = "trans_sid_metal"
      @user_agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"
      @charset    = "UTF-8"
    end

    it "で redirect_to がエラーにならない" do
      res = get_with_session(@controller, "redirect", @user_agent)

      expect(res.response).to be_redirect
    end
  end

  describe TransSidMobileController, "という trans_sid :mobile が指定されているコントローラ" do
    before(:each) do
      @controller = "trans_sid_mobile"
      @user_agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"
      @charset    = "UTF-8"
    end

    it "の trans_sid_mode は :mobile" do
      get "/#{@controller}/link", {}, {"HTTP_USER_AGENT" => @user_agent}

      expect(controller.trans_sid_mode).to eq(:mobile)
    end
  end

  describe TransSidAlwaysAndSessionOffController, "という trans_sid :always が指定されていて session がロードされていないとき" do
    before(:each) do
      @controller = "trans_sid_always_and_session_off"
      @user_agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"
      @charset    = "UTF-8"
    end

    it "の trans_sid_mode は :always" do
      res = get_with_session(@controller, "link", @user_agent)

      expect(res.controller.trans_sid_mode).to eq(:always)
    end
    it_should_behave_like "trans_sid が起動しないとき"
  end

  # NOTE: 3.0.0RC では accept-charset は UTF-8 で埋め込まれるので保留
  describe_mobile_with_ua "DoCoMo/2.0 SH902i(c100;TB;W24H12)", "Shift_JIS" do
    it_should_behave_like "trans_sid が起動するとき"
  end

  # NOTE: 3.0.0RC では accept-charset は UTF-8 で埋め込まれるので保留
  describe_mobile_with_ua "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0", "Shift_JIS" do
    it_should_behave_like "trans_sid が起動しないとき"
  end

  describe_mobile_with_ua "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1", "UTF-8" do
    it_should_behave_like "trans_sid が起動しないとき"
  end

  describe_mobile_with_ua "Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0", "UTF-8" do
    it_should_behave_like "trans_sid が起動しないとき"
  end

  describe TransSidAlwaysController, "という trans_sid :always が指定されているコントローラを session を作らずに Rack として使用するとき" do
    # before(:each) do
    #   @controller = "trans_sid_always"
    #   @user_agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"
    #   @charset    = "UTF-8"
    # end
    let(:controller) { TransSidAlwaysController }
    let(:user_agent) { "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)" }
    let(:charset) { "UTF-8" }
    let(:env) do
      {
        "rack.input" => "",
        "REQUEST_METHOD" => "GET",
        "HTTP_USER_AGENT" => user_agent
      }
    end

    it do
      # expect(0).to eq 1
      status, header, body = controller.action("link").call(env)
      expect(status.to_i).to eq 200
      expect(body).to match(/<a href=\"\/.+?\/link\">linkto<\/a>/)
    end

    it do
      status, header, body = controller.action("form").call(env)
      expect(status.to_i).to eq 200
      expect(body).to match(/<form.*action=\"\/.+?\/form\".*accept-charset="#{@charset}"/)
    end

    it do
      status, header, body = controller.action("redirect").call(env)
      expect(status.to_i).to eq 302
      expect(header['Location']).to match(/\?_session_id=[a-zA-Z0-9]{32}$/)
    end
  end
end
