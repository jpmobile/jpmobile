# -*- coding: utf-8 -*-
require File.join(File.expand_path(File.dirname(__FILE__)), 'spec_helper')

describe Jpmobile::Mobile::AbstractMobile do
  before(:each) do
    @mobile = Jpmobile::Mobile::AbstractMobile.new(nil, nil)
  end

  context "to_mail_subject" do
    it "should convert string to ISO-2022-JP B-Encoding when string contains Japanese" do
      @mobile.to_mail_subject("ほげ").should == "=?ISO-2022-JP?B?GyRCJFskMhsoQg==?="
    end
  end

  context "to_mail_body" do
    it "should convert string to ISO-2022-JP when string contains Japanese" do
      @mobile.to_mail_body("ほげ").should == "ほげ".encode(Encoding::ISO2022_JP)
    end
  end
end
