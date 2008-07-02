# =位置情報等を要求するヘルパー
module Jpmobile
  # 携帯電話端末に位置情報を要求するための、特殊なリンクを出力するヘルパー群。
  # 多くのキャリアでは特殊なFORMでも位置情報を要求できる。
  module Helpers
    # 位置情報(緯度経度がとれるもの。オープンiエリアをのぞく)要求するリンクを作成する。
    # 位置情報を受け取るページを +url_for+ に渡す引数の形式で +options+ に指定する。
    # :show_all => +true+ とするとキャリア判別を行わず全てキャリアのリンクを返す。
    # 第1引数に文字列を与えるとその文字列をアンカーテキストにする。
    # 第1引数がHashの場合はデフォルトのアンカーテキストを出力する。
    def get_position_link_to(str=nil, options={})
      if str.is_a?(Hash)
        options = str
        str = nil
      end
      options = options.symbolize_keys
      show_all = options.delete(:show_all)

      # TODO: コード汚い
      s = []
      if show_all || request.mobile.instance_of?(Mobile::Docomo)
        s << docomo_foma_gps_link_to(str||"DoCoMo FOMA(GPS)", options)
      end
      if show_all || request.mobile.instance_of?(Mobile::Au)
        if show_all || request.mobile.supports_gps?
          s << au_gps_link_to(str||"au(GPS)", options)
        end
        if show_all || (!(request.mobile.supports_gps?) && request.mobile.supports_location?)
          s << au_location_link_to(str||"au(antenna)", options)
        end
      end
      if show_all || request.mobile.instance_of?(Mobile::Jphone)
        s << jphone_location_link_to(str||"Softbank(antenna)", options)
      end
      if show_all || request.mobile.instance_of?(Mobile::Vodafone) || request.mobile.instance_of?(Mobile::Softbank)
        s << softbank_location_link_to(str||"Softbank 3G(GPS)", options)
      end
      if show_all || request.mobile.instance_of?(Mobile::Willcom)
        s << willcom_location_link_to(str||"Willcom", options)
      end
      return s.join("<br />\n")
    end

    # DoCoMo FOMAでGPS位置情報を取得するためのリンクを返す。
    def docomo_foma_gps_link_to(str, options={})
      options = options.symbolize_keys
      options[:only_path] = false
      return %{<a href="#{url_for(options)}" lcs>#{str}</a>}
    end

    # DoCoMoでオープンiエリアを取得するためのURLを返す。
    def docomo_openiarea_url_for(options={})
      options = options.symbolize_keys
      options[:only_path] = false
      posinfo = options.delete(:posinfo) || "1" # 基地局情報を元に測位した緯度経度情報を要求　
      "http://w1m.docomo.ne.jp/cp/iarea?ecode=OPENAREACODE&msn=OPENAREAKEY&posinfo=#{posinfo}&nl=#{CGI.escape(url_for(options))}"
    end

    # DoCoMoでオープンiエリアを取得するためのリンクを返す。
    def docomo_openiarea_link_to(str, options={})
      link_to_url(str, docomo_openiarea_url_for(options))
    end

    # DoCoMoで端末製造番号等を取得するためのリンクを返す。
    def docomo_utn_link_to(str, options={})
      options = options.symbolize_keys
      options[:only_path] = false
      return %{<a href="#{url_for(options)}" utn>#{str}</a>}
    end

    # DoCoMoでiモードIDを取得するためのリンクを返す。
    def docomo_guid_link_to(str, options={})
      options = options.symbolize_keys
      options[:guid] = "ON"
      link_to_url(str, url_for(options))
    end

    # au GPS位置情報を取得するためのURLを返す。
    def au_gps_url_for(options={})
      options = options.symbolize_keys
      options[:only_path] = false
      datum = (options.delete(:datum) || 0 ).to_i # 0:wgs84, 1:tokyo
      unit = (options.delete(:unit) || 0 ).to_i # 0:dms, 1:deg
      "device:gpsone?url=#{CGI.escape(url_for(options))}&ver=1&datum=#{datum}&unit=#{unit}&acry=0&number=0"
    end

    # au GPS位置情報を取得するためのリンクを返す。
    def au_gps_link_to(str, options={})
      link_to_url(str, au_gps_url_for(options))
    end

    # au 簡易位置情報を取得するためのURLを返す。
    def au_location_url_for(options={})
      options = options.symbolize_keys
      options[:only_path] = false
      "device:location?url=#{CGI.escape(url_for(options))}"
    end

    # au 簡易位置情報を取得するためのリンクを返す。
    def au_location_link_to(str, options={})
      link_to_url(str, au_location_url_for(options))
    end

    # J-PHONE 位置情報 (基地局) を取得するためのリンクを返す。
    def jphone_location_link_to(str,options={})
      options = options.symbolize_keys
      options[:only_path] = false
      return %{<a z href="#{url_for(options)}">#{str}</a>}
    end

    # Softbank(含むVodafone 3G)で位置情報を取得するためのURLを返す。
    def softbank_location_url_for(options={})
      options = options.symbolize_keys
      options[:only_path] = false
      mode = options[:mode] || "auto"
      "location:#{mode}?url=#{url_for(options)}"
    end

    # Softbank(含むVodafone 3G)で位置情報を取得するためのリンクを返す。
    def softbank_location_link_to(str,options={})
      link_to_url(str,softbank_location_url_for(options))
    end

    # Willcom 基地局位置情報を取得するためのURLを返す。
    def willcom_location_url_for(options={})
      options = options.symbolize_keys
      options[:only_path] = false
      "http://location.request/dummy.cgi?my=#{url_for(options)}&pos=$location"
    end

    # Willcom 基地局位置情報を取得するためのリンクを返す。
    def willcom_location_link_to(str,options={})
      link_to_url(str, willcom_location_url_for(options))
    end

    private
    # 外部へのリンク
    def link_to_url(str, url)
      %{<a href="#{url}">#{str}</a>}
    end
  end
end
