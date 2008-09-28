require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Jpmobile::Email' do

  Spec::Fixture::Base.new self, :email_addr => :carrier do

    it '#detect should return :carrier when take :email_addr as EmailAddr' do |email_addr, carrier|
      Jpmobile::Email.detect(email_addr).should == carrier 
    end

    set_fixtures([
      ['example@example.ne.jp'  => nil                        ],
      ['test@docomo.ne.jp'      => Jpmobile::Mobile::Docomo   ],
      ['test@docomo.ne.jp.jp'   => nil                        ],
      ['a(--)l@ezweb.ne.jp'     => Jpmobile::Mobile::Au       ],
      ['a(--)l@ezweb.ne.jp.jp'  => nil                        ],
      ['dadaea@pdx.ne.jp'       => Jpmobile::Mobile::Willcom  ],
      ['dadaea@pdx.ne.jp.jp'    => nil                        ],
      ['xxxe@dj.pdx.ne.jp'      => Jpmobile::Mobile::Willcom  ],
      ['xxxe@dj.pdx.ne.jp.jp'   => nil                        ],
      ['oeeikx@softbank.ne.jp'  => Jpmobile::Mobile::Softbank ],
      ['oeeikx@softbank.ne.jp.jp' => nil                      ],
      ['eaae@disney.ne.jp'      => Jpmobile::Mobile::Softbank ],
      ['eaae@disney.ne.jp.jp'   => nil                        ],
      ['iiiaa@r.vodafone.ne.jp' => Jpmobile::Mobile::Vodafone ],
      ['iiiaa@r.vodafone.ne.jp.jp' => nil                     ],
      ['aaaaa.aaaa@jp-h.ne.jp'  => Jpmobile::Mobile::Jphone    ],
      ['aaaaa.aaaa@jp-h.ne.jp.jp' => nil                      ],
    ])
  end.run
end
