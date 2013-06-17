# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))
require 'mail'
require 'jpmobile/mail'

describe "Jpmobile::Mail#receive" do
  include Jpmobile::Util

  before(:each) do
    @to = "info@jpmobile-rails.org"
    Jpmobile::Email.japanese_mail_address_regexp = Regexp.new(/\.jp[^a-zA-Z\.\-]/)
  end

  describe "PC mail" do
    before(:each) do
      @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/pc-mail-single.eml")).read)
    end

    it "subject should be parsed correctly" do
      @mail.subject.should == "タイトルの長いメールの場合の対処を実装するためのテストケースとしてのメールに含まれている件名であるサブジェクト部分"
    end

    it "body should be parsed correctly" do
      @mail.body.to_s.should == "本文です\n\n"
    end

    context "to_s" do
      it "should have subject which is same as original" do
        ascii_8bit(@mail.to_s).should match("GyRCJT8lJCVIJWskTkQ5JCQlYSE8JWskTj5s")
      end

      it "should have body which is same as original" do
        ascii_8bit(@mail.to_s).should match(Regexp.compile(Regexp.escape(ascii_8bit(utf8_to_jis("本文です")))))
      end
    end

    context "modify and to_s" do
      it "should encode subject correctly" do
        @mail.subject = "大江戸"
        ascii_8bit(@mail.to_s).should match("GyRCQmc5PjhNGyhC")
      end

      it "should encode body correctly" do
        @mail.body = "会議が開催"
        ascii_8bit(@mail.to_s).should match(Regexp.compile(Regexp.escape(ascii_8bit(utf8_to_jis("会議が開催")))))
      end
    end
  end

  describe "multipart" do
    describe "PC mail" do
      before(:each) do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/pc-mail-multi.eml")).read)
      end

      it "subject should be parsed correctly" do
        @mail.subject.should == "タイトルの長いメールの場合の対処を実装するためのテストケースとしてのメールに含まれている件名であるサブジェクト部分"
      end

      it "body should be parsed correctly" do
        @mail.body.parts.size.should == 2
        @mail.body.parts.first.body.to_s.should == "本文です\n\n"
      end

      it "should encode correctly" do
        ascii_8bit(@mail.to_s).should match(/GyRCJT8lJCVIJWskTkQ5JCQlYSE8JWskTj5s/)
      end
    end

    describe "Docomo" do
      before(:each) do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "../../test/rails/overrides/spec/fixtures/mobile_mailer/docomo-gmail-sjis.eml")).read)
      end

      it "subject should be parsed correctly" do
        @mail.subject.should == "テスト&#xe6ec;"
      end

      it "body should be parsed correctly" do
        @mail.body.parts.size.should == 1
        @mail.body.parts.first.parts.size == 2
        @mail.body.parts.first.parts.first.body.should match("テストです&#xe72d;")
        @mail.body.parts.first.parts.last.body.raw_source.should match("テストです&#xe72d;")
      end

      it "should encode correctly" do
        @mail.to_s.should match(Regexp.escape("g2WDWINn+ZE"))
      end
    end

    describe "Au" do
      before(:each) do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "../../test/rails/overrides/spec/fixtures/mobile_mailer/au-decomail.eml")).read)
      end

      it "subject should be parsed correctly" do
        @mail.subject.should == "テスト&#xe4f4;"
      end

      it "body should be parsed correctly" do
        @mail.body.parts.size.should == 1
        @mail.body.parts.first.parts.size == 1
        @mail.body.parts.first.parts.first.body.to_s.should match("テストです&#xe595;")
        @mail.body.parts.first.parts.last.body.raw_source.should match("テストです&#xe595;")
      end

      it "should encode correctly" do
        ascii_8bit(@mail.to_s).should match(Regexp.escape("GyRCJUYlOSVIdk8bKEI="))
      end
    end

    describe "Softbank" do
      context "Shift_JIS" do
        before(:each) do
          @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "../../test/rails/overrides/spec/fixtures/mobile_mailer/softbank-gmail-sjis.eml")).read)
        end

        it "subject should be parsed correctly" do
          @mail.subject.should == "テスト&#xf221;&#xf223;&#xf221;"
        end

        it "body should be parsed correctly" do
          @mail.body.parts.size.should == 2
          @mail.body.parts.first.body.to_s.should == "テストです&#xf018;"
        end

        it "should encode correctly" do
          @mail.to_s.should match(Regexp.escape("g2WDWINn98H3w/fB"))
        end
      end

      context "UTF-8" do
        before(:each) do
          @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "../../test/rails/overrides/spec/fixtures/mobile_mailer/softbank-gmail-utf8.eml")).read)
        end

        it "subject should be parsed correctly" do
          @mail.subject.should == "テストです&#xf221;"
        end

        it "body should be parsed correctly" do
          @mail.body.parts.size.should == 2
          @mail.body.parts.first.body.raw_source.should == "テストです&#xf223;"
        end

        it "should encode correctly to Shift_JIS" do
          @mail.to_s.should match(Regexp.escape("g2WDWINngsWCt/fB"))
        end
      end
    end

    context 'bounced mail' do
      it 'should parse sub-part charset correctly' do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/bounce_with_utf8_part.eml")).read)
        @mail.parts.first.charset.should match(/iso-2022-jp/i)
        @mail.parts.last.charset.should  match(/utf-8/i)
      end
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
      @mail.body.to_s.should == "本文&#xe6e2;\nFor docomo\n\n"
    end

    context "to_s" do
      it "should have subject which is same as original" do
        @mail.to_s.should match(Regexp.escape("keiWvPjX"))
      end

      it "should have body which is same as original" do
        @mail.to_s.should match(sjis_regexp(utf8_to_sjis("本文")))
      end
    end

    context "modify and to_s" do
      it "should encode subject correctly" do
        @mail.subject = "大江戸&#xe63e;"
        @mail.to_s.should match(Regexp.escape("keWNXYzL+J8="))
      end

      it "should encode body correctly" do
        @mail.body = "会議が開催&#xe646;"
        @mail.to_s.should match(sjis_regexp(sjis("\x89\xEF\x8Bc\x82\xAA\x8AJ\x8D\xC3\xF8\xA7")))
      end
    end
  end

  describe "Au" do
    context 'au-emoji.eml' do
      before(:each) do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/au-emoji.eml")).read)
      end

      it "subject should be parsed correctly" do
        @mail.subject.should == "題名&#xe503;"
      end

      it "body should be parsed correctly" do
        @mail.body.to_s.should == "本文&#xe522;\nFor au\n\n"
      end

      context "to_s" do
        it "should have subject which is same as original" do
          ascii_8bit(@mail.to_s).should match(Regexp.escape("GyRCQmpMPnZeGyhC"))
        end

        it "should have body which is same as original" do
          ascii_8bit(@mail.to_s).should match(Regexp.compile(Regexp.escape(ascii_8bit("\e\x24\x42\x4B\x5C\x4A\x38\x76\x7D\e\x28\x42"))))
        end
      end

      context "modify and to_s" do
        it "should encode subject correctly" do
          @mail.subject = "大江戸&#xe63e;"
          ascii_8bit(@mail.to_s).should match(/\?GyRCQmc5PjhNdUEbKEI=/)
        end

        it "should encode body correctly" do
          @mail.body = "会議が開催&#xe646;"
          ascii_8bit(@mail.to_s).should match(Regexp.compile(Regexp.escape(ascii_8bit("\x1b\x24\x42\x32\x71\x35\x44\x24\x2C\x33\x2B\x3A\x45\x75\x48\x1b\x28\x42"))))
        end
      end
    end

    it "should not be raised when parsing incoming email #41" do
      lambda {
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/au-email.eml")).read)
      }.should_not raise_error
    end

    it "should not be raised when parsing incoming email #45" do
      lambda {
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/au-decomail2.eml")).read)
      }.should_not raise_error
    end

    it "should not be raised when parsing incoming email - include kigou" do
      lambda {
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/au-kigou.eml")).read)
      }.should_not raise_error
    end

    context 'From au iPhone' do
      it 'charset should be UTF-8' do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/iphone-message.eml")).read)
        @mail.mobile.should be_a(Jpmobile::Mobile::Au)
        @mail.charset.should match(/utf-8/i)
      end

      it 'should be encoded correctly' do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/iphone-message.eml")).read)
        @mail.encoded
      end
    end

    context 'From iPad' do
      it 'charset should be UTF-8' do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/iphone-mail3.eml")).read)
        @mail.mobile.should be_a(Jpmobile::Mobile::AbstractMobile)
        @mail.charset.should match(/utf-8/i)
      end

      it 'should be encoded correctly' do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/iphone-mail3.eml")).read)
        @mail.encoded
      end
    end

    it 'should not raise when parsing attached email' do
      lambda {
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/au-attached.eml")).read)
        @mail.encoded
      }.should_not raise_error
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
      @mail.body.to_s.should == "本文&#xf21c;\nFor softbank\n\n"
    end

    context "to_s" do
      it "should have subject which is same as original" do
        @mail.to_s.should match(sjis_regexp("keiWvPl8"))
      end

      it "should have body which is same as original" do
        @mail.to_s.should match(sjis_regexp(utf8_to_sjis("本文")))
      end
    end

    context "modify and to_s" do
      it "should encode subject correctly" do
        @mail.subject = "大江戸&#xe63e;"
        @mail.to_s.should match(Regexp.escape("keWNXYzL+Ys="))
      end

      it "should encode body correctly" do
        @mail.body = "会議が開催&#xe646;"
        @mail.to_s.should match(sjis_regexp(utf8_to_sjis("会議が開催") + sjis("\xf7\xdf")))
      end
    end
  end

  describe "Softbank blank-mail" do
    before(:each) do
      @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/softbank-blank.eml")).read)
    end

    it "subject should be parsed correctly" do
      @mail.subject.should be_blank
    end

    it "body should be parsed correctly" do
      @mail.body.to_s.should be_blank
    end
  end

  describe "JIS mail" do
    context "Docomo" do
      before(:each) do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/docomo-jis.eml")).read)
      end

      it "subject should be parsed correctly" do
        @mail.subject.should == "テスト"
      end

      it "body should be parsed correctly" do
        @mail.body.to_s.should == "テスト本文\n\n"
      end
    end
  end

  describe 'bounced mail' do
    context "has jp address" do
      before(:each) do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "../../test/rails/overrides/spec/fixtures/mobile_mailer/bounced-jp.eml")).read)
      end

      it "mobile should abstract mobile" do
        @mail.mobile.should be_a Jpmobile::Mobile::AbstractMobile
      end
    end
  end

  describe "non-Japanese mail" do
    context "us-ascii" do
      before(:each) do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "../../test/rails/overrides/spec/fixtures/mobile_mailer/non-jp.eml")).read)
      end

      it "mobile should be nil" do
        @mail.mobile.should be_nil
        @mail.parts.first.charset.should == 'us-ascii'
      end
    end

    context "no From header" do
      before(:each) do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "../../test/rails/overrides/spec/fixtures/mobile_mailer/no-from.eml")).read)
      end

      it "mobile should be nil" do
        @mail.mobile.should be_nil
        @mail.parts.first.charset.should == 'iso-8859-1'
      end
    end
  end
end
