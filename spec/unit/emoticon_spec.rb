# -*- coding: utf-8 -*-
require File.join(File.expand_path(File.dirname(__FILE__)), 'spec_helper')

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
    end
  end
end
