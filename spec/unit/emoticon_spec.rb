# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

describe Jpmobile::Emoticon do
  include Jpmobile::Util

  describe "unicodecr_to_external" do
    context "should convert unicodecr to docomo encoding" do
      it "when no options" do
        Jpmobile::Emoticon::unicodecr_to_external("&#xe63e;").should == sjis("\xf8\x9f")
      end

      it "in multiple convertion" do
        Jpmobile::Emoticon::unicodecr_to_external("&#xE48E;", Jpmobile::Emoticon::CONVERSION_TABLE_TO_DOCOMO, true).should == sjis("\xf8\x9f\xf8\xa0")
      end
    end

    context "should convert unicodecr to au encoding" do
      it "when no options" do
        Jpmobile::Emoticon::unicodecr_to_external("&#xe481;").should == sjis("\xf6\x59")
      end
    end

    context "should convert unicodecr to softbank encoding" do
      it "when no opptions" do
        Jpmobile::Emoticon::unicodecr_to_external("&#xf001;").should == [0xe001].pack('U')
      end

      it "in multiple convertion" do
        Jpmobile::Emoticon::unicodecr_to_external("&#xE48E;", Jpmobile::Emoticon::CONVERSION_TABLE_TO_SOFTBANK, true).should == [0xe04a, 0xe049].pack('U*')
      end
    end

    it 'should convert docomo unicodecr to Unicode 6.0 emoticon' do
      Jpmobile::Emoticon.unicodecr_to_external("&#xe63e;", Jpmobile::Emoticon::CONVERSION_TABLE_TO_UNICODE_EMOTICON, false).should == [0x2600].pack('U')
    end

    it 'should convert au unicodecr to Unicode 6.0 emoticon' do
      Jpmobile::Emoticon.unicodecr_to_external("&#xe48e;", Jpmobile::Emoticon::CONVERSION_TABLE_TO_UNICODE_EMOTICON, false).should == [0x26C5].pack('U')
    end

    it 'should convert Softbank unicodecr to Unicode 6.0 emoticon' do
      Jpmobile::Emoticon.unicodecr_to_external("&#xf001;", Jpmobile::Emoticon::CONVERSION_TABLE_TO_UNICODE_EMOTICON, false).should == [0x1F466].pack('U')
    end

    it 'should not convert 〓' do
      Jpmobile::Emoticon.unicodecr_to_external("&#x3013;", Jpmobile::Emoticon::CONVERSION_TABLE_TO_UNICODE_EMOTICON, false).should == '〓'
    end

    it 'should convert docomo unicodecr to Google emoticon' do
      Jpmobile::Emoticon.unicodecr_to_external("&#xe63e;", Jpmobile::Emoticon::CONVERSION_TABLE_TO_GOOGLE_EMOTICON, false).should == [0xFE000].pack('U')
    end

    it 'should convert au unicodecr to Google emoticon' do
      Jpmobile::Emoticon.unicodecr_to_external("&#xe48e;", Jpmobile::Emoticon::CONVERSION_TABLE_TO_GOOGLE_EMOTICON, false).should == [0xFE00F].pack('U')
    end

    it 'should convert Softbank unicodecr to Google emoticon' do
      Jpmobile::Emoticon.unicodecr_to_external("&#xf001;", Jpmobile::Emoticon::CONVERSION_TABLE_TO_GOOGLE_EMOTICON, false).should == [0xFE19B].pack('U')
    end

    it 'should not convert 〓' do
      Jpmobile::Emoticon.unicodecr_to_external("&#x3013;", Jpmobile::Emoticon::CONVERSION_TABLE_TO_GOOGLE_EMOTICON, false).should == '〓'
    end
  end

  describe "unicodecr_to_utf8" do
    it "should convert unicodecr to internal utf8 encoding" do
      # docomo codepoint
      Jpmobile::Emoticon::unicodecr_to_utf8("&#xe63e;").should == utf8("\356\230\276")
      # au codepoint
      Jpmobile::Emoticon::unicodecr_to_utf8("&#xe481;").should == utf8("\356\222\201")
      # softbank codepoint
      Jpmobile::Emoticon::unicodecr_to_utf8("&#xf001;").should == utf8("\xef\x80\x81")
    end
  end

  describe "utf8_to_unicodecr" do
    it "should convert utf8 encoding to unicodecr" do
      # docomo codepoint
      Jpmobile::Emoticon::utf8_to_unicodecr(utf8("\356\230\276")).should == "&#xe63e;"
      # au codepoint
      Jpmobile::Emoticon::utf8_to_unicodecr(utf8("\356\222\201")).should == "&#xe481;"
      # softbank codepoint
      Jpmobile::Emoticon::utf8_to_unicodecr(utf8("\xef\x80\x81")).should == "&#xf001;"
    end
  end

  describe "external_to_unicodecr" do
    it "should convert docomo encoding to unicodecr" do
      Jpmobile::Emoticon::external_to_unicodecr_docomo(sjis("\xf8\x9f")).should == "&#xe63e;"
    end

    it "should convert au encoding to unicodecr" do
      Jpmobile::Emoticon::external_to_unicodecr_au(sjis("\xf6\x59")).should == "&#xe481;"
    end

    it "should convert softbank encoding to unicodecr" do
      Jpmobile::Emoticon::external_to_unicodecr_softbank([0xe001].pack('U')).should == "&#xf001;"
    end

    it "should not convert docomo encoding of koukai-sjis emoticons to unicodecr" do
      Jpmobile::Emoticon::external_to_unicodecr_docomo(sjis("\x8c\xf6\x8a\x4a")).should == sjis("\x8c\xf6\x8a\x4a")
    end

    context 'at iPhone emoticon' do
      it 'should convert iPhone Unicode emoticon to SoftBank emoticon' do
        Jpmobile::Emoticon::external_to_unicodecr_unicode60("\342\230\200").should == "&#xf04a;"
      end

      it 'should convert iPhone Unicode emoticon to multi SoftBank emoticons' do
        Jpmobile::Emoticon::external_to_unicodecr_unicode60("\342\233\205").should == "&#xF04A;,&#xF049;"
      end

      it 'should not convert 〓' do
        Jpmobile::Emoticon::external_to_unicodecr_unicode60('〓').should == "〓"
      end
    end

    context 'at Android emoticon' do
      it 'should convert Android Google Unicode emoticon to Docomo emoticon' do
        Jpmobile::Emoticon::external_to_unicodecr_google("\363\276\200\200").should == "&#xe63e;"
      end

      it 'should convert Android Google Unicode emoticon to multi Docomo emoticon' do
        Jpmobile::Emoticon::external_to_unicodecr_google("\363\276\200\217").should == "&#xE63E;&#xE63F;"
      end

      it 'should not convert 〓' do
        Jpmobile::Emoticon::external_to_unicodecr_google('〓').should == "〓"
      end
    end
  end

  context "for email" do
    describe "au" do
      it "should not convert 助助 that does not contain emoticons" do
        Jpmobile::Emoticon.external_to_unicodecr_au_mail(utf8_to_jis("助助")).should_not match(/e484/i)
      end

      it "should not convert exterior of 2byte Kanji-code" do
        Jpmobile::Emoticon.external_to_unicodecr_au_mail(utf8_to_jis("abcd=uしから=uずんば=u")).should_not match(/e484/i)
      end

      it "should not convert ascii string to unicodecr" do
        Jpmobile::Emoticon.external_to_unicodecr_au_mail(utf8_to_jis("-------=_NextPart_15793_72254_63179")).should_not match(/e5c2/i)
      end

      it "should not include extra JIS escape sequence between Kanji-code and emoticon" do
        Jpmobile::Emoticon.unicodecr_to_au_email(utf8_to_jis("&#xe481;掲示板")).should == Jpmobile::Util.ascii_8bit("\x1b\x24\x42\x75\x3a\x37\x47\x3C\x28\x48\x44\x1b\x28\x42")
      end
    end
  end
end
