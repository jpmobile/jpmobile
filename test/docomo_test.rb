require File.dirname(__FILE__)+'/helper'

class DocomoTest < Test::Unit::TestCase
  # DoCoMo, 端末種別の識別
  def test_docomo_sh902i
    reqs = request_with_ua("DoCoMo/2.0 SH902i(c100;TB;W24H12)")
    reqs.each do |req|
      assert_equal(true, req.mobile?)
      assert_instance_of(Jpmobile::Mobile::Docomo, req.mobile)
      assert_equal(nil, req.mobile.position)
      assert_equal(nil, req.mobile.areacode)
      assert_equal(nil, req.mobile.serial_number)
      assert_equal(nil, req.mobile.icc)
      assert_equal(nil, req.mobile.ident)
      assert_equal(nil, req.mobile.ident_device)
      assert_equal(nil, req.mobile.ident_subscriber)
      assert(!req.mobile.supports_cookie?)
    end
  end

  # DoCoMo, 端末種別の識別
  def test_docomo_so506i
    reqs = request_with_ua("DoCoMo/1.0/SO506iC/c20/TB/W20H10")
    reqs.each do |req|
      assert_equal(true, req.mobile?)
      assert_instance_of(Jpmobile::Mobile::Docomo, req.mobile)
      assert_equal(nil, req.mobile.position)
      assert_equal(nil, req.mobile.areacode)
      assert_equal(nil, req.mobile.serial_number)
      assert_equal(nil, req.mobile.icc)
      assert_equal(nil, req.mobile.ident)
      assert_equal(nil, req.mobile.ident_device)
      assert_equal(nil, req.mobile.ident_subscriber)
    end
  end

  # DoCoMo, iarea
  def test_docomo_iarea
    reqs = request_with_ua("DoCoMo/1.0/SO506iC/c20/TB/W20H10",
                          {"QUERY_STRING"=>"AREACODE=00100&ACTN=OK"})
    reqs.each do |req|
      assert_equal("00100", req.mobile.areacode)
    end
  end

  # DoCoMo, iarea
  def test_docomo_iarea_with_posinfo
    reqs = request_with_ua("DoCoMo/1.0/SO506iC/c20/TB/W20H10",
                          {"QUERY_STRING"=>"LAT=%2B35.00.35.600&LON=%2B135.41.35.600&GEO=wgs84&POSINFO=2&AREACODE=00100&ACTN=OK"})
    reqs.each do |req|
      assert_equal("00100", req.mobile.areacode)
      assert_in_delta(35.00988889, req.mobile.position.lat, 1e-7)
      assert_in_delta(135.6932222, req.mobile.position.lon, 1e-7)
    end
  end

  # DoCoMo, gps
  # http://www.nttdocomo.co.jp/service/imode/make/content/html/outline/gps.html
  def test_docomo_gps_sa702i
    reqs = request_with_ua("DoCoMo/2.0 SA702i(c100;TB;W30H15)",
                          {"QUERY_STRING"=>"lat=%2B35.00.35.600&lon=%2B135.41.35.600&geo=wgs84&x-acc=3"})
    reqs.each do |req|
      assert_in_delta(35.00988889, req.mobile.position.lat, 1e-7)
      assert_in_delta(135.6932222, req.mobile.position.lon, 1e-7)
    end
  end

  # DoCoMo, 903i, GPS
  # "WGS84"が大文字。altで高度が取得できているようだ。どちらも仕様書には記述がない。
  # http://www.nttdocomo.co.jp/service/imode/make/content/html/outline/gps.html
  def test_docomo_gps_sh903i
    reqs = request_with_ua("DoCoMo/2.0 SH903i(c100;TB;W24H16)",
                          {"QUERY_STRING"=>
                           "lat=%2B35.00.35.600&lon=%2B135.41.35.600&geo=WGS84&alt=%2B64.000&x-acc=1"})
    reqs.each do |req|
      assert_in_delta(35.00988889, req.mobile.position.lat, 1e-7)
      assert_in_delta(135.6932222, req.mobile.position.lon, 1e-7)
    end
  end

  # DoCoMo, utn, mova
  def test_docomo_utn_mova
    reqs = request_with_ua("DoCoMo/1.0/SO505iS/c20/TC/W30H16/serXXXXX000000")
    reqs.each do |req|
      assert_equal("XXXXX000000", req.mobile.serial_number)
      assert_equal("XXXXX000000", req.mobile.ident)
      assert_equal(nil, req.mobile.icc)
      assert_equal("XXXXX000000", req.mobile.ident_device)
      assert_equal(nil, req.mobile.ident_subscriber)
    end
  end

  # DoCoMo, utn, foma
  def test_docomo_utn_foma
    reqs = request_with_ua("DoCoMo/2.0 D902i(c100;TB;W23H16;ser999999999999999;icc0000000000000000000f)")
    reqs.each do |req|
      assert_equal("999999999999999", req.mobile.serial_number)
      assert_equal("0000000000000000000f", req.mobile.icc)
      assert_equal("0000000000000000000f", req.mobile.ident)
      assert_equal("999999999999999", req.mobile.ident_device)
      assert_equal("0000000000000000000f", req.mobile.ident_subscriber)
    end
  end

  # 正しいIPアドレス空間からのアクセスを判断できるか。
  def test_docomo_valid_ip_address
    reqs = request_with_ua("DoCoMo/2.0 SH902i(c100;TB;W24H12)",
                          {"REMOTE_ADDR"=>"210.153.84.1"})
    reqs.each do |req|
      assert_equal(true, req.mobile.valid_ip?)
    end
  end

  # 正しくないIPアドレス空間からのアクセスを判断できるか。
  def test_docomo_invalid_ip_address
    reqs = request_with_ua("DoCoMo/2.0 SH902i(c100;TB;W24H12)",
                          {"REMOTE_ADDR"=>"127.0.0.1"})
    reqs.each do |req|
      assert_equal(false, req.mobile.valid_ip?)
    end
  end

  # 端末の画面サイズを正しく取得できるか。
  def test_docomo_so506ic_display
    reqs = request_with_ua("DoCoMo/1.0/SO506iC/c20/TB/W20H10")
    reqs.each do |req|
      assert_equal(240, req.mobile.display.browser_width)
      assert_equal(256, req.mobile.display.browser_height)
      assert_equal(240, req.mobile.display.width)
      assert_equal(256, req.mobile.display.height)
      assert_equal(true, req.mobile.display.color?)
      assert_equal(262144, req.mobile.display.colors)
    end
  end

  # 端末の画面サイズを正しく取得できるか。
  def test_docomo_sh902i_display
    reqs = request_with_ua("DoCoMo/2.0 SH902i(c100;TB;W24H12)")
    reqs.each do |req|
      assert_equal(240, req.mobile.display.browser_width)
      assert_equal(240, req.mobile.display.browser_height)
      assert_equal(240, req.mobile.display.width)
      assert_equal(240, req.mobile.display.height)
      assert_equal(true, req.mobile.display.color?)
      assert_equal(262144, req.mobile.display.colors)
    end
  end
end
