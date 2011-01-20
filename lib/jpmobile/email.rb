# -*- coding: utf-8 -*-
# =メールアドレスモジュール
#
module Jpmobile
  # email関連の処理
  module Email
    module_function

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
    def detect_from_mail_header(str)
      Mobile.carriers.each do |const|
        c = Mobile.const_get(const)
        return c if c::MAIL_ADDRESS_REGEXP && str.match(/#{c::MAIL_ADDRESS_REGEXP}#{c::NOT_DOMAIN_REGEXP}/)
      end
      nil
    end
  end
end
