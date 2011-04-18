# -*- coding: utf-8 -*-
require 'ipaddr'

module Jpmobile::Mobile
  # 携帯電話の抽象クラス。
  class AbstractMobile
    # メールのデフォルトのcharset
    MAIL_CHARSET = "ISO-2022-JP"

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
      @ip_list ||= ip_address_class
      return false unless @ip_list

      @ip_list.valid_ip?(remote_addr)
    end

    def valid_ip?
      @__valid_ip ||= self.class.valid_ip? @request.ip
    end

    # 画面情報を +Display+ クラスのインスタンスで返す。
    def display
      @__displlay ||= Jpmobile::Mobile::Terminfo.new(self, @env)
    rescue LoadError
      puts "display method require jpmobile-terminfo plugin."
    end

    # クッキーをサポートしているか。
    def supports_cookie?
      return false
    end

    # smartphone かどうか
    def smart_phone?
      false
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

    # for view selector
    def variants
      return @_variants if @_variants

      @_variants = self.class.ancestors.select {|c| c.to_s =~ /^Jpmobile/}.map do |klass|
        klass = klass.to_s.
          gsub(/Jpmobile::/, '').
          gsub(/AbstractMobile::/, '').
          gsub(/Mobile::SmartPhone/, 'smart_phone').
          gsub(/::/, '_').
          gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
          gsub(/([a-z\d])([A-Z])/, '\1_\2').
          downcase
        klass =~ /abstract/ ? "mobile" : klass
      end

      if @_variants.include?("smart_phone")
        @_variants = @_variants.reject{|v| v == "mobile"}.map{|v| v.gsub(/mobile/, "smart_phone")}
      end

      @_variants
    end

    # メール送信用
    def to_mail_subject(str)
      Jpmobile::Util.fold_text(Jpmobile::Emoticon.unicodecr_to_utf8(str)).
        map{|text| "=?#{mail_charset}?B?" + [to_mail_encoding(text)].pack('m').strip + "?=" }.
        join("\n\s")
    end
    def to_mail_body(str)
      to_mail_encoding(str)
    end
    def mail_charset(charset = nil)
      (charset.nil? or charset == "") ? self.class::MAIL_CHARSET : charset
    end
    def to_mail_encoding(str)
      str = Jpmobile::Emoticon.utf8_to_unicodecr(str)
      str = Jpmobile::Emoticon.unicodecr_to_external(str, Jpmobile::Emoticon::CONVERSION_TABLE_TO_PC_EMAIL, false)
      Jpmobile::Util.encode(str, mail_charset)
    end
    def utf8_to_mail_encode(str)
      case mail_charset
      when /ISO-2022-JP/i
        Jpmobile::Util.utf8_to_jis(str)
      when /Shift_JIS/i
        Jpmobile::Util.utf8_to_sjis(str)
      else
        str
      end
    end
    def to_mail_internal(str, charset)
      str
    end
    def to_mail_subject_encoded?(str)
      str.match(/\=\?#{mail_charset}\?B.+\?\=/i)
    end
    def to_mail_body_encoded?(str)
      Jpmobile::Util.jis?(str)
    end
    def decode_transfer_encoding(body, charset)
      body = Jpmobile::Util.set_encoding(body, charset)
      body = to_mail_internal(body, nil)
      Jpmobile::Util.force_encode(body, charset, Jpmobile::Util::UTF8)
    end

    # リクエストがこのクラスに属するか調べる
    # メソッド名に関して非常に不安
    def self.check_carrier(env)
      self::USER_AGENT_REGEXP && env['HTTP_USER_AGENT'] =~ self::USER_AGENT_REGEXP
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

    #
    def self.ip_address_class
      eval("::Jpmobile::Mobile::IpAddresses::#{self.to_s.split(/::/).last}").new rescue nil
    end
  end
end
