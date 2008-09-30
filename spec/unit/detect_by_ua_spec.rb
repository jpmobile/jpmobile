require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Jpmobile::RequestWithMobile' do
  before(:all) do
    ReqClass = Class.new
    ReqClass.class_eval do
      include Jpmobile::RequestWithMobile

      def initialize user_agent
        @user_agent = user_agent
      end

      def user_agent
        @user_agent
      end
    end
  end

  Spec::Fixture::Base.new self, :carrier => :user_agent do

    it '#mobile should return :carrier when take :user_agent as UserAgent' do |carrier, user_agent|
      ReqClass.new(user_agent).mobile.class.should == carrier
    end

    set_fixtures([
      [ Jpmobile::Mobile::Docomo    => 'DoCoMo/2.0 SH902i(c100;TB;W24H12)' ],
      [ Jpmobile::Mobile::Docomo    => 'DoCoMo/1.0/SO506iC/c20/TB/W20H10'  ],
      [ Jpmobile::Mobile::Docomo    => 'DoCoMo/2.0 D902i(c100;TB;W23H16;ser999999999999999;icc0000000000000000000f)' ],
      [ Jpmobile::Mobile::Au        => 'KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0' ],
      [ Jpmobile::Mobile::Au        => 'UP.Browser/3.04-KCTA UP.Link/3.4.5.9' ],
      [ Jpmobile::Mobile::Softbank  => 'SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1' ],
      [ Jpmobile::Mobile::Softbank  => 'Semulator' ],
      [ Jpmobile::Mobile::Vodafone  => 'Vodafone/1.0/V903SH/SHJ001/SN000000000000000 Browser/UP.Browser/7.0.2.1 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0' ],
      [ Jpmobile::Mobile::Jphone    => 'J-PHONE/4.3/V603SH/SNXXXX0000000 SH/0007aa Profile/MIDP-1.0 Configuration/CLDC-1.0 Ext-Profile/JSCL-1.3.2' ],
      [ Jpmobile::Mobile::Jphone    => 'J-EMULATOR' ],
      [ Jpmobile::Mobile::Willcom   => 'Mozilla/3.0(WILLCOM;KYOCERA/WX310K/2;1.2.2.16.000000/0.1/C100) Opera 7.0' ],
      [ Jpmobile::Mobile::Ddipocket => 'Mozilla/3.0(DDIPOCKET;KYOCERA/AH-K3001V/1.8.2.71.000000/0.1/C100) Opera 7.0'],
      [ Jpmobile::Mobile::Emobile   => 'emobile/1.0.0 (H11T; like Gecko; Wireless) NetFront/3.4' ],
      [ NilClass                    => 'Googlebot' ],
    ])
  end.run
end
