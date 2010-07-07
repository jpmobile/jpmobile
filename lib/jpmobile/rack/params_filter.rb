# -*- coding: utf-8 -*-
# リクエストパラメータの変換
module Jpmobile
  module Rack
    class ParamsFilter
      def initialize(app)
        @app = app
      end

      def call(env)
        # 入力
        if @mobile = env['rack.jpmobile']
          # パラメータをkey, valueに分解
          # form_params
          if env['REQUEST_METHOD'] == 'POST'
            env['rack.input'] = StringIO.new(parse_query(env['rack.input'].read))
          end

          # query_params
          env['QUERY_STRING'] = parse_query(env['QUERY_STRING'])
        end

        status, env, body = @app.call(env)

        [status, env, body]
      end

      private
      def to_internal(str)
        ::Rack::Utils.escape(@mobile.to_internal(::Rack::Utils.unescape(str)))
      end
      def parse_query(str)
        return nil unless str

        new_array = []
        str.split("&").each do |param_pair|
          k, v = param_pair.split("=")
          k = to_internal(k) if k
          v = to_internal(v) if v
          new_array << "#{k}=#{v}" if k and v
        end

        new_array.join("&")
      end
    end
  end
end
