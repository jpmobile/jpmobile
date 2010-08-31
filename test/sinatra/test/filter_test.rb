# -*- coding: utf-8 -*-
require 'guestbook'
require 'rack/test'
require 'test/unit'

class SinatraOnJpmobile < Test::Unit::TestCase
  include Rack::Test::Methods
  include Jpmobile::Util

  def app
    Guestbook
  end

  def last_app
    SinatraTestHelper.instance.last_app
  end

  def test_not_convert_pc_get
    get '/', {:g => Jpmobile::Util.sjis("万葉")}, {}
    assert_equal last_response.body, "万葉"
  end

  def test_not_convert_pc_post
    post '/', {:p => Jpmobile::Util.utf8("けーたい")}, {}
    assert_equal last_response.body, "けーたい"
  end

  def test_docomo_get_convert_to_utf8
    get '/', {:g => utf8_to_sjis("万葉")}, {"HTTP_USER_AGENT" => "DoCoMo/2.0 SH902i(c100;TB;W24H12)"}
    assert_equal last_app.assigns(:g), "万葉"
    assert_equal last_response.body, utf8_to_sjis("万葉")
  end

  def test_docomo_post_convert_to_utf8
    post '/', {:p => utf8_to_sjis("けーたい")}, {"HTTP_USER_AGENT" => "DoCoMo/2.0 SH902i(c100;TB;W24H12)"}
    assert_equal last_app.assigns(:p), "けーたい"
    assert_equal last_response.body, utf8_to_sjis("けーたい")
  end
end
