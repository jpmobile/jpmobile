require File.dirname(__FILE__)+'/helper'
require 'hpricot'

class FakeView
  include Jpmobile::Helpers
  def initialize
    @requiest = nil
  end
  def url_for(options={})
    return "http://example.jp"
  end
  attr_accessor :request
end

class HelpersTest < Test::Unit::TestCase
  def setup
    @view = FakeView.new
  end

  # get_position_link_to_がエラー無く終わるか。
  def test_get_position_link_to_show_all
    assert_nothing_raised {
      @view.get_position_link_to(:show_all=>true)
    }
  end

  # get_position_link_to(自動判別), DoCoMo
  def test_get_position_link_to_docomo
    @view.request = request_with_ua("DoCoMo/2.0 SH903i(c100;TB;W24H16)").first
    links = get_href_and_texts(@view.get_position_link_to("STRING"))
    assert_equal(1, links.size)
    text,attrs,path,params = links.first
    assert_equal("STRING", text)
    assert_equal("http://example.jp", path)
    assert(attrs.include?("lcs"))
  end

  # get_position_link_to(自動判別), TUKA
  def test_get_position_link_to_tuka
    @view.request = request_with_ua("UP.Browser/3.04-KCTA UP.Link/3.4.5.9").first
    links = get_href_and_texts(@view.get_position_link_to("STRING"))
    assert(links.empty?)
  end

  # get_position_link_to(自動判別), au, location only
  def test_get_position_link_to_au_location_only
    @view.request = request_with_ua("KDDI-SN26 UP.Browser/6.2.0.6.2 (GUI) MMP/2.0").first
    links = get_href_and_texts(@view.get_position_link_to("STRING"))
    assert_equal(1, links.size)
    text,attrs,path,params = links.first
    assert_equal("STRING", text)
    assert_equal("device:location", path)
    assert_equal("http://example.jp", params["url"])
  end

  # get_position_link_to(自動判別), au, gps
  def test_get_position_link_to_au_gps
    @view.request = request_with_ua("KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0").first
    links = get_href_and_texts(@view.get_position_link_to("STRING"))
    assert_equal(1, links.size)
    text,attrs,path,params = links.first
    assert_equal("STRING", text)
    assert_equal("device:gpsone", path)
    assert_equal("http://example.jp", params["url"])
    assert_equal("0", params["number"])
    assert_equal("0", params["acry"])
    assert_equal("1", params["ver"])
    assert_equal("0", params["unit"])
    assert_equal("0", params["datum"])
  end

  # get_position_link_to(自動判別), J-PHONE
  def test_get_position_link_to_jphone
    @view.request = request_with_ua("J-PHONE/4.3/V603SH/SNXXXX0000000 SH/0007aa Profile/MIDP-1.0 Configuration/CLDC-1.0 Ext-Profile/JSCL-1.3.2").first
    links = get_href_and_texts(@view.get_position_link_to("STRING"))
    assert_equal(1, links.size)
    text,attrs,path,params = links.first
    assert_equal("STRING", text)
    assert_equal("http://example.jp", path)
    assert(attrs.include?("z"))
  end

  # get_position_link_to(自動判別), Vodafone
  def test_get_position_link_to_vodafone
    @view.request = request_with_ua("Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0").first
    links = get_href_and_texts(@view.get_position_link_to("STRING"))
    assert_equal(1, links.size)
    text,attrs,path,params = links.first
    assert_equal("STRING", text)
    assert_equal("location:auto", path)
  end

  # get_position_link_to(自動判別), Softbank
  def test_get_position_link_to_softbank
    @view.request = request_with_ua("SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1").first
    links = get_href_and_texts(@view.get_position_link_to("STRING"))
    assert_equal(1, links.size)
    text,attrs,path,params = links.first
    assert_equal("STRING", text)
    assert_equal("location:auto", path)
  end

  # get_position_link_to(自動判別), Willcom
  def test_get_position_link_to_willcom
    @view.request = request_with_ua("Mozilla/3.0(WILLCOM;KYOCERA/WX310K/2;1.2.2.16.000000/0.1/C100) Opera 7.0").first
    links = get_href_and_texts(@view.get_position_link_to("STRING"))
    assert_equal(1, links.size)
    text,attrs,path,params = links.first
    assert_equal("STRING", text)
    assert_equal("http://location.request/dummy.cgi", path)
    assert_equal("http://example.jp", params["my"])
    assert_equal("$location", params["pos"])
  end

  # DoCoMo 端末情報取得用のリンクが正しく出力されるか。
  def test_docomo_utn_link_to
    links = get_href_and_texts(@view.docomo_utn_link_to("STRING"))
    assert_equal(1, links.size)
    text,attrs,path,params = links.first
    assert_equal("STRING", text)
    assert_equal("http://example.jp", path)
    assert(attrs.include?("utn"))
  end

  # DoCoMo オープンiエリア取得用のリンクが正しく出力されるか。
  def test_docomo_openiarea_link_to
    links = get_href_and_texts(@view.docomo_openiarea_link_to("STRING"))
    assert_equal(1, links.size)
    text,attrs,path,params = links.first
    assert_equal("STRING", text)
    assert_equal("http://w1m.docomo.ne.jp/cp/iarea", path)
    assert_equal("OPENAREACODE", params["ecode"])
    assert_equal("OPENAREAKEY", params["msn"])
    assert_equal("1", params["posinfo"])
    assert_equal("http://example.jp", params["nl"])
  end

  # DoCoMo GPS取得用のリンクが正しく出力されるか。
  def test_docomo_foma_gps_link_to
    links = get_href_and_texts(@view.docomo_foma_gps_link_to("STRING"))
    assert_equal(1, links.size)
    text,attrs,path,params = links.first
    assert_equal("STRING", text)
    assert_equal("http://example.jp", path)
    assert(attrs.include?("lcs"))
  end

  # au簡易位置情報取得用のリンクが正しく出力されるか。
  def test_au_location_link_to
    links = get_href_and_texts(@view.au_location_link_to("STRING"))
    assert_equal(1, links.size)
    text,attrs,path,params = links.first
    assert_equal("STRING", text)
    assert_equal("device:location", path)
    assert_equal("http://example.jp", params["url"])
  end

  # au GPS位置情報取得用のリンクが正しく出力されるか。
  def test_au_gps_link_to
    links = get_href_and_texts(@view.au_gps_link_to("STRING"))
    assert_equal(1, links.size)
    text,attrs,path,params = links.first
    assert_equal("STRING", text)
    assert_equal("device:gpsone", path)
    assert_equal("http://example.jp", params["url"])
    assert_equal("0", params["number"])
    assert_equal("0", params["acry"])
    assert_equal("1", params["ver"])
    assert_equal("0", params["unit"])
    assert_equal("0", params["datum"])
  end

  # J-PHONE 位置情報取得用のリンクが正しく出力されるか。
  def test_jphone_location_link_to
    links = get_href_and_texts(@view.jphone_location_link_to("STRING"))
    assert_equal(1, links.size)
    text,attrs,path,params = links.first
    assert_equal("STRING", text)
    assert_equal("http://example.jp", path)
    assert(attrs.include?("z"))
  end

  # Softbank 3G 位置情報取得用のリンクが正しく出力されるか。
  def test_softbank_location_link_to
    links = get_href_and_texts(@view.softbank_location_link_to("STRING"))
    assert_equal(1, links.size)
    text,attrs,path,params = links.first
    assert_equal("STRING", text)
    assert_equal("location:auto", path)
  end

  # Willcom 位置情報取得用のリンクが正しく出力されるか。
  def test_willcom_location_link_to
    links = get_href_and_texts(@view.willcom_location_link_to("STRING"))
    assert_equal(1, links.size)
    text,attrs,path,params = links.first
    assert_equal("STRING", text)
    assert_equal("http://location.request/dummy.cgi", path)
    assert_equal("http://example.jp", params["my"])
    assert_equal("$location", params["pos"])
  end

  private
  # 文字列 +str+ 中に含まれるリンクについて、
  # リンクテキスト、属性のHash、URLのqueryをのぞいた部分、ueryをHashにしたもの
  # の3要素からなる配列の配列で返す。
  def get_href_and_texts(str)
    results = []
    (Hpricot(str)/:a).each do |link|
      path, query = link["href"].split(/\?/, 2)
      params = query.nil? ? nil : ActionController::AbstractRequest.parse_query_parameters(query)
      results << [link.inner_html, link.attributes, path, params]
    end
    return results
  end
end
