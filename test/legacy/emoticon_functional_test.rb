require File.dirname(__FILE__)+'/helper'

class EmoticonTestController < ActionController::Base
  mobile_filter
  def docomo_cr
    render :text=>"&#xE63E;"
  end
  def docomo_utf8
    render :text=>[0xe63e].pack("U")
  end
  def docomo_docomopoint
    render :text=>"&#xE6D5;"
  end
  def au_cr
    render :text=>"&#xE488;"
  end
  def au_utf8
    render :text=>[0xe488].pack("U")
  end
  def softbank_cr
    render :text=>"&#xF04A;"
  end
  def softbank_utf8
    render :text=>[0xf04a].pack("U")
  end
  def query
    @q = params[:q]
    render :text=>@q
  end
end

class EmoticonFunctionalTest < Test::Unit::TestCase
  def setup
    init EmoticonTestController
  end

  def test_docomo_from_pc
    # PC
    get :docomo_cr
    assert_equal "&#xE63E;", @response.body
    get :docomo_utf8
    assert_equal "\xee\x98\xbe", @response.body
  end

  def test_docomo_from_docomo
    # DoCoMo携帯
    user_agent "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
    get :docomo_cr
    assert_equal "\xf8\x9f", @response.body
    get :docomo_utf8
    assert_equal "\xf8\x9f", @response.body
    get :query, :q=>"\xf8\x9f"
    assert_equal "\xee\x98\xbe", assigns["q"]
    assert_equal "\xf8\x9f", @response.body

    get :docomo_docomopoint
    assert_equal "\xf9\x79", @response.body
  end

  def test_docomo_from_au
    # Au携帯電話での閲覧
    user_agent "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0"
    get :docomo_cr
    assert_equal "\xf6\x60", @response.body
    get :docomo_utf8
    assert_equal "\xf6\x60", @response.body
    get :docomo_docomopoint
    assert_equal "［ドコモポイント］".tosjis, @response.body
  end

  def test_docomo_from_softbank
    # SoftBank携帯電話での閲覧
    user_agent "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
    get :docomo_cr
    assert_equal "\e$Gj\x0f", @response.body
    get :docomo_utf8
    assert_equal "\e$Gj\x0f", @response.body
    get :docomo_docomopoint
    assert_equal "［ドコモポイント］", @response.body
  end

  def test_docomo_from_jphone
    # J-PHONE携帯電話での閲覧
    user_agent "J-PHONE/3.0/V301D"
    get :docomo_cr
    assert_equal "\e$Gj\x0f", @response.body
    get :docomo_utf8
    assert_equal "\e$Gj\x0f", @response.body
    get :docomo_docomopoint
    assert_equal "Shift_JIS", @response.charset
    assert_equal "［ドコモポイント］".tosjis, @response.body
  end

  def test_au_from_pc
    # PC
    get :au_cr
    assert_equal "&#xE488;", @response.body
    get :au_utf8
    assert_equal [0xe488].pack("U"), @response.body
  end

  def test_au_from_au
    # Au
    user_agent "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0"
    get :au_cr
    assert_equal "\xf6\x60", @response.body
    get :au_utf8
    assert_equal "\xf6\x60", @response.body
    get :query, :q=>"\xf6\x60"
    assert_equal [0xe488].pack("U"), assigns["q"]
    assert_equal "\xf6\x60", @response.body
  end

  def test_au_from_docomo
    # DoCoMo携帯電話での閲覧
    user_agent "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
    get :au_cr
    assert_equal "\xf8\x9f", @response.body
    get :au_utf8
    assert_equal "\xf8\x9f", @response.body
  end

  def test_au_from_softbank
    # SoftBank携帯電話での閲覧
    user_agent "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
    get :au_cr
    assert_equal "\e$Gj\x0f", @response.body
    get :au_utf8
    assert_equal "\e$Gj\x0f", @response.body
  end

  def test_softbank_from_pc
    # PCから
    get :softbank_cr
    assert_equal "&#xF04A;", @response.body
    get :softbank_utf8
    assert_equal [0xf04a].pack("U"), @response.body
  end

  def test_softbank_from_softbank
    # SoftBank携帯電話から
    user_agent "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
    get :softbank_cr
    assert_equal "\e$Gj\x0f", @response.body
    get :softbank_utf8
    assert_equal "\e$Gj\x0f", @response.body
    get :query, :q=>[0xe04A].pack("U") # 3G端末はUTF-8で絵文字を送ってくる
    assert_equal [0xf04a].pack("U"), assigns["q"]
    assert_equal "\e$Gj\x0f", @response.body
  end

  def test_softbank_from_vodafone3g
    # Vodafone3G携帯電話から
    user_agent "Vodafone/1.0/V705SH/SHJ001/SN000000000000000 Browser/VF-NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
    get :softbank_cr
    assert_equal "\e$Gj\x0f", @response.body
    get :softbank_utf8
    assert_equal "\e$Gj\x0f", @response.body
    get :query, :q=>[0xe04A].pack("U") # 3G端末はUTF-8で絵文字を送ってくる
    assert_equal [0xf04a].pack("U"), assigns["q"]
    assert_equal "\e$Gj\x0f", @response.body
  end

  def test_softbank_from_jphone
    # J-PHONE携帯電話から
    user_agent "J-PHONE/3.0/V301D"
    get :softbank_cr
    assert_equal "\e$Gj\x0f", @response.body
    get :softbank_utf8
    assert_equal "\e$Gj\x0f", @response.body
    get :query, :q=>"\e$Gj\x0f" # J-PHONE端末はWebcodeで絵文字を送ってくる
    assert_equal [0xf04a].pack("U"), assigns["q"]
    assert_equal "\e$Gj\x0f", @response.body
  end

  def test_softbank_from_docomo
    # DoCoMo携帯電話での閲覧
    user_agent "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
    get :softbank_cr
    assert_equal "\xf8\x9f", @response.body
    get :softbank_utf8
    assert_equal "\xf8\x9f", @response.body
  end

  def test_softbank_from_au
    # Au携帯電話での閲覧
    user_agent "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0"
    get :softbank_cr
    assert_equal "\xf6\x60", @response.body
    get :softbank_utf8
    assert_equal "\xf6\x60", @response.body
  end
end
