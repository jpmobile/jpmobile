require 'rails_helper'

describe 'PCからのアクセスの場合', type: :request do
  before do
    @headers = {
      'HTTP_USER_AGENT' => 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; .NET CLR 1.1.4322)',
    }
  end

  it 'request.mobile は nil であるべき' do
    get '/mobile_spec/index', params: {}, env: @headers

    expect(request.mobile).to be_nil
  end
  it 'request.mobile? は false であるべき' do
    get '/mobile_spec/index', params: {}, env: @headers

    expect(request.mobile?).to be_falsey
  end

  context 'routesが存在しない場合' do
    it '404を返す' do
      get '/not_exist', params: {}, env: @headers
      expect(response).to have_http_status(404)
    end
  end
end
