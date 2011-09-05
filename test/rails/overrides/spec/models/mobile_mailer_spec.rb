# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), '/../spec_helper'))

describe MobileMailer do
  include Jpmobile::Util

  before(:each) do
    ActionMailer::Base.deliveries = []

    @to      = ["outer@jp.mobile", "outer1@jp.mobile"]
    @subject = "日本語題名"
    @text    = "日本語テキスト"
    @sjis_regexp = %r!=\?shift_jis\?B\?(.+)\?=!
    @jis_regexp  = %r!=\?iso-2022-jp\?B\?(.+)\?=!
  end

  shared_examples_for "PC宛メール" do
    it "正常に送信できること" do
      email = MobileMailer.view_selection(@to, "題名", "本文").deliver

      ActionMailer::Base.deliveries.size.should == 1
      email.to.include?(@to).should be_true
    end

    it "ISO-2022-JPに変換されること" do
      email = MobileMailer.view_selection(@to, "題名", "本文").deliver

      ActionMailer::Base.deliveries.size.should == 1

      raw_mail = ascii_8bit(email.to_s)
      raw_mail.should match(/iso-2022-jp/i)
      raw_mail.should match(Regexp.compile(Regexp.escape(ascii_8bit([utf8_to_jis("題名")].pack('m').strip))))
      raw_mail.should match(Regexp.compile(Regexp.escape(ascii_8bit(utf8_to_jis("本文")))))
    end

    it "絵文字がゲタ(〓)に変換されること" do
      email = MobileMailer.view_selection(@to, "題名&#xe676;", "本文&#xe68b;".html_safe).deliver

      ActionMailer::Base.deliveries.size.should == 1

      raw_mail = ascii_8bit(email.to_s)
      raw_mail.should match(Regexp.escape("GyRCQmpMPiIuGyhC"))
      raw_mail.should match(Regexp.compile(Regexp.escape(ascii_8bit(utf8_to_jis("本文〓")))))
    end

    it "quoted-printableではないときに勝手に変換されないこと" do
      email = MobileMailer.view_selection(@to, "題名",
        "本文です\nhttp://test.rails/foo/bar/index?d=430d0d1cea109cdb384ec5554b890e3940f293c7&e=ZVG%0FE%16%5E%07%04%21P%5CZ%06%00%0D%1D%40L").deliver

      ActionMailer::Base.deliveries.size.should == 1

      raw_mail = ascii_8bit(email.to_s)
      raw_mail.should match(/ZVG%0FE%16%5E%07%04%21P%5CZ%06%00%0D%1D%40L/)
    end

    context ":toの指定が" do
      it "ない場合でも正常に送信できること" do
        email = MobileMailer.default_to_mail('題名', '本文').deliver

        ActionMailer::Base.deliveries.size.should == 1
      end
    end
  end

  describe "PC宛に送るとき" do
    before(:each) do
      @to = "bill.gate@microsoft.com"
    end

    it_behaves_like "PC宛メール"

    it "複数に配信するときもISO-2022-JPに変換されること" do
      email = MobileMailer.view_selection(@to, "題名", "本文").deliver

      ActionMailer::Base.deliveries.size.should == 1

      raw_mail = ascii_8bit(email.to_s)
      raw_mail.should match(/iso-2022-jp/i)
      raw_mail.should match(Regexp.compile(Regexp.escape(ascii_8bit([utf8_to_jis("題名")].pack('m').strip))))
      raw_mail.should match(Regexp.compile(Regexp.escape(ascii_8bit(utf8_to_jis("本文")))))
    end
  end

  describe "docomo にメールを送るとき" do
    before(:each) do
      @to = "docomo@docomo.ne.jp"
    end

    it "subject/body が Shift-JIS になること" do
      email = MobileMailer.view_selection(@to, @subject, @text).deliver

      ActionMailer::Base.deliveries.size.should == 1

      raw_mail = email.to_s
      raw_mail.should match(/shift_jis/i)
      # raw_mail.should match(/For docomo/)
      raw_mail.should match(Regexp.escape("k/qWe4zqkeiWvA=="))
      raw_mail.should match(Regexp.compile(utf8_to_sjis(@text)))
    end

    it "数値参照の絵文字が変換されること" do
      emoji_subject = @subject + "&#xe676;"
      emoji_text = @text + "&#xe68b;"

      email = MobileMailer.view_selection(@to, emoji_subject, emoji_text.html_safe).deliver

      ActionMailer::Base.deliveries.size.should == 1

      raw_mail = email.to_s
      raw_mail.should match(/For docomo/)
      raw_mail.should match(Regexp.escape("k/qWe4zqkeiWvPjX"))
      raw_mail.should match(regexp_to_sjis("\xf8\xec"))
    end

    it "半角カナがそのまま送信されること" do
      half_kana_subject = @subject + "ｹﾞｰﾑ"
      half_kana_text    = @text + "ﾌﾞｯｸ"

      email = MobileMailer.view_selection(@to, half_kana_subject, half_kana_text).deliver

      ActionMailer::Base.deliveries.size.should == 1

      raw_mail = email.to_s
      raw_mail.should match(/For docomo/)
      raw_mail.should match(Regexp.escape("k/qWe4zqkeiWvLnesNE="))
      raw_mail.should match(Regexp.compile(Regexp.escape(utf8_to_sjis(half_kana_text))))
    end

    it "quoted-printable ではないときに勝手に変換されないこと" do
      email = MobileMailer.view_selection(@to, "題名",
        "本文です\nhttp://test.rails/foo/bar/index?d=430d0d1cea109cdb384ec5554b890e3940f293c7&e=ZVG%0FE%16%5E%07%04%21P%5CZ%06%00%0D%1D%40L").deliver

      ActionMailer::Base.deliveries.size.should == 1

      raw_mail = email.to_s
      raw_mail.should match(/ZVG%0FE%16%5E%07%04%21P%5CZ%06%00%0D%1D%40L/)
    end
  end

  describe "au にメールを送るとき" do
    before(:each) do
      @to = "au@ezweb.ne.jp"
    end

    it "subject/body がISO-2022-JPになること" do
      email = MobileMailer.view_selection(@to, @subject, @text).deliver

      ActionMailer::Base.deliveries.size.should == 1

      raw_mail = ascii_8bit(email.to_s)
      raw_mail.should match(/iso-2022-jp/i)
      raw_mail.should match(Regexp.compile(Regexp.escape(ascii_8bit([utf8_to_jis(@subject)].pack('m').strip))))
      raw_mail.should match(Regexp.compile(Regexp.escape(ascii_8bit(utf8_to_jis(@text)))))
    end

    it "数値参照が絵文字に変換されること" do
      emoji_subject = @subject + "&#xe676;"
      emoji_text    = @text    + "&#xe68b;"

      email = MobileMailer.view_selection(@to, emoji_subject, emoji_text.html_safe).deliver

      ActionMailer::Base.deliveries.size.should == 1

      raw_mail = ascii_8bit(email.to_s)
      raw_mail.should match(/For au/)
      raw_mail.should match(Regexp.escape("GyRCRnxLXDhsQmpMPhsoQhskQnZeGyhC"))
      raw_mail.should match(Regexp.compile(ascii_8bit("\x76\x21")))
    end

    it "quoted-printable ではないときに勝手に変換されないこと" do
      email = MobileMailer.view_selection(@to, "題名",
        "本文です\nhttp://test.rails/foo/bar/index?d=430d0d1cea109cdb384ec5554b890e3940f293c7&e=ZVG%0FE%16%5E%07%04%21P%5CZ%06%00%0D%1D%40L").deliver

      ActionMailer::Base.deliveries.size.should == 1

      raw_mail = ascii_8bit(email.to_s)
      raw_mail.should match(/ZVG%0FE%16%5E%07%04%21P%5CZ%06%00%0D%1D%40L/)
    end
  end

  describe "softbank にメールを送るとき" do
    before(:each) do
      @to = "softbank@softbank.ne.jp"
    end

    it "subject/body が Shift_JIS になること" do
      email = MobileMailer.view_selection(@to, @subject, @text).deliver

      ActionMailer::Base.deliveries.size.should == 1

      raw_mail = email.to_s
      raw_mail.should match(/shift_jis/i)
      raw_mail.should match(/For softbank/)
      raw_mail.should match(Regexp.escape("k/qWe4zqkeiWvA=="))
      raw_mail.should match(Regexp.compile(utf8_to_sjis(@text)))
    end

    it "数値参照が絵文字に変換されること" do
      emoji_subject = @subject + "&#xe676;"
      emoji_text    = @text    + "&#xe68a;"

      email = MobileMailer.view_selection(@to, emoji_subject, emoji_text.html_safe).deliver

      ActionMailer::Base.deliveries.size.should == 1

      raw_mail = email.to_s
      raw_mail.should match(/For softbank/)
      raw_mail.should match(Regexp.escape("k/qWe4zqkeiWvPl8"))
      raw_mail.should match(regexp_to_sjis("\xf7\x6a"))
    end

    it "quoted-printable ではないときに勝手に変換されないこと" do
      email = MobileMailer.view_selection(@to, "題名",
        "本文です\nhttp://test.rails/foo/bar/index?d=430d0d1cea109cdb384ec5554b890e3940f293c7&e=ZVG%0FE%16%5E%07%04%21P%5CZ%06%00%0D%1D%40L").deliver

      ActionMailer::Base.deliveries.size.should == 1

      raw_mail = email.to_s
      raw_mail.should match(/ZVG%0FE%16%5E%07%04%21P%5CZ%06%00%0D%1D%40L/)
    end
  end

  describe "vodafone にメールを送るとき" do
    before(:each) do
      @to = "vodafone@d.vodafone.ne.jp"
    end

    it "subject/body が Shift_JIS になること" do
      email = MobileMailer.view_selection(@to, @subject, @text).deliver

      ActionMailer::Base.deliveries.size.should == 1

      raw_mail = email.to_s
      raw_mail.should match(/shift_jis/i)
      raw_mail.should match(/For vodafone/)
      raw_mail.should match(Regexp.escape("k/qWe4zqkeiWvA=="))
      raw_mail.should match(Regexp.compile(utf8_to_sjis(@text)))
    end

    it "数値参照が絵文字に変換されること" do
      emoji_subject = @subject + "&#xe676;"
      emoji_text    = @text    + "&#xe68a;"

      email = MobileMailer.view_selection(@to, emoji_subject, emoji_text.html_safe).deliver

      ActionMailer::Base.deliveries.size.should == 1

      raw_mail = email.to_s
      raw_mail.should match(/For vodafone/)
      raw_mail.should match(Regexp.escape("k/qWe4zqkeiWvPl8"))
      raw_mail.should match(regexp_to_sjis("\xf7\x6a"))
    end

    it "quoted-printable ではないときに勝手に変換されないこと" do
      email = MobileMailer.view_selection(@to, "題名",
        "本文です\nhttp://test.rails/foo/bar/index?d=430d0d1cea109cdb384ec5554b890e3940f293c7&e=ZVG%0FE%16%5E%07%04%21P%5CZ%06%00%0D%1D%40L").deliver

      ActionMailer::Base.deliveries.size.should == 1

      raw_mail = email.to_s
      raw_mail.should match(/ZVG%0FE%16%5E%07%04%21P%5CZ%06%00%0D%1D%40L/)
    end
  end

  describe "willcom にメールを送るとき" do
    before(:each) do
      @to = "willcom@wm.pdx.ne.jp"
    end

    it_behaves_like "PC宛メール"
  end

  describe "emobile にメールを送るとき" do
    before(:each) do
      @to = "emobile@emnet.ne.jp"
    end

    it_behaves_like "PC宛メール"
  end

  describe "multipart メールを送信するとき" do
    before(:each) do
      ActionMailer::Base.deliveries = []

      @subject = "題名"
      @text    = "本文"
      @html    = "万葉"
    end

    describe "PC の場合" do
      before(:each) do
        @to = "gate@bill.com"
      end

      it "漢字コードが変換されること" do
        email = MobileMailer.multi_message(@to, @subject, @text, @html).deliver

        ActionMailer::Base.deliveries.size.should == 1

        email.parts.size.should == 2

        raw_mail = ascii_8bit(email.to_s)
        raw_mail.should match(Regexp.escape(ascii_8bit(utf8_to_jis(@text))))
        raw_mail.should match(Regexp.escape(ascii_8bit(utf8_to_jis(@html))))
      end
    end

    describe "docomo の場合" do
      before(:each) do
        @to     = "docomo@docomo.ne.jp"
      end

      it "漢字コードが変換されること" do
        email = MobileMailer.multi_message(@to, @subject, @text, @html).deliver

        ActionMailer::Base.deliveries.size.should == 1

        email.parts.size.should == 2

        raw_mail = email.to_s
        raw_mail.should match(sjis_regexp(utf8_to_sjis(@text)))
        raw_mail.should match(sjis_regexp(utf8_to_sjis(@html)))
      end

      it "絵文字が変換されること" do
        @text  += "&#xe68b;"
        @html  += "&#xe676;"
        email = MobileMailer.multi_message(@to, @subject, @text, @html).deliver

        ActionMailer::Base.deliveries.size.should == 1

        email.parts.size.should == 2

        raw_mail = email.to_s
        raw_mail.should match(sjis_regexp(sjis("\xf8\xec")))
        raw_mail.should match(sjis_regexp(sjis("\xf8\xd7")))
      end
    end

    describe "au の場合" do
      before(:each) do
        @to     = "au@ezweb.ne.jp"
      end

      it "漢字コードが変換されること" do
        email = MobileMailer.multi_message(@to, @subject, @text, @html).deliver

        ActionMailer::Base.deliveries.size.should == 1

        email.parts.size.should == 2

        raw_mail = ascii_8bit(email.to_s)
        raw_mail.should match(Regexp.escape(ascii_8bit(utf8_to_jis(@text))))
        raw_mail.should match(Regexp.escape(ascii_8bit(utf8_to_jis(@html))))
      end

      it "絵文字が変換されること" do
        @text += "&#xe68b;"
        @html += "&#xe676;"
        email = MobileMailer.multi_message(@to, @subject, @text, @html).deliver

        ActionMailer::Base.deliveries.size.should == 1

        email.parts.size.should == 2

        raw_mail = ascii_8bit(email.to_s)
        raw_mail.should match(jis_regexp("\x76\x21"))
        raw_mail.should match(jis_regexp("\x76\x5e"))
      end
    end

    describe "softbank の場合" do
      before(:each) do
        @to     = "softbank@softbank.ne.jp"
      end

      it "漢字コードが変換されること" do
        email = MobileMailer.multi_message(@to, @subject, @text, @html).deliver

        ActionMailer::Base.deliveries.size.should == 1

        email.parts.size.should == 2

        raw_mail = email.to_s
        raw_mail.should match(sjis_regexp(utf8_to_sjis(@text)))
        raw_mail.should match(sjis_regexp(utf8_to_sjis(@html)))
      end

      it "絵文字が変換されること" do
        @text  += "&#xe68a;"
        @html  += "&#xe676;"
        email = MobileMailer.multi_message(@to, @subject, @text, @html).deliver

        ActionMailer::Base.deliveries.size.should == 1

        email.parts.size.should == 2

        raw_mail = email.to_s
        raw_mail.should match(sjis_regexp(sjis("\xf7\x6a")))
        raw_mail.should match(sjis_regexp(sjis("\xf9\x7c")))
      end
    end

    describe "vodafone の場合" do
      before(:each) do
        @to     = "vodafone@d.vodafone.ne.jp"
      end

      it "漢字コードが変換されること" do
        email = MobileMailer.multi_message(@to, @subject, @text, @html).deliver

        ActionMailer::Base.deliveries.size.should == 1

        email.parts.size.should == 2

        raw_mail = email.to_s
        raw_mail.should match(sjis_regexp(utf8_to_sjis(@text)))
        raw_mail.should match(sjis_regexp(utf8_to_sjis(@html)))
      end

      it "絵文字が変換されること" do
        @text  += "&#xe68a;"
        @html  += "&#xe676;"
        email = MobileMailer.multi_message(@to, @subject, @text, @html).deliver

        ActionMailer::Base.deliveries.size.should == 1

        email.parts.size.should == 2

        raw_mail = email.to_s
        raw_mail.should match(sjis_regexp(sjis("\xf7\x6a")))
        raw_mail.should match(sjis_regexp(sjis("\xf9\x7c")))
      end
    end
  end
