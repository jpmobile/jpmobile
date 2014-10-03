require 'rails_helper'

describe Admin::TopController, :type => :feature do
  describe "GET 'full_path'" do
    before do
      page.driver.header('user_agent', user_agent)
    end

    context "PCからのアクセスの場合" do
      let(:user_agent) do
        "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; .NET CLR 1.1.4322)"
      end
      it '_partial.html.erbが使用されること' do
        visit '/admin/top/full_path'

        expect(page).to have_content("_partial.html.erb")
      end
    end

    context "DoCoMoからのアクセスの場合" do
      let(:user_agent) do
        "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
      end
      it '_partial_mobile_docomo.html.erbが使用されること' do
        visit '/admin/top/full_path'

        expect(page).to have_content("_partial_mobile_docomo.html.erb")
      end
    end
  end
end
