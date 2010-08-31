# -*- coding: utf-8 -*-
# UserAgent から生成すべき class 名を判定する
module Jpmobile
  module Rack
    class MobileCarrier
      def initialize(app)
        @app = app
      end

      def call(env)
        env['rack.jpmobile'] = carrier(env)

        @app.call(env)
      end

      def carrier(env)
        ::Jpmobile::Mobile.carriers.each do |const|
          c = ::Jpmobile::Mobile.const_get(const)
          if c.check_carrier(env)
            res = ::Rack::Request.new(env)
            return c.new(env, res)
          end
        end

        nil
      end
    end
  end
end

class Rack::Request
  include Jpmobile::RequestWithMobile
end
