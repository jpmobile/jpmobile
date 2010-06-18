# -*- coding: utf-8 -*-
# 出力変換
module Jpmobile
  module Rack
    class Filter
      def initialize(app)
        @app = app
      end

      def call(env)
        # 入力を保存
        mobile = env['rack.jpmobile']

        status, env, response = @app.call(env)

        body, content_type, charset = extract_response(response, env)
        if mobile and body
          body, charset = mobile.to_external(body, content_type, charset)
          response, env = set_response(response, env, body, content_type, charset)
        end

        [status, env, response]
      end

      private
      def extract_response(response, env)
        # 出力
        case response.to_s
        when /ActionController/
          [response.body, response.content_type, response.charset]
        else
          if env['Content-Type']
            content_type, charset = env['Content-Type'].split(/;/)
            content_type.chomp!
            charset.chomp!
          else
            content_type, charset = [nil, nil]
          end
          [response, content_type, charset]
        end
      end

      def set_response(response, env, body, content_type, charset)
        # 出力
        case response.to_s
        when /ActionController/
          response.body    = body
          response.charset = charset

          [response, env]
        else
          content_type = "#{content_type}; #{charset}"
          env['Content-Type'] = content_type

          [body, env]
        end
      end
    end
  end
end
