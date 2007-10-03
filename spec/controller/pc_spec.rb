require File.dirname(__FILE__) + '/../spec_helper'

describe "PCからのアクセスの場合", :behaviour_type=>:controller do
  controller_name :mobile_spec
  it "request.mobile は nil であるべき" do
    request.mobile.should be_nil
  end
  it "request.mobile? は false であるべき" do
    request.mobile?.should be_false
  end
end
