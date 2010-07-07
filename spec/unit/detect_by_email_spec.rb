require File.join(File.expand_path(File.dirname(__FILE__)), 'spec_helper')

describe 'Jpmobile::Email' do
  [
    ['example@example.ne.jp'     , nil                        ],
    ['test@docomo.ne.jp'         , Jpmobile::Mobile::Docomo   ],
    ['test@docomo.ne.jp.jp'      , nil                        ],
    ['a(--)l@ezweb.ne.jp'        , Jpmobile::Mobile::Au       ],
    ['a(--)l@ezweb.ne.jp.jp'     , nil                        ],
    ['dadaea@pdx.ne.jp'          , Jpmobile::Mobile::Willcom  ],
    ['dadaea@pdx.ne.jp.jp'       , nil                        ],
    ['xxxe@dj.pdx.ne.jp'         , Jpmobile::Mobile::Willcom  ],
    ['xxxe@dj.pdx.ne.jp.jp'      , nil                        ],
    ['oeeikx@softbank.ne.jp'     , Jpmobile::Mobile::Softbank ],
    ['oeeikx@softbank.ne.jp.jp'  , nil                        ],
    ['eaae@disney.ne.jp'         , Jpmobile::Mobile::Softbank ],
    ['eaae@disney.ne.jp.jp'      , nil                        ],
    ['iiiaa@r.vodafone.ne.jp'    , Jpmobile::Mobile::Vodafone ],
    ['iiiaa@r.vodafone.ne.jp.jp' , nil                        ],
  ].each do |email_addr, carrier|
    it "#detect should return #{carrier} when take #{email_addr} as EmailAddr'" do
      Jpmobile::Email.detect(email_addr).should == carrier
    end
  end
end
