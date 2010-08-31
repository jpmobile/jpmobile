# -*- coding: utf-8 -*-
require File.join(File.expand_path(File.dirname(__FILE__)), '../../rack_helper.rb')

describe Jpmobile::Rack::MobileCarrier do
  include Rack::Test::Methods

  [
    [ Jpmobile::Mobile::Docomo    , 'DoCoMo/2.0 SH902i(c100;TB;W24H12)' ],
    [ Jpmobile::Mobile::Docomo    , 'DoCoMo/1.0/SO506iC/c20/TB/W20H10'  ],
    [ Jpmobile::Mobile::Docomo    , 'DoCoMo/2.0 D902i(c100;TB;W23H16;ser999999999999999;icc0000000000000000000f)' ],
    [ Jpmobile::Mobile::Au        , 'KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0' ],
    [ Jpmobile::Mobile::Au        , 'UP.Browser/3.04-KCTA UP.Link/3.4.5.9' ],
    [ Jpmobile::Mobile::Softbank  , 'SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1' ],
    [ Jpmobile::Mobile::Softbank  , 'Semulator' ],
    [ Jpmobile::Mobile::Vodafone  , 'Vodafone/1.0/V903SH/SHJ001/SN000000000000000 Browser/UP.Browser/7.0.2.1 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0' ],
    [ Jpmobile::Mobile::Willcom   , 'Mozilla/3.0(WILLCOM;KYOCERA/WX310K/2;1.2.2.16.000000/0.1/C100) Opera 7.0' ],
    [ Jpmobile::Mobile::Ddipocket , 'Mozilla/3.0(DDIPOCKET;KYOCERA/AH-K3001V/1.8.2.71.000000/0.1/C100) Opera 7.0'],
    [ Jpmobile::Mobile::Emobile   , 'emobile/1.0.0 (H11T; like Gecko; Wireless) NetFront/3.4' ],
    [ Jpmobile::Mobile::Iphone       , 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; ja-jp) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16' ],
    [ Jpmobile::Mobile::Android      , 'Mozilla/5.0 (Linux; U; Android 1.6; ja-jp; SonyEriccsonSO-01B Build/R1EA018) AppleWebKit/528.5+ (KHTML, like Gecko) Version/3.1.2 Mobile Safari/525.20.1' ],
    [ Jpmobile::Mobile::WindowsPhone , 'Mozilla/4.0 (Compatible; MSIE 6.0; Windows NT 5.1 T-01A_6.5; Windows Phone 6.5)' ],
  ].each do |carrier, user_agent|
    it '#mobile should return #{carrier} when take #{user_agent} as UserAgent' do
      res = Rack::MockRequest.env_for(
        'http://jpmobile-rails.org/',
        'HTTP_USER_AGENT' => user_agent)
      env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]
      env['rack.jpmobile'].class.should == carrier
    end
  end

  it "Googlebot のときは rack['rack.jpmobile.carrier'] が nil になること" do
    res = Rack::MockRequest.env_for(
      'http://jpmobile-rails.org/',
      'HTTP_USER_AGENT' => 'Googlebot')
    env = Jpmobile::Rack::MobileCarrier.new(UnitApplication.new).call(res)[1]
    env['rack.jpmobile'].should be_nil
  end
end