end

describe MobileMailer, " mail address" do
  before(:each) do
    ActionMailer::Base.deliveries = []

    @subject = "日本語題名"
    @text    = "日本語テキスト"
  end

  it "ピリオドが3つ以上連続するアドレスが有効になること" do
    to = "ruby...rails@domomo-ezweb.ne.jp"
    MobileMailer.view_selection(to, @subject, @text).deliver

    emails = ActionMailer::Base.deliveries
    emails.size.should == 1
    emails.first.to.include?(to).should be_true
    emails.first.destinations.include?(to).should be_true
  end

  it "@マークの直前にピリオドあるアドレスが有効になること" do
    to = "ruby.rails.@domomo-ezweb.ne.jp"
    MobileMailer.view_selection(to, @subject, @text).deliver

    emails = ActionMailer::Base.deliveries
    emails.size.should == 1
    emails.first.to.include?(to).should be_true
    emails.first.destinations.include?(to).should be_true
  end

  it "ピリオドから始まるアドレスが有効になること" do
    to = ".ruby.rails.@domomo-ezweb.ne.jp"
    MobileMailer.view_selection(to, @subject, @text).deliver

    emails = ActionMailer::Base.deliveries
    emails.size.should == 1
    emails.first.to.include?(to).should be_true
    emails.first.destinations.include?(to).should be_true
  end

  it "複数のアドレスが有効になること" do
    to = [".ruby.rails.@domomo-ezweb.ne.jp", "ruby.rails.@domomo-ezweb.ne.jp", "ruby...rails@domomo-ezweb.ne.jp"].join(", ")
    MobileMailer.view_selection(to, @subject, @text).deliver

    emails = ActionMailer::Base.deliveries
    emails.size.should == 1
    emails.first.to.should == to
    emails.first.destinations.should == [to]
  end
