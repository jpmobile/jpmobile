require 'action_controller/test_case'
ActionController::TestRequest.send :include, Jpmobile::RequestWithMobileTesting
