#!/usr/bin/env ruby -Ku
# willcomのwebページからIPリストを抽出する場当たり的なスクリプト。

require 'kconv'
require 'open-uri'

src = open("http://www.willcom-inc.com/ja/service/contents_service/club_air_edge/for_phone/ip/index.html").read.toutf8

src =~ /削除IPアドレス/

s = $`
ips = s.scan(/(\d+\.\d+\.\d+\.\d+\/\d+)/).flatten

puts ips
