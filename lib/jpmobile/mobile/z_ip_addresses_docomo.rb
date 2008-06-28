# = IPアドレス帯域テーブル(手動更新分)
# == DoCoMo
# http://www.nttdocomo.co.jp/service/imode/make/content/ip/index.html
# 2006/09現在
Jpmobile::Mobile::Docomo::IP_ADDRESSES = %w(
210.153.84.0/24
210.136.161.0/24
210.153.86.0/24
).map {|ip| IPAddr.new(ip) }

