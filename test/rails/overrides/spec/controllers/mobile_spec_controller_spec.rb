require 'rails_helper'

describe MobileSpecController, type: :controller do
  render_views

  let(:iphone_user_agent) do
    'Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; ja-jp) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16'
  end

  describe "GET 'index'" do
    context 'PC access' do
      it 'should be successful' do
        request.user_agent = 'Mozilla'
        get 'index'

        expect(response).to be_successful
        expect(response.body).to match(/PC page/)
        expect(request.smart_phone?).to be_falsey
      end
    end

    context 'smart phone access' do
      it 'should be successful' do
        request.user_agent = iphone_user_agent
        get 'index'
        expect(response).to be_successful
        expect(response.body).to match(/smart phone page/)
        expect(request.smart_phone?).to be_truthy
        expect(request.mobile).to be_a(Jpmobile::Mobile::Iphone)
      end
    end
  end

  describe "GET 'file_render'" do
    context 'PC access' do
      it 'should be successful' do
        request.user_agent = 'Mozilla'
        get 'file_render'

        expect(response).to be_successful
        expect(response.body).to match('The change you wanted was rejected')
        expect(request.smart_phone?).to be_falsey
      end
    end

    context 'smart phone access' do
      it 'should be successful' do
        request.user_agent = iphone_user_agent
        get 'file_render'

        expect(response).to be_successful
        expect(response.body).to match('The change you wanted was rejected')
        expect(request.smart_phone?).to be_truthy
        expect(request.mobile).to be_a(Jpmobile::Mobile::Iphone)
      end
    end
  end

  describe "GET 'mobile_not_exist'" do
    around do |example|
      orig_value = Jpmobile.config.fallback_view_selector
      Jpmobile.config.fallback_view_selector = true

      example.run

      Jpmobile.config.fallback_view_selector = orig_value
    end

    context 'PC access' do
      it 'should be successful' do
        request.user_agent = 'Mozilla'
        get 'mobile_not_exist'

        expect(response).to be_successful
        expect(response.body).to match('PC mobile_not_exist')
      end
    end

    context 'smart phone access' do
      it 'should be successful' do
        request.user_agent = iphone_user_agent
        get 'mobile_not_exist'

        expect(response).to be_successful
        expect(response.body).to match('PC mobile_not_exist')
      end
    end
  end
end
