require 'ipaddr'

module Jpmobile::Mobile
  # 携帯電話の抽象クラス。
  class AbstractMobile
    def initialize(request)
      @request = request
    end

    # 対応するuser-agentの正規表現
    USER_AGENT_REGEXP = nil

    # 緯度経度があれば Position のインスタンスを返す。
    def position; return nil; end

    # 契約者又は端末を識別する文字列があれば返す。
    def ident; ident_subscriber || ident_device; end
    # 契約者を識別する文字列があれば返す。
    def ident_subscriber; nil; end
    # 端末を識別する文字列があれば返す。
    def ident_device; nil; end

    # IPアドレスデータ
    IP_ADDRESSES = nil
    
    # 当該キャリアのIPアドレス帯域からのアクセスであれば +true+ を返す。
    # そうでなければ +false+ を返す。
    # IP空間が定義されていない場合は +nil+ を返す。
    def valid_ip?
      addrs = self.class::IP_ADDRESSES
      return nil if addrs.nil?
      remote = IPAddr.new(@request.remote_ip)
      addrs.each do |s|
        return true if IPAddr.new(s.chomp).include?(remote)
      end
      return false
    end
    
    # 画面情報を +Display+ クラスのインスタンスで返す。
    def display
      Jpmobile::Display.new
    end

    # クッキーをサポートしているか。
    def supports_cookie?
      return false
    end

    private
    # リクエストのパラメータ。
    def params
      @request.parameters
    end
  end
end
