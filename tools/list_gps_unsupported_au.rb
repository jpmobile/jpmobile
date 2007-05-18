
require 'open-uri'

html = URI('http://www.au.kddi.com/ezfactory/tec/spec/4_4.html').read
array = html.scan %r{<td bgcolor="#f2f2f2"><div class="TableText">(.+?)</div></td>.*?<td><div class="TableText">(.+?)</div></td>}m


gps_unsupported = []
array.each do |pair|
  pair.map! {|x| x.gsub(/<br>|&nbsp;/,"")}
  next if pair.first.empty? || pair.last.empty?
  name = pair.first
  devids = pair.last.split(/\//)

  case name
  when /^T[DKSTP]/, /^[AC]1\d\d\d/, /^C\d\d\d[^\d]/, "B01K"
    gps_unsupported |= devids
  else
    gps_supported |= devids
  end
end

p gps_unsupported
