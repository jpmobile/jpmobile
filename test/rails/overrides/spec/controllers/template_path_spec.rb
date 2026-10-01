require 'rails_helper'

describe TemplatePathController, type: :controller do
  render_views

  before do
    request.user_agent = user_agent
  end

  describe 'iPhone からのアクセス' do
    let(:user_agent) do
      'Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; ja-jp) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16'
    end
    it 'テンプレートの探索順が正しいこと' do
      get :index

      expect(controller.lookup_context.mobile).to eq(%w[smart_phone_iphone smart_phone])
    end
  end

  describe 'Android からのアクセス' do
    let(:user_agent) do
      'Mozilla/5.0 (Linux; U; Android 1.6; ja-jp; SonyEriccsonSO-01B Build/R1EA018) AppleWebKit/528.5+ (KHTML, like Gecko) Version/3.1.2 Mobile Safari/525.20.1'
    end
    it 'テンプレートの探索順が正しいこと' do
      get :index

      expect(controller.lookup_context.mobile).to eq(%w[smart_phone_android smart_phone])
    end
  end

  describe 'Windows Phone からのアクセス' do
    let(:user_agent) do
      'Mozilla/4.0 (Compatible; MSIE 6.0; Windows NT 5.1 T-01A_6.5; Windows Phone 6.5)'
    end
    it 'テンプレートの探索順が正しいこと' do
      get :index

      expect(controller.lookup_context.mobile).to eq(%w[smart_phone_windows_phone smart_phone])
    end
  end
end
