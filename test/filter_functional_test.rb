require File.dirname(__FILE__)+'/helper'

class FilterTestControllerBase < ActionController::Base
  def abracadabra
    render :text=>"アブラカダブラ"
  end
  def query
    @q = params[:q]
    render :text=>@q
  end
  def binary
    send_data "アブラカダブラ"
  end
  def xhtml
    response.content_type = "application/xhtml+xml"
    render :text=>"アブラカダブラ"
  end
end

class FilterTestController < FilterTestControllerBase
  mobile_filter
end

class HankakuFilterTestController < FilterTestControllerBase
  mobile_filter :hankaku=>true
end

class FilterFunctionalTestOutput < Test::Unit::TestCase
  def setup
    init FilterTestController
  end
  def test_docomo
    user_agent "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
    get :abracadabra
    assert_equal "Shift_JIS", @response.charset
    assert_equal "\203A\203u\203\211\203J\203_\203u\203\211", @response.body # "アブラカダブラ", 全角, Shift_JIS
  end
end

class HankakuFilterFunctionalTestOutput < Test::Unit::TestCase
  def setup
    init HankakuFilterTestController
  end
  def test_pc
    get :abracadabra
    assert_equal "utf-8", @response.charset
    assert_equal "アブラカダブラ", @response.body
  end
  def test_docomo_binary
    user_agent "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
    get :binary
    assert_equal "アブラカダブラ", @response.body
  end
  def test_docomo_xhtml
    user_agent "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
    get :xhtml
    assert_equal "Shift_JIS", @response.charset
    assert_equal "\261\314\336\327\266\300\336\314\336\327", @response.body # "アブラカダブラ", 半角, Shift_JIS
  end
  def test_docomo
    user_agent "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
    get :abracadabra
    assert_equal "Shift_JIS", @response.charset
    assert_equal "\261\314\336\327\266\300\336\314\336\327", @response.body # "アブラカダブラ", 半角, Shift_JIS
  end
  def test_jphone
    user_agent "J-PHONE/3.0/V301D"
    get :abracadabra
    assert_equal "Shift_JIS", @response.charset
    assert_equal "\261\314\336\327\266\300\336\314\336\327", @response.body # "アブラカダブラ", 半角, Shift_JIS
  end
  def test_au
    user_agent "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0"
    get :abracadabra
    assert_equal "Shift_JIS", @response.charset
    assert_equal "\261\314\336\327\266\300\336\314\336\327", @response.body # "アブラカダブラ", 半角, Shift_JIS
  end
  def test_softbank
    user_agent "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
    get :abracadabra
    assert_equal "utf-8", @response.charset
    assert_equal "ｱﾌﾞﾗｶﾀﾞﾌﾞﾗ", @response.body
  end
  def test_vodafone
    user_agent "Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0"
    get :abracadabra
    assert_equal "utf-8", @response.charset
    assert_equal "ｱﾌﾞﾗｶﾀﾞﾌﾞﾗ", @response.body
  end
end

class FilterFunctionalTestInput < Test::Unit::TestCase
  def setup
    init FilterTestController
  end
  def test_docomo
    user_agent "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
    get :query, :q=>"アブラカダブラ".tosjis
    assert_equal "アブラカダブラ", assigns["q"]
    get :query, :q=>"\261\314\336\327\266\300\336\314\336\327"
    assert_equal "ｱﾌﾞﾗｶﾀﾞﾌﾞﾗ", assigns["q"]
  end
end

class HankakuFilterFunctionalTestInput < Test::Unit::TestCase
  def setup
    init HankakuFilterTestController
  end
  def test_pc
    get :query, :q=>"アブラカダブラ"
    assert_equal "アブラカダブラ", assigns["q"]
  end
  def test_docomo
    user_agent "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
    get :query, :q=>"アブラカダブラ".tosjis
    assert_equal "アブラカダブラ", assigns["q"]
    get :query, :q=>"\261\314\336\327\266\300\336\314\336\327"
    assert_equal "アブラカダブラ", assigns["q"]
  end
  def test_jphone
    user_agent "J-PHONE/3.0/V301D"
    get :query, :q=>"アブラカダブラ".tosjis
    assert_equal "アブラカダブラ", assigns["q"]
    get :query, :q=>"\261\314\336\327\266\300\336\314\336\327"
    assert_equal "アブラカダブラ", assigns["q"]
  end
  def test_au
    user_agent "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0"
    get :query, :q=>"アブラカダブラ".tosjis
    assert_equal "アブラカダブラ", assigns["q"]
    get :query, :q=>"\261\314\336\327\266\300\336\314\336\327"
    assert_equal "アブラカダブラ", assigns["q"]
  end
  def test_softbank
    user_agent "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
    get :query, :q=>"アブラカダブラ"
    assert_equal "アブラカダブラ", assigns["q"]
    get :query, :q=>"ｱﾌﾞﾗｶﾀﾞﾌﾞﾗ"
    assert_equal "アブラカダブラ", assigns["q"]
  end
  def test_vodafone
    user_agent "Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0"
    get :query, :q=>"アブラカダブラ"
    assert_equal "アブラカダブラ", assigns["q"]
  end
end
