# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), '../../rack_helper.rb')

describe Jpmobile::Rack::MobileCarrier, "docomo" do
  include Rack::Test::Methods

  # before(:each) do
  #   @target_app = mock("Target Rack Application")
  #   @target_app.stub!(:call).and_return([200, {}, "Target app"])
  # end

  context "SH902i のとき" do
    before(:each) do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        {'HTTP_USER_AGENT' => 'DoCoMo/2.0 SH902i(c100;TB;W24H16)'})
      @env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]
    end

    it "Jpmobile::Mobile::Docomo のインスタンスが env['rack.mobile'] にあること" do
      @env['rack.jpmobile'].class.should == Jpmobile::Mobile::Docomo
    end

    it "#position などが nil になること" do
      @env['rack.jpmobile'].position.should be_nil
      @env['rack.jpmobile'].areacode.should be_nil
      @env['rack.jpmobile'].serial_number.should be_nil
      @env['rack.jpmobile'].icc.should be_nil
      @env['rack.jpmobile'].ident.should be_nil
      @env['rack.jpmobile'].ident_device.should be_nil
      @env['rack.jpmobile'].ident_subscriber.should be_nil
    end

    it "#supports_cookie? などが false になること" do
      @env['rack.jpmobile'].supports_cookie?.should be_false
    end
  end

  context "SO506iC のとき" do
    before(:each) do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        {'HTTP_USER_AGENT' => "DoCoMo/1.0/SO506iC/c20/TB/W20H10"})
      @env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]
    end

    it "Jpmobile::Mobile::Docomo のインスタンスが env['rack.mobile'] にあること" do
      @env['rack.jpmobile'].class.should == Jpmobile::Mobile::Docomo
    end

    it "#position などが nil になること" do
      @env['rack.jpmobile'].position.should be_nil
      @env['rack.jpmobile'].areacode.should be_nil
      @env['rack.jpmobile'].serial_number.should be_nil
      @env['rack.jpmobile'].icc.should be_nil
      @env['rack.jpmobile'].ident.should be_nil
      @env['rack.jpmobile'].ident_device.should be_nil
      @env['rack.jpmobile'].ident_subscriber.should be_nil
    end

    it "#supports_cookie? などが false になること" do
      @env['rack.jpmobile'].supports_cookie?.should be_false
    end
  end
end
