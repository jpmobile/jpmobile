# User-Agent Client Hints Carrier の使用例

# Rails での使用例
# config/application.rb
class Application < Rails::Application
  # Client Hints ベースの検出を使用
  config.middleware.use Jpmobile::ClientHintsCarrier
  config.middleware.use Jpmobile::Rack::ParamsFilter
  config.middleware.use Jpmobile::Rack::Filter
end

# または従来の User-Agent ベースと併用
# config/application.rb
class Application < Rails::Application
  # まず Client Hints で試行し、フォールバックで User-Agent を使用
  config.middleware.use Jpmobile::ClientHintsCarrier
  config.middleware.use Jpmobile::Rack::ParamsFilter  
  config.middleware.use Jpmobile::Rack::Filter
end

# Sinatra での使用例
require 'jpmobile'
require 'jpmobile/rack'

use Jpmobile::ClientHintsCarrier
use Jpmobile::Rack::ParamsFilter
use Jpmobile::Rack::Filter

get '/' do
  case request.mobile
  when Jpmobile::Mobile::Android
    "Android device detected via Client Hints"
  when Jpmobile::Mobile::Iphone  
    "iPhone detected via Client Hints"
  when Jpmobile::Mobile::Ipad
    "iPad detected via Client Hints"
  when Jpmobile::Mobile::AndroidTablet
    "Android Tablet detected via Client Hints"
  else
    "PC or unknown device"
  end
end

# Client Hints を有効にするためのレスポンスヘッダー設定例
# Rails の場合: config/application.rb
class Application < Rails::Application
  config.force_ssl = true # HTTPS が必要
  
  # Client Hints を要求するヘッダーを設定
  config.middleware.insert_before 0, Rack::ClientHintsHeaders
end

# Client Hints ヘッダーを設定するミドルウェア例
class Rack::ClientHintsHeaders
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    
    # Client Hints を要求するヘッダーを追加
    headers['Accept-CH'] = 'Sec-CH-UA, Sec-CH-UA-Mobile, Sec-CH-UA-Platform, Sec-CH-UA-Model, Sec-CH-UA-Full-Version-List'
    headers['Critical-CH'] = 'Sec-CH-UA-Mobile, Sec-CH-UA-Platform'
    
    [status, headers, response]
  end
end