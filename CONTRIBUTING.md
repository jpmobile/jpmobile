# CONTRIBUTING
## 環境構築方法

```
$ git clone git@github.com:jpmobile/jpmobile.git
$ bundle install
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
