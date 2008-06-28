# = IPアドレス帯域テーブル(手動更新分)
# == SoftBank
# http://developers.softbankmobile.co.jp/dp/tech_svc/web/ip.php
# 2007/10/09現在
Jpmobile::Mobile::Softbank::IP_ADDRESSES = %w(
123.108.236.0/24
123.108.237.0/27
202.179.204.0/24
202.253.96.224/27
210.146.7.192/26
210.146.60.192/26
210.151.9.128/26
210.169.130.112/28
210.175.1.128/25
210.228.189.0/24
211.8.159.128/25
).map {|ip| IPAddr.new(ip) }
