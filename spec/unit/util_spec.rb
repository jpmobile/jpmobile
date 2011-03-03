# -*- coding: utf-8 -*-
require 'stringio'
require 'nkf'
require File.join(File.expand_path(File.dirname(__FILE__)), 'spec_helper')

describe Jpmobile::Util, ".deep_apply" do
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

  it "utf8_to_sjis で改行コードが CRLF に変更されること" do
    utf8_to_sjis("UTF8\nTEXT\n").should == sjis("UTF8\r\nTEXT\r\n")
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

  it "jis_string_regexpでISO-2022-JPの文字列がマッチすること" do
    jis_string_regexp.match(ascii_8bit(utf8_to_jis("abcしからずんばこじをえずdef"))).should_not be_nil
    jis_to_utf8(jis("\x1b\x24\x42#{$1}\x1b\x28\x42")).should == "しからずんばこじをえず"
  end
end
