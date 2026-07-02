require 'guestbook'
require 'rack/test'
require 'test/unit'

class SinatraOnJpmobile < Test::Unit::TestCase
  include Rack::Test::Methods

  IPHONE_USER_AGENT = 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; ja-jp) ' \
                      'AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16'.freeze

  def app
    Guestbook
  end

  def last_app
    SinatraTestHelper.instance.last_app
  end

  def test_pc_get
    get '/', { g: '万葉' }, {}
    assert_equal last_response.body, '万葉'
  end

  def test_pc_post
    post '/', { p: 'けーたい' }, {}
    assert_equal last_response.body, 'けーたい'
  end

  def test_view_selector_pc
    get '/top', {}, { 'HTTP_USER_AGENT' => 'Mozilla' }
    assert_equal last_response.body.strip, 'PC'
  end

  def test_view_selector_smart_phone
    get '/top', {}, { 'HTTP_USER_AGENT' => IPHONE_USER_AGENT }
    assert_equal last_response.body.strip, 'SMARTPHONE'
  end
end
