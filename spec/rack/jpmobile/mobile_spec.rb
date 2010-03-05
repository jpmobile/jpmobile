# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), '../../rack_helper.rb')


class TestApplication
  def call(env)
    env
  end
end

describe Jpmobile::Rack::Mobile do
  include Rack::Test::Methods

  before(:each) do
    @target_app = mock("Target Rack Application")
    @target_app.stub!(:call).and_return([200, {}, "Target app"])
  end

  describe "docomo のとき" do
    it "Jpmobile::Mobile::Docomo のインスタンスが env['rack.mobile'] にあること" do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => 'DoCoMo/2.0 SH906i(c100;TB;W24H16)')
      env = Jpmobile::Rack::Mobile.new(TestApplication.new).call(res)
      env['rack.jpmobile'].should be_a(Jpmobile::Mobile::Docomo)
    end
  end
end
