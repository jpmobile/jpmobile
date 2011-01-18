# -*- coding: utf-8 -*-
require File.join(File.expand_path(File.dirname(__FILE__)), 'spec_helper')
require 'mail'
require 'jpmobile/mail'

describe "Jpmobile::Mail" do
  include Jpmobile::Util

  before(:each) do
    @mail         = Mail.new
    @mail.subject = "万葉"
    @mail.body    = "ほげ"
    @mail.from    = "info@jpmobile-rails.org"
  end

  context "Mail#to" do
    it "sets multi-tos" do
      expect{@mail.to = ["a@hoge.com", "b@hoge.com"]}.to_not raise_error
    end
  end

  describe "AbstractMobile" do
    before(:each) do
      @mobile = Jpmobile::Mobile::AbstractMobile.new(nil, nil)
      @mail.mobile = @mobile
      @mail.to = "info+to@jpmobile-rails.org"
    end

    context "to_s" do
      it "should contain encoded subject" do
        ascii_8bit(@mail.to_s).should match(Regexp.compile(Regexp.escape("=?ISO-2022-JP?B?GyRCS3xNVRsoQg==?=")))
      end

      it "should contain encoded body" do
        ascii_8bit(@mail.to_s).should match(Regexp.compile(Regexp.escape(ascii_8bit("\x1b\x24\x42\x24\x5B\x24\x32\e\x28\x42"))))
      end
    end
  end

  describe "Docomo" do
    before(:each) do
      @mobile = Jpmobile::Mobile::Docomo.new(nil, nil)
      @mail.mobile = @mobile
      @mail.to = "info+to@jpmobile-rails.org"
    end

    context "to_s" do
      it "should contain encoded subject" do
        @mail.to_s.should match(sjis_regexp("=?Shift_JIS?B?lpyXdA==?="))
      end

      it "should contain encoded body" do
        @mail.to_s.should match(Regexp.escape(utf8_to_sjis("ほげ")))
      end

      it "should contains encoded emoticon" do
        @mail.subject += "&#xe63e;"
        @mail.body = "#{@mail.body}&#xe63e;"

        @mail.to_s.should match(Regexp.escape("=?Shift_JIS?B?lpyXdPif?="))
        @mail.to_s.should match(sjis_regexp("\xF8\x9F"))
      end
    end
  end

  describe "Au" do
    before(:each) do
      @mobile = Jpmobile::Mobile::Au.new(nil, nil)
      @mail.mobile = @mobile
      @mail.to = "info+to@jpmobile-rails.org"
    end

    context "to_s" do
      it "should contain encoded subject" do
        ascii_8bit(@mail.to_s).should match(Regexp.compile(Regexp.escape("=?ISO-2022-JP?B?GyRCS3xNVRsoQg==?=")))
      end

      it "should contain encoded body" do
        ascii_8bit(@mail.to_s).should match(Regexp.compile(Regexp.escape(ascii_8bit("\x1b\x24\x42\x24\x5B\x24\x32\e\x28\x42"))))
      end

      it "should contain encoded emoticon" do
        @mail.subject += "&#xe63e;"
        @mail.body = "#{@mail.body}&#xe63e;"

        ascii_8bit(@mail.to_s).should match(Regexp.compile(Regexp.escape("=?ISO-2022-JP?B?GyRCS3xNVRsoQhskQnVBGyhC?=")))
        ascii_8bit(@mail.to_s).should match(Regexp.compile(Regexp.escape(ascii_8bit("\x1b\x24\x42\x75\x41\x1b\x28\x42"))))
      end
    end
  end

  describe "Softbank" do
    before(:each) do
      @mobile = Jpmobile::Mobile::Softbank.new(nil, nil)
      @mail.mobile = @mobile
      @mail.to = "info+to@jpmobile-rails.org"
    end

    context "to_s" do
      it "should contain encoded subject" do
        @mail.to_s.should match(Regexp.escape(sjis("=?Shift_JIS?B?lpyXdA==?=")))
      end

      it "should contain encoded body" do
        @mail.to_s.should match(Regexp.escape(utf8_to_sjis("ほげ")))
      end

      it "should contains encoded emoticon" do
        @mail.subject += "&#xe63e;"
        @mail.body = "#{@mail.body}&#xe63e;"

        @mail.to_s.should match(Regexp.escape("=?Shift_JIS?B?lpyXdPmL?="))
        @mail.to_s.should match(sjis_regexp("\xf9\x8b"))
      end
    end
  end
end
