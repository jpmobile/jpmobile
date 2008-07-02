require File.dirname(__FILE__) + '/../spec_helper'

describe Jpmobile::Helpers do
  include Jpmobile::Helpers
  it "docomo_guid_link_to が guid=ON を付けたリンクを生成すること" do
    docomo_guid_link_to("STRING", :controller => "MyController", :action => "myaction").should == %{<a href="/mycontroller/myaction?guid=ON">STRING</a>}
  end
end
