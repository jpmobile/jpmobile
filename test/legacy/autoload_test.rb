require File.expand_path(File.dirname(__FILE__)) + '/helper'

module Jpmobile
  module Mobile
    require 'jpmobile/mobile/abstract_mobile'
  end
end

class TestAutoLoad < Test::Unit::TestCase
  def test_display_info_docomo
    require 'jpmobile/mobile/docomo'
    assert_nothing_raised { Jpmobile::Mobile::Docomo::DISPLAY_INFO }
    assert_kind_of(Hash, Jpmobile::Mobile::Docomo::DISPLAY_INFO)
  end
end
