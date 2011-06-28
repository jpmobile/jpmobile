# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), '/../spec_helper'))

describe MobileSpecController do
  describe "GET 'index'" do
    context 'PC access' do
      it "should be successful" do
        request.user_agent = 'Mozilla'
        get 'index'

        response.should be_success
        response.should render_template('index')
        request.mobile?.should be_false
      end
    end

    context 'mobile access' do
      it "should be successful" do
        request.user_agent = "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
        get 'index'
        response.should be_success
        response.should render_template('index_mobile')
        request.mobile?.should be_true
        request.mobile.should be_a(Jpmobile::Mobile::Docomo)
      end
    end
  end
end
