require 'rails_helper'

describe MobileMailer, type: :mailer do
  include Jpmobile::Util

  before(:each) do
    ActionMailer::Base.deliveries = []

    @to      = ['outer@jp.mobile', 'outer1@jp.mobile']
    @subject = '日本語題名'
    @text    = '日本語テキスト'
    @sjis_regexp = /=\?shift_jis\?B\?(.+)\?=/
    @jis_regexp  = /=\?iso-2022-jp\?B\?(.+)\?=/
  end

  shared_examples_for 'PC宛メール' do
    it '正常に送信できること' do
      email = MobileMailer.view_selection(@to, '題名', '本文').deliver_now

      expect(ActionMailer::Base.deliveries.size).to eq(1)
      expect(email.to.include?(@to)).to be_truthy
    end

    it 'ISO-2022-JPに変換されること' do
      email = MobileMailer.view_selection(@to, '題名', '本文').deliver_now

      expect(ActionMailer::Base.deliveries.size).to eq(1)

      raw_mail = ascii_8bit(email.to_s)
      expect(raw_mail).to match(/iso-2022-jp/i)
      expect(raw_mail).to match(Regexp.compile(Regexp.escape(ascii_8bit([utf8_to_jis('題名')].pack('m').strip))))
      expect(raw_mail).to match(Regexp.compile(Regexp.escape(ascii_8bit(utf8_to_jis('本文')))))
    end

    it '絵文字がゲタ(〓)に変換されること' do
      email = MobileMailer.view_selection(@to, '題名&#xe676;', '本文&#xe68b;'.html_safe).deliver_now

      expect(ActionMailer::Base.deliveries.size).to eq(1)

      raw_mail = ascii_8bit(email.to_s)
      expect(raw_mail).to match(Regexp.escape('GyRCQmpMPiIuGyhC'))
      expect(raw_mail).to match(Regexp.compile(Regexp.escape(ascii_8bit(utf8_to_jis('本文〓')))))
    end

    it 'quoted-printableではないときに勝手に変換されないこと' do
      email = MobileMailer.view_selection(
        @to,
        '題名',
        "本文です\nhttp://test.rails/foo/bar/index?d=430d0d1cea109cdb384ec5554b890e3940f293c7&e=ZVG%0FE%16%5E%07%04%21P%5CZ%06%00%0D%1D%40L",
      ).deliver_now

      expect(ActionMailer::Base.deliveries.size).to eq(1)

      raw_mail = ascii_8bit(email.to_s)
      expect(raw_mail).to match(/ZVG%0FE%16%5E%07%04%21P%5CZ%06%00%0D%1D%40L/)
    end

    context ':toの指定が' do
      it 'ない場合でも正常に送信できること' do
        MobileMailer.default_to_mail('題名', '本文').deliver_now

        expect(ActionMailer::Base.deliveries.size).to eq(1)
      end
    end
  end

  describe 'PC宛に送るとき' do
    before(:each) do
      @to = 'bill.gate@microsoft.com'
    end

    it_behaves_like 'PC宛メール'

    it '複数に配信するときもISO-2022-JPに変換されること' do
      email = MobileMailer.view_selection(@to, '題名', '本文').deliver_now

      expect(ActionMailer::Base.deliveries.size).to eq(1)

      raw_mail = ascii_8bit(email.to_s)
      expect(raw_mail).to match(/iso-2022-jp/i)
      expect(raw_mail).to match(Regexp.compile(Regexp.escape(ascii_8bit([utf8_to_jis('題名')].pack('m').strip))))
      expect(raw_mail).to match(Regexp.compile(Regexp.escape(ascii_8bit(utf8_to_jis('本文')))))
      expect(raw_mail).to match(/For PC/)
    end
  end

  describe 'docomo にメールを送るとき' do
    before(:each) do
      @to = 'docomo@docomo.ne.jp'
    end

    it 'subject/body が Shift-JIS になること' do
      email = MobileMailer.view_selection(@to, @subject, @text).deliver_now

      expect(ActionMailer::Base.deliveries.size).to eq(1)

      raw_mail = email.to_s
      expect(raw_mail).to match(/shift_jis/i)
      # raw_mail.should match(/For docomo/)
      expect(raw_mail).to match(Regexp.escape('k/qWe4zqkeiWvA=='))
      expect(raw_mail).to match(Regexp.compile(utf8_to_sjis(@text)))
    end

    it '数値参照の絵文字が変換されること' do
      emoji_subject = @subject + '&#xe676;'
      emoji_text = @text + '&#xe68b;'

      email = MobileMailer.view_selection(@to, emoji_subject, emoji_text.html_safe).deliver_now

      expect(ActionMailer::Base.deliveries.size).to eq(1)

      raw_mail = email.to_s
      expect(raw_mail).to match(/For docomo/)
      expect(raw_mail).to match(Regexp.escape('k/qWe4zqkeiWvPjX'))
      expect(raw_mail).to match(regexp_to_sjis("\xf8\xec"))
    end

    it '半角カナがそのまま送信されること' do
      half_kana_subject = @subject + 'ｹﾞｰﾑ'
      half_kana_text    = @text + 'ﾌﾞｯｸ'

      email = MobileMailer.view_selection(@to, half_kana_subject, half_kana_text).deliver_now

      expect(ActionMailer::Base.deliveries.size).to eq(1)

      raw_mail = email.to_s
      expect(raw_mail).to match(/For docomo/)
      expect(raw_mail).to match(Regexp.escape('k/qWe4zqkeiWvLnesNE='))
      expect(raw_mail).to match(Regexp.compile(Regexp.escape(utf8_to_sjis(half_kana_text))))
    end

    it 'quoted-printable ではないときに勝手に変換されないこと' do
      email = MobileMailer.view_selection(
        @to,
        '題名',
        "本文です\nhttp://test.rails/foo/bar/index?d=430d0d1cea109cdb384ec5554b890e3940f293c7&e=ZVG%0FE%16%5E%07%04%21P%5CZ%06%00%0D%1D%40L",
      ).deliver_now

      expect(ActionMailer::Base.deliveries.size).to eq(1)

      raw_mail = email.to_s
      expect(raw_mail).to match(/ZVG%0FE%16%5E%07%04%21P%5CZ%06%00%0D%1D%40L/)
    end
  end

  describe 'au にメールを送るとき' do
    before(:each) do
      @to = 'au@ezweb.ne.jp'
    end

    it 'subject/body がISO-2022-JPになること' do
      email = MobileMailer.view_selection(@to, @subject, @text).deliver_now

      expect(ActionMailer::Base.deliveries.size).to eq(1)

      raw_mail = ascii_8bit(email.to_s)
      expect(raw_mail).to match(/iso-2022-jp/i)
      expect(raw_mail).to match(Regexp.compile(Regexp.escape(ascii_8bit([utf8_to_jis(@subject)].pack('m').strip))))
      expect(raw_mail).to match(Regexp.compile(Regexp.escape(ascii_8bit(utf8_to_jis(@text)))))
    end

    it '数値参照が絵文字に変換されること' do
      emoji_subject = @subject + '&#xe676;'
      emoji_text    = @text    + '&#xe68b;'

      email = MobileMailer.view_selection(@to, emoji_subject, emoji_text.html_safe).deliver_now

      expect(ActionMailer::Base.deliveries.size).to eq(1)

      raw_mail = ascii_8bit(email.to_s)
      expect(raw_mail).to match(/For au/)
      expect(raw_mail).to match(Regexp.escape('GyRCRnxLXDhsQmpMPnZeGyhC'))
      expect(raw_mail).to match(Regexp.compile(ascii_8bit("\x76\x21")))
    end

    it 'quoted-printable ではないときに勝手に変換されないこと' do
      email = MobileMailer.view_selection(
        @to,
        '題名',
        "本文です\nhttp://test.rails/foo/bar/index?d=430d0d1cea109cdb384ec5554b890e3940f293c7&e=ZVG%0FE%16%5E%07%04%21P%5CZ%06%00%0D%1D%40L",
      ).deliver_now

      expect(ActionMailer::Base.deliveries.size).to eq(1)

      raw_mail = ascii_8bit(email.to_s)
      expect(raw_mail).to match(/ZVG%0FE%16%5E%07%04%21P%5CZ%06%00%0D%1D%40L/)
    end
  end

  describe 'softbank にメールを送るとき' do
    before(:each) do
      @to = 'softbank@softbank.ne.jp'
    end

    it 'subject/body が Shift_JIS になること' do
      email = MobileMailer.view_selection(@to, @subject, @text).deliver_now

      expect(ActionMailer::Base.deliveries.size).to eq(1)

      raw_mail = email.to_s
      expect(raw_mail).to match(/shift_jis/i)
      expect(raw_mail).to match(/For softbank/)
      expect(raw_mail).to match(Regexp.escape('k/qWe4zqkeiWvA=='))
      expect(raw_mail).to match(Regexp.compile(utf8_to_sjis(@text)))
    end

    it '数値参照が絵文字に変換されること' do
      emoji_subject = @subject + '&#xe676;'
      emoji_text    = @text    + '&#xe68a;'

      email = MobileMailer.view_selection(@to, emoji_subject, emoji_text.html_safe).deliver_now

      expect(ActionMailer::Base.deliveries.size).to eq(1)

      raw_mail = email.to_s
      expect(raw_mail).to match(/For softbank/)
      expect(raw_mail).to match(Regexp.escape('k/qWe4zqkeiWvPl8'))
      expect(raw_mail).to match(regexp_to_sjis("\xf7\x6a"))
    end

    it 'quoted-printable ではないときに勝手に変換されないこと' do
      email = MobileMailer.view_selection(
        @to,
        '題名',
        "本文です\nhttp://test.rails/foo/bar/index?d=430d0d1cea109cdb384ec5554b890e3940f293c7&e=ZVG%0FE%16%5E%07%04%21P%5CZ%06%00%0D%1D%40L",
      ).deliver_now

      expect(ActionMailer::Base.deliveries.size).to eq(1)

      raw_mail = email.to_s
      expect(raw_mail).to match(/ZVG%0FE%16%5E%07%04%21P%5CZ%06%00%0D%1D%40L/)
    end
  end

  describe 'vodafone にメールを送るとき' do
    before(:each) do
      @to = 'vodafone@d.vodafone.ne.jp'
    end

    it 'subject/body が Shift_JIS になること' do
      email = MobileMailer.view_selection(@to, @subject, @text).deliver_now

      expect(ActionMailer::Base.deliveries.size).to eq(1)

      raw_mail = email.to_s
      expect(raw_mail).to match(/shift_jis/i)
      expect(raw_mail).to match(/For vodafone/)
      expect(raw_mail).to match(Regexp.escape('k/qWe4zqkeiWvA=='))
      expect(raw_mail).to match(Regexp.compile(utf8_to_sjis(@text)))
    end

    it '数値参照が絵文字に変換されること' do
      emoji_subject = @subject + '&#xe676;'
      emoji_text    = @text    + '&#xe68a;'

      email = MobileMailer.view_selection(@to, emoji_subject, emoji_text.html_safe).deliver_now

      expect(ActionMailer::Base.deliveries.size).to eq(1)

      raw_mail = email.to_s
      expect(raw_mail).to match(/For vodafone/)
      expect(raw_mail).to match(Regexp.escape('k/qWe4zqkeiWvPl8'))
      expect(raw_mail).to match(regexp_to_sjis("\xf7\x6a"))
    end

    it 'quoted-printable ではないときに勝手に変換されないこと' do
      email = MobileMailer.view_selection(
        @to,
        '題名',
        "本文です\nhttp://test.rails/foo/bar/index?d=430d0d1cea109cdb384ec5554b890e3940f293c7&e=ZVG%0FE%16%5E%07%04%21P%5CZ%06%00%0D%1D%40L",
      ).deliver_now

      expect(ActionMailer::Base.deliveries.size).to eq(1)

      raw_mail = email.to_s
      expect(raw_mail).to match(/ZVG%0FE%16%5E%07%04%21P%5CZ%06%00%0D%1D%40L/)
    end
  end

  describe 'willcom にメールを送るとき' do
    before(:each) do
      @to = 'willcom@wm.pdx.ne.jp'
    end

    it_behaves_like 'PC宛メール'
  end

  describe 'emobile にメールを送るとき' do
    before(:each) do
      @to = 'emobile@emnet.ne.jp'
    end

    it_behaves_like 'PC宛メール'
  end

  describe 'multipart メールを送信するとき' do
    before(:each) do
      ActionMailer::Base.deliveries = []

      @subject = '題名'
      @text    = '本文'
      @html    = '万葉'
    end

    describe 'PC の場合' do
      before(:each) do
        @to = 'gate@bill.com'
      end

      it '漢字コードが変換されること' do
        email = MobileMailer.multi_message(@to, @subject, @text, @html).deliver_now

        expect(ActionMailer::Base.deliveries.size).to eq(1)

        expect(email.parts.size).to eq(2)

        raw_mail = ascii_8bit(email.to_s)
        expect(raw_mail).to match(Regexp.escape(ascii_8bit(utf8_to_jis(@text))))
        expect(raw_mail).to match(Regexp.escape(ascii_8bit(utf8_to_jis(@html))))
      end
    end

    describe 'docomo の場合' do
      before(:each) do
        @to = 'docomo@docomo.ne.jp'
      end

      it '漢字コードが変換されること' do
        email = MobileMailer.multi_message(@to, @subject, @text, @html).deliver_now

        expect(ActionMailer::Base.deliveries.size).to eq(1)

        expect(email.parts.size).to eq(2)

        raw_mail = email.to_s
        expect(raw_mail).to match(sjis_regexp(utf8_to_sjis(@text)))
        expect(raw_mail).to match(sjis_regexp(utf8_to_sjis(@html)))
      end

      it '絵文字が変換されること' do
        @text  += '&#xe68b;'
        @html  += '&#xe676;'
        email = MobileMailer.multi_message(@to, @subject, @text, @html).deliver_now

        expect(ActionMailer::Base.deliveries.size).to eq(1)

        expect(email.parts.size).to eq(2)

        raw_mail = email.to_s
        expect(raw_mail).to match(sjis_regexp(sjis("\xf8\xec")))
        expect(raw_mail).to match(sjis_regexp(sjis("\xf8\xd7")))
      end
    end

    describe 'au の場合' do
      before(:each) do
        @to = 'au@ezweb.ne.jp'
      end

      it '漢字コードが変換されること' do
        email = MobileMailer.multi_message(@to, @subject, @text, @html).deliver_now

        expect(ActionMailer::Base.deliveries.size).to eq(1)

        expect(email.parts.size).to eq(2)

        raw_mail = ascii_8bit(email.to_s)
        expect(raw_mail).to match(Regexp.escape(ascii_8bit(utf8_to_jis(@text))))
        expect(raw_mail).to match(Regexp.escape(ascii_8bit(utf8_to_jis(@html))))
      end

      it '絵文字が変換されること' do
        @text += '&#xe68b;'
        @html += '&#xe676;'
        email = MobileMailer.multi_message(@to, @subject, @text, @html).deliver_now

        expect(ActionMailer::Base.deliveries.size).to eq(1)

        expect(email.parts.size).to eq(2)

        raw_mail = ascii_8bit(email.to_s)
        expect(raw_mail).to match(jis_regexp("\x76\x21"))
        expect(raw_mail).to match(jis_regexp("\x76\x5e"))
      end
    end

    describe 'softbank の場合' do
      before(:each) do
        @to = 'softbank@softbank.ne.jp'
      end

      it '漢字コードが変換されること' do
        email = MobileMailer.multi_message(@to, @subject, @text, @html).deliver_now

        expect(ActionMailer::Base.deliveries.size).to eq(1)

        expect(email.parts.size).to eq(2)

        raw_mail = email.to_s
        expect(raw_mail).to match(sjis_regexp(utf8_to_sjis(@text)))
        expect(raw_mail).to match(sjis_regexp(utf8_to_sjis(@html)))
      end

      it '絵文字が変換されること' do
        @text  += '&#xe68a;'
        @html  += '&#xe676;'
        email = MobileMailer.multi_message(@to, @subject, @text, @html).deliver_now

        expect(ActionMailer::Base.deliveries.size).to eq(1)

        expect(email.parts.size).to eq(2)

        raw_mail = email.to_s
        expect(raw_mail).to match(sjis_regexp(sjis("\xf7\x6a")))
        expect(raw_mail).to match(sjis_regexp(sjis("\xf9\x7c")))
      end
    end

    describe 'vodafone の場合' do
      before(:each) do
        @to = 'vodafone@d.vodafone.ne.jp'
      end

      it '漢字コードが変換されること' do
        email = MobileMailer.multi_message(@to, @subject, @text, @html).deliver_now

        expect(ActionMailer::Base.deliveries.size).to eq(1)

        expect(email.parts.size).to eq(2)

        raw_mail = email.to_s
        expect(raw_mail).to match(sjis_regexp(utf8_to_sjis(@text)))
        expect(raw_mail).to match(sjis_regexp(utf8_to_sjis(@html)))
      end

      it '絵文字が変換されること' do
        @text  += '&#xe68a;'
        @html  += '&#xe676;'
        email = MobileMailer.multi_message(@to, @subject, @text, @html).deliver_now

        expect(ActionMailer::Base.deliveries.size).to eq(1)

        expect(email.parts.size).to eq(2)

        raw_mail = email.to_s
        expect(raw_mail).to match(sjis_regexp(sjis("\xf7\x6a")))
        expect(raw_mail).to match(sjis_regexp(sjis("\xf9\x7c")))
      end
    end
  end
