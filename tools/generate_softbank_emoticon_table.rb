require 'rubygems'
require 'hpricot'
require 'cgi'
require 'open-uri'

# 'http://developers.softbankmobile.co.jp/dp/tool_dl/web/picword_01.php'

table = []
for i in 1..6
  uri = "http://developers.softbankmobile.co.jp/dp/tool_dl/web/picword_%02d.php" % i
  h = Hpricot(URI(uri).read.toutf8)
  (h/"//table[@width='100%']//tr").each do |tr|
    if tr
      a = (tr/"td/font[@class='j10']").map { |td| td.inner_html }
      unless a.empty?
        s = CGI.unescapeHTML(a.last)
        raise Exception, "something is wrong" if s[0,2] != "\x1b\x24" || s[4] != 0x0f
        table << [a.first, s[2,2]]
      end
    end
  end
end

open(File.dirname(__FILE__)+"/../lib/jpmobile/emoticon/softbank.rb","w") do |f|
  f.puts "Jpmobile::Emoticon::SOFTBANK_UNICODE_TO_WEBCODE = {"
  table.each do |a|
    f.puts %{  0x%s => %p,} % a
  end
  f.puts "}"
  f.puts "Jpmobile::Emoticon::SOFTBANK_WEBCODE_TO_UNICODE = Jpmobile::Emoticon::SOFTBANK_UNICODE_TO_WEBCODE.invert"
end
