# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

describe Jpmobile::Emoticon do
  include Jpmobile::Util

  describe "unicodecr_to_external" do
    context "should convert unicodecr to docomo encoding" do
      it "when no options" do
        expect(Jpmobile::Emoticon::unicodecr_to_external("&#xe63e;")).to eq(sjis("\xf8\x9f"))
      end

      it "in multiple convertion" do
        expect(Jpmobile::Emoticon::unicodecr_to_external("&#xE48E;", Jpmobile::Emoticon::CONVERSION_TABLE_TO_DOCOMO, true)).to eq(sjis("\xf8\x9f\xf8\xa0"))
      end
    end

    context "should convert unicodecr to au encoding" do
      it "when no options" do
        expect(Jpmobile::Emoticon::unicodecr_to_external("&#xe481;")).to eq(sjis("\xf6\x59"))
      end
    end

    context "should convert unicodecr to softbank encoding" do
      it "when no opptions" do
        expect(Jpmobile::Emoticon::unicodecr_to_external("&#xf001;")).to eq([0xe001].pack('U'))
      end

      it "in multiple convertion" do
        expect(Jpmobile::Emoticon::unicodecr_to_external("&#xE48E;", Jpmobile::Emoticon::CONVERSION_TABLE_TO_SOFTBANK, true)).to eq([0xe04a, 0xe049].pack('U*'))
      end
    end

    it 'should convert docomo unicodecr to Unicode 6.0 emoticon' do
      expect(Jpmobile::Emoticon.unicodecr_to_external("&#xe63e;", Jpmobile::Emoticon::CONVERSION_TABLE_TO_UNICODE_EMOTICON, false)).to eq([0x2600].pack('U'))
    end

    it 'should convert au unicodecr to Unicode 6.0 emoticon' do
      expect(Jpmobile::Emoticon.unicodecr_to_external("&#xe48e;", Jpmobile::Emoticon::CONVERSION_TABLE_TO_UNICODE_EMOTICON, false)).to eq([0x26C5].pack('U'))
    end

    it 'should convert Softbank unicodecr to Unicode 6.0 emoticon' do
      expect(Jpmobile::Emoticon.unicodecr_to_external("&#xf001;", Jpmobile::Emoticon::CONVERSION_TABLE_TO_UNICODE_EMOTICON, false)).to eq([0x1F466].pack('U'))
    end

    it 'should not convert 〓' do
      expect(Jpmobile::Emoticon.unicodecr_to_external("&#x3013;", Jpmobile::Emoticon::CONVERSION_TABLE_TO_UNICODE_EMOTICON, false)).to eq('〓')
    end

    it 'should convert docomo unicodecr to Google emoticon' do
      expect(Jpmobile::Emoticon.unicodecr_to_external("&#xe63e;", Jpmobile::Emoticon::CONVERSION_TABLE_TO_GOOGLE_EMOTICON, false)).to eq([0xFE000].pack('U'))
    end

    it 'should convert au unicodecr to Google emoticon' do
      expect(Jpmobile::Emoticon.unicodecr_to_external("&#xe48e;", Jpmobile::Emoticon::CONVERSION_TABLE_TO_GOOGLE_EMOTICON, false)).to eq([0xFE00F].pack('U'))
    end

    it 'should convert Softbank unicodecr to Google emoticon' do
      expect(Jpmobile::Emoticon.unicodecr_to_external("&#xf001;", Jpmobile::Emoticon::CONVERSION_TABLE_TO_GOOGLE_EMOTICON, false)).to eq([0xFE19B].pack('U'))
    end

    it 'should not convert 〓' do
      expect(Jpmobile::Emoticon.unicodecr_to_external("&#x3013;", Jpmobile::Emoticon::CONVERSION_TABLE_TO_GOOGLE_EMOTICON, false)).to eq('〓')
    end
  end

  describe "unicodecr_to_utf8" do
    it "should convert unicodecr to internal utf8 encoding" do
      # docomo codepoint
      expect(Jpmobile::Emoticon::unicodecr_to_utf8("&#xe63e;")).to eq(utf8("\356\230\276"))
      # au codepoint
      expect(Jpmobile::Emoticon::unicodecr_to_utf8("&#xe481;")).to eq(utf8("\356\222\201"))
      # softbank codepoint
      expect(Jpmobile::Emoticon::unicodecr_to_utf8("&#xf001;")).to eq(utf8("\xef\x80\x81"))
    end
  end

  describe "utf8_to_unicodecr" do
    it "should convert utf8 encoding to unicodecr" do
      # docomo codepoint
      expect(Jpmobile::Emoticon::utf8_to_unicodecr(utf8("\356\230\276"))).to eq("&#xe63e;")
      # au codepoint
      expect(Jpmobile::Emoticon::utf8_to_unicodecr(utf8("\356\222\201"))).to eq("&#xe481;")
      # softbank codepoint
      expect(Jpmobile::Emoticon::utf8_to_unicodecr(utf8("\xef\x80\x81"))).to eq("&#xf001;")
    end
  end

  describe "external_to_unicodecr" do
    it "should convert docomo encoding to unicodecr" do
      expect(Jpmobile::Emoticon::external_to_unicodecr_docomo(sjis("\xf8\x9f"))).to eq("&#xe63e;")
    end

    it "should convert au encoding to unicodecr" do
      expect(Jpmobile::Emoticon::external_to_unicodecr_au(sjis("\xf6\x59"))).to eq("&#xe481;")
    end

    it "should convert softbank encoding to unicodecr" do
      expect(Jpmobile::Emoticon::external_to_unicodecr_softbank([0xe001].pack('U'))).to eq("&#xf001;")
    end

    it "should not convert docomo encoding of koukai-sjis emoticons to unicodecr" do
      expect(Jpmobile::Emoticon::external_to_unicodecr_docomo(sjis("\x8c\xf6\x8a\x4a"))).to eq(sjis("\x8c\xf6\x8a\x4a"))
    end

    context 'at iPhone emoticon' do
      it 'should convert iPhone Unicode emoticon to SoftBank emoticon' do
        expect(Jpmobile::Emoticon::external_to_unicodecr_unicode60("\342\230\200")).to eq("&#xf04a;")
      end

      it 'should convert iPhone Unicode emoticon to multi SoftBank emoticons' do
        expect(Jpmobile::Emoticon::external_to_unicodecr_unicode60("\342\233\205")).to eq("&#xF04A;,&#xF049;")
      end

      it 'should not convert 〓' do
        expect(Jpmobile::Emoticon::external_to_unicodecr_unicode60('〓')).to eq("〓")
      end
    end

    context 'at Android emoticon' do
      it 'should convert Android Google Unicode emoticon to Docomo emoticon' do
        expect(Jpmobile::Emoticon::external_to_unicodecr_google("\363\276\200\200")).to eq("&#xe63e;")
      end

      it 'should convert Android Google Unicode emoticon to multi Docomo emoticon' do
        expect(Jpmobile::Emoticon::external_to_unicodecr_google("\363\276\200\217")).to eq("&#xE63E;&#xE63F;")
      end

      it 'should not convert 〓' do
        expect(Jpmobile::Emoticon::external_to_unicodecr_google('〓')).to eq("〓")
      end
    end
  end

  context "for email" do
    describe "au" do
      it "should not convert 助助 that does not contain emoticons" do
        expect(Jpmobile::Emoticon.external_to_unicodecr_au_mail(utf8_to_jis("助助"))).not_to match(/e484/i)
      end

      it "should not convert exterior of 2byte Kanji-code" do
        expect(Jpmobile::Emoticon.external_to_unicodecr_au_mail(utf8_to_jis("abcd=uしから=uずんば=u"))).not_to match(/e484/i)
      end

      it "should not convert ascii string to unicodecr" do
        expect(Jpmobile::Emoticon.external_to_unicodecr_au_mail(utf8_to_jis("-------=_NextPart_15793_72254_63179"))).not_to match(/e5c2/i)
      end

      it "should not include extra JIS escape sequence between Kanji-code and emoticon" do
        expect(Jpmobile::Emoticon.unicodecr_to_au_email(utf8_to_jis("&#xe481;掲示板"))).to eq(Jpmobile::Util.ascii_8bit("\x1b\x24\x42\x75\x3a\x37\x47\x3C\x28\x48\x44\x1b\x28\x42"))
      end
    end
  end
end
