# UserAgent または Client Hints から生成すべき class 名を判定する
module Jpmobile
  class MobileCarrier
    # Client Hints を要求するレスポンスヘッダー
    ACCEPT_CLIENT_HINTS = 'Sec-CH-UA-Mobile, Sec-CH-UA-Platform'.freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      env['rack.jpmobile'] = Jpmobile::Mobile::AbstractMobile.carrier(env)

      status, headers, body = @app.call(env)
      headers['Accept-CH'] ||= ACCEPT_CLIENT_HINTS
      [status, headers, body]
    end
  end
end

class Rack::Request
  include ::Jpmobile::RequestWithMobile
end
