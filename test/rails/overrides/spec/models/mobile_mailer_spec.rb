# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

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

    it "絵文字がゲタ(〓)に変換されること", :broken => true do
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
      # raw_mail.should match(/For docomo/) # TODO: revise Resolver in view selector
      raw_mail.should match(Regexp.escape("k/qWe4zqkeiWvA=="))
      raw_mail.should match(Regexp.compile(utf8_to_sjis(@text)))
    end

    it "数値参照の絵文字が変換されること" do
      emoji_subject = @subject + "&#xe676;"
      emoji_text = @text + "&#xe68b;"

      email = MobileMailer.view_selection(@to, emoji_subject, emoji_text.html_safe).deliver

      ActionMailer::Base.deliveries.size.should == 1

      raw_mail = email.to_s
      # raw_mail.should match(/For docomo/) # TODO: revise Resolver in view selector
      raw_mail.should match(Regexp.escape("k/qWe4zqkeiWvPjX"))
      raw_mail.should match(regexp_to_sjis("\xf8\xec"))
    end

    it "半角カナがそのまま送信されること" do
      half_kana_subject = @subject + "ｹﾞｰﾑ"
      half_kana_text    = @text + "ﾌﾞｯｸ"

      email = MobileMailer.view_selection(@to, half_kana_subject, half_kana_text).deliver

      ActionMailer::Base.deliveries.size.should == 1

      raw_mail = email.to_s
      # raw_mail.should match(/For docomo/) # TODO: revise Resolver in view selector
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
      # raw_mail.should match(/For au/) # TODO: revise Resolver in view selector
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
      # raw_mail.should match(/For softbank/) # TODO: revise Resolver in view selector
      raw_mail.should match(Regexp.escape("k/qWe4zqkeiWvA=="))
      raw_mail.should match(Regexp.compile(utf8_to_sjis(@text)))
    end

    it "数値参照が絵文字に変換されること" do
      emoji_subject = @subject + "&#xe676;"
      emoji_text    = @text    + "&#xe68a;"

      email = MobileMailer.view_selection(@to, emoji_subject, emoji_text.html_safe).deliver

      ActionMailer::Base.deliveries.size.should == 1

      raw_mail = email.to_s
      # raw_mail.should match(/For softbank/) # TODO: revise Resolver in view selector
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
      # raw_mail.should match(/For softbank/) # TODO: revise Resolver in view selector
      raw_mail.should match(Regexp.escape("k/qWe4zqkeiWvA=="))
      raw_mail.should match(Regexp.compile(utf8_to_sjis(@text)))
    end

    it "数値参照が絵文字に変換されること" do
      emoji_subject = @subject + "&#xe676;"
      emoji_text    = @text    + "&#xe68a;"

      email = MobileMailer.view_selection(@to, emoji_subject, emoji_text.html_safe).deliver

      ActionMailer::Base.deliveries.size.should == 1

      raw_mail = email.to_s
      # raw_mail.should match(/For softbank/) # TODO: revise Resolver in view selector
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
