# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
require 'nokogiri'

describe Jpmobile::Helpers do
  # 文字列 +str+ 中に含まれるリンクについて、
  # リンクテキスト、属性のHash、URLのqueryをのぞいた部分、ueryをHashにしたもの
  # の3要素からなる配列の配列で返す。
  def get_href_and_texts(str)
    results = []
    (Nokogiri::HTML.parse(str)/"a").each do |link|
      path, query = link["href"].split(/\?/, 2)
      params = query.nil? ? nil : Rack::Utils.parse_query(query)
      results << [link.inner_html, link.attributes, path, params]
    end
    return results
  end

  it "get_position_link_to_がエラー無く終わるか" do
    lambda {
      get "/links/show_all", {}, {"HTTP_USER_AGENT" => "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"}
    }.should_not raise_error
  end

  context "docomo で" do
    it "get_position_link_to が正常に表示されること" do
      get "/links/link", {}, { "HTTP_USER_AGENT" => "DoCoMo/2.0 SH903i(c100;TB;W24H16)"}
      links = get_href_and_texts(body)

      links.size.should == 1
      text, attrs, path, params = links.first
      text.should == "STRING"
      path.should == "http://www.example.com/links/link"
      body.should =~ /lcs>/
    end

    it "docomo_utn_link_to が正しく出力されること" do
      get "/links/docomo_utn", {}, {"HTTP_USER_AGENT" => "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"}
      links = get_href_and_texts(body)

      links.size.should == 1
      text, attrs, path, params = links.first
      text.should == "STRING"
      path.should == "http://www.example.com/links/docomo_utn"
      body.should =~ /utn>/
    end

    it "オープンiエリア取得用のリンクが正しく出力されること" do
      get "/links/docomo_openiarea", {}, {"HTTP_USER_AGENT" => "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"}
      links = get_href_and_texts(body)

      links.size.should == 1
      text, attrs, path, params = links.first
      text.should == "STRING"
      path.should == "http://w1m.docomo.ne.jp/cp/iarea"
      params["ecode"].should   == "OPENAREACODE"
      params["msn"].should     == "OPENAREAKEY"
      params["posinfo"].should == "1"
      params["nl"].should      == "http://www.example.com/links/docomo_openiarea"
    end

    it "GPS取得用のリンクが正しく出力されること" do
      get "/links/docomo_foma_gps", {}, {"HTTP_USER_AGENT" => "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"}
      links = get_href_and_texts(body)

      links.size.should == 1
      text, attrs, path, params = links.first
      text.should == "STRING"
      path.should == "http://www.example.com/links/docomo_foma_gps"
      body.should =~ /lcs>/
    end
  end

  context "au で" do
    # get_position_link_to(自動判別), au, location only
    def test_get_position_link_to_au_location_only
      get "/links/link", {}, {"HTTP_USER_AGENT" => "KDDI-SN26 UP.Browser/6.2.0.6.2 (GUI) MMP/2.0"}
      links = get_href_and_texts(body)
      assert_equal(1, links.size)
      text, attrs, path, params = links.first
      assert_equal("STRING", text)
      assert_equal("device:location", path)
      assert_equal("http://www.example.com/links/link", params["url"])
    end

    # get_position_link_to(自動判別), au, gps
    def test_get_position_link_to_au_gps
      get "/links/link", {}, {"HTTP_USER_AGENT" => "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0"}
      links = get_href_and_texts(body)
      assert_equal(1, links.size)
      text, attrs, path, params = links.first
      assert_equal("STRING", text)
      assert_equal("device:gpsone", path)
      assert_equal("http://www.example.com/links/link", params["url"])
      assert_equal("0", params["number"])
      assert_equal("0", params["acry"])
      assert_equal("1", params["ver"])
      assert_equal("0", params["unit"])
      assert_equal("0", params["datum"])
    end

    # au簡易位置情報取得用のリンクが正しく出力されるか。
    def test_au_location_link_to
      get "/links/au_location", {}, {"HTTP_USER_AGENT" => "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"}
      links = get_href_and_texts(body)
      assert_equal(1, links.size)
      text, attrs, path, params = links.first
      assert_equal("STRING", text)
      assert_equal("device:location", path)
      assert_equal("http://www.example.com/links/au_location", params["url"])
    end

    # au GPS位置情報取得用のリンクが正しく出力されるか。
    def test_au_gps_link_to
      get "/links/au_gps", {}, {"HTTP_USER_AGENT" => "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"}
      links = get_href_and_texts(body)
      assert_equal(1, links.size)
      text, attrs, path, params = links.first
      assert_equal("STRING", text)
      assert_equal("device:gpsone", path)
      assert_equal("http://www.example.com/links/au_gps", params["url"])
      assert_equal("0", params["number"])
      assert_equal("0", params["acry"])
      assert_equal("1", params["ver"])
      assert_equal("0", params["unit"])
      assert_equal("0", params["datum"])
    end
  end

  context "softbank で" do
    # get_position_link_to(自動判別), Vodafone
    def test_get_position_link_to_vodafone
      get "/links/link", {}, {"HTTP_USER_AGENT" => "Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0"}
      links = get_href_and_texts(body)
      assert_equal(1, links.size)
      text, attrs, path, params = links.first
      assert_equal("STRING", text)
      assert_equal("location:auto", path)
    end

    # get_position_link_to(自動判別), Softbank
    def test_get_position_link_to_softbank
      get "/links/link", {}, {"HTTP_USER_AGENT" => "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"}
      links = get_href_and_texts(body)
      assert_equal(1, links.size)
      text, attrs, path, params = links.first
      assert_equal("STRING", text)
      assert_equal("location:auto", path)
    end

    # Softbank 3G 位置情報取得用のリンクが正しく出力されるか。
    def test_softbank_location_link_to
      get "/links/softbank_location", {}, {"HTTP_USER_AGENT" => "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"}
      links = get_href_and_texts(body)
      assert_equal(1, links.size)
      text, attrs, path, params = links.first
      assert_equal("STRING", text)
      assert_equal("location:auto", path)
    end
  end

  context "willcom で" do
    # get_position_link_to(自動判別), Willcom
    def test_get_position_link_to_willcom
      get "/links/link", {}, {"HTTP_USER_AGENT" => "Mozilla/3.0(WILLCOM;KYOCERA/WX310K/2;1.2.2.16.000000/0.1/C100) Opera 7.0"}
      links = get_href_and_texts(body)
      assert_equal(1, links.size)
      text, attrs, path, params = links.first
      assert_equal("STRING", text)
      assert_equal("http://location.request/dummy.cgi", path)
      assert_equal("http://www.example.com/links/link", params["my"])
      assert_equal("$location", params["pos"])
    end

    # Willcom 位置情報取得用のリンクが正しく出力されるか。
    def test_willcom_location_link_to
      get "/links/willcom_location", {}, {"HTTP_USER_AGENT" => "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"}
      links = get_href_and_texts(body)
      assert_equal(1, links.size)
      text, attrs, path, params = links.first
      assert_equal("STRING", text)
      assert_equal("http://location.request/dummy.cgi", path)
      assert_equal("http://www.example.com/links/willcom_location", params["my"])
      assert_equal("$location", params["pos"])
    end
  end
end
