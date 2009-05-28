module Jpmobile
  module Rack
    class Request < ::Rack::Request
      include ::Jpmobile::RequestWithMobile
    end
  end
end
