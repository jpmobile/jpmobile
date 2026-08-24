require 'rails_helper'

describe Jpmobile::Helpers, type: :helper do
  include Jpmobile::Helpers
  include Rails.application.routes.url_helpers

  it 'docomo_guid_link_to が guid=ON を付けたリンクを生成すること' do
    expect(docomo_guid_link_to('STRING', host: 'jpmobile.info', controller: 'filter', action: 'rawdata')).to eq(%(<a href="http://jpmobile.info/filter/rawdata?guid=ON">STRING</a>))
  end

  it 'softbank_location_link_to がリンク先にパラメータを含んでいても正常に動作すること' do
    # http://d.hatena.ne.jp/mizincogrammer/20090123/1232702067
    expect(softbank_location_link_to('STRING', host: 'jpmobile.info', controller: 'filter', action: 'rawdata', p: 'param')).to eq(%(<a href="location:auto?url=http://jpmobile.info/filter/rawdata&amp;p=param">STRING</a>))
  end

  it '各キャリアの位置情報 URL に直接指定した callback URL が引き継がれること' do
    callback_url = 'https://jpmobile.info/positions'

    aggregate_failures do
      expect(docomo_foma_gps_link_to('位置情報', callback_url)).to include(%(href="#{callback_url}"))
      expect(docomo_openiarea_url_for(callback_url)).to end_with("nl=#{CGI.escape(callback_url)}")
      expect(docomo_utn_link_to('端末情報', callback_url)).to include(%(href="#{callback_url}"))
      expect(docomo_guid_link_to('iモードID', callback_url)).to include(%(href="#{callback_url}"))
      expect(au_gps_url_for(callback_url)).to include("url=#{CGI.escape(callback_url)}")
      expect(au_location_url_for(callback_url)).to include("url=#{CGI.escape(callback_url)}")
      expect(softbank_location_url_for(callback_url.dup)).to eq("location:auto?url=#{callback_url}")
      expect(willcom_location_url_for(callback_url)).to eq("http://location.request/dummy.cgi?my=#{callback_url}&pos=$location")
    end
  end
end
