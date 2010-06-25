# -*- coding: utf-8 -*-
require 'ipaddr'

module Jpmobile::Mobile
  # 携帯電話の抽象クラス。
  class AbstractMobile
    def initialize(env, request)
      @env     = env
      @request = request
    end

    # 対応するuser-agentの正規表現
    USER_AGENT_REGEXP = nil
    # 対応するメールアドレスの正規表現
    MAIL_ADDRESS_REGEXP = nil

    # 緯度経度があれば Position のインスタンスを返す。
    def position; return nil; end

    # 契約者又は端末を識別する文字列があれば返す。
    def ident; ident_subscriber || ident_device; end
    # 契約者を識別する文字列があれば返す。
    def ident_subscriber; nil; end
    # 端末を識別する文字列があれば返す。
    def ident_device; nil; end

    # 当該キャリアのIPアドレス帯域からのアクセスであれば +true+ を返す。
    # そうでなければ +false+ を返す。
    # IP空間が定義されていない場合は +nil+ を返す。
    def self.valid_ip? remote_addr
      addrs = nil
      begin
        addrs = self::IP_ADDRESSES
      rescue NameError => e
        return nil
      end
      remote = IPAddr.new(remote_addr)
      addrs.any? {|ip| ip.include? remote }
    end

    def valid_ip?
      @__valid_ip ||= self.class.valid_ip? @request.ip
    end

    # 画面情報を +Display+ クラスのインスタンスで返す。
    def display
      @__displlay ||= Jpmobile::Display.new
    end

    # クッキーをサポートしているか。
    def supports_cookie?
      return false
    end

    # エンコーディング変換用
    def to_internal(str)
      str
    end
    def to_external(str, content_type, charset)
      [str, charset]
    end
    def default_charset
      "UTF-8"
    end

    #XXX: lib/jpmobile.rbのautoloadで先に各キャリアの定数を定義しているから動くのです
    Jpmobile::Mobile.carriers.each do |carrier|
      carrier_class = Jpmobile::Mobile.const_get(carrier)
      next if carrier_class == self

      define_method "#{carrier.downcase}?" do
        self.is_a?(carrier_class)
      end
    end

    private
    # リクエストのパラメータ。
    def params
      if @request.respond_to? :parameters
        @request.parameters
      else
        @request.params
      end
    end
  end
end