end

describe MobileMailer, "receiving" do
  describe "blank mail" do
    it "softbank からの空メールがで受信できること" do
      email = open(Rails.root + "spec/fixtures/mobile_mailer/softbank-blank.eml").read
      # expect {
        email = MobileMailer.receive(email)
      # }.to_not raise_error

      email.subject.should be_blank
      email.body.should be_blank
    end
  end

  describe "docomo からのメールを受信するとき" do
    before(:each) do
      @email = open(Rails.root + "spec/fixtures/mobile_mailer/docomo-emoji.eml").read
    end

    it "漢字コードを適切に変換できること" do
      email = MobileMailer.receive(@email)
      email.subject.should match(/題名/)
      email.body.should match(/本文/)
    end

    it "絵文字が数値参照に変わること" do
      email = MobileMailer.receive(@email)

      email.subject.should match(/&#xe676;/)
      email.body.should match(/&#xe6e2;/)
    end

    describe "jis コードの場合に" do
      before(:each) do
        @email = open(Rails.root + "spec/fixtures/mobile_mailer/docomo-jis.eml").read
      end

      it "適切に変換できること" do
        email = MobileMailer.receive(@email)

        email.subject.should match(/テスト/)
        email.body.should match(/テスト本文/)
      end
    end
  end

  describe "au からのメールを受信するとき" do
    describe "jpmobile で送信したメールの場合" do
      before(:each) do
        @email = open(Rails.root + "spec/fixtures/mobile_mailer/au-emoji.eml").read
      end

      it "漢字コードを適切に変換できること" do
        email = MobileMailer.receive(@email)

        email.subject.should match(/題名/)
        email.body.should match(/本文/)
      end

      it "絵文字が数値参照に変わること" do
        email = MobileMailer.receive(@email)

        email.subject.should match(/&#xe503;/)
        email.body.should match(/&#xe522;/)
      end
    end

    describe "実機からのメールの場合" do
      before(:each) do
        @email = open(Rails.root + "spec/fixtures/mobile_mailer/au-emoji2.eml").read
      end

      it "漢字コードを適切に変換できること" do
        email = MobileMailer.receive(@email)

        email.subject.should match(/題名/)
        email.body.should match(/本文/)
      end

      it "絵文字が数値参照に変わること" do
        email = MobileMailer.receive(@email)

        email.subject.should match(/&#xe4f4;/)
        email.body.should match(/&#xe471;/)
      end
    end
  end

  describe "softbank からのメールを受信するとき" do
    describe "shift_jis のとき" do
      before(:each) do
        @email = open(Rails.root + "spec/fixtures/mobile_mailer/softbank-emoji.eml").read
      end

      it "漢字コードを適切に変換できること" do
        email = MobileMailer.receive(@email)

        email.subject.should match(/題名/)
        email.body.should match(/本文/)
      end

      it "絵文字が数値参照に変わること" do
        email = MobileMailer.receive(@email)

        email.subject.should match(/&#xf03c;/)
        email.body.should match(/&#xf21c;/)
      end
    end

    describe "utf-8 のとき" do
      before(:each) do
        @email = open(Rails.root + "spec/fixtures/mobile_mailer/softbank-emoji-utf8.eml").read
      end

      it "漢字コードを適切に変換できること" do
        email = MobileMailer.receive(@email)

        email.subject.should match(/題名/)
        email.body.should match(/本文/)
      end

      it "絵文字が数値参照に変わること" do
        email = MobileMailer.receive(@email)

        email.subject.should match(/&#xf03c;/)
        email.body.should match(/&#xf21c;/)
      end
    end
  end

  describe "multipart メールを受信するとき" do
    describe "docomo の場合" do
      # NOTE: キャリアメールサーバで絵文字を変換するため検証は困難
      before(:each) do
        @email = open(Rails.root + "spec/fixtures/mobile_mailer/docomo-gmail-sjis.eml").read
      end

      it "正常に受信できること" do
        lambda {
          MobileMailer.receive(@email)
        }.should_not raise_exception
      end

      it "絵文字が変換されること" do
        email = MobileMailer.receive(@email)

        email.subject.should match(/&#xe6ec;/)

        email.parts.size.should == 1
        email.parts.first.parts.size == 2

        parts = email.parts.first.parts
        parts.first.body.should match("テストです&#xe72d;")
        parts.last.body.raw_source.should  match("テストです&#xe72d;")
      end
    end

    describe "au の場合" do
      before(:each) do
        @email = open(Rails.root + "spec/fixtures/mobile_mailer/au-decomail.eml").read
      end

      it "正常に受信できること" do
        lambda {
          MobileMailer.receive(@email)
        }.should_not raise_exception
      end

      it "絵文字が変換されること" do
        email = MobileMailer.receive(@email)

        email.subject.should match(/&#xe4f4;/)

        email.parts.size.should == 1
        email.parts.first.parts.size == 2

        parts = email.parts.first.parts
        parts.first.body.should match(/テストです&#xe595;/)
        parts.last.body.raw_source.should match(/テストです&#xe595;/)
      end
    end

    describe "softbank(sjis) の場合" do
      # NOTE: キャリアメールサーバで絵文字を変換するため検証は困難
      before(:each) do
        @email = open(Rails.root + "spec/fixtures/mobile_mailer/softbank-gmail-sjis.eml").read
      end

      it "正常に受信できること" do
        lambda {
          MobileMailer.receive(@email)
        }.should_not raise_exception
      end

      it "絵文字が変換されること" do
        email = MobileMailer.receive(@email)

        email.subject.should match(/&#xf221;&#xf223;&#xf221;/)

        email.parts.size.should == 2

        email.parts.first.body.should match(/テストです&#xf018;/)
        email.parts.last.body.raw_source.should match(/テストです&#xf231;/)
      end
    end

    describe "softbank(utf8) の場合" do
      # NOTE: キャリアメールサーバで絵文字を変換するため検証は困難
      before(:each) do
        @email = open(Rails.root + "spec/fixtures/mobile_mailer/softbank-gmail-utf8.eml").read
      end

      it "正常に受信できること" do
        lambda {
          MobileMailer.receive(@email)
        }.should_not raise_exception
      end

      it "絵文字が変換されること" do
        email = MobileMailer.receive(@email)

        email.subject.should match(/テストです&#xf221;/)

        email.parts.size.should == 2

        email.parts.first.body.should match(/テストです&#xf223;/)
        email.parts.last.body.raw_source.should match(/テストです&#xf223;/)
      end
    end

    describe "添付ファイルがある場合" do
      # NOTE: au のみテスト
      before(:each) do
        @email = open(Rails.root + "spec/fixtures/mobile_mailer/au-attached.eml").read
      end

      it "正常に受信できること" do
        lambda {
          MobileMailer.receive(@email)
        }.should_not raise_exception
      end

      it "添付ファイルが壊れないこと" do
        email = MobileMailer.receive(@email)

        email.subject.should match(/&#xe481;/)

        email.parts.size.should == 2

        email.parts.first.body.should match(/カレンダーだ&#xe4f4;/)

        email.has_attachments?.should be_true
        email.attachments.size.should == 1
        email.attachments['20098calendar01.jpg'].content_type.should match("image/jpeg")
        email.attachments['20098calendar01.jpg'].body.to_s[2..6] == "JFIF"
        email.attachments['20098calendar01.jpg'].body.to_s.size == 86412
      end
    end
  end

  describe "PCからメールを受信するとき" do
    describe "日本語ではない場合" do
      before(:each) do
        @email = open(Rails.root + "spec/fixtures/mobile_mailer/non-jp.eml").read
      end

      it "正常に受信できること" do
        lambda {
          MobileMailer.receive(@email)
        }.should_not raise_exception
      end

      it "mobile が nil であること" do
        mail = MobileMailer.receive(@email)
        mail.mobile.should be_nil
      end
    end

    describe "From がない場合" do
      before(:each) do
        @email = open(Rails.root + "spec/fixtures/mobile_mailer/no-from.eml").read
      end

      it "正常に受信できること" do
        lambda {
          MobileMailer.receive(@email)
        }.should_not raise_exception
      end

      it "mobile が nil であること" do
        mail = MobileMailer.receive(@email)
        mail.mobile.should be_nil
      end
    end
  end
end
