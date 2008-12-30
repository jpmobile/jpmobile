#!/usr/bin/env ruby -Ku
# willcomのwebページからIPリストを抽出する場当たり的なスクリプト。

require 'kconv'
require 'open-uri'
require 'pp'

src = open("http://www.willcom-inc.com/ja/service/contents_service/create/center_info/index.html").read.toutf8

src.sub!(%r{^.*<b>Webアクセス時のIPアドレス帯域</b>(.+?)</table>.*$}m, '\\1')
ips = src.scan(/(\d+\.\d+\.\d+\.\d+\/\d+)/).flatten

# 書き出し
open("lib/jpmobile/mobile/z_ip_addresses_willcom.rb","w") do |f|
  f.puts "Jpmobile::Mobile::Willcom::IP_ADDRESSES ="
  f.puts "#{ips.pretty_inspect.chomp }.map {|ip| IPAddr.new(ip) }"
end
