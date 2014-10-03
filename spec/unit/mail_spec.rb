# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))
require 'mail'
require 'jpmobile/mail'

describe "Jpmobile::Mail" do
  include Jpmobile::Util

  before(:each) do
    @mail         = Mail.new
    @mail.subject = "万葉"
    @mail.body    = "ほげ"
    @mail.from    = "ちはやふる <info@jpmobile-rails.org>"
  end

  context "Mail#to" do
    it "sets multi-tos" do
      expect{@mail.to = ["a@hoge.com", "b@hoge.com"]}.to_not raise_error
    end
  end

  describe "Non-mobile" do
    before(:each) do
      @mail = Mail.new do
        subject "万葉"
        from "ちはやふる <info@jpmobile-rails.org>"
      end
    end
    context "has multipart body" do
      before(:each) do
        @mail.parts << Mail::Part.new { body "ほげ" }
        @mail.parts << Mail::Part.new { body "ほげほげ" }
        @mail.parts.each{|p| p.charset = "ISO-2022-JP" }
      end
      context "to_s" do
        subject {
          Mail.new ascii_8bit(@mail.to_s)
        }
        it "should be able to decode bodies" do
          subject.parts[0].body == "ほげ"
          subject.parts[1].body == "ほげほげ"
        end
      end
    end
  end

  describe "AbstractMobile" do
    before(:each) do
      @mobile = Jpmobile::Mobile::AbstractMobile.new(nil, nil)
      @mail.mobile = @mobile
      @mail.to = "むすめふさほせ <info+to@jpmobile-rails.org>"
    end

    context "to_s" do
      it "should contain encoded subject" do
        expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape("=?ISO-2022-JP?B?GyRCS3xNVRsoQg==?=")))
      end

      it "should contain encoded body" do
        expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape(ascii_8bit("\x1b\x24\x42\x24\x5B\x24\x32\e\x28\x42"))))
      end

      it "should contain encoded from"do
        expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape(ascii_8bit("=?ISO-2022-JP?B?GyRCJEEkTyRkJFUkaxsoQg==?="))))
      end

      it "should contain encoded to" do
        expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape(ascii_8bit("=?ISO-2022-JP?B?GyRCJGAkOSRhJFUkNSRbJDsbKEI=?="))))
      end

      it "should contain correct Content-Type:" do
        expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape(ascii_8bit("charset=ISO-2022-JP"))))
      end
    end
  end

  describe "Docomo" do
    before(:each) do
      @mobile = Jpmobile::Mobile::Docomo.new(nil, nil)
      @mail.mobile = @mobile
      @mail.to = "むすめふさほせ <info+to@jpmobile-rails.org>"
    end

    context "to_s" do
      it "should contain encoded subject" do
        expect(@mail.to_s).to match(sjis_regexp("=?Shift_JIS?B?lpyXdA==?="))
      end

      it "should contain encoded body" do
        expect(@mail.to_s).to match(Regexp.escape(utf8_to_sjis("ほげ")))
      end

      it "should contain encoded from" do
        expect(@mail.to_s).to match(sjis_regexp("gr+CzYLigtOC6Q=="))
      end

      it "should contain encoded to" do
        expect(@mail.to_s).to match(sjis_regexp("gt6Ct4LfgtOCs4LZgrk="))
      end

      it "should contains encoded emoticon" do
        @mail.subject += "&#xe63e;"
        @mail.body = "#{@mail.body}&#xe63e;"

        expect(@mail.to_s).to match(Regexp.escape("=?Shift_JIS?B?lpyXdPif?="))
        expect(@mail.to_s).to match(sjis_regexp("\xF8\x9F"))
      end
    end
  end

  describe "Au" do
    before(:each) do
      @mobile = Jpmobile::Mobile::Au.new(nil, nil)
      @mail.mobile = @mobile
      @mail.to = "むすめふさほせ <info+to@jpmobile-rails.org>"
    end

    context "to_s" do
      it "should contain encoded subject" do
        expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape("=?ISO-2022-JP?B?GyRCS3xNVRsoQg==?=")))
      end

      it "should contain encoded body" do
        expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape(ascii_8bit("\x1b\x24\x42\x24\x5B\x24\x32\e\x28\x42"))))
      end

      it "should contain encoded from" do
        expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape(ascii_8bit("=?ISO-2022-JP?B?GyRCJEEkTyRkJFUkaxsoQg==?="))))
      end

      it "should contain encoded to" do
        expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape(ascii_8bit("=?ISO-2022-JP?B?GyRCJGAkOSRhJFUkNSRbJDsbKEI=?="))))
      end

      it "should contain encoded emoticon" do
        @mail.subject += "&#xe63e;"
        @mail.body = "#{@mail.body}&#xe63e;"

        expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape("=?ISO-2022-JP?B?GyRCS3xNVXVBGyhC?=")))
        expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape(ascii_8bit("\e\x24\x42\x24\x5B\x24\x32\x75\x41\e\x28\x42"))))
      end
    end
  end

  describe "Softbank" do
    before(:each) do
      @mobile = Jpmobile::Mobile::Softbank.new(nil, nil)
      @mail.mobile = @mobile
      @mail.to = "むすめふさほせ <info+to@jpmobile-rails.org>"
    end

    context "to_s" do
      it "should contain encoded subject" do
        expect(@mail.to_s).to match(Regexp.escape(sjis("=?Shift_JIS?B?lpyXdA==?=")))
      end

      it "should contain encoded body" do
        expect(@mail.to_s).to match(Regexp.escape(utf8_to_sjis("ほげ")))
      end

      it "should contain encoded from" do
        expect(@mail.to_s).to match(sjis_regexp("gr+CzYLigtOC6Q=="))
      end

      it "should contain encoded to" do
        expect(@mail.to_s).to match(sjis_regexp("gt6Ct4LfgtOCs4LZgrk="))
      end

      it "should contains encoded emoticon" do
        @mail.subject += "&#xe63e;"
        @mail.body = "#{@mail.body}&#xe63e;"

        expect(@mail.to_s).to match(Regexp.escape("=?Shift_JIS?B?lpyXdPmL?="))
        expect(@mail.to_s).to match(sjis_regexp("\xf9\x8b"))
      end
    end
  end

  describe "long subject" do
    before(:each) do
      @mail         = Mail.new
      @mail.subject = "弊社採用応募へのお申込み誠にありがとうございますと言いたいところだがそうは簡単には物事は運ばないことを心しておいてもらいたいと苦言を呈する故に弊社は維持しているのです"
      @mail.body    = "株式会社・・"
      @mail.from    = "info@jpmobile-rails.org"
    end

    describe "Docomo" do
      before(:each) do
        @mobile = Jpmobile::Mobile::Docomo.new(nil, nil)
        @mail.mobile = @mobile
        @mail.to = "むすめふさほせ <info+to@jpmobile-rails.org>"
      end

      it "should contain encoded subject" do
        expect(@mail.to_s).to match(sjis_regexp("=?Shift_JIS?B?lb6O0I3Ml3CJnpXlgtaCzIKokFyNnoLdkL2CyYKg?="))
        expect(@mail.to_s).to match(sjis_regexp("=?Shift_JIS?B?guiCqoLGgqSCsoK0gqKC3IK3gsaMvoKigr2CooLG?="))
        expect(@mail.to_s).to match(sjis_regexp("=?Shift_JIS?B?grGC64K+gqqCu4Kkgs2KyJJQgsmCzZWojpaCzYle?="))
        expect(@mail.to_s).to match(sjis_regexp("=?Shift_JIS?B?gs6CyIKigrGCxoLwkFOCtYLEgqiCooLEguCC54Ki?="))
        expect(@mail.to_s).to match(sjis_regexp("=?Shift_JIS?B?gr2CooLGi+qMvoLwkuaCt4LpjMyCyZW+jtCCzYjb?="))
        expect(@mail.to_s).to match(sjis_regexp("=?Shift_JIS?B?jp2CtYLEgqKC6YLMgsWCtw==?="))
      end
    end

    describe "Au" do
      before(:each) do
        @mobile = Jpmobile::Mobile::Au.new(nil, nil)
        @mail.mobile = @mobile
        @mail.to = "むすめふさほせ <info+to@jpmobile-rails.org>"
      end

      it "should contain encoded subject" do
        expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape("=?ISO-2022-JP?B?GyRCSkA8UjpOTVExfkpnJFgkTiQqPz05fiRfQD8kSyQiGyhC?=")))
        expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape("=?ISO-2022-JP?B?GyRCJGokLCRIJCYkNCQ2JCQkXiQ5JEg4QCQkJD8kJCRIGyhC?=")))
        expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape("=?ISO-2022-JP?B?GyRCJDMkbSRAJCwkPSQmJE80SkMxJEskT0oqO3YkTzE/GyhC?=")))
        expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape("=?ISO-2022-JP?B?GyRCJFAkSiQkJDMkSCRyPzQkNyRGJCokJCRGJGIkaSQkGyhC?=")))
        expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape("=?ISO-2022-JP?B?GyRCJD8kJCRINmw4QCRyRGgkOSRrOE4kS0pAPFIkTzBdGyhC?=")))
        expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape("=?ISO-2022-JP?B?GyRCO30kNyRGJCQkayROJEckORsoQg==?=")))
      end
    end

    describe "Softbank" do
      before(:each) do
        @mobile = Jpmobile::Mobile::Softbank.new(nil, nil)
        @mail.mobile = @mobile
        @mail.to = "むすめふさほせ <info+to@jpmobile-rails.org>"
      end

      it "should contain encoded subject" do
        expect(@mail.to_s).to match(sjis_regexp("=?Shift_JIS?B?lb6O0I3Ml3CJnpXlgtaCzIKokFyNnoLdkL2CyYKg?="))
        expect(@mail.to_s).to match(sjis_regexp("=?Shift_JIS?B?guiCqoLGgqSCsoK0gqKC3IK3gsaMvoKigr2CooLG?="))
        expect(@mail.to_s).to match(sjis_regexp("=?Shift_JIS?B?grGC64K+gqqCu4Kkgs2KyJJQgsmCzZWojpaCzYle?="))
        expect(@mail.to_s).to match(sjis_regexp("=?Shift_JIS?B?gs6CyIKigrGCxoLwkFOCtYLEgqiCooLEguCC54Ki?="))
        expect(@mail.to_s).to match(sjis_regexp("=?Shift_JIS?B?gr2CooLGi+qMvoLwkuaCt4LpjMyCyZW+jtCCzYjb?="))
        expect(@mail.to_s).to match(sjis_regexp("=?Shift_JIS?B?jp2CtYLEgqKC6YLMgsWCtw==?="))
      end
    end

    describe "AbstractMobile" do
      before(:each) do
        @mobile = Jpmobile::Mobile::AbstractMobile.new(nil, nil)
        @mail.mobile = @mobile
        @mail.to = "むすめふさほせ <info+to@jpmobile-rails.org>"
      end

      context "to_s" do
        it "should contain encoded subject" do
          expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape("=?ISO-2022-JP?B?GyRCSkA8UjpOTVExfkpnJFgkTiQqPz05fiRfQD8kSyQiGyhC?=")))
          expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape("=?ISO-2022-JP?B?GyRCJGokLCRIJCYkNCQ2JCQkXiQ5JEg4QCQkJD8kJCRIGyhC?=")))
          expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape("=?ISO-2022-JP?B?GyRCJDMkbSRAJCwkPSQmJE80SkMxJEskT0oqO3YkTzE/GyhC?=")))
          expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape("=?ISO-2022-JP?B?GyRCJFAkSiQkJDMkSCRyPzQkNyRGJCokJCRGJGIkaSQkGyhC?=")))
          expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape("=?ISO-2022-JP?B?GyRCJD8kJCRINmw4QCRyRGgkOSRrOE4kS0pAPFIkTzBdGyhC?=")))
          expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape("=?ISO-2022-JP?B?GyRCO30kNyRGJCQkayROJEckORsoQg==?=")))
        end
      end
    end
  end

  describe "long subject with half-characters" do
    before(:each) do
      @mail         = Mail.new
      @mail.subject = "西暦2012年09月03日は今日になるわけだが10時16分現在のこの時間ではどうかな"
      @mail.body    = "株式会社・・"
      @mail.from    = "info@jpmobile-rails.org"
    end

    describe "AbstractMobile" do
      before(:each) do
        @mobile = Jpmobile::Mobile::AbstractMobile.new(nil, nil)
        @mail.mobile = @mobile
        @mail.to = "むすめふさほせ <info+to@jpmobile-rails.org>"
      end

      context "to_s" do
        it "should contain encoded subject" do
          expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape("=?ISO-2022-JP?B?GyRCQD5OcRsoQjIwMTIbJEJHLxsoQjA5GyRCN24bKEIwMxskQkZ8JE86IxsoQg==?=")))
          expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape("=?ISO-2022-JP?B?GyRCRnwkSyRKJGskbyQxJEAkLBsoQjEwGyRCO34bKEIxNhskQkosOD0bKEI=?=")))
          expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape("=?ISO-2022-JP?B?GyRCOl8kTiQzJE47fjRWJEckTyRJJCYkKyRKGyhC?=")))
        end
      end
    end
  end

  context "with attachments" do
    before(:each) do
      @mobile = Jpmobile::Mobile::AbstractMobile.new(nil, nil)
      @mail.mobile = @mobile
      @mail.to = "むすめふさほせ <info+to@jpmobile-rails.org>"
      @photo = open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/photo.jpg")).read
    end

    it "should encodes itself successfully" do
      @mail.attachments['photo.jpg'] = @photo

      expect {
        @mail.to_s
      }.not_to raise_error
    end

    it "should encodes itself successfully with an inline attachment" do
      @mail.attachments.inline['photo.jpg'] = @photo

      expect {
        @mail.to_s
      }.not_to raise_error
    end

    it "should encodes itself successfully with an UTF-8 filename attachment" do
      @mail.attachments.inline['日本語のファイル名です.jpg'] = @photo

      expect {
        @mail.to_s
      }.not_to raise_error
    end
  end

  context "encoding conversion" do
    before(:each) do
      @mobile = Jpmobile::Mobile::AbstractMobile.new(nil, nil)
      @mail.mobile = @mobile
      @mail.to = "むすめふさほせ <info+to@jpmobile-rails.org>"
      @photo = open(File.join(File.expand_path(File.dirname(__FILE__)), "email-fixtures/photo.jpg")).read
    end

    it "wave dash converting correctly" do
      @mail.body = '10:00〜12:00'

      expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape(ascii_8bit("\x31\x30\x3a\x30\x30\x1b\x24\x42\x21\x41\x1b\x28\x42\x31\x32\x3a\x30\x30"))))
    end

    it "full width tilde converting correctly" do
      @mail.body = "10:00#{[0xff5e].pack("U")}12:00"

      expect(ascii_8bit(@mail.to_s)).to match(Regexp.compile(Regexp.escape(ascii_8bit("\x31\x30\x3a\x30\x30\x1b\x24\x42\x21\x41\x1b\x28\x42\x31\x32\x3a\x30\x30"))))
    end
  end

  context "delivering" do
    before(:each) do
      @mobile = Jpmobile::Mobile::AbstractMobile.new(nil, nil)
      @mail.mobile = @mobile
      @mail.to = "むすめふさほせ <info+to@jpmobile-rails.org>"
    end

    it "delivers through SMTP" do
      @mail.delivery_method :smtp, {:enable_starttls_auto => false}
      expect {
        @mail.deliver
      }.not_to raise_error

      Mail::TestMailer.deliveries.size
    end
  end

  context 'sending with carrier from' do
    before do
      @mail         = Mail.new
      @mail.subject = "万葉"
      @mail.to      = "ちはやふる <info@jpmobile-rails.org>"
    end

    it 'should convert content-transfer-encoding' do
      mobile = Jpmobile::Mobile::Au.new(nil, nil)
      @mail.content_transfer_encoding = 'base64'
      @mail.body = ['ほげ'].pack('m')
      @mail.charset = 'UTF-8'

      @mail.mobile = mobile
      @mail.from = '<えーゆー> au@ezweb.ne.jp'

      expect(@mail.encoded).to match(/content-transfer-encoding: 7bit/i)
    end

    it 'should not convert content-transfer-encoding with BINARY' do
      mobile = Jpmobile::Mobile::Au.new(nil, nil)
      data = ['ほげ'].pack('m').strip

      @mail.content_transfer_encoding = 'base64'
      @mail.content_type = 'image/jpeg'
      @mail.body = data
      @mail.charset = 'UTF-8'

      @mail.mobile = mobile
      @mail.from = '<えーゆー> au@ezweb.ne.jp'

      expect(@mail.encoded).to match(/content-transfer-encoding: base64/i)
      expect(@mail.encoded).to match(data)
    end
  end
end
