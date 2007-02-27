require File.dirname(__FILE__)+'/helper'

class JpmobileTest < Test::Unit::TestCase
  def test_ie
    req = request_with_ua("Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)")
    assert_equal(false, req.mobile?)
  end
end
