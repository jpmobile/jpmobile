# -*- coding: utf-8 -*-
require File.join(File.expand_path(File.dirname(__FILE__)), 'spec_helper')
require 'mail'
require 'jpmobile/mail'

describe "Jpmobile::Mail#receive" do
  include Jpmobile::Util

  before(:each) do
    @to = "info@jpmobile-rails.org"
  end

  describe "PC mail" do
    before(:each) do
      @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/pc-mail-single.eml")).read)
    end

    it "subject should be parsed correctly" do
      @mail.subject.should == "タイトルの長いメールの場合の対処を実装するためのテストケースとしてのメールに含まれている件名であるサブジェクト部分"
    end

    it "body should be parsed correctly" do
      @mail.body.to_s.should == "本文です"
    end
  end

  describe "multipart PC mail" do
    before(:each) do
      @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/pc-mail-multi.eml")).read)
    end

    it "subject should be parsed correctly" do
      @mail.subject.should == "タイトルの長いメールの場合の対処を実装するためのテストケースとしてのメールに含まれている件名であるサブジェクト部分"
    end

    it "body should be parsed correctly" do
      @mail.body.parts.size.should == 2
      @mail.body.parts.first.body.to_s.should == "本文です"
    end
  end

  describe "Docomo" do
    before(:each) do
      @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/docomo-emoji.eml")).read)
    end

    it "subject should be parsed correctly" do
      @mail.subject.should == "題名&#xe676;"
    end

    it "body should be parsed correctly" do
      @mail.body.to_s.should == "本文&#xe6e2;\nFor docomo"
    end
  end

  describe "Au" do
    before(:each) do
      @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/au-emoji.eml")).read)
    end

    it "subject should be parsed correctly" do
      @mail.subject.should == "題名&#xe503;"
    end

    it "body should be parsed correctly" do
      @mail.body.to_s.should == "本文&#xe522;\nFor au"
    end
  end

  describe "Softbank" do
    before(:each) do
      @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/softbank-emoji.eml")).read)
    end

    it "subject should be parsed correctly" do
      @mail.subject.should == "題名&#xf03c;"
    end

    it "body should be parsed correctly" do
      @mail.body.to_s.should == "本文&#xf21c;\nFor softbank"
    end
  end
    end
  end
end
