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

        if mobile
          if content_type = env['Content-Type']
            type, charset = content_type.split(/;\s*charset=/)
          else
            type    = nil
            charset = nil
          end

          body = response_to_body(response)
          if body.to_str.encoding == ::Encoding::UTF_8
          # or unless body.to_str.encoding == ::Encoding::BINARY
            body = body.gsub(/<input name="utf8" type="hidden" value="#{[0x2713].pack("U")}"[^>]*?>/, ' ')
            body = body.gsub(/<input name="utf8" type="hidden" value="&#x2713;"[^>]*?>/, ' ')
            response, charset = mobile.to_external(body, type, charset)
          end

          if type and charset
            env['Content-Type'] = "#{type}; charset=#{charset}"
          end
        end

        new_response = ::Rack::Response.new(response, status, env)
        new_response.finish
      end

      private
      def response_to_body(response)
        if response.respond_to?(:to_str)
          response.to_str
        elsif response.respond_to?(:each)
          body = []
          response.each do |part|
            body << response_to_body(part)
          end
          body.join("\n")
        else
          body
        end
      end
    end
  end
end
