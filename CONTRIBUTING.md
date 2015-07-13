# CONTRIBUTING
## 環境構築方法
jpmobile-ipaddressesとjpmobile-terminfoのgemをインストールしていない場合。

```
$ git clone git@github.com:jpmobile/jpmobile.git
$ bundle install
$ cd vendor
$ git clone git@github.com:jpmobile/jpmobile-ipaddresses.git
$ git clone git@github.com:jpmobile/jpmobile-terminfo.git
```

## テスト
テストにはSMTP通信を行うものも含まれるため、
[koseki-mocksmtpd](https://github.com/koseki/mocksmtpd)などの、
smtpdのmockを利用する必要があります。

### 必要なgemパッケージ
テストを実行するためには以下のgemパッケージが必要です。
* rails (include rack)
* sqlite3
* nokogiri
* rspec
* rspec-rails
* rspec-fixture
* rack-test
* mocha
* geokit
