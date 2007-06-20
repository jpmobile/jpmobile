require File.dirname(__FILE__)+'/helper'

class DocomoPictogramTest < Test::Unit::TestCase
  def test_docomo_sjis_unicodecr
    assert_equal "&#xe63e;", Jpmobile::Pictogram::sjis_to_unicodecr("\xf8\x9f")
  end
  def test_docomo_unicodecr_sjis
    assert_equal "\xf8\x9f", Jpmobile::Pictogram::unicodecr_to_sjis("&#xe63e;")
  end
  def test_docomo_unicodecr_utf8
    assert_equal "\356\230\276", Jpmobile::Pictogram::unicodecr_to_utf8("&#xe63e;")
  end
  def test_docomo_utf8_unicodecr
    assert_equal "&#xe63e;", Jpmobile::Pictogram::utf8_to_unicodecr("\356\230\276")
  end
end

class AuPictogramTest < Test::Unit::TestCase
  def test_au_sjis_unicodecr
    assert_equal "&#xe481;", Jpmobile::Pictogram::sjis_to_unicodecr("\xf6\x59")
  end
  def test_au_unicodecr_sjis
    assert_equal "\xf6\x59", Jpmobile::Pictogram::unicodecr_to_sjis("&#xe481;")
  end
  def test_au_unicodecr_utf8
    assert_equal "\356\222\201", Jpmobile::Pictogram::unicodecr_to_utf8("&#xe481;")
  end
  def test_au_utf8_unicodecr
    assert_equal "&#xe481;", Jpmobile::Pictogram::utf8_to_unicodecr("\356\222\201")
  end
end

class SoftbankPictogramTest < Test::Unit::TestCase
  def test_softbank_webcode_cr
    assert_equal "&#xe001;", Jpmobile::Pictogram::softbank_webcode_cr("\x1b$G!\x0f")
    assert_equal "&#xe001;&#xe001;", Jpmobile::Pictogram::softbank_webcode_cr("\x1b$G!!\x0f")
    assert_equal "&#xf001;", Jpmobile::Pictogram::softbank_webcode_cr("\x1b$G!\x0f", true)
  end
  def test_softbank_cr_webcode
    assert_equal "\x1b$G!\x0f", Jpmobile::Pictogram::softbank_cr_webcode("&#xe001;")
    assert_equal "\x1b$G!\x0f", Jpmobile::Pictogram::softbank_cr_webcode("&#xf001;", true)
  end
  def test_softbank_cr_utf8
    assert_equal "\xee\x80\x81", Jpmobile::Pictogram::softbank_cr_utf8("&#xe001;")
    assert_equal "\xee\x80\x81", Jpmobile::Pictogram::softbank_cr_utf8("&#xf001;", true)
  end
  def test_softbank_utf8_cr
    assert_equal "&#xe001;", Jpmobile::Pictogram::softbank_utf8_cr("\xee\x80\x81")
    assert_equal "&#xf001;", Jpmobile::Pictogram::softbank_utf8_cr("\xee\x80\x81", true)
  end
end
