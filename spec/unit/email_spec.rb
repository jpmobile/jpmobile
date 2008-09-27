require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Jpmobile::Email::carrier_by_email' do
  it 'should return nil for a non-mobile email address' do
    Jpmobile::Email.carrier_by_email("example@example.jp").should be_nil
  end
  Spec::Fixture::Base.new self, :email => :carrier do
    it 'should return an instance of :carrier for E-mail address :address' do |email, carrier|
      Jpmobile::Email.carrier_by_email(email).class.should == carrier
    end
    set_fixtures([
      [ 'example@docomo.ne.jp'     => Jpmobile::Mobile::Docomo  ],
      [ 'example@ezweb.ne.jp'      => Jpmobile::Mobile::Au      ],
      [ 'example@pdx.ne.jp'        => Jpmobile::Mobile::Willcom ],
      [ 'example@dj.pdx.ne.jp'     => Jpmobile::Mobile::Willcom ],
      [ 'example@softbank.ne.jp'   => Jpmobile::Mobile::Softbank],
      [ 'example@disney.ne.jp'     => Jpmobile::Mobile::Softbank],
      [ 'example@r.vodafone.ne.jp' => Jpmobile::Mobile::Vodafone],
      [ 'example@jp-h.ne.jp'       => Jpmobile::Mobile::Jphone  ],
      [ 'example@emnet.ne.jp'      => Jpmobile::Mobile::Emobile ],
    ])
  end.run
end
