# -*- coding: utf-8 -*-
# UserAgent から生成すべき class 名を判定する
module Jpmobile
  module Rack
    class MobileCarrier
      def initialize(app)
        @app = app
      end

      def call(env)
        env['rack.jpmobile'] = Jpmobile::Mobile::AbstractMobile.carrier(env)

        @app.call(env)
      end
    end
  end
end

class Rack::Request
  include Jpmobile::RequestWithMobile
end
