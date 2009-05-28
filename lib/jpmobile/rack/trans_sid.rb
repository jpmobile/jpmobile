# = セッションID を QUERY_STRING などから上書きする処理
module Jpmobile
  module Rack
    class TransSid
      def initialize(app)
        @app = app
      end

      def call(env)
        @app.call(env)
      end
    end
  end
end
