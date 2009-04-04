require File.dirname(__FILE__) + '/../spec_helper'

describe Jpmobile::Helpers do
  include Jpmobile::Helpers
  it "docomo_guid_link_to が guid=ON を付けたリンクを生成すること" do
    docomo_guid_link_to("STRING", :controller => "MyController", :action => "myaction").should == %{<a href="/mycontroller/myaction?guid=ON">STRING</a>}
  end

  it "softbank_location_link_to がリンク先にパラメータを含んでいても正常に動作すること" do
    # http://d.hatena.ne.jp/mizincogrammer/20090123/1232702067
    softbank_location_link_to("STRING", :controller => "MyController", :action => "myaction", :p => "param").should == %{<a href="location:auto?url=http://test.host/mycontroller/myaction&p=param">STRING</a>}
  end
end
