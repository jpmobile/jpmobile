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
      expect(@mail.subject).to eq("タイトルの長いメールの場合の対処を実装するためのテストケースとしてのメールに含まれている件名であるサブジェクト部分")
    end

    it "body should be parsed correctly" do
      expect(@mail.body.to_s).to eq("本文です\n\n")
    end

    context "to_s" do
      it "should have subject which is same as original" do
        expect(ascii_8bit(@mail.to_s)).to match("GyRCJT8lJCVIJWskTkQ5JCQlYSE8JWskTj5s")
      end

      it "should have body which is same as original" do
        expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape(ascii_8bit(utf8_to_jis("本文です")))))
      end
    end

    context "modify and to_s" do
      it "should encode subject correctly" do
        @mail.subject = "大江戸"
        expect(ascii_8bit(@mail.to_s)).to match("GyRCQmc5PjhNGyhC")
      end

      it "should encode body correctly" do
        @mail.body = "会議が開催"
        expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape(ascii_8bit(utf8_to_jis("会議が開催")))))
      end
    end
  end

  describe "multipart" do
    describe "PC mail" do
      before(:each) do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/pc-mail-multi.eml")).read)
      end

      it "subject should be parsed correctly" do
        expect(@mail.subject).to eq("タイトルの長いメールの場合の対処を実装するためのテストケースとしてのメールに含まれている件名であるサブジェクト部分")
      end

      it "body should be parsed correctly" do
        expect(@mail.body.parts.size).to eq(2)
        expect(@mail.body.parts.first.body.to_s).to eq("本文です\n\n")
      end

      it "should encode correctly" do
        expect(ascii_8bit(@mail.to_s)).to match(/GyRCJT8lJCVIJWskTkQ5JCQlYSE8JWskTj5s/)
      end
    end

    describe "PC mail without subject" do
      before(:each) do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/pc-mail-attached-without-subject.eml")).read)
      end

      it "body should be parsed correctly" do
        expect(@mail.body.parts.size).to eq(2)
        expect(@mail.body.parts.first.body.to_s).to eq("本文です\n\n")
      end

      it "should encode correctly" do
        expect(ascii_8bit(@mail.to_s)).to match(/GODlhAQABAIAAAAAAAP/)
      end
    end

    describe "Docomo" do
      context "with sjis decomail" do
        before(:each) do
          @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "../../test/rails/overrides/spec/fixtures/mobile_mailer/docomo-gmail-sjis.eml")).read)
        end

        it "subject should be parsed correctly" do
          expect(@mail.subject).to eq("テスト&#xe6ec;")
        end

        it "body should be parsed correctly" do
          expect(@mail.body.parts.size).to eq(1)
          @mail.body.parts.first.parts.size == 2
          expect(@mail.body.parts.first.parts.first.body).to match("テストです&#xe72d;")
          expect(@mail.body.parts.first.parts.last.body.raw_source).to match("テストです&#xe72d;")
        end

        it "should encode correctly" do
          expect(@mail.to_s).to match(Regexp.escape("g2WDWINn+ZE"))
        end

        it "does not cause double-conversion on reparsing" do
          @reparsed = Mail.new(@mail.to_s)
          expect(@reparsed.to_s).to match(Regexp.escape("g2WDWINn+ZE"))
          expect(@reparsed.body.parts.first.parts.first.body).to match("テストです&#xe72d;")
        end
      end

      context "with jis decomail" do
        before(:each) do
          @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/docomo-decomail.eml")).read)
        end

        it "does not contain charset within multipart Content-Type" do
          expect(@mail.to_s.scan(/Content-Type:\s+multipart(?:.+;\r\n)*.+[^;]\r\n/)).
            to satisfy{|matches| matches.all?{|type| !type.include?('charset')}}
        end

        it "does not cause double-conversion on reparsing" do
          @reparsed = Mail.new(@mail.to_s)
          expect(@reparsed.to_s).to match(Regexp.escape("g2WDWINn"))
          expect(@reparsed.parts.first.parts.first.parts.first.body.decoded).to match("テストです")
        end
      end
    end

    describe "Au" do
      before(:each) do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "../../test/rails/overrides/spec/fixtures/mobile_mailer/au-decomail.eml")).read)
      end

      it "subject should be parsed correctly" do
        expect(@mail.subject).to eq("テスト&#xe4f4;")
      end

      it "body should be parsed correctly" do
        expect(@mail.body.parts.size).to eq(1)
        @mail.body.parts.first.parts.size == 1
        expect(@mail.body.parts.first.parts.first.body.to_s).to match("テストです&#xe595;")
        expect(@mail.body.parts.first.parts.last.body.raw_source).to match("テストです&#xe595;")
      end

      it "should encode correctly" do
        expect(ascii_8bit(@mail.to_s)).to match(Regexp.escape("GyRCJUYlOSVIdk8bKEI="))
      end
    end

    describe "Softbank" do
      context "Shift_JIS" do
        before(:each) do
          @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "../../test/rails/overrides/spec/fixtures/mobile_mailer/softbank-gmail-sjis.eml")).read)
        end

        it "subject should be parsed correctly" do
          expect(@mail.subject).to eq("テスト&#xf221;&#xf223;&#xf221;")
        end

        it "body should be parsed correctly" do
          expect(@mail.body.parts.size).to eq(2)
          expect(@mail.body.parts.first.body.to_s).to eq("テストです&#xf018;")
        end

        it "should encode correctly" do
          expect(@mail.to_s).to match(Regexp.escape("g2WDWINn98H3w/fB"))
        end
      end

      context "UTF-8" do
        before(:each) do
          @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "../../test/rails/overrides/spec/fixtures/mobile_mailer/softbank-gmail-utf8.eml")).read)
        end

        it "subject should be parsed correctly" do
          expect(@mail.subject).to eq("テストです&#xf221;")
        end

        it "body should be parsed correctly" do
          expect(@mail.body.parts.size).to eq(2)
          expect(@mail.body.parts.first.body.raw_source).to eq("テストです&#xf223;")
        end

        it "should encode correctly to Shift_JIS" do
          expect(@mail.to_s).to match(Regexp.escape("g2WDWINngsWCt/fB"))
        end
      end
    end

    context 'bounced mail' do
      it 'should parse sub-part charset correctly' do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/bounce_with_utf8_part.eml")).read)
        expect(@mail.parts.first.charset).to match(/iso-2022-jp/i)
        expect(@mail.parts.last.charset).to  match(/utf-8/i)
      end
    end
  end

  describe "Docomo" do
    before(:each) do
      @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/docomo-emoji.eml")).read)
    end

    it "subject should be parsed correctly" do
      expect(@mail.subject).to eq("題名&#xe676;")
    end

    it "body should be parsed correctly" do
      expect(@mail.body.to_s).to eq("本文&#xe6e2;\nFor docomo\n\n")
    end

    context "to_s" do
      it "should have subject which is same as original" do
        expect(@mail.to_s).to match(Regexp.escape("keiWvPjX"))
      end

      it "should have body which is same as original" do
        expect(@mail.to_s).to match(sjis_regexp(utf8_to_sjis("本文")))
      end
    end

    context "modify and to_s" do
      it "should encode subject correctly" do
        @mail.subject = "大江戸&#xe63e;"
        expect(@mail.to_s).to match(Regexp.escape("keWNXYzL+J8="))
      end

      it "should encode body correctly" do
        @mail.body = "会議が開催&#xe646;"
        expect(@mail.to_s).to match(sjis_regexp(sjis("\x89\xEF\x8Bc\x82\xAA\x8AJ\x8D\xC3\xF8\xA7")))
      end
    end

    context "JIS mail" do
      before(:each) do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/docomo-jis.eml")).read)
      end

      it "subject should be parsed correctly" do
        expect(@mail.subject).to eq("テスト")
      end

      it "body should be parsed correctly" do
        expect(@mail.body.to_s).to eq("テスト本文\n\n")
      end
    end
  end

  describe "Au" do
    context 'au-emoji.eml' do
      before(:each) do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/au-emoji.eml")).read)
      end

      it "subject should be parsed correctly" do
        expect(@mail.subject).to eq("題名&#xe503;")
      end

      it "body should be parsed correctly" do
        expect(@mail.body.to_s).to eq("本文&#xe522;\nFor au\n\n")
      end

      context "to_s" do
        it "should have subject which is same as original" do
          expect(ascii_8bit(@mail.to_s)).to match(Regexp.escape("GyRCQmpMPnZeGyhC"))
        end

        it "should have body which is same as original" do
          expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape(ascii_8bit("\e\x24\x42\x4B\x5C\x4A\x38\x76\x7D\e\x28\x42"))))
        end
      end

      context "modify and to_s" do
        it "should encode subject correctly" do
          @mail.subject = "大江戸&#xe63e;"
          expect(ascii_8bit(@mail.to_s)).to match(/\?GyRCQmc5PjhNdUEbKEI=/)
        end

        it "should encode body correctly" do
          @mail.body = "会議が開催&#xe646;"
          expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape(ascii_8bit("\x1b\x24\x42\x32\x71\x35\x44\x24\x2C\x33\x2B\x3A\x45\x75\x48\x1b\x28\x42"))))
        end
      end
    end

    it "should not be raised when parsing incoming email #41" do
      expect {
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/au-email.eml")).read)
      }.not_to raise_error
    end

    it "should not be raised when parsing incoming email #45" do
      expect {
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/au-decomail2.eml")).read)
      }.not_to raise_error
    end

    it "should not be raised when parsing incoming email - include kigou" do
      expect {
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/au-kigou.eml")).read)
      }.not_to raise_error
    end

    context 'From au iPhone' do
      it 'charset should be UTF-8' do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/iphone-message.eml")).read)
        expect(@mail.mobile).to be_a(Jpmobile::Mobile::Au)
        expect(@mail.charset).to match(/utf-8/i)
      end

      it 'should be encoded correctly' do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/iphone-message.eml")).read)
        expect(@mail.encoded).to match(Regexp.escape("%[\e$B1`;yL>\e(B]%\e$B$N\e(B%[\e$BJ]8n<TL>\e(B]%"))
      end

      it 'should decode cp932-encoded mail correctly' do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/iphone-cp932.eml")).read)
        expect(@mail.subject).to eq 'Re: 【NKSC】test'
        expect(@mail.body.to_s).to eq 'テストです。㈱'
      end
    end

    context 'From iPad' do
      it 'charset should be UTF-8' do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/iphone-mail3.eml")).read)
        expect(@mail.mobile).to be_a(Jpmobile::Mobile::AbstractMobile)
        expect(@mail.charset).to match(/utf-8/i)
      end

      it 'should be encoded correctly' do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/iphone-mail3.eml")).read)
        expect(@mail.encoded).to match(/BK\\J82~9T\$J\$7!2#5#1#2J8;z!2/)
      end
    end

    it 'should not raise when parsing attached email' do
      expect {
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/au-attached.eml")).read)
        expect(@mail.encoded).to match('/9j/4AAQSkZJRgABAgAAZABkAAD/7AARRHVja3kAAQAEAAAAPQAA')
      }.not_to raise_error
    end
  end

  describe "Softbank" do
    before(:each) do
      @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/softbank-emoji.eml")).read)
    end

    it "subject should be parsed correctly" do
      expect(@mail.subject).to eq("題名&#xf03c;")
    end

    it "body should be parsed correctly" do
      expect(@mail.body.to_s).to eq("本文&#xf21c;\nFor softbank\n\n")
    end

    context "to_s" do
      it "should have subject which is same as original" do
        expect(@mail.to_s).to match(sjis_regexp("keiWvPl8"))
      end

      it "should have body which is same as original" do
        expect(@mail.to_s).to match(sjis_regexp(utf8_to_sjis("本文")))
      end
    end

    context "modify and to_s" do
      it "should encode subject correctly" do
        @mail.subject = "大江戸&#xe63e;"
        expect(@mail.to_s).to match(Regexp.escape("keWNXYzL+Ys="))
      end

      it "should encode body correctly" do
        @mail.body = "会議が開催&#xe646;"
        expect(@mail.to_s).to match(sjis_regexp(utf8_to_sjis("会議が開催") + sjis("\xf7\xdf")))
      end
    end

    describe "blank-mail" do
      before(:each) do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/softbank-blank.eml")).read)
      end

      it "subject should be parsed correctly" do
        expect(@mail.subject).to be_blank
      end

      it "body should be parsed correctly" do
        expect(@mail.body.to_s).to be_blank
      end
    end
  end

  describe "iPhone" do
    context "JIS mail" do
      before(:each) do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/iphone-jis.eml")).read)
      end

      it "body should be parsed correctly" do
        expect(@mail.body.to_s).to eq("(=ﾟωﾟ)ﾉ\n\n\n")
      end
    end

    context "when the mail contains UTF-8 emojis" do
      before(:each) do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/iphone-unicode-emoji.eml")).read)
      end

      it "subject should be parsed correctly" do
        expect(@mail.subject).to eq("絵文字\u{1F385}")
      end

      it "body should be parsed correctly" do
        expect(@mail.body.to_s).to eq("\u{1F384}\u2763")
      end
    end

    context "when the mail contains circled-numbers" do
      before(:each) do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/iphone-circled-numbers-in-jis.eml")).read)
      end

      it "subject should be parsed correctly" do
        expect(@mail.subject).to eq("テスト①")
      end

      it "body should be parsed correctly" do
        expect(@mail.body.to_s).to eq("丸数字のテストです②ⅱ\n\n")
      end
    end
  end

  describe 'bounced mail' do
    context "has jp address" do
      before(:each) do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "../../test/rails/overrides/spec/fixtures/mobile_mailer/bounced-jp.eml")).read)
      end

      it "mobile should abstract mobile" do
        expect(@mail.mobile).to be_a Jpmobile::Mobile::AbstractMobile
      end
    end
  end

  describe "non-Japanese mail" do
    context "us-ascii" do
      before(:each) do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "../../test/rails/overrides/spec/fixtures/mobile_mailer/non-jp.eml")).read)
      end

      it "mobile should be nil" do
        expect(@mail.mobile).to be_nil
        expect(@mail.parts.first.charset).to eq('us-ascii')
      end
    end

    context "no From header" do
      before(:each) do
        @mail = Mail.new(open(File.join(File.expand_path(File.dirname(__FILE__)), "../../test/rails/overrides/spec/fixtures/mobile_mailer/no-from.eml")).read)
      end

      it "mobile should be nil" do
        expect(@mail.mobile).to be_nil
        expect(@mail.parts.first.charset).to eq('iso-8859-1')
      end
    end
  end
end
