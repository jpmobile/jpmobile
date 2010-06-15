if Rails.env == 'test'
  class ActionController::Request
    include Jpmobile::RequestWithMobile
  end
end
