require 'jpmobile/request_with_mobile'

if ::ActionPack::VERSION::MAJOR >=2 and ::ActionPack::VERSION::MINOR >= 3
  ### Handle Rails 2.3 case
  class ActionController::Request
    include Jpmobile::RequestWithMobile
  end
else
  ### Handle Rails 2.2 or lower case
  class ActionController::AbstractRequest
    include Jpmobile::RequestWithMobile
  end
end
