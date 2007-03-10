require 'kconv'
require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'cgi'

$KCODE="u"

def parse(html)
  results = []
  (Hpricot(html)/"//table//tr").each do |tr|
    tds = (tr/:td/:span)
    if tds && tds.size > 0
      results << tds.map {|td| CGI.unescapeHTML(td.inner_html)}
    end
  end
  results
end

table = []
%w(basic extention).each do |x|
  uri = "http://www.nttdocomo.co.jp/service/imode/make/content/pictograph/#{x}/index.html"
  table += parse(URI(uri).read.toutf8)
end


open("lib/jpmobile/mobile/z_emoji_docomo.rb","w") do |f|
  f.puts "Jpmobile::Filter::Emoji::DOCOMO_UNICODE_TO_SJIS = {"
  table.each do |row|
    f.puts "  0x%s=>0x%s, "%[row[3], row[1]]
  end
  f.puts "}"
  f.puts "Jpmobile::Filter::Emoji::DOCOMO_SJIS_TO_UNICODE = {"
  table.each do |row|
    f.puts "  0x%s=>0x%s, "%[row[1], row[3]]
  end
  f.puts "}"
end
