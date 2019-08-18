require 'rails_helper'
require 'action_mailbox/test_helper'

describe MobileMailerMailbox, type: :mailbox do
  include ActionMailbox::TestHelper

  describe 'blank mail' do
    it 'softbank からの空メールがで受信できること' do
      expect {
        inbound_email = receive_inbound_email_from_fixture('mobile_mailer/softbank-blank.eml')

        expect(inbound_email.mail.subject).to be_blank
        expect(inbound_email.mail.body).to be_blank
      }.to_not raise_error
    end
  end

  describe 'docomo からのメールを受信するとき' do
    it '漢字コードを適切に変換できること' do
      inbound_email = receive_inbound_email_from_fixture('mobile_mailer/docomo-emoji.eml')

      expect(inbound_email.mail.subject).to match(/題名/)
      expect(inbound_email.mail.body).to match(/本文/)
    end

    it '絵文字が数値参照に変わること' do
      inbound_email = receive_inbound_email_from_fixture('mobile_mailer/docomo-emoji.eml')

      expect(inbound_email.mail.subject).to match(/&#xe676;/)
      expect(inbound_email.mail.body).to match(/&#xe6e2;/)
    end

    describe 'jis コードの場合に' do
      it '適切に変換できること' do
        inbound_email = receive_inbound_email_from_fixture('mobile_mailer/docomo-jis.eml')

        expect(inbound_email.mail.subject).to match(/テスト/)
        expect(inbound_email.mail.body).to match(/テスト本文/)
      end
    end
  end

  describe 'au からのメールを受信するとき' do
    describe 'jpmobile で送信したメールの場合' do
      it '漢字コードを適切に変換できること' do
        inbound_email = receive_inbound_email_from_fixture('mobile_mailer/au-emoji.eml')

        expect(inbound_email.mail.subject).to match(/題名/)
        expect(inbound_email.mail.body).to match(/本文/)
      end

      it '絵文字が数値参照に変わること' do
        inbound_email = receive_inbound_email_from_fixture('mobile_mailer/au-emoji.eml')

        expect(inbound_email.mail.subject).to match(/&#xe503;/)
        expect(inbound_email.mail.body).to match(/&#xe522;/)
      end
    end

    describe '実機からのメールの場合' do
      it '漢字コードを適切に変換できること' do
        inbound_email = receive_inbound_email_from_fixture('mobile_mailer/au-emoji2.eml')

        expect(inbound_email.mail.subject).to match(/題名/)
        expect(inbound_email.mail.body).to match(/本文/)
      end

      it '絵文字が数値参照に変わること' do
        inbound_email = receive_inbound_email_from_fixture('mobile_mailer/au-emoji2.eml')

        expect(inbound_email.mail.subject).to match(/&#xe4f4;/)
        expect(inbound_email.mail.body).to match(/&#xe471;/)
      end
    end
  end

  describe 'softbank からのメールを受信するとき' do
    describe 'shift_jis のとき' do
      it '漢字コードを適切に変換できること' do
        inbound_email = receive_inbound_email_from_fixture('mobile_mailer/softbank-emoji.eml')

        expect(inbound_email.mail.subject).to match(/題名/)
        expect(inbound_email.mail.body).to match(/本文/)
      end

      it '絵文字が数値参照に変わること' do
        inbound_email = receive_inbound_email_from_fixture('mobile_mailer/softbank-emoji.eml')

        expect(inbound_email.mail.subject).to match(/&#xf03c;/)
        expect(inbound_email.mail.body).to match(/&#xf21c;/)
      end
    end

    describe 'utf-8 のとき' do
      it '漢字コードを適切に変換できること' do
        inbound_email = receive_inbound_email_from_fixture('mobile_mailer/softbank-emoji.eml')

        expect(inbound_email.mail.subject).to match(/題名/)
        expect(inbound_email.mail.body).to match(/本文/)
      end

      it '絵文字が数値参照に変わること' do
        inbound_email = receive_inbound_email_from_fixture('mobile_mailer/softbank-emoji-utf8.eml')

        expect(inbound_email.mail.subject).to match(/&#xf03c;/)
        expect(inbound_email.mail.body).to match(/&#xf21c;/)
      end
    end
  end

  describe 'multipart メールを受信するとき' do
    describe 'docomo の場合' do
      # NOTE: キャリアメールサーバで絵文字を変換するため検証は困難
      it '正常に受信できること' do
        expect {
          receive_inbound_email_from_fixture('mobile_mailer/docomo-gmail-sjis.eml')
        }.not_to raise_exception
      end

      it '絵文字が変換されること' do
        inbound_email = receive_inbound_email_from_fixture('mobile_mailer/docomo-gmail-sjis.eml')

        expect(inbound_email.mail.subject).to match(/&#xe6ec;/)

        expect(inbound_email.mail.parts.size).to eq(1)
        expect(inbound_email.mail.parts.first.parts.size).to eq(2)

        parts = inbound_email.mail.parts.first.parts
        expect(parts.first.body).to match('テストです&#xe72d;')
        expect(parts.last.body.raw_source).to match('テストです&#xe72d;')
      end
    end

    describe 'au の場合' do
      it '正常に受信できること' do
        expect {
          receive_inbound_email_from_fixture('mobile_mailer/au-decomail.eml')
        }.not_to raise_exception
      end

      it '絵文字が変換されること' do
        inbound_email = receive_inbound_email_from_fixture('mobile_mailer/au-decomail.eml')

        expect(inbound_email.mail.subject).to match(/&#xe4f4;/)

        expect(inbound_email.mail.parts.size).to eq(1)
        expect(inbound_email.mail.parts.first.parts.size).to eq(2)

        parts = inbound_email.mail.parts.first.parts
        expect(parts.first.body).to match(/テストです&#xe595;/)
        expect(parts.last.body.raw_source).to match(/テストです&#xe595;/)
      end

      context 'iPhone' do
        it 'should parse correctly' do
          expect {
            inbound_email = receive_inbound_email_from_fixture('mobile_mailer/iphone-message.eml')
            inbound_email.mail.encoded
          }.not_to raise_error
        end
      end
    end

    describe 'softbank(sjis) の場合' do
      # NOTE: キャリアメールサーバで絵文字を変換するため検証は困難
      it '正常に受信できること' do
        expect {
          receive_inbound_email_from_fixture('mobile_mailer/softbank-gmail-sjis.eml')
        }.not_to raise_exception
      end

      it '絵文字が変換されること' do
        inbound_email = receive_inbound_email_from_fixture('mobile_mailer/softbank-gmail-sjis.eml')

        expect(inbound_email.mail.subject).to match(/&#xf221;&#xf223;&#xf221;/)

        expect(inbound_email.mail.parts.size).to eq(2)

        expect(inbound_email.mail.parts.first.body).to match(/テストです&#xf018;/)
        expect(inbound_email.mail.parts.last.body.raw_source).to match(/テストです&#xf231;/)
      end
    end

    describe 'softbank(utf8) の場合' do
      # NOTE: キャリアメールサーバで絵文字を変換するため検証は困難
      it '正常に受信できること' do
        expect {
          receive_inbound_email_from_fixture('mobile_mailer/softbank-gmail-utf8.eml')
        }.not_to raise_exception
      end

      it '絵文字が変換されること' do
        inbound_email = receive_inbound_email_from_fixture('mobile_mailer/softbank-gmail-utf8.eml')

        expect(inbound_email.mail.subject).to match(/テストです&#xf221;/)

        expect(inbound_email.mail.parts.size).to eq(2)

        expect(inbound_email.mail.parts.first.body).to match(/テストです&#xf223;/)
        expect(inbound_email.mail.parts.last.body.raw_source).to match(/テストです&#xf223;/)
      end
    end

    describe '添付ファイルがある場合' do
      # NOTE: au のみテスト
      it '正常に受信できること' do
        expect {
          receive_inbound_email_from_fixture('mobile_mailer/au-attached.eml')
        }.not_to raise_exception
      end

      it '添付ファイルが壊れないこと' do
        inbound_email = receive_inbound_email_from_fixture('mobile_mailer/au-attached.eml')

        expect(inbound_email.mail.subject).to match(/&#xe481;/)

        expect(inbound_email.mail.parts.size).to eq(2)

        expect(inbound_email.mail.parts.first.body).to match(/カレンダーだ&#xe4f4;/)

        expect(inbound_email.mail.has_attachments?).to be_truthy
        expect(inbound_email.mail.attachments.size).to eq(1)
        expect(inbound_email.mail.attachments['20098calendar01.jpg'].content_type).to match('image/jpeg')
        expect(inbound_email.mail.attachments['20098calendar01.jpg'].body.to_s.size).to eq(86412)
        expect(inbound_email.mail.attachments['20098calendar01.jpg'].body.to_s[6..9]).to eq('JFIF')
      end
    end
  end

  describe 'PCからメールを受信するとき' do
    describe '日本語ではない場合' do
      before(:each) do
        @email = file_fixture('mobile_mailer/non-jp.eml').read
      end

      it '正常に受信できること' do
        expect {
          receive_inbound_email_from_fixture('mobile_mailer/non-jp.eml')
        }.not_to raise_exception
      end

      it 'mobile が nil であること' do
        inbound_email = receive_inbound_email_from_fixture('mobile_mailer/non-jp.eml')
        expect(inbound_email.mail.mobile).to be_nil
      end
    end

    describe 'From がない場合' do
      before(:each) do
        @email = file_fixture('mobile_mailer/no-from.eml').read
      end

      it '正常に受信できること' do
        expect {
          receive_inbound_email_from_fixture('mobile_mailer/no-from.eml')
        }.not_to raise_exception
      end

      it 'mobile が nil であること' do
        inbound_email = receive_inbound_email_from_fixture('mobile_mailer/no-from.eml')
        expect(inbound_email.mail.mobile).to be_nil
      end
    end
  end
end
