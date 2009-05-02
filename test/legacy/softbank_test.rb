require File.dirname(__FILE__)+'/helper'

class SoftbankTest < Test::Unit::TestCase
  # SoftBank, 端末種別の識別
  def test_softbank_910t
    reqs = request_with_ua("SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1")
    reqs.each do |req|
      assert_equal(true, req.mobile?)
      assert_instance_of(Jpmobile::Mobile::Softbank, req.mobile)
      assert_kind_of(Jpmobile::Mobile::Softbank, req.mobile)
      assert_equal(nil, req.mobile.position)
      assert_equal("000000000000000", req.mobile.serial_number)
      assert_equal("000000000000000", req.mobile.ident)
      assert_equal("000000000000000", req.mobile.ident_device)
      assert_equal(nil, req.mobile.ident_subscriber)
      assert(req.mobile.supports_cookie?)
    end
  end

  # SoftBank, X_JPHONE_UID付き
  def test_softbank_910t_x_jphone_uid
    reqs = request_with_ua("SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1", "HTTP_X_JPHONE_UID"=>"aaaaaaaaaaaaaaaa")
    reqs.each do |req|
      assert_equal("000000000000000", req.mobile.serial_number)
      assert_equal("aaaaaaaaaaaaaaaa", req.mobile.x_jphone_uid)
      assert_equal("aaaaaaaaaaaaaaaa", req.mobile.ident)
      assert_equal("000000000000000", req.mobile.ident_device)
      assert_equal("aaaaaaaaaaaaaaaa", req.mobile.ident_subscriber)
      assert(req.mobile.supports_cookie?)
    end
  end

  # Vodafone, 端末種別の識別
  def test_vodafone_v903t
    reqs = request_with_ua("Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0")
    reqs.each do |req|
      assert_equal(true, req.mobile?)
      assert_instance_of(Jpmobile::Mobile::Vodafone, req.mobile)
      assert_kind_of(Jpmobile::Mobile::Softbank, req.mobile)
      assert_equal(nil, req.mobile.position)
      assert_equal(nil, req.mobile.ident)
      assert(req.mobile.supports_cookie?)
    end
  end

  # Vodafone, 端末種別の識別
  def test_vodafone_v903sh
    reqs = request_with_ua("Vodafone/1.0/V903SH/SHJ001/SN000000000000000 Browser/UP.Browser/7.0.2.1 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0")
    reqs.each do |req|
      assert_equal(true, req.mobile?)
      assert_instance_of(Jpmobile::Mobile::Vodafone, req.mobile)
      assert_kind_of(Jpmobile::Mobile::Softbank, req.mobile)
      assert_equal("000000000000000", req.mobile.serial_number)
      assert_equal("000000000000000", req.mobile.ident)
      assert_equal("000000000000000", req.mobile.ident_device)
      assert_equal(nil, req.mobile.ident_subscriber)
      assert_equal(nil, req.mobile.position)
      assert(req.mobile.supports_cookie?)
    end
  end

  # J-PHONE, 端末種別の識別
  def test_jphone_v603sh
    reqs = request_with_ua("J-PHONE/4.3/V603SH/SNXXXX0000000 SH/0007aa Profile/MIDP-1.0 Configuration/CLDC-1.0 Ext-Profile/JSCL-1.3.2")
    reqs.each do |req|
      assert_equal(true, req.mobile?)
      assert_instance_of(Jpmobile::Mobile::Jphone, req.mobile)
      assert_kind_of(Jpmobile::Mobile::Softbank, req.mobile)
      assert_equal("XXXX0000000", req.mobile.serial_number)
      assert_equal("XXXX0000000", req.mobile.ident)
      assert_equal("XXXX0000000", req.mobile.ident_device)
      assert_equal(nil, req.mobile.ident_subscriber)
      assert_equal(nil, req.mobile.position)
      assert(!req.mobile.supports_cookie?)
    end
  end

  # J-PHONE, 端末種別の識別
  def test_jphone_v301d
    reqs = request_with_ua("J-PHONE/3.0/V301D")
    reqs.each do |req|
      assert_equal(true, req.mobile?)
      assert_instance_of(Jpmobile::Mobile::Jphone, req.mobile)
      assert_kind_of(Jpmobile::Mobile::Softbank, req.mobile)
      assert_equal(nil, req.mobile.serial_number)
      assert_equal(nil, req.mobile.position)
      assert(!req.mobile.supports_cookie?)
    end
  end

  # J-PHONE
  # http://kokogiko.net/wiki.cgi?page=vodafone%A4%C7%A4%CE%B0%CC%C3%D6%BC%E8%C6%C0%CA%FD%CB%A1
  def test_jphone_antenna
    reqs = request_with_ua("J-PHONE/3.0/V301D",
                          "HTTP_X_JPHONE_GEOCODE"=>"353840%1A1394440%1A%93%8C%8B%9E%93s%8D%60%8B%E6%8E%C5%82T%92%9A%96%DA")
    reqs.each do |req|
      assert_in_delta(35.64768482, req.mobile.position.lat, 1e-4)
      assert_in_delta(139.7412141, req.mobile.position.lon, 1e-4)
      assert_equal("東京都港区芝５丁目", req.mobile.position.options["address"])
    end
  end

  # J-PHONE 位置情報なし
  def test_jphone_antenna_empty
    reqs = request_with_ua("J-PHONE/3.0/V301D",
                          "HTTP_X_JPHONE_GEOCODE"=>"0000000%1A0000000%1A%88%CA%92%75%8F%EE%95%F1%82%C8%82%B5")
    reqs.each do |req|
      assert_equal(nil, req.mobile.position)
    end
  end

  # Vodafone 3G, wgs84, gps
  def test_vodafone_gps
    reqs = request_with_ua("Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0",
                          {"QUERY_STRING"=>"pos=N43.3.18.42E141.21.1.88&geo=wgs84&x-acr=1"})
    reqs.each do |req|
      assert_in_delta(43.05511667, req.mobile.position.lat, 1e-7)
      assert_in_delta(141.3505222, req.mobile.position.lon, 1e-7)
      assert_equal("N43.3.18.42E141.21.1.88", req.mobile.position.options["pos"])
      assert_equal("wgs84", req.mobile.position.options["geo"])
      assert_equal("1", req.mobile.position.options["x-acr"])
    end
  end

  # 正しいIPアドレス空間からのアクセスを判断できるか。
  def test_softbank_valid_ip_address
    reqs = request_with_ua("Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0",
                          {"REMOTE_ADDR"=>"202.179.204.1"})
    reqs.each do |req|
      assert_equal(true, req.mobile.valid_ip?)
    end
  end

  # 正しいIPアドレス空間からのアクセスを判断できるか。
  def test_jphone_valid_ip_address
    reqs = request_with_ua("J-PHONE/3.0/V301D",
                          {"REMOTE_ADDR"=>"202.179.204.1"})
    reqs.each do |req|
      assert_equal(true, req.mobile.valid_ip?)
    end
  end

  # 正しくないIPアドレス空間からのアクセスを判断できるか。
  def test_softbank_ip_address
    reqs = request_with_ua("Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0",
                          {"REMOTE_ADDR"=>"127.0.0.1"})
    reqs.each do |req|
      assert_equal(false, req.mobile.valid_ip?)
    end
  end

  # 端末の画面サイズを正しく取得できるか。
  def test_softbank_v903t_display
    reqs = request_with_ua("Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0",
                          "HTTP_X_JPHONE_DISPLAY"=>"240*320",
                          "HTTP_X_JPHONE_COLOR"=>"C262144" )
    reqs.each do |req|
      assert_equal(240, req.mobile.display.width)
      assert_equal(320, req.mobile.display.height)
      assert_equal(240, req.mobile.display.physical_width)
      assert_equal(320, req.mobile.display.physical_height)
      assert_equal(true, req.mobile.display.color?)
      assert_equal(262144, req.mobile.display.colors)
    end
  end

  # 端末の画面情報が渡ってない場合に正しく動作するか。
  def test_softbank_v903t_display_information_omitted
    reqs = request_with_ua("Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0")
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
end
