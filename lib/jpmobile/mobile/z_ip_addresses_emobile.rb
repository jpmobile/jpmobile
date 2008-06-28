# = IPアドレス帯域テーブル(手動更新分)
# == EMOBILE
# http://developer.emnet.ne.jp/ipaddress.html
# 2008/02/26現在

#:enddoc:

Jpmobile::Mobile::Emobile::IP_ADDRESSES = %w(
117.55.1.224/27
).map {|ip| IPAddr.new(ip) }
