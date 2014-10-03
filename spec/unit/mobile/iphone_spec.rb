# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Jpmobile::Mobile::Iphone do
  describe 'iOS 4.0' do
    it "unicode_emoticon? should be false" do
      request = double('request')
      allow(request).to receive(:user_agent) {'Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_4 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8K2 Safari/6533.18.5'}

      mobile = Jpmobile::Mobile::Iphone.new({}, request)
      expect(mobile.unicode_emoticon?).to be_falsey
    end
  end

  describe 'iOS 5.0' do
    it "unicode_emoticon? should be true" do
      request = double('request')
      allow(request).to receive(:user_agent) {'Mozilla/5.0 (iPhone; CPU iPhone OS 5_1_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B206 Safari/7534.48.3'}

      mobile = Jpmobile::Mobile::Iphone.new({}, request)
      expect(mobile.unicode_emoticon?).to be_truthy
    end
  end

  describe 'iOS 6.0' do
    it "unicode_emoticon? should be true" do
      request = double('request')
      allow(request).to receive(:user_agent) {'Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A403 Safari/8536.25'}

      mobile = Jpmobile::Mobile::Iphone.new({}, request)
      expect(mobile.unicode_emoticon?).to be_truthy
    end
  end
end
