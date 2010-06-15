# -*- coding: utf-8 -*-
# 出力変換
module Jpmobile
  module Rack
    class Filter
      def initialize(app)
        @app     = app
      end

      def call(env)
        status, env, body = @app.call(env)

        # 出力
        if mobile = env['rack.jpmobile'] and body
          body = mobile.to_external(body)
        end

        [status, env, body]
      end
    end
  end
end
