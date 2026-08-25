require 'rails_helper'

describe TemplatePathController, 'integrated_views', type: :request do
  describe 'index' do
    context 'PCからのアクセスの場合' do
      let(:user_agent) do
        'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; .NET CLR 1.1.4322)'
      end
      it 'index.html.erbが使用されること' do
        get '/template_path/index', env: { 'HTTP_USER_AGENT' => user_agent }

        expect(response.body).to include('index.html.erb')
      end
    end

    context 'Androidからのアクセスの場合' do
      let(:user_agent) do
        'Mozilla/5.0 (Linux; U; Android 1.6; ja-jp; SonyEriccsonSO-01B Build/R1EA018) AppleWebKit/528.5+ (KHTML, like Gecko) Version/3.1.2 Mobile Safari/525.20.1'
      end
      it 'index_smart_phone.html.erbが使用されること' do
        get '/template_path/index', env: { 'HTTP_USER_AGENT' => user_agent }

        expect(response.body).to include('index_smart_phone.html.erb')
      end

      it 'show.html.erb がなくとも show_smart_phone.html.erbが使用されること' do
        get '/template_path/show', env: { 'HTTP_USER_AGENT' => user_agent }

        expect(response.body).to include('show_smart_phone.html.erb')
      end

      it 'disable_mobile_view! のときには index.html.erb が使用されること' do
        get '/template_path/index?pc=true', env: { 'HTTP_USER_AGENT' => user_agent }

        expect(response.body).to include('index.html.erb')
      end
    end

    context 'iPhoneからのアクセスの場合' do
      let(:user_agent) do
        'Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; ja-jp) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16'
      end
      it 'smart_phone_iphone.html.erbが使用されること' do
        get '/template_path/index', env: { 'HTTP_USER_AGENT' => user_agent }

        expect(response.body).to include('smart_phone_iphone.html.erb')
      end
    end

    context 'Windows Phoneからのアクセスの場合' do
      let(:user_agent) do
        'Mozilla/4.0 (Compatible; MSIE 6.0; Windows NT 5.1 T-01A_6.5; Windows Phone 6.5)'
      end
      it 'smart_phone.html.erbが使用されること' do
        get '/template_path/index', env: { 'HTTP_USER_AGENT' => user_agent }

        expect(response.body).to include('smart_phone.html.erb')
      end
    end
  end

  context 'only smart_phone view' do
    context 'iPadからのアクセスの場合' do
      let(:user_agent) do
        'Mozilla/5.0 (iPad; U; CPU OS 4_3 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8F191 Safari/6533.18.5'
      end
      it 'smart_phone_only.html.erbが使用されること' do
        get '/template_path/smart_phone_only', env: { 'HTTP_USER_AGENT' => user_agent }

        expect(response.body).to include('smart_phone_only_smart_phone.html.erb')
      end
    end

    context 'Android Tabletからのアクセスの場合' do
      let(:user_agent) do
        'Mozilla/5.0 (Linux; U; Android 2.2; ja-jp; SC-01C Build/FROYO) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1'
      end
      it 'smart_phone_only.html.erbが使用されること' do
        get '/template_path/smart_phone_only', env: { 'HTTP_USER_AGENT' => user_agent }

        expect(response.body).to include('smart_phone_only_smart_phone.html.erb')
      end
    end
  end

  context 'with_tblt view' do
    context 'iPadからのアクセスの場合' do
      let(:user_agent) do
        'Mozilla/5.0 (iPad; U; CPU OS 4_3 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8F191 Safari/6533.18.5'
      end
      it 'with_tblt_tablet.html.erbが使用されること' do
        get '/template_path/with_tblt', env: { 'HTTP_USER_AGENT' => user_agent }

        expect(response.body).to include('with_tblt_tablet.html.erb')
      end
    end

    context 'Android Tabletからのアクセスの場合' do
      let(:user_agent) do
        'Mozilla/5.0 (Linux; U; Android 2.2; ja-jp; SC-01C Build/FROYO) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1'
      end
      it 'with_tblt_tablet.html.erbが使用されること' do
        get '/template_path/with_tblt', env: { 'HTTP_USER_AGENT' => user_agent }

        expect(response.body).to include('with_tblt_tablet.html.erb')
      end
    end
  end

  context 'with_ipd view' do
    context 'iPadからのアクセスの場合' do
      let(:user_agent) do
        'Mozilla/5.0 (iPad; U; CPU OS 4_3 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8F191 Safari/6533.18.5'
      end
      it 'with_ipd_tablet_ipad.html.erbが使用されること' do
        get '/template_path/with_ipd', env: { 'HTTP_USER_AGENT' => user_agent }

        expect(response.body).to include('with_ipd_tablet_ipad.html.erb')
      end
    end

    context 'Android Tabletからのアクセスの場合' do
      let(:user_agent) do
        'Mozilla/5.0 (Linux; U; Android 2.2; ja-jp; SC-01C Build/FROYO) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1'
      end
      it 'with_ipd.html.erbが使用されること' do
        get '/template_path/with_ipd', env: { 'HTTP_USER_AGENT' => user_agent }

        expect(response.body).to include('with_ipd.html.erb')
      end
    end
  end

  context 'partial' do
    context 'PCからのアクセスの場合' do
      let(:user_agent) do
        'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; .NET CLR 1.1.4322)'
      end
      it '_partial.html.erbが使用されること' do
        get '/template_path/partial', env: { 'HTTP_USER_AGENT' => user_agent }

        expect(response.body).to include('_partial.html.erb')
      end
    end

    context 'iPhoneからのアクセスの場合' do
      let(:user_agent) do
        'Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; ja-jp) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16'
      end
      it '_partial_smart_phone_iphone.html.erbが使用されること' do
        get '/template_path/partial', env: { 'HTTP_USER_AGENT' => user_agent }

        expect(response.body).to include('_partial_smart_phone_iphone.html.erb')
      end
    end

    context 'Androidからのアクセスの場合' do
      let(:user_agent) do
        'Mozilla/5.0 (Linux; U; Android 1.6; ja-jp; SonyEriccsonSO-01B Build/R1EA018) AppleWebKit/528.5+ (KHTML, like Gecko) Version/3.1.2 Mobile Safari/525.20.1'
      end
      it '_partial_smart_phone.html.erbが使用されること' do
        get '/template_path/partial', env: { 'HTTP_USER_AGENT' => user_agent }

        expect(response.body).to include('_partial_smart_phone.html.erb')
      end
    end

    context 'Windows Phoneからのアクセスの場合' do
      let(:user_agent) do
        'Mozilla/4.0 (Compatible; MSIE 6.0; Windows NT 5.1 T-01A_6.5; Windows Phone 6.5)'
      end
      it '_partial_smart_phone.html.erbが使用されること' do
        get '/template_path/partial', env: { 'HTTP_USER_AGENT' => user_agent }

        expect(response.body).to include('_partial_smart_phone.html.erb')
      end
    end
  end

  context 'full_path_partial' do
    context 'PCからのアクセスの場合' do
      let(:user_agent) do
        'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; .NET CLR 1.1.4322)'
      end
      it '_partial.html.erbが使用されること' do
        get '/template_path/full_path_partial', env: { 'HTTP_USER_AGENT' => user_agent }

        expect(response.body).to include('_partial.html.erb')
      end
    end
  end

  context 'fallback_view_selector が有効な場合' do
    around do |example|
      original_value = Jpmobile.config.fallback_view_selector
      Jpmobile.config.fallback_view_selector = true

      example.run
    ensure
      Jpmobile.config.fallback_view_selector = original_value
    end

    context 'iPhoneからのアクセスの場合' do
      let(:user_agent) do
        'Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; ja-jp) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16'
      end

      it 'キャリア固有 view を使用すること' do
        get '/template_path/index', env: { 'HTTP_USER_AGENT' => user_agent }

        expect(response.body).to include('index_smart_phone_iphone.html.erb')
      end

      it 'キャリア固有 partial を使用すること' do
        get '/template_path/partial_only', env: { 'HTTP_USER_AGENT' => user_agent }

        expect(response.body).to include('_partial_smart_phone_iphone.html.erb')
      end
    end

    context 'Androidからのアクセスの場合' do
      let(:user_agent) do
        'Mozilla/5.0 (Linux; U; Android 1.6; ja-jp; SonyEriccsonSO-01B Build/R1EA018) AppleWebKit/528.5+ (KHTML, like Gecko) Version/3.1.2 Mobile Safari/525.20.1'
      end

      it '利用可能な smart phone view へフォールバックすること' do
        get '/template_path/index', env: { 'HTTP_USER_AGENT' => user_agent }

        expect(response.body).to include('index_smart_phone.html.erb')
      end
    end
  end
end

describe Jpmobile::Resolver::PathParser do
  it 'locale と variant を持ち format と handler を省略したテンプレート名を解釈すること' do
    parsed_path = described_class.new.parse('template_path/index.en+tablet')

    aggregate_failures do
      expect(parsed_path.path.to_s).to eq('template_path/index')
      expect(parsed_path.details.locale).to eq(:en)
      expect(parsed_path.details.variant).to eq(:tablet)
      expect(parsed_path.details.format).to be_nil
      expect(parsed_path.details.handler).to be_nil
    end
  end
end
