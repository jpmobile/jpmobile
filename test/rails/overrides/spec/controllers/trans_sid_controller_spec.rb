# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), '/../spec_helper'))

describe TransSidAlwaysController do
  describe "GET 'redirect_action'" do
    it "redirects 'form'" do
      get :redirect_action
      response.should redirect_to(:action => 'form')
    end
  end
end
