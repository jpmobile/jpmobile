#!/usr/bin/env ruby -Ku
# willcomのwebページからIPリストを抽出する場当たり的なスクリプト。

require 'kconv'
require 'open-uri'
require 'pp'

src = open("http://www.willcom-inc.com/ja/service/contents_service/club_air_edge/for_phone/ip/index.html").read.toutf8

ips = src.scan(/(\d+\.\d+\.\d+\.\d+\/\d+)/).flatten

# 書き出し
open("lib/jpmobile/mobile/z_ip_addresses_willcom.rb","w") do |f|
  f.puts "Jpmobile::Mobile::Willcom::IP_ADDRESSES ="
  f.puts "#{ips.pretty_inspect.chomp }.map {|ip| IPAddr.new(ip) }"
end
