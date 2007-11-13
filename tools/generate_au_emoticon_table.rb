#!/usr/bin/ruby

# http://www.au.kddi.com/ezfactory/tec/spec/pdf/typeD.pdf から生成
# - OSXのpreviewで開き、すべてを選択してコピーし、テキストファイルに落とす
# - http://moriq.tdiary.net/20070212.html#p01
# などの手段によって生成する。

table = []
open("au.txt") do |f|
  f.each do |l|
    l.chomp!
    l.scan( /(([0-9A-F] )+)/ ) do |s|
      s = s[0].gsub!(/ /, "")
      next if s.size < 16
      out = s[s.size-16,16]
      table << a = [0,4,8,12].map{|i| out[i,4]}
    end
  end
end

open(File.dirname(__FILE__)+"/../lib/jpmobile/emoticon/au.rb","w") do |f|
  f.puts "Jpmobile::Emoticon::AU_SJIS_TO_UNICODE = {"
  table.each do |a|
    f.puts "  0x%s=>0x%s," % [a[0],a[1]]
  end
  f.puts "}.freeze"
  f.puts "Jpmobile::Emoticon::AU_UNICODE_TO_SJIS = Jpmobile::Emoticon::AU_SJIS_TO_UNICODE.invert.freeze"
  # EmailJIS -> UNICODE
  f.puts "Jpmobile::Emoticon::AU_EMAILJIS_TO_UNICODE = {"
  table.each do |a|
    f.puts "  0x%s=>0x%s," % [a[2],a[1]]
  end
  f.puts "}.freeze"
end
