require File.dirname(__FILE__) + '/../spec_helper'

describe "transit_sid が起動しないとき", :shared => true do
  it "で link_to の自動書き換えが行われない" do
    get :link
    response.body.should =~ %r{^<a href="/.+?/link">linkto</a>$}
  end
  it "で form の自動書き換えが行われない" do
    get :form
    response.body.should =~ %r{^<form action="/.+?/form" method="post">Hello</form>$}
  end
end

describe "transit_sid が起動するとき", :shared => true do
  before :each do
    request.session.session_id = "mysessionid"
  end
  it "で link_to の自動書き換えが行われる" do
    get :link
    response.body.should =~ %r{^<a href="/.+?/link\?_session_id=mysessionid">linkto</a>$}
  end
  it "で form の自動書き換えが行われる" do
    get :form
    response.body.should =~ %r{^<form action="/.+?/form\?_session_id=mysessionid" method="post">Hello<input type="hidden" name="_session_id" value="mysessionid" /></form>$}
  end
end

describe TransitSidBaseController, "という transit_sid が有効になっていないコントローラ" do
  controller_name :transit_sid_base
  it "の transit_sid_mode は nil" do
    controller.transit_sid_mode.should be_nil
  end
  it_should_behave_like "transit_sid が起動しないとき"
end

describe TransitSidNoneController, "という transit_sid :none が指定されているコントローラ" do
  controller_name :transit_sid_none
  it "の transit_sid_mode は :none" do
    controller.transit_sid_mode.should == :none
  end
  it_should_behave_like "transit_sid が起動しないとき"
end

describe TransitSidAlwaysController, "という transit_sid :always が指定されているコントローラ" do
  controller_name :transit_sid_always
  before :each do
    request.session.session_id = "mysessionid"
  end
  it "の transit_sid_mode は :always" do
    controller.transit_sid_mode.should == :always
  end
  it_should_behave_like "transit_sid が起動するとき"
end

describe TransitSidMobileController, "という transit_sid :mobile が指定されているコントローラ" do
  controller_name :transit_sid_mobile
  it "の transit_sid_mode は :mobile" do
    controller.transit_sid_mode.should == :mobile
  end
end

def describe_mobile_with_ua(user_agent, &block)
  describe("transit_sid :mobile が指定されているコントローラに #{user_agent} からアクセスしたとき") do
    controller_name :transit_sid_mobile
    before do
      request.user_agent = user_agent
    end
    instance_eval(&block)
  end
end

describe_mobile_with_ua "DoCoMo/2.0 SH902i(c100;TB;W24H12)" do
  it_should_behave_like "transit_sid が起動するとき"
end

describe_mobile_with_ua "J-PHONE/3.0/V301D" do
  it_should_behave_like "transit_sid が起動するとき"
end

describe_mobile_with_ua "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0" do
  it_should_behave_like "transit_sid が起動しないとき"
end

describe_mobile_with_ua "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1" do
  it_should_behave_like "transit_sid が起動しないとき"
end

describe_mobile_with_ua "Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0" do
  it_should_behave_like "transit_sid が起動しないとき"
end


describe TransitSidAlwaysAndSessionOffController, "という transit_sid :always と session :off を同時に指定しているコントローラ" do
  controller_name :transit_sid_always_and_session_off
  it_should_behave_like "transit_sid が起動しないとき"
end
