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
      UNICODE_EMOTICONS UNICODE_EMOTICON_REGEXP UNICODE_EMOTICON_TO_CARRIER_EMOTICON
      GOOGLE_EMOTICONS GOOGLE_EMOTICON_REGEXP GOOGLE_EMOTICON_TO_CARRIER_EMOTICON
      CONVERSION_TABLE_TO_UNICODE_EMOTICON CONVERSION_TABLE_TO_GOOGLE_EMOTICON
      GETA_CODE GETA
    ).each do |const|
      autoload const, 'jpmobile/emoticon/z_combine'
    end
    %w( GOOGLE_TO_DOCOMO_UNICODE GOOGLE_TO_AU_UNICODE GOOGLE_TO_SOFTBANK_UNICODE ).each do |const|
      autoload const, 'jpmobile/emoticon/google'
    end
    %w( UNICODE_TO_DOCOMO_UNICODE UNICODE_TO_AU_UNICODE UNICODE_TO_SOFTBANK_UNICODE ).each do |const|
      autoload const, 'jpmobile/emoticon/unicode'
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

    # Unicode 6.0絵文字の変換
    def self.external_to_unicodecr_unicode60(str)
      str.gsub(UNICODE_EMOTICON_REGEXP) do |match|
        unicodes = match.unpack('U*')
        unicodes = unicodes.first if unicodes.size == 1

        if (emoticon = UNICODE_EMOTICON_TO_CARRIER_EMOTICON[unicodes]) == GETA_CODE
          GETA
        elsif emoticon
          case emoticon
          when GETA_CODE
            GETA
          when Integer
            "&#x%04x;" % emoticon
          when String
            emoticon
          end
        else
          # 変換できなければ〓に
          GETA
        end
      end
    end

    # Google絵文字の変換
    def self.external_to_unicodecr_google(str)
      str.gsub(GOOGLE_EMOTICON_REGEXP) do |match|
        unicodes = match.unpack('U*')
        unicodes = unicodes.first if unicodes.size == 1

        if emoticon = GOOGLE_EMOTICON_TO_CARRIER_EMOTICON[unicodes]
          case emoticon
          when GETA_CODE
            GETA
          when Integer
            "&#x%04x;" % emoticon
          when String
            emoticon
          end
        else
          # 変換できなければ〓に
          GETA
        end
      end
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
              Jpmobile::Util.sjis([sjis].pack('n'))
            else
              [converted].pack("U")
            end
          elsif SOFTBANK_UNICODE_TO_WEBCODE[converted-0x1000]
            [converted-0x1000].pack('U')
          elsif converted == GETA_CODE
            # PCで〓を表示する場合
            GETA
          elsif UNICODE_EMOTICONS.include?(converted) or GOOGLE_EMOTICONS.include?(converted)
            if unicode == GETA_CODE
              GETA
            else
              [converted].pack('U*')
            end
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
      str = str.gsub(regexp) do |match|
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
      regexp = Regexp.compile(Regexp.escape(Jpmobile::Util.ascii_8bit("\x1b\x28\x42\x1b\x24\x42")), Regexp::IGNORECASE)
      str.gsub(regexp, '')
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

    @@pc_emoticon_image_path = nil
    @@pc_emoticon_yaml       = nil
    @@pc_emoticon_hash       = nil

    def self.pc_emoticon_image_path
      @@pc_emoticon_image_path
    end
    def self.pc_emoticon_image_path=(path)
      @@pc_emoticon_image_path=(path)
    end

    def self.pc_emoticon_yaml=(file)
      @@pc_emoticon_yaml = file
    end
    def self.pc_emoticon_yaml
      @@pc_emoticon_yaml
    end

    def self.pc_emoticon?
      if @@pc_emoticon_yaml and File.exist?(@@pc_emoticon_yaml) and @@pc_emoticon_image_path

        unless @@pc_emoticon_hash
          begin
            yaml_hash = YAML.load_file(@@pc_emoticon_yaml)
            @@pc_emoticon_hash = Hash[*(yaml_hash.values.inject([]){ |r, v| r += v.to_a.flatten; r})]
            @@pc_emoticon_image_path.chop if @@pc_emoticon_image_path.match(/\/$/)

            return true
          rescue
          end
        else
          return true
        end
      end

      return false
    end

    def self.emoticons_to_image(str)
      if @@pc_emoticon_hash
        utf8_to_unicodecr(str).gsub(/&#x([0-9a-f]{4});/i) do |match|
          img = @@pc_emoticon_hash[$1.upcase] || (@@pc_emoticon_hash[("%x" % ($1.scanf("%x").first - 0x1000)).upcase] rescue nil)
          if img
            "<img src=\"#{@@pc_emoticon_image_path}/#{img}.gif\" alt=\"#{img}\" />"
          else
            ""
          end
        end
      end
    end
  end
end
