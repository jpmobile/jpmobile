require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))
require 'rack/mock'
require 'rack/request'
require 'jpmobile/rack/mobile_carrier'

describe Jpmobile::RequestWithMobile do
  let(:generic_request_class) do
    Class.new do
      include Jpmobile::RequestWithMobile

      attr_reader :env

      def initialize(env)
        @env = env
      end
    end
  end

  it 'Rack リクエストでは Rack が解決した接続元 IP を返すこと' do
    request = Rack::Request.new(Rack::MockRequest.env_for('/', 'REMOTE_ADDR' => '210.153.84.1'))

    expect(request.remote_addr).to eq('210.153.84.1')
  end

  it '汎用リクエストではリバースプロキシが渡した接続元 IP を優先すること' do
    request = generic_request_class.new('HTTP_X_FORWARDED_FOR' => '210.153.84.1', 'REMOTE_ADDR' => '192.0.2.1')

    expect(request.remote_addr).to eq('210.153.84.1')
  end

  it 'プロキシ情報がない汎用リクエストでは直接の接続元 IP を返すこと' do
    request = generic_request_class.new('REMOTE_ADDR' => '210.153.84.1')

    expect(request.remote_addr).to eq('210.153.84.1')
  end
end
