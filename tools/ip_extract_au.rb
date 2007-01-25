#!/usr/bin/env ruby -Ku
# auのwebページからIPリストを抽出する場当たり的なスクリプト。

require 'kconv'
require 'open-uri'

src = open("http://www.au.kddi.com/ezfactory/tec/spec/ezsava_ip.html").read.toutf8

ips = []
src.scan(/(\d+[.．]\d+[.．]\d+[.．]\d+).*?(\/\d+)/m) {|a,b|
  ips << a.gsub(/．/,".") + b
}

puts ips
