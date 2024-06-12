# =EMOBILE携帯電話

module Jpmobile::Mobile
  # ==EMOBILE携帯電話
  class Emobile < AbstractMobile
    USER_AGENT_REGEXP = %r{^emobile/|^Mozilla/5.0 \(H11T; like Gecko; OpenBrowser\) NetFront/3.4$|^Mozilla/4.0 \(compatible; MSIE 6.0; Windows CE; IEMobile 7.7\) S11HT$}
    # 対応するメールアドレスの正規表現
    MAIL_ADDRESS_REGEXP = /.+@emnet\.ne\.jp/
    # EMnet対応端末から通知されるユニークなユーザIDを取得する。
    def em_uid
      @request.env['HTTP_X_EM_UID']
    end
    alias_method :ident_subscriber, :em_uid
  end
end
