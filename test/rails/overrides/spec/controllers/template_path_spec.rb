require 'rails_helper'

describe TemplatePathController, :type => :controller do
  before do
    request.user_agent = user_agent
  end

  describe "DoCoMo SH902i からのアクセス" do
    let(:user_agent) do
      "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
    end

    it 'テンプレートの探索順が正しいこと' do
      get :index

      expect(controller.lookup_context.mobile).to eq([ 'mobile_docomo', 'mobile' ])
    end
  end

  describe "au CA32 からのアクセス" do
    let(:user_agent) do
      "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0"
    end
    it 'テンプレートの探索順が正しいこと' do
      get :index

      expect(controller.lookup_context.mobile).to eq([ 'mobile_au', 'mobile' ])
    end
  end

  describe "Vodafone V903T からのアクセス" do
    let(:user_agent) do
      "Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0"
    end
    it 'テンプレートの探索順が正しいこと' do
      get :index

      expect(controller.lookup_context.mobile).to eq([ 'mobile_vodafone', 'mobile_softbank', 'mobile' ])
    end
  end

  describe "SoftBank 910T からのアクセス" do
    let(:user_agent) do
      "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
    end
    it 'テンプレートの探索順が正しいこと' do
      get :index

      expect(controller.lookup_context.mobile).to eq([ 'mobile_softbank', 'mobile' ])
    end
  end

  describe "iPhone からのアクセス" do
    let(:user_agent) do
      'Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; ja-jp) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16'
    end
    it 'テンプレートの探索順が正しいこと' do
      get :index

      expect(controller.lookup_context.mobile).to eq([ 'smart_phone_iphone', 'smart_phone' ])
    end
  end

  describe "Android からのアクセス" do
    let(:user_agent) do
      'Mozilla/5.0 (Linux; U; Android 1.6; ja-jp; SonyEriccsonSO-01B Build/R1EA018) AppleWebKit/528.5+ (KHTML, like Gecko) Version/3.1.2 Mobile Safari/525.20.1'
    end
    it 'テンプレートの探索順が正しいこと' do
      get :index

      expect(controller.lookup_context.mobile).to eq([ 'smart_phone_android', 'smart_phone' ])
    end
  end

  describe "Windows Phone からのアクセス" do
    let(:user_agent) do
      'Mozilla/4.0 (Compatible; MSIE 6.0; Windows NT 5.1 T-01A_6.5; Windows Phone 6.5)'
    end
    it 'テンプレートの探索順が正しいこと' do
      get :index

      expect(controller.lookup_context.mobile).to eq([ 'smart_phone_windows_phone', 'smart_phone' ])
    end
  end
end
