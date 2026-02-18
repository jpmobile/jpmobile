require 'rails_helper'

describe TemplatePathController, type: :controller do
  render_views

  describe 'iPhone からの Client Hints アクセス' do
    before do
      request.env['HTTP_SEC_CH_UA_PLATFORM'] = '"iOS"'
      request.env['HTTP_SEC_CH_UA_MOBILE'] = '?1'
    end

    it 'テンプレートの探索順が正しいこと' do
      get :index

      expect(controller.lookup_context.mobile).to eq(%w[smart_phone_iphone smart_phone])
    end
  end

  describe 'iPad からの Client Hints アクセス' do
    before do
      request.env['HTTP_SEC_CH_UA_PLATFORM'] = '"iOS"'
      request.env['HTTP_SEC_CH_UA_MOBILE'] = '?0'
    end

    it 'テンプレートの探索順が正しいこと' do
      get :index

      expect(controller.lookup_context.mobile).to eq(%w[tablet_ipad tablet smart_phone])
    end
  end

  describe 'Android からの Client Hints アクセス' do
    before do
      request.env['HTTP_SEC_CH_UA_PLATFORM'] = '"Android"'
      request.env['HTTP_SEC_CH_UA_MOBILE'] = '?1'
    end

    it 'テンプレートの探索順が正しいこと' do
      get :index

      expect(controller.lookup_context.mobile).to eq(%w[smart_phone_android smart_phone])
    end
  end

  describe 'Android タブレットからの Client Hints アクセス' do
    before do
      request.env['HTTP_SEC_CH_UA_PLATFORM'] = '"Android"'
      request.env['HTTP_SEC_CH_UA_MOBILE'] = '?0'
    end

    it 'テンプレートの探索順が正しいこと' do
      get :index

      expect(controller.lookup_context.mobile).to eq(%w[tablet_android_tablet tablet smart_phone])
    end
  end
end
