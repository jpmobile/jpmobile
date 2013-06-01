# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), '/../spec_helper'))

describe MobileSpecController do
  render_views

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

  describe "GET 'file_render'" do
    context 'PC access' do
      it "should be successful" do
        request.user_agent = 'Mozilla'
        get 'file_render'

        response.should be_success
        response.body.should match('The change you wanted was rejected')
        request.mobile?.should be_false
      end
    end

    context 'mobile access' do
      it "should be successful" do
        request.user_agent = "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
        get 'file_render'

        response.should be_success
        response.body.should match('The change you wanted was rejected')
        request.mobile?.should be_true
        request.mobile.should be_a(Jpmobile::Mobile::Docomo)
      end
    end
  end

  describe "GET 'no_mobile'" do
    around do |example|
      orig_value = Jpmobile.config.fallback_view_selector
      Jpmobile.config.fallback_view_selector = true

      example.run

      Jpmobile.config.fallback_view_selector = orig_value
    end

    context 'PC access' do
      it "should be successful" do
        request.user_agent = 'Mozilla'
        get 'no_mobile'

        response.should be_success
        response.body.should_not match('RailsRoot PC mobile')
      end
    end

    context 'mobile access' do
      it "should be successful" do
        request.user_agent = "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
        get 'no_mobile'

        response.should be_success
        response.body.should_not match('RailsRoot mobile')
      end
    end
  end
end
