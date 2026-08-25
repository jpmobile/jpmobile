[![CI](https://github.com/jpmobile/jpmobile/actions/workflows/ci.yml/badge.svg)](https://github.com/jpmobile/jpmobile/actions/workflows/ci.yml)

# jpmobile: A Rails plugin for Japanese mobile-phones

## jpmobileとは

スマートフォン・タブレット特有の機能を Rails や Rack middleware で利用するためのプラグイン。以下の機能を備える。

* スマートフォン・タブレットの判別
    * User-Agent による判別に加え、HTTP Client Hints (`Sec-CH-UA-Mobile`,
      `Sec-CH-UA-Platform`) による判別に対応。Client Hints が送信されている場合は
      User-Agent より優先して判定する。
* Rails のビューへの自動振分け

他のバージョンの Rails については [Versions : Jpmobile vs
Rails](https://github.com/jpmobile/jpmobile/wiki/Version-:-Jpmobile-vs-Rails)
を参照。

なお、フィーチャーフォン（ガラケー）関連の機能（キャリア判別、絵文字・文字コード変換、
位置情報・端末情報の取得、Trans SID、キャリアメール送受信など）は削除されました。

### 旧バージョンからのアップグレード

フィーチャーフォン関連機能の削除に伴い、以下の設定メソッドも削除されました。
`config/initializers/jpmobile.rb` などでこれらを呼び出していると `NoMethodError`
が発生するため、アップグレード時に該当する設定を削除してください。

* `config.jpmobile.mobile_filter`
* `config.jpmobile.form_accept_charset_conversion`
* `config.jpmobile.smart_phone_emoticon_compatibility`
* `config.jpmobile.session_store`

## インストール

### gemでインストールする場合

```shell
% gem install jpmobile
```

## 使用例

### 端末の識別

環境変数 `ENV['rack.jpmobile']` に端末クラスのインスタンスが格納されています。
`Rack::Request#mobile` としても取得可能です。

```ruby
case request.mobile
when Jpmobile::Mobile::Iphone
  # for iPhone
when Jpmobile::Mobile::Android
  # for Android
else
  # for PC
end
```

あるいは

```ruby
if request.mobile.is_a?(Jpmobile::Mobile::Iphone)
  # for iPhone
end
```

#### ビューの中で一部を切替える例

```ruby
<% if request.smart_phone? %>
  スマートフォンからのアクセスです。
<% else %>
  スマートフォンからのアクセスではありません。
<% end %>

<% if request.tablet? %>
  タブレットからのアクセスです。
<% else %>
  タブレットからのアクセスではありません。
<% end %>
```

#### 別に用意したスマートフォン用コントローラへリダイレクトする例

```ruby
class PcController < ApplicationController
  before_action :redirect_if_smart_phone

  def index
  end

  private

  def redirect_if_smart_phone
    return unless request.smart_phone?

    new_params = params.dup
    new_params[:controller] = '/smart_phone'
    redirect_to new_params
  end
end

class SmartPhoneController < ApplicationController
end
```

#### Client Hints による識別

モダンブラウザは `Sec-CH-UA-Mobile` / `Sec-CH-UA-Platform` ヘッダー（HTTP Client
Hints）を送信できる。jpmobile はこれらが存在する場合、User-Agent より優先して
端末判別に使用する。

| `Sec-CH-UA-Platform` | `Sec-CH-UA-Mobile` | 判定結果 |
|---|---|---|
| `"iOS"` | `?1` | `Jpmobile::Mobile::Iphone` |
| `"iOS"` | `?0` | `Jpmobile::Mobile::Ipad` |
| `"Android"` | `?1` | `Jpmobile::Mobile::Android` |
| `"Android"` | `?0` | `Jpmobile::Mobile::AndroidTablet` |

`Jpmobile::MobileCarrier` ミドルウェアはレスポンスに以下のヘッダーを付与し、
ブラウザに Client Hints の送信を要求する。

```
Accept-CH: Sec-CH-UA-Mobile, Sec-CH-UA-Platform
```

初回リクエストでは Client Hints がまだ送信されないため、User-Agent による判別にフォールバックする。

### ビューの自動振り分け

ビューの自動振り分けを行うには、以下の設定が必要です。

```ruby
class ApplicationController < ActionController::Base
  include Jpmobile::ViewSelector
end
```

iPhone からアクセスすると、次の順でテンプレートを検索し、最初に見付かったテンプレートを利用する。

* `index_smart_phone_iphone.html.erb`
* `index_smart_phone.html.erb`
* `index.html.erb`

Android の場合は `index_smart_phone_android.html.erb`、Windows Phone の場合は
`index_smart_phone_windows_phone.html.erb` が最初に検索される。

iPad からアクセスすると、次の順でテンプレートを検索する。

* `index_tablet_ipad.html.erb`
* `index_tablet.html.erb`
* `index.html.erb`

自動振り分けを無効化するには、アクションにおいて以下のように設定する。

```ruby
def index
  disable_mobile_view!
end
```

### アクション定義の省略

Rails では、アクション名に対応するテンプレートが存在する場合、アクション用のメソッド定義を省略できる。
しかし、端末向けテンプレートしか存在しないアクションの場合、jpmobile ではメソッド定義が必要になる。

```ruby
class MyController < ApplicationController
  include Jpmobile::MethodLessActionSupport
end
```

### Sinatra で使う場合

```ruby
require 'jpmobile'
require 'jpmobile/sinatra'

class App < Jpmobile::Sinatra::Base
  use Jpmobile::MobileCarrier

  get '/' do
    erb :index
  end
end
```

## jpmobileの開発方法

jpmobileの開発に関しては
[こちら](https://github.com/jpmobile/jpmobile/blob/main/CONTRIBUTING.md) へ

## リンク

* http://jpmobile-rails.org

## 作者

Copyright 2006-2012 (c) Yoji Shidara, under MIT License.

Shin-ichiro OGAWA <rust.stnard@gmail.com>, Yoji Shidara <dara@shidara.net>
