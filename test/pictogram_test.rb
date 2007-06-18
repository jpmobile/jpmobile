require File.dirname(__FILE__)+'/helper'

class DocomoPictogramTest < Test::Unit::TestCase
  def test_docomo_sjis_cr
    assert_equal "&#xe63e;", Jpmobile::Pictogram::docomo_sjis_cr("\xf8\x9f")
  end
  def test_docomo_cr_sjis
    assert_equal "\xf8\x9f", Jpmobile::Pictogram::docomo_cr_sjis("&#xe63e;")
  end
  def test_docomo_cr_utf8
    assert_equal "\356\230\276", Jpmobile::Pictogram::docomo_cr_utf8("&#xe63e;")
  end
  def test_docomo_utf8_cr
    assert_equal "&#xe63e;", Jpmobile::Pictogram::docomo_utf8_cr("\356\230\276")
  end
end

class AuPictogramTest < Test::Unit::TestCase
  def test_au_sjis_cr
    assert_equal "&#xe481;", Jpmobile::Pictogram::au_sjis_cr("\xf6\x59")
  end
  def test_au_cr_sjis
    assert_equal "\xf6\x59", Jpmobile::Pictogram::au_cr_sjis("&#xe481;")
  end
  def test_au_cr_utf8
    assert_equal "\356\222\201", Jpmobile::Pictogram::au_cr_utf8("&#xe481;")
  end
  def test_au_utf8_cr
    assert_equal "&#xe481;", Jpmobile::Pictogram::au_utf8_cr("\356\222\201")
  end
end
