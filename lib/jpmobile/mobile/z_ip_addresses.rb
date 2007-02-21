# = IPアドレス帯域テーブル(手動更新分)
# == DoCoMo
# http://www.nttdocomo.co.jp/service/imode/make/content/ip/about/
# 2006/09現在
# == SoftBank
# http://developers.softbankmobile.co.jp/dp/tech_svc/web/ip.php
# 2006/11/17現在

#:enddoc:
Jpmobile::Mobile::Docomo::IP_ADDRESSES = <<EOF
210.153.84.0/24
210.136.161.0/24
210.153.86.0/24
EOF

Jpmobile::Mobile::Softbank::IP_ADDRESSES=<<EOF
202.179.204.0/24
202.253.96.248/29
210.146.7.192/26
210.146.60.192/26
210.151.9.128/26
210.169.130.112/29
210.169.130.120/29
210.169.176.0/24
210.175.1.128/25
210.228.189.0/24
211.8.159.128/25
EOF
