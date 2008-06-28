require 'test/unit'
module Jpmobile
  module Mobile
    require 'jpmobile/mobile/abstract_mobile'
  end
end

class TestAutoLoad < Test::Unit::TestCase
  def test_ip_addresses_docomo
    require 'jpmobile/mobile/docomo'
    assert_nothing_raised { Jpmobile::Mobile::Docomo::IP_ADDRESSES }
    assert_kind_of(Array, Jpmobile::Mobile::Docomo::IP_ADDRESSES)
  end

  def test_display_info_docomo
    require 'jpmobile/mobile/docomo'
    assert_nothing_raised { Jpmobile::Mobile::Docomo::DISPLAY_INFO }
    assert_kind_of(Hash, Jpmobile::Mobile::Docomo::DISPLAY_INFO)
  end

  def test_ip_addresses_au
    require 'jpmobile/mobile/au'
    assert_nothing_raised { Jpmobile::Mobile::Au::IP_ADDRESSES }
    assert_kind_of(Array, Jpmobile::Mobile::Au::IP_ADDRESSES)
  end

  def test_ip_addresses_softbank
    require 'jpmobile/mobile/softbank'
    assert_nothing_raised { Jpmobile::Mobile::Softbank::IP_ADDRESSES }
    assert_nothing_raised { Jpmobile::Mobile::Vodafone::IP_ADDRESSES }
    assert_nothing_raised { Jpmobile::Mobile::Jphone::IP_ADDRESSES }
    assert_kind_of(Array, Jpmobile::Mobile::Softbank::IP_ADDRESSES)
    assert_kind_of(Array, Jpmobile::Mobile::Vodafone::IP_ADDRESSES)
    assert_kind_of(Array, Jpmobile::Mobile::Jphone::IP_ADDRESSES)
  end

  def test_ip_addresses_willcom
    require 'jpmobile/mobile/willcom'
    assert_nothing_raised { Jpmobile::Mobile::Willcom::IP_ADDRESSES }
    assert_kind_of(Array, Jpmobile::Mobile::Willcom::IP_ADDRESSES)
  end

  def test_ip_addresses_emobile
    require 'jpmobile/mobile/emobile'
    assert_nothing_raised { Jpmobile::Mobile::Emobile::IP_ADDRESSES }
    assert_kind_of(Array, Jpmobile::Mobile::Emobile::IP_ADDRESSES)
  end

end
