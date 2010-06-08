# -*- coding: utf-8 -*-
# UserAgent から生成すべき class 名を判定する
module Jpmobile
  module Rack
    class MobileCarrier
      def initialize(app, options = {})
        @app     = app
        @options = options.dup.clone
      end

      def call(env)
        env = env.clone
        env['rack.jpmobile.carrier'] = carrier(env)

        @app.call(env)
      end

      def carrier(env)
        ::Jpmobile::Mobile.carriers.each do |const|
          c = ::Jpmobile::Mobile.const_get(const)
          return c if c::USER_AGENT_REGEXP && env['HTTP_USER_AGENT'] =~ c::USER_AGENT_REGEXP
        end

        nil
      end
    end
  end
end
