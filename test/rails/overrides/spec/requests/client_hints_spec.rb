require 'rails_helper'

describe 'iPhone からの Client Hints アクセス', type: :request do
  before do
    @headers = {
      'HTTP_SEC_CH_UA_PLATFORM' => '"iOS"',
      'HTTP_SEC_CH_UA_MOBILE' => '?1',
    }
  end

  it 'request.mobile は Iphone のインスタンスであるべき' do
    get '/mobile_spec/index', params: {}, env: @headers

    expect(request.mobile).to be_an_instance_of(Jpmobile::Mobile::Iphone)
  end

  it 'request.smart_phone? は true であるべき' do
    get '/mobile_spec/index', params: {}, env: @headers

    expect(request.smart_phone?).to be_truthy
  end

  it 'request.mobile? は false であるべき' do
    get '/mobile_spec/index', params: {}, env: @headers

    expect(request.mobile?).to be_falsey
  end
end

describe 'iPad からの Client Hints アクセス', type: :request do
  before do
    @headers = {
      'HTTP_SEC_CH_UA_PLATFORM' => '"iOS"',
      'HTTP_SEC_CH_UA_MOBILE' => '?0',
    }
  end

  it 'request.mobile は Ipad のインスタンスであるべき' do
    get '/mobile_spec/index', params: {}, env: @headers

    expect(request.mobile).to be_an_instance_of(Jpmobile::Mobile::Ipad)
  end

  it 'request.tablet? は true であるべき' do
    get '/mobile_spec/index', params: {}, env: @headers

    expect(request.tablet?).to be_truthy
  end
end

describe 'Android からの Client Hints アクセス', type: :request do
  before do
    @headers = {
      'HTTP_SEC_CH_UA_PLATFORM' => '"Android"',
      'HTTP_SEC_CH_UA_MOBILE' => '?1',
    }
  end

  it 'request.mobile は Android のインスタンスであるべき' do
    get '/mobile_spec/index', params: {}, env: @headers

    expect(request.mobile).to be_an_instance_of(Jpmobile::Mobile::Android)
  end

  it 'request.smart_phone? は true であるべき' do
    get '/mobile_spec/index', params: {}, env: @headers

    expect(request.smart_phone?).to be_truthy
  end
end

describe 'Android タブレットからの Client Hints アクセス', type: :request do
  before do
    @headers = {
      'HTTP_SEC_CH_UA_PLATFORM' => '"Android"',
      'HTTP_SEC_CH_UA_MOBILE' => '?0',
    }
  end

  it 'request.mobile は AndroidTablet のインスタンスであるべき' do
    get '/mobile_spec/index', params: {}, env: @headers

    expect(request.mobile).to be_an_instance_of(Jpmobile::Mobile::AndroidTablet)
  end

  it 'request.tablet? は true であるべき' do
    get '/mobile_spec/index', params: {}, env: @headers

    expect(request.tablet?).to be_truthy
  end
end

describe 'Client Hints と UA が混在するアクセス', type: :request do
  it 'Client Hints が UA より優先されること' do
    get '/mobile_spec/index', params: {}, env: {
      'HTTP_USER_AGENT' => 'Mozilla/5.0 (Linux; Android 9; Pixel 3) Mobile Safari/537.36',
      'HTTP_SEC_CH_UA_PLATFORM' => '"iOS"',
      'HTTP_SEC_CH_UA_MOBILE' => '?1',
    }

    expect(request.mobile).to be_an_instance_of(Jpmobile::Mobile::Iphone)
  end

  it 'Client Hints がなければ UA にフォールバックすること' do
    get '/mobile_spec/index', params: {}, env: {
      'HTTP_USER_AGENT' => 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; ja-jp) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16',
    }

    expect(request.mobile).to be_an_instance_of(Jpmobile::Mobile::Iphone)
  end
end
