require File.dirname(__FILE__)+'/helper'
require 'hpricot'

class FakeView
  include Jpmobile::Helpers
  def url_for(options={})
    return "http://example.jp"
  end
end

class HelpersTest < Test::Unit::TestCase
  def setup
    @view = FakeView.new
  end
  
  # get_position_link_to_がエラー無く終わるか。
  def test_get_position_link_to
    # TODO: もう少しまじめにテストする
    assert_nothing_raised {
      @view.get_position_link_to(:show_all=>true)
    }
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
      params = query.nil? ? nil : CGIMethods.parse_query_parameters(query)
      results << [link.inner_html, link.attributes, path, params]
    end
    return results
  end
end
