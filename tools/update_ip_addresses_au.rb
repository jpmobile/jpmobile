#!/usr/bin/env ruby -Ku
# auのwebページからIPリストを抽出する場当たり的なスクリプト。

require 'kconv'
require 'open-uri'
require 'pp'

src = open("http://www.au.kddi.com/ezfactory/tec/spec/ezsava_ip.html").read.toutf8

ips = []
src.scan(/(\d+[.．]\d+[.．]\d+[.．]\d+).*?(\/\d+)/m) {|a,b|
  ips << a.gsub(/．/,".") + b
}

# 書き出し
open("lib/jpmobile/mobile/z_ip_addresses_au.rb","w") do |f|
  f.puts "Jpmobile::Mobile::Au::IP_ADDRESSES = "
  f.puts "#{ips.pretty_inspect.chomp }.map {|ip| IPAddr.new(ip) }"
end
