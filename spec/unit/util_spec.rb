# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))
require 'stringio'
require 'nkf'

describe Jpmobile::Util do
  include Jpmobile::Util

  it 'nilのときはnilを返すこと' do
    deep_apply(nil) {|obj| obj }.should equal(nil)
  end

  it 'trueのときはtrueを返すこと' do
    deep_apply(true) {|obj| obj }.should equal(true)
  end

  it 'falseのときはそのまま値を返すこと' do
    deep_apply(false) {|obj| obj }.should equal(false)
  end

  it 'Tempfileのインスタンスのときはそのまま値を返すこと' do
    temp = Tempfile.new('test')
    deep_apply(temp) {|obj| obj}.object_id.should equal(temp.object_id)
    # 本来 deep_apply(temp) {|obj| obj }.should equal(temp) が通るべきのような。
    # 参考 http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-list/41720
  end

  it 'StringIOのインスタンスのときはそのまま値を返すこと' do
    string_io = StringIO.new('test')
    deep_apply(string_io) {|obj| obj }.should equal(string_io)
  end

  it "utf8_to_sjis で変換できない文字列が含んでいた場合?に変換される" do
    utf8_to_sjis("اللغة العربية").should == sjis("????? ???????")
  end

  it "utf8_to_sjis ですべての改行コードが CRLF に変更されること" do
    utf8_to_sjis("UTF8\rSAMPLE\nTEXT\r\n").should == sjis("UTF8\r\nSAMPLE\r\nTEXT\r\n")
  end

  it "0x8150がU+FFE3に変換されること" do
    sjis_to_utf8(sjis("\x81\x50")).should == [0xffe3].pack("U")
  end

  it "U+FFE3が0x8150に変換されること" do
    utf8_to_sjis([0xffe3].pack("U")).should == sjis("\x81\x50")
  end

  it "U+203Eが0x8150に変換されること" do
    utf8_to_sjis([0x203e].pack("U")).should == sjis("\x81\x50")
  end

  it "U+2014が0x815Cに変換されること" do
    utf8_to_sjis([0x2014].pack("U")).should == sjis("\x81\x5C")
  end

  it "U+2212が0x817Cに変換されること" do
    utf8_to_sjis([0x2212].pack("U")).should == sjis("\x81\x7C")
  end

  it "jis_string_regexpでISO-2022-JPの文字列がマッチすること" do
    jis_string_regexp.match(ascii_8bit(utf8_to_jis("abcしからずんばこじをえずdef"))).should_not be_nil
    jis_to_utf8(jis("\x1b\x24\x42#{$1}\x1b\x28\x42")).should == "しからずんばこじをえず"
  end

  it "sjis_to_utf8 ですべての改行コードが LF に変更されること" do
    sjis_to_utf8("SJIS\rSAMPLE\nTEXT\r\n").should == utf8("SJIS\nSAMPLE\nTEXT\n")
  end

  it "utf8_to_sjis で変換できない文字列が含んでいた場合?に変換される" do
    utf8_to_jis("اللغة العربية").should == jis("????? ???????")
  end

  it "utf8_to_jis ですべての改行コードが CRLF に変更されること" do
    utf8_to_jis("UTF8\rSAMPLE\nTEXT\r\n").should == jis("UTF8\r\nSAMPLE\r\nTEXT\r\n")
  end

  it "jis_to_utf8 ですべての改行コードが LF に変更されること" do
    jis_to_utf8("JIS\rSAMPLE\nTEXT\r\n").should == utf8("JIS\nSAMPLE\nTEXT\n")
  end

  it "fold_textでUTF-8の日本語文字列が指定文字数で折り返された配列で返ること" do
    fold_text('長い日本語の題名で折り返されるかようにするには事前に分割していないとダメなことがわかりましたよ', 15).should == [
      '長い日本語の題名で折り返される',
      'かようにするには事前に分割して',
      'いないとダメなことがわかりまし',
      'たよ'
    ]
  end

  it "fold_textでUTF-8の短い文字列は折り返されないこと" do
    fold_text('短い', 15).should == ['短い']
  end

  it "split_textでUTF-8の日本語文字列が指定文字数で2つに分割されること" do
    split_text('長い日本語の題名で折り返されるかようにするには事前に分割していないとダメなことがわかりましたよ', 15).should == [
      '長い日本語の題名で折り返される',
      'かようにするには事前に分割していないとダメなことがわかりましたよ'
    ]
  end

  it "split_textでnilかblankの場合はnilが返ること" do
    split_text('', 15).should be_nil
    split_text(nil, 15).should be_nil
  end

  it "全角チルダがjisに適切に変換されること" do
    ascii_8bit(utf8_to_jis("\xef\xbd\x9e")).should == ascii_8bit("\x1b\x24\x42\x21\x41\x1b\x28\x42")
    ascii_8bit(encode("\xef\xbd\x9e", "ISO-2022-JP")).should == ascii_8bit("\x1b\x24\x42\x21\x41\x1b\x28\x42")
  end

  describe 'invert_table' do
    it 'pickups the first(least) of duplicated values when inverting hash table' do
      hash = invert_table({
          0xFE009 => 0xE63E,
          0xFE00A => 0xE63E,
          0xFE00B => 0x3013,
          0xFE010 => 0xE6B3,
          0xFE038 => 0xE73F})
      hash[0xE63E].should == 0xFE009
      hash[0x3013].should == 0xFE00B
    end

    it 'should not raise error when hash has Array keys' do
      hash = invert_table({
          [0x1F1E8, 0x1F1F3] => 0x3013,
          0x1F1FF            => 0x3013,
          0x1F526            => 0xE6FB,
          [0x0023, 0x20E3]   => 0xE6E0,
          0x1F354            => 0xE673})
      hash[0x3013].should == [0x1F1E8, 0x1F1F3]
      hash[0xE6FB].should == 0x1F526
    end
  end
end
