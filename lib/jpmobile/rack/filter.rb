# -*- coding: utf-8 -*-
# 出力変換
module Jpmobile
  module Rack
    class Filter
      def initialize(app, options = {})
        @app     = app
        @options = options.dup.clone
      end

      def call(env)
        status, env, body = @app.call(env)

        # 出力
        if @klass = env['rack.jpmobile.carrier']
          body = @klass.to_external(body)
        end

        [status, env, body]
      end
    end
  end
end
