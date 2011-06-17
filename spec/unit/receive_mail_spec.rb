# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))
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
        @mail.body.parts.first.body.to_s.should == "本文です"
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
        ascii_8bit(@mail.to_s).should match(Regexp.escape("GyRCJUYlOSVIGyhCGyRCdk8bKEI="))
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
    before(:each) do
      @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/au-emoji.eml")).read)
    end

    it "subject should be parsed correctly" do
      @mail.subject.should == "題名&#xe503;"
    end

    it "body should be parsed correctly" do
      @mail.body.to_s.should == "本文&#xe522;\nFor au"
    end

    context "to_s" do
      it "should have subject which is same as original" do
        ascii_8bit(@mail.to_s).should match(Regexp.escape("GyRCQmpMPhsoQhskQnZeGyhC"))
      end

      it "should have body which is same as original" do
        ascii_8bit(@mail.to_s).should match(Regexp.compile(Regexp.escape(ascii_8bit(utf8_to_jis("本文")))))
      end
    end

    context "modify and to_s" do
      it "should encode subject correctly" do
        @mail.subject = "大江戸&#xe63e;"
        ascii_8bit(@mail.to_s).should match("GyRCQmc5PjhNGyhCGyRCdUEbKEI=")
      end

      it "should encode body correctly" do
        @mail.body = "会議が開催&#xe646;"
        ascii_8bit(@mail.to_s).should match(Regexp.compile(Regexp.escape(ascii_8bit("\x1b\x24\x42\x32\x71\x35\x44\x24\x2C\x33\x2B\x3A\x45\x1b\x28\x42\x1b\x24\x42\x75\x48\x1b\x28\x42"))))
      end
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
        @mail.body.to_s.should == "テスト本文"
      end
    end
  end
end
