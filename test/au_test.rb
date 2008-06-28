require File.dirname(__FILE__)+'/helper'

class AuTest < Test::Unit::TestCase
  # au, 端末種別の識別
  def test_au_ca32
    reqs = request_with_ua("KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0",
                          "HTTP_X_UP_SUBNO"=>"00000000000000_mj.ezweb.ne.jp")
    reqs.each do |req|
      assert_equal(true, req.mobile?)
      assert_instance_of(Jpmobile::Mobile::Au, req.mobile)
      assert_equal("00000000000000_mj.ezweb.ne.jp", req.mobile.subno)
      assert_equal("00000000000000_mj.ezweb.ne.jp", req.mobile.ident)
      assert_equal("00000000000000_mj.ezweb.ne.jp", req.mobile.ident_subscriber)
      assert_equal(nil, req.mobile.position)
      assert(req.mobile.supports_cookie?)
    end
  end

  # TuKa, 端末種別の識別
  def test_tuka_tk22
    reqs = request_with_ua("UP.Browser/3.04-KCTA UP.Link/3.4.5.9")
    reqs.each do |req|
      assert_equal(true, req.mobile?)
      assert_instance_of(Jpmobile::Mobile::Au, req.mobile)
    end
  end

  # au, gps, degree, wgs84
  def test_au_gps_degree
    reqs = request_with_ua("KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0",
                          {"QUERY_STRING"=>"ver=1&datum=0&unit=1&lat=%2b43.07772&lon=%2b141.34114&alt=64&time=20061016192415&smaj=69&smin=18&vert=21&majaa=115&fm=1"})
    reqs.each do |req|
      assert_equal(43.07772, req.mobile.position.lat)
      assert_equal(141.34114, req.mobile.position.lon)
    end
  end

  # au, gps, dms, wgs84
  # これが一番端末を選ばないようだ
  # http://hiyuzawa.jpn.org/blog/2006/09/gps1_augps_1.html
  def test_au_gps_dms
    reqs = request_with_ua("KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0",
                          {"QUERY_STRING"=>"ver=1&datum=0&unit=0&lat=%2b43.05.08.95&lon=%2b141.20.25.99&alt=155&time=20060521010328&smaj=76&smin=62&vert=65&majaa=49&fm=1"})
    reqs.each do |req|
      assert_in_delta(43.08581944, req.mobile.position.lat, 1e-7)
      assert_in_delta(141.3405528, req.mobile.position.lon, 1e-7)
    end
  end

  # au, gps, degree, tokyo
  def test_au_gps_degree_tokyo
    reqs = request_with_ua("KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0",
                          {"QUERY_STRING"=>"ver=1&datum=1&unit=1&lat=%2b43.07475&lon=%2b141.34259&alt=8&time=20061017182825&smaj=113&smin=76&vert=72&majaa=108&fm=1"})
    reqs.each do |req|
      assert_in_delta(43.07719289, req.mobile.position.lat, 1e-4)
      assert_in_delta(141.3389013, req.mobile.position.lon, 1e-4)
    end
  end

  # au, gps, dms, tokyo
  def test_au_gps_dms_tokyo
    reqs = request_with_ua("KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0",
                          {"QUERY_STRING"=>"ver=1&datum=1&unit=0&lat=%2b43.04.28.26&lon=%2b141.20.33.15&alt=-5&time=20061017183807&smaj=52&smin=36&vert=31&majaa=101&fm=1"})
    reqs.each do |req|
      assert_in_delta(43.07695833, req.mobile.position.lat, 1e-4)
      assert_in_delta(141.3388528, req.mobile.position.lon, 1e-4)
    end
  end

  # au, antenna, dms (au簡易位置情報)
  def test_au_antenna
    reqs = request_with_ua("KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0",
                          {"QUERY_STRING"=>"datum=tokyo&unit=dms&lat=43.04.55.00&lon=141.20.50.75"})
    reqs.each do |req|
      assert_in_delta(43.08194444, req.mobile.position.lat, 1e-7)
      assert_in_delta(141.3474306, req.mobile.position.lon, 1e-7)
    end
  end

  # 正しいIPアドレス空間からのアクセスを判断できるか。
  def test_au_valid_ip_address
    reqs = request_with_ua("KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0",
                          {"REMOTE_ADDR"=>"210.169.40.1"})
    reqs.each do |req|
      assert_equal(req.mobile.valid_ip?, true)
    end
  end

  # 正しくないIPアドレス空間からのアクセスを判断できるか。
  def test_au_invalid_ip_address
    reqs = request_with_ua("KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0",
                          {"REMOTE_ADDR"=>"127.0.0.1"})
    reqs.each do |req|
      assert_equal(req.mobile.valid_ip?, false)
    end
  end

  # 端末の画面サイズを正しく取得できるか。
  def test_au_w41ca_display
    reqs = request_with_ua("KDDI-CA33 UP.Browser/6.2.0.10.4 (GUI) MMP/2.0",
                          "HTTP_X_UP_DEVCAP_SCREENDEPTH"=>"16,RGB565",
                          "HTTP_X_UP_DEVCAP_SCREENPIXELS"=>"240,346",
                          "HTTP_X_UP_DEVCAP_ISCOLOR"=>"1"
                          )

    reqs.each do |req|
      assert_equal(240, req.mobile.display.width)
      assert_equal(346, req.mobile.display.height)
      assert_equal(true, req.mobile.display.color?)
      assert_equal(65536, req.mobile.display.colors)
    end
  end

  # 端末の画面情報が渡ってない場合に正しく動作するか。
  def test_au_w41ca_display_information_omitted
    reqs = request_with_ua("KDDI-CA33 UP.Browser/6.2.0.10.4 (GUI) MMP/2.0")
    reqs.each do |req|
      assert_equal(nil, req.mobile.display.width)
      assert_equal(nil, req.mobile.display.height)
      assert_equal(nil, req.mobile.display.browser_width)
      assert_equal(nil, req.mobile.display.browser_height)
      assert_equal(nil, req.mobile.display.physical_width)
      assert_equal(nil, req.mobile.display.physical_height)
      assert_equal(nil, req.mobile.display.color?)
      assert_equal(nil, req.mobile.display.colors)
    end
  end

  # for GeoKit::Mappable
  def test_au_gps_degree_geokit
    reqs = request_with_ua("KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0",
                          {"QUERY_STRING"=>"ver=1&datum=0&unit=1&lat=%2b43.07772&lon=%2b141.34114&alt=64&time=20061016192415&smaj=69&smin=18&vert=21&majaa=115&fm=1"})
    reqs.each do |req|
      assert_equal(43.07772, req.mobile.position.lat)
      assert_equal(141.34114, req.mobile.position.lng)
      assert_equal("43.07772,141.34114", req.mobile.position.ll)
      assert_equal(req.mobile.position, req.mobile.position)
      if req.mobile.position.respond_to?(:distance_to) # GeoKitがインストールされている場合
        assert_equal(0, req.mobile.position.distance_to(req.mobile.position))
      end
    end
  end
  
  # 位置情報取得機能の有無, W31CA
  def test_au_location_capability_w31ca
    reqs = request_with_ua("KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0")
    reqs.each do |req|
      assert_equal("CA32", req.mobile.device_id)
      assert_equal(true, req.mobile.supports_location?)
      assert_equal(true, req.mobile.supports_gps?)
    end
  end

  # 位置情報取得機能の有無, A1402S
  def test_au_location_capability_a1402s
    reqs = request_with_ua("KDDI-SN26 UP.Browser/6.2.0.6.2 (GUI) MMP/2.0")
    reqs.each do |req|
      assert_equal("SN26", req.mobile.device_id)
      assert_equal(true, req.mobile.supports_location?)
      assert_equal(false, req.mobile.supports_gps?)
    end
  end

  # 位置情報取得機能の有無, TK22
  def test_au_location_capability_tk22
    reqs = request_with_ua("UP.Browser/3.04-KCTA UP.Link/3.4.5.9")
    reqs.each do |req|
      assert_equal("KCTA", req.mobile.device_id)
      assert_equal(false, req.mobile.supports_location?)
      assert_equal(false, req.mobile.supports_gps?)
    end
  end
end
