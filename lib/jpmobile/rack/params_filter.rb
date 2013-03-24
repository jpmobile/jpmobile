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
        if @mobile = env['rack.jpmobile'] and @mobile.apply_params_filter?
          # パラメータをkey, valueに分解
          # form_params
          unless env['REQUEST_METHOD'] == 'GET' || env['REQUEST_METHOD'] == 'HEAD'
            unless env['CONTENT_TYPE'] =~ /application\/json|application\/xml/
              env['rack.input'] = StringIO.new(parse_query(env['rack.input'].read))
            end
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
          new_array << "#{k}=#{v}" if k
        end

        new_array.join("&")
      end
    end
  end
end
