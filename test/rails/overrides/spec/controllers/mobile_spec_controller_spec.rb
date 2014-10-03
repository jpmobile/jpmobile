require 'rails_helper'

describe MobileSpecController, :type => :controller do
  render_views

  describe "GET 'index'" do
    context 'PC access' do
      it "should be successful" do
        request.user_agent = 'Mozilla'
        get 'index'

        expect(response).to be_success
        expect(response).to render_template('index')
        expect(request.mobile?).to be_falsey
      end
    end

    context 'mobile access' do
      it "should be successful" do
        request.user_agent = "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
        get 'index'
        expect(response).to be_success
        expect(response).to render_template('index_mobile')
        expect(request.mobile?).to be_truthy
        expect(request.mobile).to be_a(Jpmobile::Mobile::Docomo)
      end
    end
  end

  describe "GET 'file_render'" do
    context 'PC access' do
      it "should be successful" do
        request.user_agent = 'Mozilla'
        get 'file_render'

        expect(response).to be_success
        expect(response.body).to match('The change you wanted was rejected')
        expect(request.mobile?).to be_falsey
      end
    end

    context 'mobile access' do
      it "should be successful" do
        request.user_agent = "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
        get 'file_render'

        expect(response).to be_success
        expect(response.body).to match('The change you wanted was rejected')
        expect(request.mobile?).to be_truthy
        expect(request.mobile).to be_a(Jpmobile::Mobile::Docomo)
      end
    end
  end

  describe "GET 'no_mobile'" do
    around do |example|
      orig_value = Jpmobile.config.fallback_view_selector
      Jpmobile.config.fallback_view_selector = true

      example.run

      Jpmobile.config.fallback_view_selector = orig_value
    end

    context 'PC access' do
      it "should be successful" do
        request.user_agent = 'Mozilla'
        get 'no_mobile'

        expect(response).to be_success
        expect(response.body).not_to match('RailsRoot PC mobile')
      end
    end

    context 'mobile access' do
      it "should be successful" do
        request.user_agent = "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
        get 'no_mobile'

        expect(response).to be_success
        expect(response.body).not_to match('RailsRoot mobile')
      end
    end
  end
end
