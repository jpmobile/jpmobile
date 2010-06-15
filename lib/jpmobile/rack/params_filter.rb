# -*- coding: utf-8 -*-
# リクエストパラメータの変換
module Jpmobile
  module Rack
    class ParamsFilter
      def initialize(app)
        @app     = app
      end

      def call(env)
        # 入力
        if mobile = env['rack.jpmobile']
          # フォームのパラメータ
          if env['REQUEST_METHOD'] == 'POST'
            form_params = mobile.to_internal(env['rack.input'].read)
            env['rack.input'] = StringIO.new(form_params)
          end

          # URI Query
          query_string = URI.decode(env['QUERY_STRING'])
          unless query_string == env['QUERY_STRING']
            env['QUERY_STRING'] = URI.encode(mobile.to_internal(query_string))
          end
        end
        status, env, body = @app.call(env)

        [status, env, body]
      end
    end
  end
end
