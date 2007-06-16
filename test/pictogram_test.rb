require File.dirname(__FILE__)+'/helper'

class PictogramTest < Test::Unit::TestCase
  def test_docomo_sjis_er
    assert_equal "&#xe63e;", Jpmobile::Pictogram::docomo_sjis_er("\xf8\x9f")
  end
  def test_docomo_er_sjis
    assert_equal "\xf8\x9f", Jpmobile::Pictogram::docomo_er_sjis("&#xe63e;")
  end
  def test_docomo_er_utf8
    assert_equal "\356\230\276", Jpmobile::Pictogram::docomo_er_utf8("&#xe63e;")
  end
  def test_docomo_utf8_er
    assert_equal "&#xe63e;", Jpmobile::Pictogram::docomo_utf8_er("\356\230\276")
  end
end
