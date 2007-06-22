module Jpmobile
  # 絵文字関連処理
  module Pictogram
    def self.external_to_unicodecr(str)
      # NOTE 現状ではキャリア間で端末が送ってくる絵文字のコード領域が重なっていないので、
      # このメソッドはUser-agentによって挙動を変更する必要は無い。
      s = str.dup
      # DoCoMo, Au
      s.gsub!(SJIS_REGEXP) do |match|
        sjis = match.unpack('n').first
        unicode = SJIS_TO_UNICODE[sjis]
        unicode ? ("&#x%04x;"%unicode) : match
      end
      # SoftBank
      s.gsub!(/\x1b\x24(.)(.+?)\x0f/) do |match|
        a = $1
        $2.split(//).map{|x| "\x1b\x24#{a}#{x}\x0f"}.join('')
      end
      s.gsub(SOFTBANK_WEBCODE_REGEXP) do |match|
        unicode = SOFTBANK_WEBCODE_TO_UNICODE[match[2,2]] + 0x1000
        unicode ? ("&#x%04x;"%unicode) : match
      end
    end
    #
    # NOTE このメソッドだけがUser-Agentに依存して挙動を変える必要がある。
    def self.unicodecr_to_external(str)
      str.gsub(/&#x([0-9a-f]{4});/i) do |match|
        unicode = $1.scanf("%x").first
        #
        # TODO ここにキャリア間の相互変換コードを入れる(Unicode-Unicode)
        #
        if sjis = UNICODE_TO_SJIS[unicode]
          [sjis].pack('n')
        elsif webcode = SOFTBANK_UNICODE_TO_WEBCODE[unicode-0x1000]
          "\x1b\x24#{webcode}\x0f"
        else
          match
        end
      end
    end
    #
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
    #
    def self.utf8_to_unicodecr(str)
      str.gsub(UTF8_REGEXP) do |match|
        "&#x%04x;" % match.unpack('U').first
      end
    end
  end
end
