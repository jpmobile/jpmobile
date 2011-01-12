# -*- coding: utf-8 -*-
require File.join(File.expand_path(File.dirname(__FILE__)), 'spec_helper')

describe "Jpmobile::Mobile" do
  include Jpmobile::Util

  describe "AbstractMobile" do
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
        @mobile.to_mail_body("ほげ").should == utf8_to_jis("ほげ")
      end
    end
  end

  describe "Docomo" do
    before(:each) do
      @mobile = Jpmobile::Mobile::Docomo.new(nil, nil)
    end

    context "to_mail_subject" do
      it "should convert string to Shift_JIS B-Encoding when string contains Japanese" do
        @mobile.to_mail_subject("ほげ").should == "=?Shift_JIS?B?gtmCsA==?="
      end

      it "should convert emoticon &#xe63e; to \xf8\x9f in B-Encoding" do
        @mobile.to_mail_subject("ほげ&#xe63e;").should == "=?Shift_JIS?B?gtmCsPif?="
      end
    end

    context "to_mail_body" do
      it "should convert string to Shift_JIS when string contains Japanese" do
        @mobile.to_mail_body("ほげ").should == utf8_to_sjis("ほげ")
      end

      it "should convert emoticon &#xe63e; to \xf8\x9f" do
        @mobile.to_mail_body("ほげ&#xe63e;").should == utf8_to_sjis("ほげ") + sjis("\xf8\x9f")
      end
    end
  end
end
