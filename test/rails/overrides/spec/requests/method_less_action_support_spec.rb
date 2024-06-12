require 'rails_helper'

describe 'Method-less mobile template only action', type: :request do
  subject do
    get '/method_less_action_support', headers:
  end

  let(:headers) do
    {}
  end

  context 'when accessed with mobile User-Agent' do
    before do
      headers['User-Agent'] = 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; ja-jp) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16'
    end

    it 'successfully renders mobile template' do
      subject
      expect(response).to have_http_status(200)
    end
  end

  context 'when accessed with non-mobile User-Agent' do
    it 'retuens 404 status' do
      subject
      expect(response).to have_http_status(404)
    end
  end
end
