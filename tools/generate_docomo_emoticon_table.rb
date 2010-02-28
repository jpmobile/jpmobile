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


open(File.dirname(__FILE__)+"/../lib/jpmobile/emoticon/docomo.rb","w") do |f|
  f.puts "Jpmobile::Emoticon::DOCOMO_SJIS_TO_UNICODE = {"
  table.each do |row|
    f.puts "  0x%s=>0x%s, "%[row[1], row[3]]
  end
  f.puts "}.freeze"
  f.puts "Jpmobile::Emoticon::DOCOMO_UNICODE_TO_SJIS = Jpmobile::Emoticon::DOCOMO_SJIS_TO_UNICODE.invert.freeze"
end
