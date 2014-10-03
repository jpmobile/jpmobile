require 'rails_helper'

describe Jpmobile::Helpers, :type => :helper do
  include Jpmobile::Helpers
  it "docomo_guid_link_to が guid=ON を付けたリンクを生成すること" do
    expect(docomo_guid_link_to("STRING", :controller => "filter", :action => "rawdata")).to eq(%{<a href="/filter/rawdata?guid=ON">STRING</a>})
  end

  it "softbank_location_link_to がリンク先にパラメータを含んでいても正常に動作すること" do
    # http://d.hatena.ne.jp/mizincogrammer/20090123/1232702067
    expect(softbank_location_link_to("STRING", :controller => "filter", :action => "rawdata", :p => "param")).to eq(%{<a href="location:auto?url=http://test.host/filter/rawdata&amp;p=param">STRING</a>})
  end
end
