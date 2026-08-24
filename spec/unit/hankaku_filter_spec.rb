require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))
require 'active_support'
require 'nokogiri'
require 'rack/mock'
require 'rack/request'
require 'jpmobile/rack/mobile_carrier'
require 'jpmobile/filter'

describe Jpmobile::HankakuFilter do
  def mobile_request(user_agent)
    env = Rack::MockRequest.env_for('/', 'HTTP_USER_AGENT' => user_agent)
    env['rack.jpmobile'] = Jpmobile::Mobile::AbstractMobile.carrier(env)
    Rack::Request.new(env)
  end

  it 'HTML fragment の送信ボタンを本文とともに半角へ変換すること' do
    request = mobile_request('SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1')
    response = Struct.new(:body, :content_type).new('<input type="submit" value="送信ア"><p>カナ</p>', 'text/html')
    controller = Struct.new(:request, :response, :params).new(request, response, {})

    described_class.new(input: true).after(controller)

    expect(response.body).to include('value="送信ｱ"', '<p>ｶﾅ</p>')
  end

  it 'Content-Type がない応答本文を変換しないこと' do
    request = mobile_request('DoCoMo/2.0 SH906i(c100;TB;W24H16)')
    response = Struct.new(:body, :content_type).new('アブラカダブラ', nil)
    controller = Struct.new(:request, :response, :params).new(request, response, {})

    described_class.new.after(controller)

    expect(response.body).to eq('アブラカダブラ')
  end

  it '入れ子のフォームパラメータを階層を保ったまま全角へ変換すること' do
    request = mobile_request('SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1')
    params = { 'profile' => { 'name' => 'ｱﾌﾞﾗ' }, 'items' => [['ｶﾀﾞ']] }
    controller = Struct.new(:request, :response, :params).new(request, nil, params)

    described_class.new.before(controller)

    expect(controller.params).to eq('profile' => { 'name' => 'アブラ' }, 'items' => [['カダ']])
  end
end