end

describe MobileMailer, ' mail address', type: :mailer do
  before(:each) do
    ActionMailer::Base.deliveries = []

    @subject = '日本語題名'
    @text    = '日本語テキスト'
  end

  it 'ピリオドが3つ以上連続するアドレスが有効になること' do
    to = 'ruby...rails@domomo-ezweb.ne.jp'
    MobileMailer.view_selection(to, @subject, @text).deliver_now

    emails = ActionMailer::Base.deliveries
    expect(emails.size).to eq(1)
    expect(emails.first.to.include?(to)).to be_truthy
    expect(emails.first.destinations.include?(to)).to be_truthy
  end

  it '@マークの直前にピリオドあるアドレスが有効になること' do
    to = 'ruby.rails.@domomo-ezweb.ne.jp'
    MobileMailer.view_selection(to, @subject, @text).deliver_now

    emails = ActionMailer::Base.deliveries
    expect(emails.size).to eq(1)
    expect(emails.first.to.include?(to)).to be_truthy
    expect(emails.first.destinations.include?(to)).to be_truthy
  end

  it 'ピリオドから始まるアドレスが有効になること' do
    to = '.ruby.rails.@domomo-ezweb.ne.jp'
    MobileMailer.view_selection(to, @subject, @text).deliver_now

    emails = ActionMailer::Base.deliveries
    expect(emails.size).to eq(1)
    expect(emails.first.to.include?(to)).to be_truthy
    expect(emails.first.destinations.include?(to)).to be_truthy
  end

  it '複数のアドレスが有効になること' do
    to = ['.ruby.rails.@domomo-ezweb.ne.jp', 'ruby.rails.@domomo-ezweb.ne.jp', 'ruby...rails@domomo-ezweb.ne.jp']
    MobileMailer.view_selection(to.join(', '), @subject, @text).deliver_now

    emails = ActionMailer::Base.deliveries
    expect(emails.size).to eq(1)
    expect(emails.first.to).to eq(to)
    expect(emails.first.destinations).to eq(to)
  end
end
