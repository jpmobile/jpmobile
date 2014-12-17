require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

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
    ['xxxe@willcom.com'          , Jpmobile::Mobile::Willcom  ],
    ['xxxe@willcom.com.jp'       , nil                        ],
    ['oeeikx@softbank.ne.jp'     , Jpmobile::Mobile::Softbank ],
    ['oeeikx@softbank.ne.jp.jp'  , nil                        ],
    ['eaae@disney.ne.jp'         , Jpmobile::Mobile::Softbank ],
    ['eaae@disney.ne.jp.jp'      , nil                        ],
    ['iiiaa@r.vodafone.ne.jp'    , Jpmobile::Mobile::Vodafone ],
    ['iiiaa@r.vodafone.ne.jp.jp' , nil                        ],
  ].each do |email_addr, carrier|
    it "#detect should return #{carrier} when take #{email_addr} as EmailAddr" do
      Jpmobile::Email.japanese_mail_address_regexp = nil
      expect(Jpmobile::Email.detect(email_addr)).to eq(carrier)
    end
  end

  [
    ['From: Jpmobile Rails <example@example.ne.jp>'     , nil                        ],
    ['From: Jpmobile Rails <test@docomo.ne.jp>'         , Jpmobile::Mobile::Docomo   ],
    ['From: test@docomo.ne.jp'                          , Jpmobile::Mobile::Docomo   ],
    ['From: Jpmobile Rails <test@docomo.ne.jp.jp>'      , nil                        ],
    ['From: Jpmobile Rails <a(--)l@ezweb.ne.jp>'        , Jpmobile::Mobile::Au       ],
    ['From: a(--)l@ezweb.ne.jp'                         , Jpmobile::Mobile::Au       ],
    ['From: Jpmobile Rails <a(--)l@ezweb.ne.jp.jp>'     , nil                        ],
    ['From: Jpmobile Rails <dadaea@pdx.ne.jp>'          , Jpmobile::Mobile::Willcom  ],
    ['From: Jpmobile Rails <dadaea@pdx.ne.jp.jp>'       , nil                        ],
    ['From: Jpmobile Rails <xxxe@dj.pdx.ne.jp>'         , Jpmobile::Mobile::Willcom  ],
    ['From: Jpmobile Rails <xxxe@dj.pdx.ne.jp.jp>'      , nil                        ],
    ['From: Jpmobile Rails <xxxe@willcom.com>'          , Jpmobile::Mobile::Willcom  ],
    ['From: Jpmobile Rails <xxxe@willcom.com.jp>'       , nil                        ],
    ['From: Jpmobile Rails <oeeikx@softbank.ne.jp>'     , Jpmobile::Mobile::Softbank ],
    ['From: oeeikx@softbank.ne.jp'                      , Jpmobile::Mobile::Softbank ],
    ['From: Jpmobile Rails <oeeikx@softbank.ne.jp.jp>'  , nil                        ],
    ['From: Jpmobile Rails <eaae@disney.ne.jp>'         , Jpmobile::Mobile::Softbank ],
    ['From: Jpmobile Rails <eaae@disney.ne.jp.jp>'      , nil                        ],
    ['From: Jpmobile Rails <iiiaa@r.vodafone.ne.jp>'    , Jpmobile::Mobile::Vodafone ],
    ['From: Jpmobile Rails <iiiaa@r.vodafone.ne.jp.jp>' , nil                        ],
  ].each do |line, carrier|
    it "#detect_from_mail_header should return #{carrier} when take mail header #{line}}" do
      Jpmobile::Email.japanese_mail_address_regexp = nil
      expect(Jpmobile::Email.detect_from_mail_header(line)).to eq(carrier)
    end
  end

  describe "japanese_mail_address_regexp" do
    before do
      Jpmobile::Email.japanese_mail_address_regexp = Regexp.new(/\.jp(?:[^a-zA-Z\.\-]|$)/)
    end

    it "#detect_from_mail_header should return Jpmobile::Mobile::AbstractMobile when the header contains .jp address" do
      expect(Jpmobile::Email.detect_from_mail_header('From: Hoge Fuga <fuga@hoge.jp>')).to eq(Jpmobile::Mobile::AbstractMobile)
      expect(Jpmobile::Email.detect_from_mail_header('From: fuga@hoge.jp')).to eq(Jpmobile::Mobile::AbstractMobile)
    end

    it "#detect_from_mail_header should return nil when the header does not contain .jp address" do
      expect(Jpmobile::Email.detect_from_mail_header('From: Hoge Fuga <fuga@example.com>')).to eq(nil)
      expect(Jpmobile::Email.detect_from_mail_header('From: fuga@example.com')).to eq(nil)
    end
  end

  describe "convertable?" do
    it "return true when text/plain; charset=iso-2022-jp" do
      expect(Jpmobile::Email.convertable?('text/plain; charset=iso-2022-jp')).to be_truthy
    end

    it "return true when text/html; charset=shift_jis" do
      expect(Jpmobile::Email.convertable?('text/html; charset=shift_jis')).to be_truthy
    end

    it "return nil when image/jpeg; name=\"20098calendar01.jpg\"" do
      expect(Jpmobile::Email.convertable?('image/jpeg; name="20098calendar01.jpg"')).to be_nil
    end
  end
end
