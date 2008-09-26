# =メールアドレスモジュール
#
module Jpmobile
  # email関連の処理
  module Email

    # メールアドレスよりキャリア情報を取得する
    # _param1_:: email メールアドレス
    # return  :: Jpmobile::Mobileで定義されている携帯キャリアクラス
    def self.detect(email)
      Jpmobile::Mobile.carriers.each do |const|
        c = Jpmobile::Mobile.const_get(const)
        return c if c::MAIL_ADDRESS_REGEXP && email =~ c::MAIL_ADDRESS_REGEXP
      end
      nil
    end

  end
end
