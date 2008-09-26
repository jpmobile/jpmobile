require File.dirname(__FILE__)+'/helper'

class AbstractMobileTest < Test::Unit::TestCase
  
  define_method('test: docomoのアドレスからキャリアを取得する') do 
    carrier = Jpmobile::Email.carrier_by_email("test@docomo.ne.jp")
    assert_equal(Jpmobile::Mobile::Docomo, carrier.class)
  end
  
  define_method('test: auのアドレスからキャリアを取得する') do 
    carrier = Jpmobile::Email.carrier_by_email("a(--)l@ezweb.ne.jp")
    assert_equal(Jpmobile::Mobile::Au, carrier.class)
  end
  
  define_method('test: willcomのアドレスからキャリアを取得する') do 
    carrier = Jpmobile::Email.carrier_by_email("dadaea@pdx.ne.jp")
    assert_equal(Jpmobile::Mobile::Willcom, carrier.class)
  end
  
  define_method('test: willcomのアドレスからキャリアを取得する') do 
    carrier = Jpmobile::Email.carrier_by_email("dadaea@pdx.ne.jp")
    assert_equal(Jpmobile::Mobile::Willcom, carrier.class)
    
    carrier = Jpmobile::Email.carrier_by_email("xxxe@dj.pdx.ne.jp")
    assert_equal(Jpmobile::Mobile::Willcom, carrier.class)
  end
  
  define_method('test: softbankのアドレスからキャリアを取得する') do 
    carrier = Jpmobile::Email.carrier_by_email("oeeikx@softbank.ne.jp")
    assert_equal(Jpmobile::Mobile::Softbank, carrier.class)
    
    carrier = Jpmobile::Email.carrier_by_email("eaaae@disney.ne.jp")
    assert_equal(Jpmobile::Mobile::Softbank, carrier.class)
  end
  
  define_method('test: vodafoneのアドレスからキャリアを取得する') do 
    carrier = Jpmobile::Email.carrier_by_email("iiiaa@r.vodafone.ne.jp")
    assert_equal(Jpmobile::Mobile::Vodafone, carrier.class)
  end
  
  define_method('test: j-phoneのアドレスからキャリアを取得する(今は利用できないはず)') do 
    carrier = Jpmobile::Email.carrier_by_email("aaaaa.aaaa@jp-h.ne.jp")
    assert_equal(Jpmobile::Mobile::Jphone, carrier.class)
  end
  
end