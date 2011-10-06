# -*- coding: utf-8 -*-
# 出力変換
require 'scanf'

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

        if mobile and mobile.apply_filter? and env['Content-Type'] =~ %r!text/html|application/xhtml\+xml!
          type, charset = env['Content-Type'].split(/;\s*charset=/)

          body = response_to_body(response)
          body = body.gsub(/<input name="utf8" type="hidden" value="#{[0x2713].pack("U")}"[^>]*?>/, ' ')
          body = body.gsub(/<input name="utf8" type="hidden" value="&#x2713;"[^>]*?>/, ' ')

          response, charset = mobile.to_external(body, type, charset)

          if type and charset
            env['Content-Type'] = "#{type}; charset=#{charset}"
          end
        elsif pc_emoticon?
          body = response_to_body(response)

          response = Jpmobile::Emoticon.utf8_to_unicodecr(body).gsub(/&#x([0-9a-f]{4});/i) do |match|
            img = @pc_emoticon_hash[$1.upcase] || (@pc_emoticon_hash[("%x" % ($1.scanf("%x").first - 0x1000)).upcase] rescue nil)
            if img
              "<img src=\"#{@@pc_emoticon_image_path}/#{img}.gif\" alt=\"#{img}\" />"
            else
              ""
            end
          end
        end

        new_response = ::Rack::Response.new(response, status, env)
        new_response.finish
      end

      private
      def pc_emoticon?
        if @@pc_emoticon_yaml and File.exist?(@@pc_emoticon_yaml) and @@pc_emoticon_image_path

          unless @pc_emoticon_hash
            begin
              yaml_hash = YAML.load_file(@@pc_emoticon_yaml)
              @pc_emoticon_hash = Hash[*(yaml_hash.values.inject([]){ |r, v| r += v.to_a.flatten; r})]
              @@pc_emoticon_image_path.chop if @@pc_emoticon_image_path.match(/\/$/)

              return true
            rescue => ex
            end
          end
        end

        return false
      end

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

      @@pc_emoticon_image_path = nil
      @@pc_emoticon_yaml       = nil
      class << self
        def pc_emoticon_image_path=(path)
          @@pc_emoticon_image_path = path
        end

        def pc_emoticon_yaml=(file)
          @@pc_emoticon_yaml = file
        end
      end
    end
  end
end
