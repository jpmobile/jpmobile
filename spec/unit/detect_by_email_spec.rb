require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Jpmobile::Email' do

  Spec::Fixture::Base.new self, :email_addr => :carrier do

    it '#detect should return :carrier when take :email_addr as EmailAddr' do |email_addr, carrier|
      Jpmobile::Email.detect(email_addr).should == carrier 
    end

    set_fixtures([
      ['test@docomo.ne.jp'      => Jpmobile::Mobile::Docomo ],
      ['a(--)l@ezweb.ne.jp'     => Jpmobile::Mobile::Au ],
      ['dadaea@pdx.ne.jp'       => Jpmobile::Mobile::Willcom  ],
      ['xxxe@dj.pdx.ne.jp'      => Jpmobile::Mobile::Willcom  ],
      ['oeeikx@softbank.ne.jp'  => Jpmobile::Mobile::Softbank ],
      ['eaae@disney.ne.jp'      => Jpmobile::Mobile::Softbank ],
      ['iiiaa@r.vodafone.ne.jp' => Jpmobile::Mobile::Vodafone ],
      ['aaaaa.aaaa@jp-h.ne.jp' => Jpmobile::Mobile::Jphone    ],
    ])
  end.run
end
