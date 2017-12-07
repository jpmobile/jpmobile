require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))
require 'stringio'
require 'nkf'

describe Jpmobile::Util do
  include Jpmobile::Util

  describe 'utf8_to_sjis' do
    it 'utf8_to_sjis で変換できない文字列が含んでいた場合?に変換される' do
      expect(utf8_to_sjis('اللغة العربية')).to eq(sjis('????? ???????'))
    end

    it 'utf8_to_sjis ですべての改行コードが CRLF に変更されること' do
      expect(utf8_to_sjis("UTF8\rSAMPLE\nTEXT\r\n")).to eq(sjis("UTF8\r\nSAMPLE\r\nTEXT\r\n"))
    end

    it 'U+FFE3が0x8150に変換されること' do
      expect(utf8_to_sjis([0xffe3].pack('U'))).to eq(sjis("\x81\x50"))
    end

    it 'U+203Eが0x8150に変換されること' do
      expect(utf8_to_sjis([0x203e].pack('U'))).to eq(sjis("\x81\x50"))
    end

    it 'U+2014が0x815Cに変換されること' do
      expect(utf8_to_sjis([0x2014].pack('U'))).to eq(sjis("\x81\x5C"))
    end

    it 'U+2212が0x817Cに変換されること' do
      expect(utf8_to_sjis([0x2212].pack('U'))).to eq(sjis("\x81\x7C"))
    end

    it 'utf8_to_sjis で変換できない文字列が含んでいた場合?に変換される' do
      expect(utf8_to_jis('اللغة العربية')).to eq(jis('????? ???????'))
    end

    it 'frozenでも通過すること' do
      expect { utf8_to_jis('漢字'.freeze) }.not_to raise_error
    end
  end

  describe 'sjis_to_utf8' do
    it '0x8150がU+FFE3に変換されること' do
      expect(sjis_to_utf8(sjis("\x81\x50"))).to eq([0xffe3].pack('U'))
    end

    it 'sjis_to_utf8 ですべての改行コードが LF に変更されること' do
      expect(sjis_to_utf8("SJIS\rSAMPLE\nTEXT\r\n")).to eq(utf8("SJIS\nSAMPLE\nTEXT\n"))
    end

    it 'frozenでも通過すること' do
      expect { sjis_to_utf8('漢字'.encode('SJIS').freeze) }.not_to raise_error
    end
  end

  describe 'utf8_to_jis' do
    it 'utf8_to_jis ですべての改行コードが CRLF に変更されること' do
      expect(utf8_to_jis("UTF8\rSAMPLE\nTEXT\r\n")).to eq(jis("UTF8\r\nSAMPLE\r\nTEXT\r\n"))
    end

    it 'frozenでも通過すること' do
      expect { utf8_to_jis('漢字'.freeze) }.not_to raise_error
    end
  end

  describe 'jis_string_regexp' do
    it 'jis_string_regexpでISO-2022-JPの文字列がマッチすること' do
      expect(jis_string_regexp.match(ascii_8bit(utf8_to_jis('abcしからずんばこじをえずdef')))).not_to be_nil
      expect(jis_to_utf8(jis("\x1b\x24\x42#{Regexp.last_match(1)}\x1b\x28\x42"))).to eq('しからずんばこじをえず')
    end
  end

  describe 'jis_to_utf8' do
    it 'jis_to_utf8 ですべての改行コードが LF に変更されること' do
      expect(jis_to_utf8("JIS\rSAMPLE\nTEXT\r\n")).to eq(utf8("JIS\nSAMPLE\nTEXT\n"))
    end

    it 'frozenでも通過すること' do
      expect { jis_to_utf8('漢字'.encode('ISO-2022-JP').freeze) }.not_to raise_error
    end
  end

  describe '#force_encode' do
    it 'converts ISO-2022-JP string which contains halfwidth-kana' do
      expect(force_encode("\e\x28\x49\x43\x3D\x44\e\x28\x42".force_encoding('ISO-2022-JP'), 'iso-2022-jp', 'UTF-8')).to eq 'ﾃｽﾄ'
    end

    it 'does not enter infinite loop on retry' do
      expect { force_encode("\e\x28\x49\x9a\x43\x3D\x44\e\x28\x42".force_encoding('ISO-2022-JP'), 'iso-2022-jp', 'UTF-8') }.to raise_error ::Encoding::InvalidByteSequenceError
    end

    it 'frozenでも通過すること' do
      expect { force_encode('漢字'.encode('ISO-2022-JP').freeze, 'iso-2022-jp', 'UTF-8') }.not_to raise_error
    end
  end

  describe '#fold_text' do
    it 'UTF-8の日本語文字列が指定文字数で折り返された配列で返ること' do
      expect(fold_text('長い日本語の題名で折り返されるかようにするには事前に分割していないとダメなことがわかりましたよ', 15)).
        to eq(
          %w[
            長い日本語の題名で折り返される
            かようにするには事前に分割して
            いないとダメなことがわかりまし
            たよ
          ],
        )
    end

    it 'UTF-8の短い文字列は折り返されないこと' do
      expect(fold_text('短い', 15)).to eq(['短い'])
    end

    it 'frozenでも通過すること' do
      expect { fold_text(('漢字' * 10).freeze, 15) }.not_to raise_error
    end
  end

  describe '#split_text' do
    it 'UTF-8の日本語文字列が指定文字数で2つに分割されること' do
      expect(split_text('長い日本語の題名で折り返されるかようにするには事前に分割していないとダメなことがわかりましたよ', 15)).
        to eq(
          %w[
            長い日本語の題名で折り返される
            かようにするには事前に分割していないとダメなことがわかりましたよ
          ],
        )
    end

    it 'nilかblankの場合はnilが返ること' do
      expect(split_text('', 15)).to be_nil
      expect(split_text(nil, 15)).to be_nil
    end

    it 'frozenでも通過すること' do
      expect { split_text(('漢字' * 10).freeze, 15) }.not_to raise_error
    end
  end

  describe '#sjis' do
    it 'frozenでも通過すること' do
      expect { sjis('漢字'.freeze) }.not_to raise_error
    end
  end

  describe '#utf8' do
    it 'frozenでも通過すること' do
      expect { utf8('漢字'.freeze) }.not_to raise_error
    end
  end

  describe '#jis' do
    it 'frozenでも通過すること' do
      expect { jis('漢字'.freeze) }.not_to raise_error
    end
  end

  describe '#jis_win' do
    it 'frozenでも通過すること' do
      expect { jis_win('漢字'.freeze) }.not_to raise_error
    end
  end

  describe '#ascii_8bit' do
    it 'frozenでも通過すること' do
      expect { ascii_8bit('漢字'.freeze) }.not_to raise_error
    end
  end

  describe '#ascii_compatible!' do
    it 'frozenでも通過すること' do
      expect { ascii_compatible!('漢字'.freeze) }.not_to raise_error
    end
  end

  it '全角チルダがjisに適切に変換されること' do
    expect(ascii_8bit(utf8_to_jis("\xef\xbd\x9e"))).to eq(ascii_8bit("\x1b\x24\x42\x21\x41\x1b\x28\x42"))
    expect(ascii_8bit(encode("\xef\xbd\x9e", 'ISO-2022-JP'))).to eq(ascii_8bit("\x1b\x24\x42\x21\x41\x1b\x28\x42"))
  end

  describe 'invert_table' do
    it 'pickups the first(least) of duplicated values when inverting hash table' do
      hash = invert_table(
        {
          0xFE009 => 0xE63E,
          0xFE00A => 0xE63E,
          0xFE00B => 0x3013,
          0xFE010 => 0xE6B3,
          0xFE038 => 0xE73F,
        },
      )
      expect(hash[0xE63E]).to eq(0xFE009)
      expect(hash[0x3013]).to eq(0xFE00B)
    end

    it 'should not raise error when hash has Array keys' do
      hash = invert_table(
        {
          [0x1F1E8, 0x1F1F3] => 0x3013,
          0x1F1FF            => 0x3013,
          0x1F526            => 0xE6FB,
          [0x0023, 0x20E3]   => 0xE6E0,
          0x1F354            => 0xE673,
        },
      )
      expect(hash[0x3013]).to eq([0x1F1E8, 0x1F1F3])
      expect(hash[0xE6FB]).to eq(0x1F526)
    end
  end
end
