# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))
require 'mail'
require 'jpmobile/mail'

describe "decorated mails" do
  include Jpmobile::Util

  before(:each) do
    @mail           = Mail.new
    @mail.subject   = "万葉"
    @mail.text_part = Mail::Part.new do
      body 'ほげ'
    end
    @mail.from      = "ちはやふる <info@jpmobile-rails.org>"
    @mail.to        = "むすめふさほせ <info+to@jpmobile-rails.org>"

    @photo = open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/photo.jpg")).read
    @mail.attachments.inline['photo.jpg'] = @photo
    @inline_url = @mail.attachments['photo.jpg'].url
  end

  describe "docomo" do
    before(:each) do
      inline_url = @inline_url
      @mobile = Jpmobile::Mobile::Docomo.new(nil, nil)
      charset = @mobile.mail_charset
      @mail.html_part = Mail::Part.new do
        body '<img src="' + inline_url + '" />'
        content_type "text/html; charset=#{charset}"
      end
      @mail.mobile = @mobile
    end

    it "top level content-type should be 'multipart/mixed'" do
      @mail.rearrange!
      expect(@mail.content_type).to match('multipart/mixed')
    end
  end

  describe "au" do
    before(:each) do
      inline_url = @inline_url
      @mobile = Jpmobile::Mobile::Au.new(nil, nil)
      charset = @mobile.mail_charset
      @mail.html_part = Mail::Part.new do
        body '<img src="' + inline_url + '" />'
        content_type "text/html; charset=#{charset}"
      end
      @mail.mobile = @mobile
    end

    it "top level content-type should be 'multipart/mixed'" do
      @mail.rearrange!
      expect(@mail.content_type).to match('multipart/mixed')
    end
  end

  describe "softbank" do
    before(:each) do
      inline_url = @inline_url
      @mobile = Jpmobile::Mobile::Softbank.new(nil, nil)
      charset = @mobile.mail_charset
      @mail.html_part = Mail::Part.new do
        body '<img src="' + inline_url + '" />'
        content_type "text/html; charset=#{charset}"
      end
      @mail.mobile = @mobile
    end

    it "top level content-type should be 'multipart/mixed'" do
      @mail.rearrange!
      expect(@mail.content_type).to match('multipart/mixed')
    end
  end
end
