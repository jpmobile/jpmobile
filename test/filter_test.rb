require File.dirname(__FILE__)+'/helper'

class FilterTest < Test::Unit::TestCase
  def setup
    @aiu_sjis = "\202\240\202\242\202\244" # あいう
    @aiu_utf8 = "\343\201\202\343\201\204\343\201\206" # あいう

    @aiu_zhz = "\343\201\202\357\275\262\343\202\246" # あイウ (イ半角), UTF-8
    @aiu_zzz = "\343\201\202\343\202\244\343\202\246" # あイウ, UTF-8
    @aiu_zhh = "\343\201\202\357\275\262\357\275\263" # あイウ (イウ半角), UTF-8

    @abracadabra_z_utf8 = "\343\202\242\343\203\226\343\203\251\343\202\253\343\203\200\343\203\226\343\203\251" # アブラカダブラ, UTF-8
    @abracadabra_h_utf8 = "\357\275\261\357\276\214\357\276\236\357\276\227\357\275\266\357\276\200\357\276\236\357\276\214\357\276\236\357\276\227" # アブラカダブラ(半角), UTF-8
    @abracadabra_z_sjis = "\203A\203u\203\211\203J\203_\203u\203\211" # アブラカダブラ, Shift_JIS
  end
  def test_filter_sjis
    filter = Jpmobile::Filter::Sjis.new
    assert_equal(@aiu_sjis, filter.to_external(@aiu_utf8, nil))
    assert_equal(@aiu_utf8, filter.to_internal(@aiu_sjis, nil))
  end
  def test_filter_hankaku
    filter = Jpmobile::Filter::HankakuKana.new

    assert_equal(@aiu_zzz, filter.to_internal(@aiu_zhz, nil))
    assert_equal(@aiu_zzz, filter.to_internal(@aiu_zzz, nil))
    assert_equal(@aiu_zhh, filter.to_external(@aiu_zhz, nil))
    assert_equal(@aiu_zhh, filter.to_external(@aiu_zzz, nil))

    assert_equal(@abracadabra_z_utf8, filter.to_internal(@abracadabra_h_utf8, nil))
    assert_equal(@abracadabra_h_utf8, filter.to_external(@abracadabra_z_utf8, nil))
  end
end
