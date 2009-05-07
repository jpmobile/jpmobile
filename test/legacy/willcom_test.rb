require File.dirname(__FILE__)+'/helper'

class WillcomTest < Test::Unit::TestCase
  # willcom, 端末種別の識別
  def test_wilcom_wx310k
    reqs = request_with_ua("Mozilla/3.0(WILLCOM;KYOCERA/WX310K/2;1.2.2.16.000000/0.1/C100) Opera 7.0")
    reqs.each do |req|
      assert_equal(true, req.mobile?)
      assert_instance_of(Jpmobile::Mobile::Willcom, req.mobile)
      assert_equal(nil, req.mobile.position)
      assert_equal(nil, req.mobile.ident)
      assert(req.mobile.supports_cookie?)
    end
  end

  # DDI-POCKET, 端末種別の識別
  def test_ddipocket_ah_k3001v
    reqs = request_with_ua("Mozilla/3.0(DDIPOCKET;KYOCERA/AH-K3001V/1.8.2.71.000000/0.1/C100) Opera 7.0")
    reqs.each do |req|
      assert_equal(true, req.mobile?)
      assert_instance_of(Jpmobile::Mobile::Ddipocket, req.mobile)
      assert_kind_of(Jpmobile::Mobile::Willcom, req.mobile)
      assert_equal(nil, req.mobile.position)
      assert_equal(nil, req.mobile.ident)
      assert(req.mobile.supports_cookie?)
    end
  end

  # willcom, antenna
  def test_wilcom_antenna
    reqs = request_with_ua("Mozilla/3.0(WILLCOM;KYOCERA/WX310K/2;1.2.2.16.000000/0.1/C100) Opera 7.0",
                          {"QUERY_STRING"=>"pos=N43.04.34.049E141.21.03.279"})
    reqs.each do |req|
      assert_in_delta(43.078568, req.mobile.position.lat, 1e-4)
      assert_in_delta(141.347223, req.mobile.position.lon, 1e-4)
    end
  end

  # 正しいIPアドレス空間からのアクセスを判断できるか。
  def test_willcom_valid_ip_address
    reqs = request_with_ua("Mozilla/3.0(WILLCOM;KYOCERA/WX310K/2;1.2.2.16.000000/0.1/C100) Opera 7.0",
                          {"REMOTE_ADDR"=>"61.198.142.1"})
    reqs.each do |req|
      assert_equal(req.mobile.valid_ip?, true)
    end
  end

  # 正しくないIPアドレス空間からのアクセスを判断できるか。
  def test_willcom_invalid_ip_address
    reqs = request_with_ua("Mozilla/3.0(WILLCOM;KYOCERA/WX310K/2;1.2.2.16.000000/0.1/C100) Opera 7.0",
                          {"REMOTE_ADDR"=>"127.0.0.1"})
    reqs.each do |req|
      assert_equal(req.mobile.valid_ip?, false)
    end
  end
end
