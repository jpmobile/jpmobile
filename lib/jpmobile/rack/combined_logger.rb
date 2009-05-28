module Jpmobile
  module Rack
    # Rack::CommonLogger show too few infomation to debugging mobile web application.
    # So you can Rack::Jpmobile::CombinedLogger as alternate.
    # SYNOPSIS
    #   in your_app.up
    #     require 'jpmobile/rack'
    #     class Rack::CommonLogger
    #       include Jpmobile::Rack::CombinedLogger
    #     end
    #
    #     use Rack::CommonLogger, STDERR   # you need not write this when you use rackup on development.
    #
    module CombinedLogger

      # XXX: It's evil way for replacing Rack::CommonLogger#each.
      def self.included klass
        klass.class_eval do
          alias orig_each each
          remove_method :each
        end
      end

      def each
        length = 0
        @body.each { |part|
          length += part.size
          yield part
        }

        @now = Time.now

        # Combined Log Format: http://httpd.apache.org/docs/1.3/logs.html#combined
        # 127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326 "http://www.example.com/start.html" "Mozilla/4.08 [en] (Win98; I ;Nav)"
        #          "%h %l %u [%t] \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\""
        @logger << %{%s - %s [%s] "%s %s%s %s" %d %s %s "%s" %0.4f\n} %
          [
           @env['HTTP_X_FORWARDED_FOR'] || @env["REMOTE_ADDR"] || "-",
           @env["REMOTE_USER"] || @env["HTTP_X_DCMGUID"] || @env["HTTP_X_UP_SUBNO"] || @env["HTTP_X_JPHONE_UID"] || @env["HTTP_X_EM_UID"] || "-",
           @now.strftime("%d/%b/%Y %H:%M:%S"),
           @env["REQUEST_METHOD"],
           @env["PATH_INFO"],
           @env["QUERY_STRING"].empty? ? "" : "?"+@env["QUERY_STRING"],
           @env["HTTP_VERSION"],
           @status.to_s[0..3],
           (length.zero? ? "-" : length.to_s),
           @env["HTTP_REFERER"] ? %{"#{@env['Referer']}"} : '-',
           @env["HTTP_USER_AGENT"],
           @now - @time
          ]
      end
    end
  end
end
