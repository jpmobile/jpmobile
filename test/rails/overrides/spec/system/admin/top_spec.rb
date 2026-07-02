require 'system_helper'

describe Admin::TopController, type: :feature do
  describe "GET 'full_path'" do
    before do
      page.driver.headers = { 'User-Agent' => user_agent }
    end

    context 'PCからのアクセスの場合' do
      let(:user_agent) do
        'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; .NET CLR 1.1.4322)'
      end
      it '_partial.html.erbが使用されること' do
        visit '/admin/top/full_path'

        expect(page).to have_content('_partial.html.erb')
      end
    end

    context 'iPhoneからのアクセスの場合' do
      let(:user_agent) do
        'Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; ja-jp) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16'
      end
      it '_partial_smart_phone_iphone.html.erbが使用されること' do
        visit '/admin/top/full_path'

        expect(page).to have_content('_partial_smart_phone_iphone.html.erb')
      end
    end
  end
end
