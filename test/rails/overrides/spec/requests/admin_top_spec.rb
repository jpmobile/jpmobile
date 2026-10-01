require 'rails_helper'

describe Admin::TopController, type: :request do
  describe "GET 'full_path'" do
    context 'PCからのアクセスの場合' do
      let(:user_agent) do
        'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; .NET CLR 1.1.4322)'
      end
      it '_partial.html.erbが使用されること' do
        get '/admin/top/full_path', env: { 'HTTP_USER_AGENT' => user_agent }

        expect(response.body).to include('_partial.html.erb')
      end
    end

    context 'iPhoneからのアクセスの場合' do
      let(:user_agent) do
        'Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 Mobile/15E148 Safari/604.1'
      end
      it '_partial_smart_phone_iphone.html.erbが使用されること' do
        get '/admin/top/full_path', env: { 'HTTP_USER_AGENT' => user_agent }

        expect(response.body).to include('_partial_smart_phone_iphone.html.erb')
      end
    end
  end
end
