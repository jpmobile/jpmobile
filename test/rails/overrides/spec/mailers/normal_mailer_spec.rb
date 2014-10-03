require 'rails_helper'

describe NormalMailer, :type => :mailer do
  include Jpmobile::Util

  before(:each) do
    ActionMailer::Base.deliveries = []

    @to      = ["outer@jp.mobile", "outer1@jp.mobile"]
    @subject = "日本語題名"
    @text    = "日本語テキスト"
  end

  context "PC宛メール" do
    it "正常に送信できること" do
      email = NormalMailer.msg(@to, "題名", "本文").deliver_now

      expect(ActionMailer::Base.deliveries.size).to eq(1)
      expect(email.to - @to).to be_empty
    end

    it "UTF-8のままであること" do
      email = NormalMailer.msg(@to, @subject, @text).deliver_now

      expect(ActionMailer::Base.deliveries.size).to eq(1)

      raw_mail = ascii_8bit(email.to_s)
      expect(raw_mail).to match(/UTF-8/i)
      expect(raw_mail).to match(Regexp.escape("=E6=97=A5=E6=9C=AC=E8=AA=9E=E9=A1=8C=E5=90=8D"))
      expect(raw_mail).to match(Regexp.escape([@text].pack("m").strip))
    end
  end
end
