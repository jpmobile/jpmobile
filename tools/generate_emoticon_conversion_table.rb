#!/usr/bin/ruby -Ku
require 'pp'
require 'iconv'
require 'scanf'

# http://labs.unoh.net/2007/02/post_65.html
# のテーブルから変換用テーブルを作成する。

# Jpmobileのテーブルを拝借
module Jpmobile
  module Emoticon
  end
end
for c in %w(au docomo softbank)
  require File.dirname(__FILE__)+"/../lib/jpmobile/emoticon/#{c}.rb"
end

class Table
  def initialize(path)
    @list = []
    @table = {}
    @code = {}
    if path =~ /emoji_(.)2(..)/
      @type = $1
      @dest_types = $2.split(//)
    else
      raise Exception, "something is wrong"
    end
    open(path) do |f|
      f.gets # ヘッダを捨てる
      f.each do |l|
        a = Iconv.conv("utf-8", "cp932", l).chomp.split(/\t/)
        @list << a
        @code[a[0]] = a[1]
        @table[a[0]] = a[2...a.size]
      end
    end
  end
  def chars
    table.keys.sort_by {|x| x.gsub(/\D/,"").to_i }
  end
  def conv(src, dest_type)
    if dest_type == @type
      src
    else
      @table[src][@dest_types.index(dest_type)]
    end
  end
  attr_reader :list, :table, :code, :type
end

class Tables
  def initialize
    @chars = []
    @tables = {}
    @types = []
    for name in %w(i2es e2is s2ie)
      table = Table.new("emoji_#{name}.txt")
      @tables[table.type] = table
      @chars |= table.chars
      @types << table.type
    end
  end
  def conv(src, dest_type)
    src_type = src[1,1]
    dest = @tables[src_type].conv(src, dest_type)
    dest = nil if dest == "〓"
    dest
  end
  def id_to_unicode(src)
    return src if src.nil? || src !~ /^%[ies]\d+%$/
    case src[1,1]
    when "i"
      sjis = tables["i"].code[src]
      return Jpmobile::Emoticon::DOCOMO_SJIS_TO_UNICODE[sjis.to_i(16)]
    when "e"
      sjis = tables["e"].code[src]
      return Jpmobile::Emoticon::AU_SJIS_TO_UNICODE[sjis.to_i(16)]
    when "s"
      webcode = tables["s"].code[src]
      unicode = Jpmobile::Emoticon::SOFTBANK_WEBCODE_TO_UNICODE[webcode]
      return nil unless unicode
      return unicode + 0x1000
    end
  end
  attr_reader :chars, :tables, :types
end

t = Tables.new
ident = {'i'=>'DOCOMO', 'e'=>'AU', 's'=>'SOFTBANK'}

open(File.dirname(__FILE__)+"/../lib/jpmobile/emoticon/conversion_table.rb","w") do |f|
  for dest_type in %w(i e s)
    f.puts "Jpmobile::Emoticon::CONVERSION_TABLE_TO_#{ident[dest_type]} = {"
    for src in t.chars
      dest = t.conv(src, dest_type)
      src_unicode = t.id_to_unicode(src)
      dest_unicode = t.id_to_unicode(dest)
      next if src_unicode.nil? || dest_unicode.nil?
      f.printf("  %s=>%s,\n",
             src_unicode.is_a?(Integer) ? "0x%04X"%src_unicode : "'#{src_unicode}'",
             dest_unicode.is_a?(Integer) ? "0x%04X"%dest_unicode : "'#{dest_unicode}'"
            )
    end
  f.puts "}"
  end
end
