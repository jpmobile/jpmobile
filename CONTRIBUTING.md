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

## SMTPサーバの準備
SMTP通信を行うテストが含まれており、現時点では[mailtrap](https://mailtrap.io/)を利用しています。

以下のように環境変数を設定してテストを実行してください。

```
export MAILTRAP_USERNAME=XXXXXXXXXXXXXX
export MAILTRAP_PASSWORD=YYYYYYYYYYYYYY
```

## テスト
以下のテストを通過する必要があります。


```
$ bundle exec rake test
$ bundle exec rubocop
```

### Railsでのテスト

```
$ bundle exec rake test:rails
```
