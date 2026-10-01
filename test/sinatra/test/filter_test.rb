if ENV['COVERAGE']
  require_relative '../../../spec/support/coverage'
  JpmobileCoverage.start('sinatra')
end

require 'guestbook'
require 'rack/test'
require 'test/unit'

class SinatraOnJpmobile < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Guestbook
  end

  def last_app
    SinatraTestHelper.instance.last_app
  end

  def test_view_selector_pc_then_smart_phone
    get '/top', {}, { 'HTTP_USER_AGENT' => 'Mozilla' }
    assert_equal 'PC', last_response.body.strip

    get '/top', {}, { 'HTTP_USER_AGENT' => 'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36' }
    assert_equal 'SMART PHONE', last_response.body.strip
  end

  def test_view_selector_smart_phone_then_pc
    get '/top', {}, { 'HTTP_USER_AGENT' => 'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36' }
    assert_equal 'SMART PHONE', last_response.body.strip

    get '/top', {}, { 'HTTP_USER_AGENT' => 'Mozilla' }
    assert_equal 'PC', last_response.body.strip
  end
end
