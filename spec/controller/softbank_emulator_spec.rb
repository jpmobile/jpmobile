require File.dirname(__FILE__) + '/../spec_helper'

describe "携帯電話からのアクセス", :shared => true do
  it "request.mobile? は true であること" do
    request.mobile?.should be_true
  end
end

describe "Softbank Emulator からのアクセスのとき", :behaviour_type=>:controller do
  before do
    request.user_agent = "Semulator"
  end
  controller_name :mobile_spec
  it "request.mobile は Softbank のインスタンスであること" do
    request.mobile.should be_an_instance_of(Jpmobile::Mobile::Softbank)
  end
  it_should_behave_like "携帯電話からのアクセス"
end

describe "Vodafone Emulator からのアクセスのとき", :behaviour_type=>:controller do
  before do
    request.user_agent = "Vemulator"
  end
  controller_name :mobile_spec
  it "request.mobile は Vodafone のインスタンスであること" do
    request.mobile.should be_an_instance_of(Jpmobile::Mobile::Vodafone)
  end
  it_should_behave_like "携帯電話からのアクセス"
end

describe "J-PHONE Emulator からのアクセスのとき", :behaviour_type=>:controller do
  before do
    request.user_agent = "J-EMULATOR"
  end
  controller_name :mobile_spec
  it "request.mobile は Jphone のインスタンスであること" do
    request.mobile.should be_an_instance_of(Jpmobile::Mobile::Jphone)
  end
  it_should_behave_like "携帯電話からのアクセス"
end
