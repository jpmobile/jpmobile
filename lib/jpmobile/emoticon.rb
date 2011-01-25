# -*- coding: utf-8 -*-

require 'scanf'
require 'nkf'

module Jpmobile
  # 絵文字関連処理
  module Emoticon
    %w( DOCOMO_SJIS_TO_UNICODE DOCOMO_UNICODE_TO_SJIS ).each do |const|
      autoload const, 'jpmobile/emoticon/docomo'
    end
    %w( AU_SJIS_TO_UNICODE AU_UNICODE_TO_EMAILJIS AU_SJIS_TO_EMAIL_JIS AU_EMAILJIS_TO_UNICODE ).each do |const|
      autoload const, 'jpmobile/emoticon/au'
    end
    %w(
      SOFTBANK_UNICODE_TO_WEBCODE SOFTBANK_WEBCODE_TO_UNICODE
      SOFTBANK_UNICODE_TO_SJIS SOFTBANK_SJIS_TO_UNICODE
    ).each do |const|
      autoload const, 'jpmobile/emoticon/softbank'
    end
    %w( CONVERSION_TABLE_TO_DOCOMO CONVERSION_TABLE_TO_AU CONVERSION_TABLE_TO_SOFTBANK ).each do |const|
      autoload const, 'jpmobile/emoticon/conversion_table'
    end
    %w(
      SJIS_TO_UNICODE UNICODE_TO_SJIS
      SJIS_REGEXP SOFTBANK_WEBCODE_REGEXP DOCOMO_SJIS_REGEXP AU_SJIS_REGEXP SOFTBANK_UNICODE_REGEXP
      EMOTICON_UNICODES UTF8_REGEXP
      CONVERSION_TABLE_TO_PC_EMAIL SOFTBANK_SJIS_REGEXP AU_EMAILJIS_REGEXP
    ).each do |const|
      autoload const, 'jpmobile/emoticon/z_combine'
    end

    # +str+ のなかでDoCoMo絵文字をUnicode数値文字参照に置換した文字列を返す。
    def self.external_to_unicodecr_docomo(str)
      str.gsub(DOCOMO_SJIS_REGEXP) do |match|
        sjis = match.unpack('n').first
        unicode = DOCOMO_SJIS_TO_UNICODE[sjis]
        unicode ? ("&#x%04x;"%unicode) : match
      end
    end

    # +str+ のなかでau絵文字をUnicode数値文字参照に置換した文字列を返す。
    def self.external_to_unicodecr_au(str)
      str.gsub(AU_SJIS_REGEXP) do |match|
        sjis = match.unpack('n').first
        unicode = AU_SJIS_TO_UNICODE[sjis]
        unicode ? ("&#x%04x;"%unicode) : match
      end
    end

    # +str+ のなかでau絵文字をUnicode数値文字参照に置換した文字列を返す。(メール専用)
    def self.external_to_unicodecr_au_mail(in_str)
      str = Jpmobile::Util.ascii_8bit(in_str)
      str.gsub(Jpmobile::Util.jis_string_regexp) do |jis_string|
        jis_string.gsub(/[\x21-\x7e]{2}/) do |match|
          jis = match.unpack('n').first
          unicode = AU_EMAILJIS_TO_UNICODE[jis]
          unicode ? Jpmobile::Util.ascii_8bit("\x1b\x28\x42&#x%04x;\x1b\x24\x42"%unicode) : match
        end
      end
    end

    # +str+のなかでUTF8のSoftBank絵文字を(+0x1000だけシフトして)Unicode数値文字参照に変換した文字列を返す。
    def self.external_to_unicodecr_softbank(str)
      # SoftBank Unicode
      str.gsub(SOFTBANK_UNICODE_REGEXP) do |match|
        unicode = match.unpack('U').first
        "&#x%04x;" % (unicode+0x1000)
      end
    end
    def self.external_to_unicodecr_softbank_sjis(str)
      # SoftBank Shift_JIS
      str.gsub(SOFTBANK_SJIS_REGEXP) do |match|
        sjis = match.unpack('n').first
        unicode = SOFTBANK_SJIS_TO_UNICODE[sjis]
        "&#x%04x;" % (unicode+0x1000)
      end
    end
    def self.external_to_unicodecr_vodafone(str)
      external_to_unicodecr_softbank(str)
    end

    # +str+ のなかでUnicode数値文字参照で表記された絵文字を携帯側エンコーディングに置換する。
    #
    # キャリア間の変換に +conversion_table+ を使う。+conversion_table+ に+nil+を与えると、
    # キャリア間の変換は行わない。
    #
    # 携帯側エンコーディングがShift_JIS場合は +to_sjis+ に +true+ を指定する。
    # +true+ を指定すると変換テーブルに文字列が指定されている場合にShift_JISで出力される。
    def self.unicodecr_to_external(str, conversion_table=nil, to_sjis=true)
      str.gsub(/&#x([0-9a-f]{4});/i) do |match|
        unicode = $1.scanf("%x").first
        if conversion_table
          converted = conversion_table[unicode] # キャリア間変換
        else
          converted = unicode # 変換しない
        end

        # 携帯側エンコーディングに変換する
        case converted
        when Integer
          # 変換先がUnicodeで指定されている。つまり対応する絵文字がある。
          if sjis = UNICODE_TO_SJIS[converted]
            if to_sjis
              sjis_emotion = Jpmobile::Util.sjis([sjis].pack('n'))
            else
              [converted].pack("U")
            end
          elsif webcode = SOFTBANK_UNICODE_TO_WEBCODE[converted-0x1000]
            [converted-0x1000].pack('U')
          elsif converted == GETA
            # PCで〓を表示する場合
            [GETA].pack("U")
          else
            # キャリア変換テーブルに指定されていたUnicodeに対応する
            # 携帯側エンコーディングが見つからない(変換テーブルの不備の可能性あり)。
            match
          end
        when String
          # 変換先が数値参照だと、再変換する
          if converted.match(/&#x([0-9a-f]{4});/i)
            self.unicodecr_to_external(converted, conversion_table, to_sjis)
          else
            # 変換先が文字列で指定されている。
            to_sjis ? Jpmobile::Util.utf8_to_sjis(converted) : converted
          end
        when nil
          # 変換先が定義されていない。
          match
        end
      end
    end
    # +str+ のなかでUnicode数値文字参照で表記された絵文字をUTF-8に置換する。
    def self.unicodecr_to_utf8(str)
      str.gsub(/&#x([0-9a-f]{4});/i) do |match|
        unicode = $1.scanf("%x").first
        if UNICODE_TO_SJIS[unicode] || SOFTBANK_UNICODE_TO_WEBCODE[unicode-0x1000]
          [unicode].pack('U')
        else
          match
        end
      end
    end
    # +str+ のなかでUTF-8で表記された絵文字をUnicode数値文字参照に置換する。
    def self.utf8_to_unicodecr(str)
      str.gsub(UTF8_REGEXP) do |match|
        "&#x%04x;" % match.unpack('U').first
      end
    end

    # +str+ のなかでUnicode数値文字参照で表記された絵文字をメール送信用JISコードに変換する
    # au 専用
    def self.unicodecr_to_au_email(in_str)
      str = Jpmobile::Util.ascii_8bit(in_str)
      regexp = Regexp.compile(Jpmobile::Util.ascii_8bit("&#x([0-9a-f]{4});"), Regexp::IGNORECASE)
      str.gsub(regexp) do |match|
        unicode = $1.scanf("%x").first
        converted = CONVERSION_TABLE_TO_AU[unicode]

        # メール用エンコーディングに変換する
        case converted
        when Integer
          if sjis = UNICODE_TO_SJIS[converted]
            if email_jis = SJIS_TO_EMAIL_JIS[sjis]
              Jpmobile::Util.ascii_8bit("\x1b\x24\x42#{[email_jis].pack('n')}\x1b\x28\x42")
            else
              Jpmobile::Util.ascii_8bit([sjis].pack('n'))
            end
          else
            match
          end
        when String
          # FIXME: 絵文字の代替が文章でいいかどうかの検証
          Jpmobile::Util.ascii_8bit(Jpmobile::Util.utf8_to_jis(converted))
        else
          match
        end
      end
    end

    # +str+ のなかでUnicode数値文字参照で表記された絵文字をメール送信用JISコードに変換する
    # softbank 専用
    def self.unicodecr_to_softbank_email(str)
      str.gsub(/&#x([0-9a-f]{4});/i) do |match|
        unicode = $1.scanf("%x").first
        converted = CONVERSION_TABLE_TO_SOFTBANK[unicode]

        # メール用エンコーディングに変換する
        case converted
        when Integer
          if sjis = SOFTBANK_UNICODE_TO_SJIS[converted-0x1000]
            Jpmobile::Util.sjis([sjis].pack('n'))
          else
            match
          end
        when String
          # FIXME: 絵文字の代替が文章でいいかどうかの検証
          Jpmobile::Util.utf8_to_sjis(converted)
        else
          match
        end
      end
    end
  end
end
