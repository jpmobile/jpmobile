# -*- coding: utf-8 -*-
# =メールアドレスモジュール
#
module Jpmobile
  # email関連の処理
  class Email
    class << self
      @@japanese_mail_address_regexp = nil
      @@converting_content_type = ['text/plain', 'text/html']

      # メールアドレスよりキャリア情報を取得する
      # _param1_:: email メールアドレス
      # return  :: Jpmobile::Mobileで定義されている携帯キャリアクラス
      def detect(email)
        Mobile.carriers.each do |const|
          c = Mobile.const_get(const)
          return c if c::MAIL_ADDRESS_REGEXP && email.match(/^#{c::MAIL_ADDRESS_REGEXP}$/)
        end
        nil
      end

      # 含まれているメールアドレスからキャリア情報を取得する
      def detect_from_mail_header(header)
        Mobile.carriers.each do |const|
          c = Mobile.const_get(const)
          if c::MAIL_ADDRESS_REGEXP &&
              header.match(/(\S+@[A-Za-z0-9\-\.\_]+)/) &&
              $1.match(/^#{c::MAIL_ADDRESS_REGEXP}$/)
            return c
          end
        end

        if japanese_mail?(header)
          return Jpmobile::Mobile::AbstractMobile
        end

        nil
      end

      def japanese_mail_address_regexp=(regexp)
        @@japanese_mail_address_regexp = regexp
      end

      def japanese_mail?(header)
        @@japanese_mail_address_regexp and header.match(@@japanese_mail_address_regexp)
      end

      def convertable?(content_type)
        if @@converting_content_type.respond_to?(:each)
          @@converting_content_type.each do |c|
            return true if content_type.match(c)
          end
        end

        nil
      end
    end
  end
end
