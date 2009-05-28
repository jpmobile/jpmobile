module Jpmobile
  module Rack
    # in your_app.ru
    #
    # check ip
    #   require 'jpmobile/rack'
    #   use Jpmobile::Rack::Auth::Docomo

    # (but allow localhost), {
    #      :ident => %w( xxxxxx ),
    #      :check_ip => true,
    #      :allow_ip => %w( 127.0.0.1 )
    #   }    # you can use block

    # req is Jpmobile::Rack::Request's subclass instance.
    #   require 'jpmobile/rack'
    #   use Jpmobile::Rack::Auth {|req|
    #     Your::Model::AuSubno.count(:subno => req.ident) != 0
    #   }
    class Auth
      FORBIDDEN = [403, {'Content-Type' => 'text/plain' }, 'Forbidden' ]

      def initialize(app, hash=nil, &block)
        @app = app
        if hash
          @allow_ip         = hash[:allow_ip]
        end
        @cond = block
      end

      def career
      end

      def call(env)
        request = Request.new(env)

        if request.mobile? and request.valid_ip?
          @app.call(env)
        else
          FORBIDDEN
        end
      end

      ::Jpmobile::Mobile.constants.each do |career|
        klass = Class.new(self)
        klass.class_eval do
          define_method :career do
            ::Jpmobile::Mobile.const_get(career)
          end
        end
        const_set(career, klass)
      end
    end
  end
end
