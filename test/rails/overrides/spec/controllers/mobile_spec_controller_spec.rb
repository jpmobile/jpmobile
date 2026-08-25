require 'rails_helper'

describe MobileSpecController, type: :controller do
  render_views

  describe "GET 'index'" do
    context 'PC access' do
      it 'should be successful' do
        request.user_agent = 'Mozilla'
        get 'index'

        expect(response).to be_successful
        expect(response.body).to match(/RailsRoot PC/)
        expect(request.mobile?).to be_falsey
      end
    end

    context 'smart phone access' do
      it 'should be successful' do
        request.user_agent = 'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36'
        get 'index'
        expect(response).to be_successful
        expect(response.body).to match(/smart phone page/)
        expect(request.smart_phone?).to be_truthy
        expect(request.mobile).to be_a(Jpmobile::Mobile::Android)
      end

      it 'uses the smart phone view when fallback is enabled' do
        original_value = Jpmobile.config.fallback_view_selector
        Jpmobile.config.fallback_view_selector = true
        request.user_agent = 'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36'

        get 'index'

        expect(response.body).to match(/smart phone page/)
      ensure
        Jpmobile.config.fallback_view_selector = original_value
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
        expect(request.mobile?).to be_falsey
      end
    end

    context 'smart phone access' do
      it 'should be successful' do
        request.user_agent = 'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36'
        get 'file_render'

        expect(response).to be_successful
        expect(response.body).to match('The change you wanted was rejected')
        expect(request.smart_phone?).to be_truthy
        expect(request.mobile).to be_a(Jpmobile::Mobile::Android)
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
        expect(response.body).not_to match('RailsRoot PC mobile')
      end
    end

    context 'smart phone access' do
      it 'should be successful' do
        request.user_agent = 'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36'
        get 'mobile_not_exist'

        expect(response).to be_successful
        expect(response.body).not_to match('RailsRoot smart phone')
      end
    end
  end
end
