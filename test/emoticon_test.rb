require File.dirname(__FILE__)+'/helper'

class DocomoEmoticonTest < Test::Unit::TestCase
  def test_docomo_external_unicodecr
    assert_equal "&#xe63e;", Jpmobile::Emoticon::external_to_unicodecr("\xf8\x9f")
  end
  def test_docomo_unicodecr_external
    assert_equal "\xf8\x9f", Jpmobile::Emoticon::unicodecr_to_external("&#xe63e;")
  end
  def test_docomo_unicodecr_utf8
    assert_equal "\356\230\276", Jpmobile::Emoticon::unicodecr_to_utf8("&#xe63e;")
  end
  def test_docomo_utf8_unicodecr
    assert_equal "&#xe63e;", Jpmobile::Emoticon::utf8_to_unicodecr("\356\230\276")
  end
end

class AuEmoticonTest < Test::Unit::TestCase
  def test_au_external_unicodecr
    assert_equal "&#xe481;", Jpmobile::Emoticon::external_to_unicodecr("\xf6\x59")
  end
  def test_au_unicodecr_external
    assert_equal "\xf6\x59", Jpmobile::Emoticon::unicodecr_to_external("&#xe481;")
  end
  def test_au_unicodecr_utf8
    assert_equal "\356\222\201", Jpmobile::Emoticon::unicodecr_to_utf8("&#xe481;")
  end
  def test_au_utf8_unicodecr
    assert_equal "&#xe481;", Jpmobile::Emoticon::utf8_to_unicodecr("\356\222\201")
  end
end

class SoftbankEmoticonTest < Test::Unit::TestCase
  def test_softbank_webcode_cr
    assert_equal "&#xf001;&#xf001;", Jpmobile::Emoticon::external_to_unicodecr("\x1b$G!!\x0f")
  end
  def test_softbank_cr_webcode
    assert_equal "\x1b$G!\x0f", Jpmobile::Emoticon::unicodecr_to_external("&#xf001;")
  end
  def test_softbank_cr_utf8
    assert_equal "\xef\x80\x81", Jpmobile::Emoticon::unicodecr_to_utf8("&#xf001;")
  end
  def test_softbank_utf8_cr
    assert_equal "&#xf001;", Jpmobile::Emoticon::utf8_to_unicodecr("\xef\x80\x81")
  end
end
