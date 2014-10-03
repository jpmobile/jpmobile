require 'rails_helper'

describe TransSidAlwaysController, :type => :controller do
  describe "GET 'redirect_action'" do
    it "redirects 'form'" do
      get :redirect_action
      expect(response).to redirect_to(:action => 'form')
    end
  end
end
