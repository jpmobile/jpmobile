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

        status, env, body = @app.call(env)

        response = ::Rack::Response.new(body, status, env)

        if mobile
          if content_type = response.content_type
            content_type, charset = content_type.split(/;/)
            content_type.chomp! if content_type.respond_to?(:chomp!)
            charset.chomp!      if charset.respond_to?(:chomp!)
          else
            content_type = nil
            charset      = nil
          end

          body = response.body.join("\n")
          body, charset = mobile.to_external(body, content_type, charset)

          if content_type and charset
            response['Content-Type'] = "#{content_type}; charset=#{charset}"
          end

          body = [body] if body.kind_of?(String)

          response.body   = body
          response.length = body.length
        end

        response.finish
      end
    end
  end
end
