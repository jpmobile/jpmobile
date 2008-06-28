require 'jpmobile/request_with_mobile'

class ActionController::AbstractRequest
  include Jpmobile::RequestWithMobile
end
